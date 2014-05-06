Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f47.google.com (mail-qa0-f47.google.com [209.85.216.47])
	by kanga.kvack.org (Postfix) with ESMTP id 879A26B0035
	for <linux-mm@kvack.org>; Tue,  6 May 2014 18:43:44 -0400 (EDT)
Received: by mail-qa0-f47.google.com with SMTP id s7so170915qap.6
        for <linux-mm@kvack.org>; Tue, 06 May 2014 15:43:44 -0700 (PDT)
Received: from cdptpa-oedge-vip.email.rr.com (cdptpa-outbound-snat.email.rr.com. [107.14.166.229])
        by mx.google.com with ESMTP id u7si3725331qab.52.2014.05.06.15.43.43
        for <linux-mm@kvack.org>;
        Tue, 06 May 2014 15:43:43 -0700 (PDT)
Date: Tue, 6 May 2014 18:43:41 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 3/4] plist: add plist_rotate
Message-ID: <20140506184341.6e12e80a@gandalf.local.home>
In-Reply-To: <CALZtONAUXiv6jfy8vW9NTotPR=V0q6Worcy9_rvou4A0s0whPw@mail.gmail.com>
References: <1397336454-13855-1-git-send-email-ddstreet@ieee.org>
	<1399057350-16300-1-git-send-email-ddstreet@ieee.org>
	<1399057350-16300-4-git-send-email-ddstreet@ieee.org>
	<20140505221846.4564e04d@gandalf.local.home>
	<CALZtONAr7XGMB8LHwKRjqeEaWTEKBbwkUuP1RAZd04YQiwxrGw@mail.gmail.com>
	<20140506163950.7e278f7c@gandalf.local.home>
	<CALZtONAUXiv6jfy8vW9NTotPR=V0q6Worcy9_rvou4A0s0whPw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Weijie Yang <weijieut@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Paul Gortmaker <paul.gortmaker@windriver.com>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>

On Tue, 6 May 2014 17:47:16 -0400
Dan Streetman <ddstreet@ieee.org> wrote:


> well the specific reason in swap's case is the need to use
> same-priority entries in a round-robin basis, but I don't know if
> plist_round_robin() is very clear.

No, that's not very clear.

> 
> Maybe plist_demote()?  Although demote might imply actually changing priority.

Agreed.

> 
> plist_shuffle()?  That might imply random shuffling though.

Yep.

> 
> plist_readd() or plist_requeue()?  That might make sense since
> technically the function could be replicated by just plist_del() and
> plist_add(), based on the implementation detail that plist_add()
> inserts after all other same-priority entries, instead of before.

plist_requeue() sounds like the best so far.

> 
> Or add priority into the name explicitly, like plist_priority_yield(),
> or plist_priority_rotate(), plist_priority_requeue()?

No, even plist_yield() assumes priority is the same, thus adding
priority to a plist that means "priority list" is rather redundant.

I think its up between plist_yield() and plist_requeue(), where I'm
leaning towards plist_requeue().

Unless others have any better ideas or objections, lets go with
plist_requeue(). I think that's rather self explanatory and it sounds
just like what you said. It's basically an optimized version of
plist_del() followed by a plist_add().

 
> Ok here's try 3, before I update the patch :)  Does this make sense?
> 
> This is needed by the next patch in this series, which changes swap
> from using regular lists to track its available swap devices
> (partitions or files) to using plists.  Each swap device has a
> priority, and swap allocates pages from devices in priority order,
> filling up the highest priority device first (and then removing it
> from the available list), by allocating a page from the swap device
> that is first in the priority-ordered list.  With regular lists, swap
> was managing the ordering by priority, while with plists the ordering
> is automatically handled.  However, swap requires special handling of
> swap devices with the same priority; pages must be allocated from them
> in round-robin order.  To accomplish this with a plist, this new
> function is used; when a page is allocated from the first swap device
> in the plist, that entry is moved to the end of any same-priority
> entries.  Then the next time a page needs to be allocated, the next
> swap device will be used, and so on.

OK, I read the above a few times and I think I know where my confusion
is coming from. I was thinking that the pages were being added to the
plist. I believe you are saying that the swap devices themselves are
added to the plist, and when the device is empty (no more pages left)
it is removed from the plist. When dealing with memory and swap one
thinks of managing pages. But here we are managing the devices.

Please state clearly at the beginning of your explanation that the swap
devices are being stored in the plist and stay there as long as they
still have pages left to be allocated from. In order to treat swap
devices of the same priority in a round robin fashion, after a device
has pages allocated from it, it needs to be requeued at the end of it's
priority, behind other swap devices of the same priority in order to
make sure the next allocation comes from a different device (of same
priority).


-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
