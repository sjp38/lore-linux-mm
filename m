Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id CB4936B026B
	for <linux-mm@kvack.org>; Mon, 20 Nov 2017 14:41:02 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id p44so9348241qtj.17
        for <linux-mm@kvack.org>; Mon, 20 Nov 2017 11:41:02 -0800 (PST)
Received: from alln-iport-7.cisco.com (alln-iport-7.cisco.com. [173.37.142.94])
        by mx.google.com with ESMTPS id p49si1709658qtb.212.2017.11.20.11.41.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Nov 2017 11:41:01 -0800 (PST)
Subject: Re: Detecting page cache trashing state
From: "Ruslan Ruslichenko -X (rruslich - GLOBALLOGIC INC at Cisco)"
 <rruslich@cisco.com>
References: <150543458765.3781.10192373650821598320@takondra-t460s>
 <20170915143619.2ifgex2jxck2xt5u@dhcp22.suse.cz>
 <150549651001.4512.15084374619358055097@takondra-t460s>
 <20170918163434.GA11236@cmpxchg.org>
 <acbf4417-4ded-fa03-7b8d-34dc0803027c@cisco.com>
 <20171025175424.GA14039@cmpxchg.org>
 <d7bc14d7-5ae4-f16d-da38-2bc36d9deae8@cisco.com>
Message-ID: <bfbfaaa1-2b12-f26f-218a-ff6804f47eae@cisco.com>
Date: Mon, 20 Nov 2017 21:40:56 +0200
MIME-Version: 1.0
In-Reply-To: <d7bc14d7-5ae4-f16d-da38-2bc36d9deae8@cisco.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Taras Kondratiuk <takondra@cisco.com>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, xe-linux-external@cisco.com, linux-kernel@vger.kernel.org

Hi Johannes,

I tested with your patches but situation is still mostly the same.

Spend some time for debugging and found that the problem is squashfs 
specific (probably some others fs's too).
The point is that iowait for squashfs reads will be awaited inside 
squashfs readpage() callback.
Here is some backtrace for page fault handling to illustrate this:

  1)               |  handle_mm_fault() {
  1)               |    filemap_fault() {
  1)               |      __do_page_cache_readahead()
  1)               |        add_to_page_cache_lru()
  1)               |        squashfs_readpage() {
  1)               |          squashfs_readpage_block() {
  1)               |            squashfs_get_datablock() {
  1)               |              squashfs_cache_get() {
  1)               |                squashfs_read_data() {
  1)               |                  ll_rw_block() {
  1)               |                    submit_bh_wbc.isra.42()
  1)               |                  __wait_on_buffer() {
  1)               |                    io_schedule() {
  ------------------------------------------
  0)   kworker-79   =>    <idle>-0
  ------------------------------------------
  0)   0.382 us    |  blk_complete_request();
  0)               |  blk_done_softirq() {
  0)               |    blk_update_request() {
  0)               |      end_buffer_read_sync()
  0) + 38.559 us   |    }
  0) + 48.367 us   |  }
  ------------------------------------------
  0)   kworker-79   =>  memhog-781
  ------------------------------------------
  0) ! 278.848 us  |                    }
  0) ! 279.612 us  |                  }
  0)               |                  squashfs_decompress() {
  0) # 4919.082 us |                    squashfs_xz_uncompress();
  0) # 4919.864 us |                  }
  0) # 5479.212 us |                } /* squashfs_read_data */
  0) # 5479.749 us |              } /* squashfs_cache_get */
  0) # 5480.177 us |            } /* squashfs_get_datablock */
  0)               |            squashfs_copy_cache() {
  0)   0.057 us    |              unlock_page();
  0) ! 142.773 us  |            }
  0) # 5624.113 us |          } /* squashfs_readpage_block */
  0) # 5628.814 us |        } /* squashfs_readpage */
  0) # 5665.097 us |      } /* __do_page_cache_readahead */
  0) # 5667.437 us |    } /* filemap_fault */
  0) # 5672.880 us |  } /* handle_mm_fault */

As you can see squashfs_read_data() schedules IO by ll_rw_block() and 
then it waits for IO to finish inside wait_on_buffer().
After that read buffer is decompressed and page is unlocked inside 
squashfs_readpage() handler.

Thus by the the time when filemap_fault() calls lock_page_or_retry() 
page will be uptodate and unlocked,
wait_on_page_bit() is not called at all, and time spent for 
read/decompress is not accounted.

Tried to apply quick workaround for test:

