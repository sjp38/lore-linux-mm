Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id A28346B0036
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 06:13:43 -0400 (EDT)
Message-ID: <5215E4B7.3020003@parallels.com>
Date: Thu, 22 Aug 2013 14:15:19 +0400
From: Maxim Patlasov <mpatlasov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: strictlimit feature -v4
References: <20130821135427.20334.79477.stgit@maximpc.sw.ru> <20130821133804.87ca602dd864df712e67342a@linux-foundation.org>
In-Reply-To: <20130821133804.87ca602dd864df712e67342a@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: riel@redhat.com, jack@suse.cz, dev@parallels.com, miklos@szeredi.hu, fuse-devel@lists.sourceforge.net, xemul@parallels.com, linux-kernel@vger.kernel.org, jbottomley@parallels.com, linux-mm@kvack.org, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, fengguang.wu@intel.com, devel@openvz.org, mgorman@suse.de

08/22/2013 12:38 AM, Andrew Morton D?D,N?DuN?:
> On Wed, 21 Aug 2013 17:56:32 +0400 Maxim Patlasov<mpatlasov@parallels.com>  wrote:
>
>> The feature prevents mistrusted filesystems to grow a large number of dirty
>> pages before throttling. For such filesystems balance_dirty_pages always
>> check bdi counters against bdi limits. I.e. even if global "nr_dirty" is under
>> "freerun", it's not allowed to skip bdi checks. The only use case for now is
>> fuse: it sets bdi max_ratio to 1% by default and system administrators are
>> supposed to expect that this limit won't be exceeded.
>>
>> The feature is on if a BDI is marked by BDI_CAP_STRICTLIMIT flag.
>> A filesystem may set the flag when it initializes its BDI.
> Now I think about it, I don't really understand the need for this
> feature.  Can you please go into some detail about the problematic
> scenarios and why they need fixing?  Including an expanded descritopn
> of the term "mistrusted filesystem"?

Saying "mistrusted filesystem" I meant FUSE mount created by 
unprivileged user. Userspace fuse library provides suid binary 
"fusermount". Here is an excerpt from its man-page:

 > Filesystem in Userspace (FUSE) is a simple interface for userspace pro-
 > grams to export a virtual filesystem to the Linux kernel. It also aims
 > to provide a secure method for non privileged users to create and mount
 > their own filesystem implementations.
 >
 > fusermount is a program to mount and unmount FUSE filesystems.

I'm citing it here to emphasize the fact that running buggy or 
malevolent filesystem implementation is not pure theoretical. Every time 
you have fuse library properly installed, any user can compile and mount 
its own filesystem implementation.

The problematic scenario comes from the fact that nobody pays attention 
to the NR_WRITEBACK_TEMP counter (i.e. number of pages under fuse 
writeback). The implementation of fuse writeback releases original page 
(by calling end_page_writeback) almost immediately. A fuse request 
queued for real processing bears a copy of original page. Hence, if 
userspace fuse daemon doesn't finalize write requests in timely manner, 
an aggressive mmap writer can pollute virtually all memory by those 
temporary fuse page copies. They are carefully accounted in 
NR_WRITEBACK_TEMP, but nobody cares.

To make further explanations shorter, let me use "NR_WRITEBACK_TEMP 
problem" as a shortcut for "a possibility of uncontrolled grow of amount 
of RAM consumed by temporary pages allocated by kernel fuse to process 
writeback".

> Is this some theoretical happens-in-the-lab thing, or are real world
> users actually hurting due to the lack of this feature?

The problem was very easy to reproduce. There is a trivial example 
filesystem implementation in fuse userspace distribution: fusexmp_fh.c. 
I added "sleep(1);" to the write methods, then recompiled and mounted 
it. Then created a huge file on the mount point and run a simple program 
which mmap-ed the file to a memory region, then wrote a data to the 
region. An hour later I observed almost all RAM consumed by fuse 
writeback. Since then some unrelated changes in kernel fuse made it more 
difficult to reproduce, but it is still possible now.

Putting this theoretical happens-in-the-lab thing aside, there is 
another thing that really hurts real world (FUSE) users. This is 
write-through page cache policy FUSE currently uses. I.e. handling 
write(2), kernel fuse populates page cache and flushes user data to the 
server synchronously. This is excessively suboptimal. Pavel Emelyanov's 
patches ("writeback cache policy") solve the problem, but they also make 
resolving NR_WRITEBACK_TEMP problem absolutely necessary. Otherwise, 
simply copying a huge file to a fuse mount would result in memory 
starvation. Miklos, the maintainer of FUSE, believes strictlimit feature 
the way to go.

And eventually putting FUSE topics aside, there is one more use-case for 
strictlimit feature. Using a slow USB stick (mass storage) in a machine 
with huge amount of RAM installed is a well-known pain. Let's make 
simple computations. Assuming 64GB of RAM installed, existing 
implementation of balance_dirty_pages will start throttling only after 
9.6GB of RAM becomes dirty (freerun == 15% of total RAM). So, the 
command "cp 9GB_file /media/my-usb-storage/" may return in a few 
seconds, but subsequent "umount /media/my-usb-storage/" will take more 
than two hours if effective throughput of the storage is, to say, 1MB/sec.

After inclusion of strictlimit feature, it will be trivial to add a knob 
(e.g. /sys/devices/virtual/bdi/x:y/strictlimit) to enable it on demand. 
Manually or via udev rule. May be I'm wrong, but it seems to be quite a 
natural desire to limit the amount of dirty memory for some devices we 
are not fully trust (in the sense of sustainable throughput).

> I think I'll apply it to -mm for now to get a bit of testing, but would
> very much like it if Fengguang could find time to review the
> implementation, please.
Great! Fengguang, please...

Thanks,
Maxim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
