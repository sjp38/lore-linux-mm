Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id EDBF26B0031
	for <linux-mm@kvack.org>; Thu,  3 Oct 2013 19:56:17 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id mc17so3160237pbc.32
        for <linux-mm@kvack.org>; Thu, 03 Oct 2013 16:56:17 -0700 (PDT)
Received: by mail-pb0-f52.google.com with SMTP id wz12so3124910pbc.25
        for <linux-mm@kvack.org>; Thu, 03 Oct 2013 16:56:15 -0700 (PDT)
Message-ID: <524E0419.3080909@linaro.org>
Date: Thu, 03 Oct 2013 16:56:09 -0700
From: John Stultz <john.stultz@linaro.org>
MIME-Version: 1.0
Subject: Re: [PATCH 00/14] Volatile Ranges v9
References: <1380761503-14509-1-git-send-email-john.stultz@linaro.org>
In-Reply-To: <1380761503-14509-1-git-send-email-john.stultz@linaro.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>, LKML <linux-kernel@vger.kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Dhaval Giani <dhaval.giani@gmail.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Rob Clark <robdclark@gmail.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 10/02/2013 05:51 PM, John Stultz wrote:
> So its been awhile since the last release of the volatile ranges
> patches, and while Minchan and I have been busy with other things,
> we have been slowly chipping away at issues and differences
> trying to get a patchset that we both agree on.
>
> There's still a few smaller issues, but we figured any further
> polishing of the patch series in private would be unproductive
> and it would be much better to send the patches out for review
> and comment and get some wider opinions.
>
> Whats new in v9:
> * Updated to v3.11
> * Added vrange purging logic to purge anonymous pages on
>   swapless systems
> * Added logic to allocate the vroot structure dynamically
>   to avoid added overhead to mm and address_space structures
> * Lots of minor tweaks, changes and cleanups
>
> Still TODO:
> * Sort out better solution for clearing volatility on new mmaps
> 	- Minchan has a different approach here
> * Sort out apparent shrinker livelock that occasionally crops
>   up under severe pressure
>  
> Feedback or thoughts here would be particularly helpful!

Andrew noted that I've forgotten to provide sufficient overview of what
volatile ranges does, and given its been while, folks may want a quick
introduction/reminder.

Volatile ranges provides a method for userland to inform the kernel that
a range of memory is safe to discard (ie: can be regenerated) but
userspace may want to try access it in the future.  It can be thought of
as similar to MADV_DONTNEED, but that the actual freeing of the memory
is delayed and only done under memory pressure, and the user can try to
cancel the action and be able to quickly access any unpurged pages. The
idea originated from Android's ashmem, but I've since learned that other
OSes provide similar functionality.

This funcitonality allows for a number of interesting uses:
* Userland caches that have kernel triggered eviction under memory
pressure. This allows for the kernel to "rightsize" userspace caches for
current system-wide workload. Things like image bitmap caches, or
rendered HTML in a hidden browser tab, where the data is not visible and
can be regenerated if needed, are good examples.

* Opportunistic freeing of memory that may be quickly reused. Minchan
has done a malloc implementation where free() marks the pages as
volatile, allowing the kernel to reclaim under pressure. This avoids the
unmapping and remapping of anonymous pages on free/malloc. So if
userland wants to malloc memory quickly after the free, it just needs to
mark the pages as non-volatile, and only purged pages will have to be
faulted back in.

The syscall interface is defined in patch 5/14 in this series, but
briefly there are two ways to utilze the functionality:

Explicit marking method:
1) Userland marks a range of memory that can be regenerated if necessary
as volatile
2) Before accessing the memory again, userland marks the memroy as
nonvolatile, and the kernel will provide notifcation if any pages in the
range has been purged.

Optimistic method:
1) Userland marks a large range of data as volatile
2) Userland continues to access the data as it needs.
3) If userland accesses a page that has been purged, the kernel will
send a SIGBUS
4) Userspace can trap the SIGBUS, mark the afected pages as
non-volatile, and refill the data as needed before continuing on


Other details:
The interface takes a range of memory, which can cover anonymous pages
as well as mmapped file pages. In the case that the pages are from a
shared mmapped file, the volatility set on those file pages is global.
Thus much as writes to those pages are shared to other processes, pages
marked volatile will be volatile to any other processes that have the
file mapped as well. It is advised that processes coordinate when using
volatile ranges on shared mappings (much as they must coordinate when
writing to shared data). Any uncleared volatility on mmapped files will
last until the the file is closed by all users (ie: volatility isn't
persistent on disk).

Volatility on anonymous pages are inherited across forks, but cleared on
exec.

You can read more about the history of volatile ranges here:
http://permalink.gmane.org/gmane.linux.kernel.mm/98848
http://permalink.gmane.org/gmane.linux.kernel.mm/98676
https://lwn.net/Articles/522135/
https://lwn.net/Kernel/Index/#Volatile_ranges


thanks
-john

thanks
-john

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
