Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f179.google.com (mail-ob0-f179.google.com [209.85.214.179])
	by kanga.kvack.org (Postfix) with ESMTP id 38B9F828EE
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 15:57:11 -0500 (EST)
Received: by mail-ob0-f179.google.com with SMTP id is5so167012819obc.0
        for <linux-mm@kvack.org>; Mon, 08 Feb 2016 12:57:11 -0800 (PST)
Received: from alln-iport-8.cisco.com (alln-iport-8.cisco.com. [173.37.142.95])
        by mx.google.com with ESMTPS id z6si18183089oec.95.2016.02.08.12.57.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Feb 2016 12:57:10 -0800 (PST)
From: "Khalid Mughal (khalidm)" <khalidm@cisco.com>
Subject: Re: computing drop-able caches
Date: Mon, 8 Feb 2016 20:57:08 +0000
Message-ID: <D2DE3289.2B1F3%khalidm@cisco.com>
References: <56AAA77D.7090000@cisco.com> <20160128235815.GA5953@cmpxchg.org>
 <56AABA79.3030103@cisco.com> <56AAC085.9060509@cisco.com>
 <20160129015534.GA6401@cmpxchg.org> <56ABEAA7.1020706@redhat.com>
In-Reply-To: <56ABEAA7.1020706@redhat.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <FCD05B1FA85B544B8DB4C51CB21569A4@emea.cisco.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, "Daniel Walker (danielwa)" <danielwa@cisco.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "xe-kernel@external.cisco.com" <xe-kernel@external.cisco.com>


How do we explain the discrepancy between MemAvaiable and MemFree count
after we drop cache? In following output, which one represents correct
data?

[Linux_0:/]$ cat /proc/meminfo
MemTotal:        3977836 kB
MemFree:          747832 kB
MemAvailable:    1441736 kB
Buffers:          123976 kB
Cached:          1210272 kB
Active:          2496932 kB
Inactive:         585364 kB
Active(anon):    2243932 kB
Inactive(anon):   142676 kB
Active(file):     253000 kB
Inactive(file):   442688 kB
Dirty:                44 kB
AnonPages:       1748088 kB
Mapped:           406512 kB
Shmem:            638564 kB
Slab:              65656 kB
SReclaimable:      30120 kB
SUnreclaim:        35536 kB
KernelStack:        5920 kB
PageTables:        19040 kB
CommitLimit:     1988916 kB
Committed_AS:    3765252 kB

[Linux_0:/]$ echo 3 > /proc/sys/vm/drop_caches
[Linux_0:/]$ cat /proc/meminfo
MemTotal:        3977836 kB
MemFree:         1095012 kB
MemAvailable:    1434148 kB
Buffers:            4348 kB
Cached:           988228 kB
Active:          1990868 kB
Inactive:         757532 kB
Active(anon):    1759968 kB
Inactive(anon):   634568 kB
Active(file):     230900 kB
Inactive(file):   122964 kB
Dirty:               196 kB
AnonPages:       1755916 kB
Mapped:           409856 kB
Shmem:            638712 kB
Slab:              51432 kB
SReclaimable:      15688 kB
SUnreclaim:        35744 kB
KernelStack:        5760 kB
PageTables:        19060 kB
CommitLimit:     1988916 kB
Committed_AS:    3765644 kB


Thanks,
-KM


How do we explain the discrepancy between MemAvaiable and MemFree count

On 1/29/16, 2:41 PM, "Rik van Riel" <riel@redhat.com> wrote:

>On 01/28/2016 08:55 PM, Johannes Weiner wrote:
>>On Thu, Jan 28, 2016 at 05:29:41PM -0800, Daniel Walker wrote:
>>>On 01/28/2016 05:03 PM, Daniel Walker wrote:
>>>[regarding MemAvaiable]
>>>
>>>This new metric purportedly helps usrespace assess available memory.
>>>But,
>>>its again based on heuristic, it takes 1/2 of page cache as
>>>reclaimable..
>>No, it takes the smaller value of cache/2 and the low watermark, which
>>is a fraction of memory. Actually, that does look a little weird. Rik?
>
>No, not quite.  The page cache calculation spans two lines:
>
>        pagecache =3D pages[LRU_ACTIVE_FILE] + pages[LRU_INACTIVE_FILE];
>        pagecache -=3D min(pagecache / 2, wmark_low);
>
>The assumption is that ALL of active & inactive file LRUs are
>freeable, except for the minimum of the low watermark, or
>half the page cache.
>
>--
>All rights reversed
>


On 1/29/16, 2:33 PM, "Johannes Weiner" <hannes@cmpxchg.org> wrote:

