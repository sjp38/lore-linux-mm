Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 027D06B0012
	for <linux-mm@kvack.org>; Sun,  8 May 2011 08:51:32 -0400 (EDT)
Message-ID: <4DC691D0.6050104@parallels.com>
Date: Sun, 8 May 2011 16:51:28 +0400
From: Konstantin Khlebnikov <khlebnikov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] tmpfs: fix race between umount and writepage
References: <4DAFD0B1.9090603@parallels.com> <20110421064150.6431.84511.stgit@localhost6> <20110421124424.0a10ed0c.akpm@linux-foundation.org> <4DB0FE8F.9070407@parallels.com> <alpine.LSU.2.00.1105031223120.9845@sister.anvils> <4DC4D9A6.9070103@parallels.com> <alpine.LSU.2.00.1105071621330.3668@sister.anvils>
In-Reply-To: <alpine.LSU.2.00.1105071621330.3668@sister.anvils>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hugh Dickins wrote:
> On Sat, 7 May 2011, Konstantin Khlebnikov wrote:
>> Hugh Dickins wrote:
>>
>>> Here's the patch I was testing last night, but I do want to test it
>>> some more (I've not even tried your unmounting case yet), and I do want
>>> to make some changes to it (some comments, and see if I can move the
>>> mem_cgroup_cache_charge outside of the mutex, making it GFP_KERNEL
>>> rather than GFP_NOFS - at the time that mem_cgroup charging went in,
>>> we did not know here if it was actually a shmem swap page, whereas
>>> nowadays we can be sure, since that's noted in the swap_map).
>>>
>>> In shmem_unuse_inode I'm widening the shmem_swaplist_mutex to protect
>>> against shmem_evict_inode; and in shmem_writepage adding to the list
>>> earlier, while holding lock on page still in pagecache to protect it.
>>>
>>> But testing last night showed corruption on this laptop (no problem
>>> on other machines): I'm guessing it's unrelated, but I can't be sure
>>> of that without more extended testing.
>>
>> This patch fixed my problem, I didn't catch any crashes on my test-case:
>> swapout-unmount.
>
> Thank you, Konstantin, for testing that and reporting back.
>
> I tried using your script on Thursday, but couldn't get the tuning right
> for this machine: with numbers too big everything would go OOM, with
> numbers too small it wouldn't even go to swap, with numbers on the edge
> it would soon settle into a steady state with almost nothing in swap.
>
> Just once, without the patch, I did get to "Self-destruct in 5 seconds",
> but that was not reproducible enough for me to test that the patch would
> be fixing anything.
>
> I was going to try today on other machines with more cpus and more memory,
> though not as much as yours; but now I'll let your report save me the time,
> and just add your Tested-by.  Big thank you for that!
>
> Besides adding comments, I have changed the patch around since then, at
> the shmem_unuse_inode end: to avoid any memory allocation while holding
> the mutex (and then we no longer need to drop and retake info->lock,
> so it gets a little simpler).  It would be dishonest of me to claim your
> Tested-by for the changed code (and your mount/write/umount loop would
> not have been testing swapoff): since it is an independent fix with a
> different justification, I'll split that part off into a 2/3.

Ok, I can test final patch-set on the next week.
Also I can try to add some swapoff test-cases.

>
> 3/3 being the fix to the "corruption" I noticed while testing, corruption
> being on the filesystem I had on /dev/loop0, over a tmpfs file filling its
> filesystem: when I wrote, I'd missed the "I/O" errors in /var/log/messages.
>
> It was another case of a long-standing but largely theoretical race,
> now made easily reproducible by recent changes (the preallocation in
> between find_lock_page and taking info->lock): when the filesystem is
> full, you could get ENOSPC from a race in bringing back a previously
> allocated page from swap.
>
> I'll write these three up now and send off to Andrew.
>
> Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