diff --git a/mm/readahead.c b/mm/readahead.c
index c4ca702..5e2be2b 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -126,9 +126,21 @@ static int read_pages(struct address_space 
*mapping, struct file *filp,

      for (page_idx = 0; page_idx < nr_pages; page_idx++) {
          struct page *page = lru_to_page(pages);
+        bool refault = false;
+        unsigned long mdflags;
+
          list_del(&page->lru);
-        if (!add_to_page_cache_lru(page, mapping, page->index, gfp))
+        if (!add_to_page_cache_lru(page, mapping, page->index, gfp)) {
+            if (!PageUptodate(page) && PageWorkingset(page)) {
+                memdelay_enter(&mdflags);
+                refault = true;
+            }
+
              mapping->a_ops->readpage(filp, page);
+
+            if (refault)
+                memdelay_leave(&mdflags);
+        }
          put_page(page);

But found that situation is not much different.
The reason is that at least in my synthetic tests I'm exhausting whole 
memory leaving almost no place for page cache:

Active(anon):   15901788 kB
Inactive(anon):    44844 kB
Active(file):        488 kB
Inactive(file):      612 kB

As result refault distance is always higher that LRU_ACTIVE_FILE size 
and Workingset flag is not set for refaulting page
even if it were active during it's lifecycle before eviction:

         workingset_refault   7773
        workingset_activate   250
         workingset_restore   233
     workingset_nodereclaim   49

Tried to apply following workaround:

diff --git a/mm/workingset.c b/mm/workingset.c
index 264f049..8035ef6 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -305,6 +305,11 @@ void workingset_refault(struct page *page, void 
*shadow)

      inc_lruvec_state(lruvec, WORKINGSET_REFAULT);

+    /* Page was active prior to eviction */
+    if (workingset) {
+        SetPageWorkingset(page);
+        inc_lruvec_state(lruvec, WORKINGSET_RESTORE);
+    }
      /*
       * Compare the distance to the existing workingset size. We
       * don't act on pages that couldn't stay resident even if all
@@ -314,13 +319,9 @@ void workingset_refault(struct page *page, void 
*shadow)
          goto out;

      SetPageActive(page);
-    SetPageWorkingset(page);
      atomic_long_inc(&lruvec->inactive_age);
      inc_lruvec_state(lruvec, WORKINGSET_ACTIVATE);

-    /* Page was active prior to eviction */
-    if (workingset)
-        inc_lruvec_state(lruvec, WORKINGSET_RESTORE);
  out:
      rcu_read_unlock();
  }

Now I see that refaults for pages a indeed accounted:

         workingset_refault   4987
        workingset_activate   590
         workingset_restore   4358
     workingset_nodereclaim   944

And memdelay counters are actively incrementing too indicating the 
trashing state:

[:~]$ cat /proc/memdelay
7539897381
63.22 63.19 44.58
14.36 15.11 11.80

So do you know what is the proper way to fix both issues?

--
Thanks,
Ruslan

On 10/27/2017 11:19 PM, Ruslan Ruslichenko -X (rruslich - GLOBALLOGIC 
INC at Cisco) wrote:
> Hi Johannes,
>
> On 10/25/2017 08:54 PM, Johannes Weiner wrote:
>> Hi Ruslan,
>>
>> sorry about the delayed response, I missed the new activity in this
>> older thread.
>>
>> On Thu, Sep 28, 2017 at 06:49:07PM +0300, Ruslan Ruslichenko -X 
>> (rruslich - GLOBALLOGIC INC at Cisco) wrote:
>>> Hi Johannes,
>>>
>>> Hopefully I was able to rebase the patch on top v4.9.26 (latest 
>>> supported
>>> version by us right now)
>>> and test a bit.
>>> The overall idea definitely looks promising, although I have one 
>>> question on
>>> usage.
>>> Will it be able to account the time which processes spend on 
>>> handling major
>>> page faults
>>> (including fs and iowait time) of refaulting page?
>> That's the main thing it should measure! :)
>>
>> The lock_page() and wait_on_page_locked() calls are where iowaits
>> happen on a cache miss. If those are refaults, they'll be counted.
>>
>>> As we have one big application which code space occupies big amount 
>>> of place
>>> in page cache,
>>> when the system under heavy memory usage will reclaim some of it, the
>>> application will
>>> start constantly thrashing. Since it code is placed on squashfs it 
>>> spends
>>> whole CPU time
>>> decompressing the pages and seem memdelay counters are not detecting 
>>> this
>>> situation.
>>> Here are some counters to indicate this:
>>>
>>> 19:02:44        CPU     %user     %nice   %system   %iowait 
>>> %steal     %idle
>>> 19:02:45        all      0.00      0.00    100.00      0.00 
>>> 0.00      0.00
>>>
>>> 19:02:44     pgpgin/s pgpgout/s   fault/s  majflt/s  pgfree/s pgscank/s
>>> pgscand/s pgsteal/s    %vmeff
>>> 19:02:45     15284.00      0.00    428.00    352.00  19990.00 
>>> 0.00      0.00
>>> 15802.00      0.00
>>>
>>> And as nobody actively allocating memory anymore looks like memdelay
>>> counters are not
>>> actively incremented:
>>>
>>> [:~]$ cat /proc/memdelay
>>> 268035776
>>> 6.13 5.43 3.58
>>> 1.90 1.89 1.26
>> How does it correlate with /proc/vmstat::workingset_activate during
>> that time? It only counts thrashing time of refaults it can actively
>> detect.
> The workingset counters are growing quite actively too. Here are
> some numbers per second:
>
> workingset_refault   8201
> workingset_activate   389
> workingset_restore   187
> workingset_nodereclaim   313
>
>> Btw, how many CPUs does this system have? There is a bug in this
>> version on how idle time is aggregated across multiple CPUs. The error
>> compounds with the number of CPUs in the system.
> The system has 2 CPU cores.
>> I'm attaching 3 bugfixes that go on top of what you have. There might
>> be some conflicts, but they should be minor variable naming issues.
>>
> I will test with your patches and get back to you.
>
> Thanks,
> Ruslan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