>On Fri, Jan 29, 2016 at 01:21:47PM -0800, Daniel Walker wrote:
>>On 01/28/2016 05:55 PM, Johannes Weiner wrote:
>>>On Thu, Jan 28, 2016 at 05:29:41PM -0800, Daniel Walker wrote:
>>>>On 01/28/2016 05:03 PM, Daniel Walker wrote:
>>>>[regarding MemAvaiable]
>>>>
>>>>This new metric purportedly helps usrespace assess available memory.
>>>>But,
>>>>its again based on heuristic, it takes 1/2 of page cache as
>>>>reclaimable..
>>>No, it takes the smaller value of cache/2 and the low watermark, which
>>>is a fraction of memory. Actually, that does look a little weird. Rik?
>>>
>>>We don't age cache without memory pressure, you don't know how much is
>>>used until you start taking some away. Heuristics is all we can offer.
>>With a simple busybox root system I get this,
>>MemTotal:          16273996 kB
>>MemFree:          16137920 kB
>>MemAvailable:   16046132 kB
>>shouldn't MemAvailable be at least the same as MemFree ? I changed the
>>code
>>somewhat so it subtracted the wmark_low only, or the pagecache/2 only,
>>both
>>are still under MemFree. This system has very little drop-able caches.
>
>No, a portion of memory is reserved for the kernel and not available
>to userland. If the kernel doesn't use it it will remain free. Hence
>the lower MemAvailable.
>



On 1/29/16, 1:21 PM, "Daniel Walker (danielwa)" <danielwa@cisco.com> wrote:

>On 01/28/2016 05:55 PM, Johannes Weiner wrote:
>>On Thu, Jan 28, 2016 at 05:29:41PM -0800, Daniel Walker wrote:
>>>On 01/28/2016 05:03 PM, Daniel Walker wrote:
>>>[regarding MemAvaiable]
>>>
>>>This new metric purportedly helps usrespace assess available memory.
>>>But,
>>>its again based on heuristic, it takes 1/2 of page cache as
>>>reclaimable..
>>No, it takes the smaller value of cache/2 and the low watermark, which
>>is a fraction of memory. Actually, that does look a little weird. Rik?
>>
>>We don't age cache without memory pressure, you don't know how much is
>>used until you start taking some away. Heuristics is all we can offer.
>
>With a simple busybox root system I get this,
>
>MemTotal:          16273996 kB
>MemFree:          16137920 kB
>MemAvailable:   16046132 kB
>
>shouldn't MemAvailable be at least the same as MemFree ? I changed the
>code somewhat so it subtracted the wmark_low only, or the pagecache/2
>only, both are still under MemFree. This system has very little
>drop-able caches.
>
>Daniel
>


On 1/28/16, 5:55 PM, "Johannes Weiner" <hannes@cmpxchg.org> wrote:

>On Thu, Jan 28, 2016 at 05:29:41PM -0800, Daniel Walker wrote:
>>On 01/28/2016 05:03 PM, Daniel Walker wrote:
>>[regarding MemAvaiable]
>>This new metric purportedly helps usrespace assess available memory. But,
>>its again based on heuristic, it takes 1/2 of page cache as reclaimable..
>
>No, it takes the smaller value of cache/2 and the low watermark, which
>is a fraction of memory. Actually, that does look a little weird. Rik?
>
>We don't age cache without memory pressure, you don't know how much is
>used until you start taking some away. Heuristics is all we can offer.
>



On 01/28/2016 05:03 PM, Daniel Walker wrote:

On 01/28/2016 03:58 PM, Johannes Weiner wrote:
On Thu, Jan 28, 2016 at 03:42:53PM -0800, Daniel Walker wrote:
"Currently there is no way to figure out the droppable pagecache size
from the meminfo output. The MemFree size can shrink during normal
system operation, when some of the memory pages get cached and is
reflected in "Cached" field. Similarly for file operations some of
the buffer memory gets cached and it is reflected in "Buffers" field.
The kernel automatically reclaims all this cached & buffered memory,
when it is needed elsewhere on the system. The only way to manually
reclaim this memory is by writing 1 to /proc/sys/vm/drop_caches. "

[...]=20

The point of the whole exercise is to get a better idea of free memory for
our employer. Does it make sense to do this for computing free memory?


/proc/meminfo::MemAvailable was added for this purpose. See the doc
text in Documentation/filesystem/proc.txt.

It's an approximation, however, because this question is not easy to
answer. Pages might be in various states and uses that can make them
unreclaimable.=20

