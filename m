Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id C9F066B0031
	for <linux-mm@kvack.org>; Sat, 15 Feb 2014 18:28:20 -0500 (EST)
Received: by mail-pd0-f172.google.com with SMTP id p10so13459165pdj.3
        for <linux-mm@kvack.org>; Sat, 15 Feb 2014 15:28:20 -0800 (PST)
Received: from mail-pb0-x22a.google.com (mail-pb0-x22a.google.com [2607:f8b0:400e:c01::22a])
        by mx.google.com with ESMTPS id xf4si10234738pab.46.2014.02.15.15.28.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 15 Feb 2014 15:28:19 -0800 (PST)
Received: by mail-pb0-f42.google.com with SMTP id jt11so13917242pbb.1
        for <linux-mm@kvack.org>; Sat, 15 Feb 2014 15:28:19 -0800 (PST)
Date: Sat, 15 Feb 2014 15:27:29 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: KSM on Android
In-Reply-To: <CAMrOTPgBtANS_ryRjan0-dTL97U7eRvtf3dCsss=Kn+Uk89fuA@mail.gmail.com>
Message-ID: <alpine.LSU.2.11.1402151344340.8605@eggly.anvils>
References: <CAMrOTPgBtANS_ryRjan0-dTL97U7eRvtf3dCsss=Kn+Uk89fuA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pradeep Sawlani <pradeep.sawlani@gmail.com>
Cc: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, surim@lab126.com, Izik Eidus <izik.eidus@ravellosystems.com>, Dave Hansen <dave@sr71.net>, Arjan van de Ven <arjan@linux.intel.com>

On Thu, 13 Feb 2014, Pradeep Sawlani wrote:
> Re-sending this in plain text format (Apologies)
> 
> Hello,
> 
> In pursuit of saving memory on Android, I started experimenting with
> Kernel Same Page Merging(KSM).
> Number of pages shared because of KSM is reported by
> /sys/kernel/mm/pages_sharing.
> Documentation/vm/ksm.txt explains this as:
> 
> "pages_sharing    - how many more sites are sharing them i.e. how much saved"
> 
> After enabling KSM on Android device, this number was reported as 19666 pages.
> Obvious optimization is to find out source of sharing and see if we
> can avoid duplicate pages at first place.
> In order to collect the data needed, It needed few
> modifications(trace_printk) statement in mm/ksm.c.
> Data should be collected from second cycle because that's when ksm
> starts merging
> pages. First KSM cycle is only used to calculate the checksum, pages
> are added to
> unstable tree and eventually moved to stable tree after this.
> 
> After analyzing data from second KSM cycle, few things which stood out:
> 1.  In the same cycle, KSM can scan same page multiple times. Scanning
> a page involves
>     comparing page with pages in stable tree, if no match is found
> checksum is calculated.
>     From the look of it, it seems to be cpu intensive operation and
> impacts dcache as well.

Yes.

Of course you can adjust /sys/kernel/mm/ksm tunables to make it more
or less cpu and dcache intensive, and correspondingly more or less
effective in combining memory; but that's not really your interest.

> 
> 2.  Same page which is already shared by multiple process can be
> replaced by KSM page.
>     In this case, let say a particular page is mapped 24 times and is
> replaced by KSM page then
>     eventually all 24 entries will point to KSM page. pages_sharing
> will account for all 24 pages.
>     so pages _sharing does not actually report amount of memory saved.
> From the above example actual
>     savings is one page.

Yes.

KSM was created mainly to support KVM, where forking is not an issue,
I think.  I do remember fixing it early on, to stop it from converting
every forked page to a KSM page.  But you're right that once there is
a stable KSM page of particular content, forked instances of a page of
the same content will be peeled off one by one to be shared with the
KSM page, and the pages_sharing count claim more has been saved than
is actually so.

The easy fix to that is to remove "i.e. how much saved" from the
Documentation, or better, to qualify it by your point on forking.
But again, that's not really your interest.

Coming up with a supportable alternative or fix to pages_sharing:
it's not obvious to me how to go about that - whether or not to
decrement the count once a write COWs off an instance of the page.
Presumably it could be done, but at cost of recording more info in the
rmap_items: I doubt it would be worth the extra memory and processing.

Easier and less consuming might be to provide a running statistic of
the average page_mapcount of pages being shared into stable.  Or even
a tunable to refuse sharing into stable above a certain mapcount,
which could be set to 1 or something higher (or 0 for no limit).

> 
> Both cases happen very often with Android because of its architecture
> - Zygote spawning(fork) multiple
> applications. To calculate actual savings, we should account for same
> page(pfn)replaced by same KSM page only once.
> In the case 2 example, page_sharing should account only one page.
> After recalculating memory saving comes out to be 8602 pages (~34MB).
> 
> I am trying to find out right solution to fix pages_sharing and
> eventually optimize KSM to scan page
> once even if it is mapped multiple times.

To scan page once (each cycle) even if it is mapped multiple times:
that does sound a useful enhancement to make for the Android case
you describe.  I see two sides to that.

One is mapping the replacement page into all sites at the same time.
That sounds doable, but without actually attempting to do it, I'm
not at all sure.  It's interesting that try_to_merge_with_ksm_page()
works on one rmap_item and down_reads the corresponding mmap_sem,
but try_to_merge_one_page() itself does not use the rmap_item.
Lots to think about there: most particularly, what is that mmap_sem
protecting here?  Because it would not be protecting the other
instances that you replace.

Something it does protect is VM_MERGEABLE in vma->vm_flags: it's
a nuisance that VM_MERGEABLE might not be set in some of the vmas
sharing this page.

(By the way, if break_cow() poses a problem for you - break_cow()
being KSM's easy answer for backtracking, just COW back to ordinary
anon page if something goes wrong - and I've a feeling it might,
I do have a patch from a year ago which I never had time to write
up and complete testing on, which eliminates its use.)

The other side is cmp_and_merge_page() skipping a page which has
already been scanned this cycle via another mapping.  I think
the easiest way to accomplish that would be with two pageflags,
using alternate flag each cycle.  But we certainly don't have
two pageflags to spare on 32-bit, and I doubt it on 64-bit:
everyone wants to use that space.  However, you could easily
prototype it that way, to measure the savings and judge whether
it's worth going further.

Good luck.  Interesting work, but I can't find time for it.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