Khalid was telling me that our internal sources rejected MemAvailable
because it was not accurate enough. It says in the description,
"The estimate takes into account that the system needs some page cache to
function well". I suspect that's part of the inaccuracy. I asked Khalid to
respond with more details on this.

Some quotes,

"[regarding MemAvaiable]

This new metric purportedly helps usrespace assess available memory. But,
its again based on heuristic, it takes 1/2 of page cache as reclaimable..

Somewhat arbitrary choice. Maybe appropriate for desktops, where page
cache is mainly used as page cache, not as a first class store which is
the case on embedded systems. Our systems are swap less, they have little
secondary storage, they use in-memory databases/filesystems/shared
memories/
etc. which are all setup on page caches).. This metric as it is implemented
in 3.14 leads to a totally mis-leading picture of available memory"

Daniel



On 01/28/2016 03:58 PM, Johannes Weiner wrote:
>On Thu, Jan 28, 2016 at 03:42:53PM -0800, Daniel Walker wrote:
>>"Currently there is no way to figure out the droppable pagecache size
>>from the meminfo output. The MemFree size can shrink during normal
>>system operation, when some of the memory pages get cached and is
>>reflected in "Cached" field. Similarly for file operations some of
>>the buffer memory gets cached and it is reflected in "Buffers" field.
>>The kernel automatically reclaims all this cached & buffered memory,
>>when it is needed elsewhere on the system. The only way to manually
>>reclaim this memory is by writing 1 to /proc/sys/vm/drop_caches. "
>[...]
>
>>The point of the whole exercise is to get a better idea of free memory
>>for
>>our employer. Does it make sense to do this for computing free memory?
>/proc/meminfo::MemAvailable was added for this purpose. See the doc
>text in Documentation/filesystem/proc.txt.
>
>It's an approximation, however, because this question is not easy to
>answer. Pages might be in various states and uses that can make them
>unreclaimable.


Khalid was telling me that our internal sources rejected MemAvailable
because it was not accurate enough. It says in the description,
"The estimate takes into account that the system needs some page cache
to function well". I suspect that's part of the inaccuracy. I asked
Khalid to respond with more details on this.

Do you know of any work to make it more accurate?

Daniel


On 1/28/16, 3:58 PM, "Johannes Weiner" <hannes@cmpxchg.org> wrote:
>On Thu, Jan 28, 2016 at 03:42:53PM -0800, Daniel Walker wrote:
>>"Currently there is no way to figure out the droppable pagecache size
>>from the meminfo output. The MemFree size can shrink during normal
>>system operation, when some of the memory pages get cached and is
>>reflected in "Cached" field. Similarly for file operations some of
>>the buffer memory gets cached and it is reflected in "Buffers" field.
>>The kernel automatically reclaims all this cached & buffered memory,
>>when it is needed elsewhere on the system. The only way to manually
>>reclaim this memory is by writing 1 to /proc/sys/vm/drop_caches. "
>
>[...]
>
>>The point of the whole exercise is to get a better idea of free memory
>>for
>>our employer. Does it make sense to do this for computing free memory?
>
>/proc/meminfo::MemAvailable was added for this purpose. See the doc
>text in Documentation/filesystem/proc.txt.
>
>It's an approximation, however, because this question is not easy to
>answer. Pages might be in various states and uses that can make them
>unreclaimable.
>


On 1/28/16, 3:42 PM, "Daniel Walker (danielwa)" <danielwa@cisco.com> wrote:
>Hi,
>
>My colleague Khalid and I are working on a patch which will provide a
>/proc file to output the size of the drop-able page cache.
>One way to implement this is to use the current drop_caches /proc
>routine, but instead of actually droping the caches just add
>up the amount.
>
>Here's a quote Khalid,
>
>"Currently there is no way to figure out the droppable pagecache size
>from the meminfo output. The MemFree size can shrink during normal
>system operation, when some of the memory pages get cached and is
>reflected in "Cached" field. Similarly for file operations some of
>the buffer memory gets cached and it is reflected in "Buffers" field.
>The kernel automatically reclaims all this cached & buffered memory,
>when it is needed elsewhere on the system. The only way to manually
>reclaim this memory is by writing 1 to /proc/sys/vm/drop_caches. "
>
>So my impression is that the drop-able cache is spread over two fields
>in meminfo.
>
>Alright, the question is does this info live someplace else that we
>don't know about? Or someplace in the kernel where it could be
>added to meminfo trivially ?
>
>The point of the whole exercise is to get a better idea of free memory
>for our employer. Does it make sense to do this for computing free memory?
>
>Any comments welcome..
>
>Daniel
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
