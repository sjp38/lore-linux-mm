From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199906292201.PAA17715@google.engr.sgi.com>
Subject: Re: filecache/swapcache questions [RFC] [RFT] [PATCH] kanoj-mm12-2.3.8 Fix swapoff races
Date: Tue, 29 Jun 1999 15:01:24 -0700 (PDT)
In-Reply-To: <14200.45499.255924.339550@dukat.scot.redhat.com> from "Stephen C. Tweedie" at Jun 29, 99 12:44:59 pm
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: andrea@suse.de, torvalds@transmeta.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> Hi,
> 
> On Mon, 28 Jun 1999 16:43:59 -0700 (PDT), kanoj@google.engr.sgi.com
> (Kanoj Sarcar) said:
> 
> > This will almost always work, except theoretically, you still can
> > not guarantee forward progress, unless you can stop forks() from
> > happening. That is, given a high enough rate of forking, swapoff
> > is never going to terminate. 
> 
> Then repeat until it converges, ie. until you have no swap entries left.
> No big deal.  Unless the swapoff sweep and the fork are running over pid
> space at exactly the same rate forever (which we do not have to worry
> about!), you will make progress.
>

Stephen,

Seeing that both of us devoted so much time to discussing this,
I felt compelled to look at what is involved in doing what you 
are suggesting. 

To know whether there are any more references left to be eliminated
on a swap page, we can not tolerate a SWAP_MAP_MAX concept; else we
can never determine whether there are processes still referencing the
swap page. Removing SWAP_MAP_MAX is a good thing in itself. The 
swap_map[] array needs to be declared as an array of elements of the 
same size as the page->count field, ie an atomic_t (since there can be
no more references to the swap page than there can be on the physical
page).

Also, I am not sure why you say that fork can not keep ahead of
the swapoff sweep forever. Are you saying it is okay not to guarantee
forward progress of swapoff while a program that keeps on forking 
(and the children exit almost immediately) is running? Then there's
the complexity of clone(CLONE_PID), which creates task structures 
with the same pid, so the pid fencepost algorithm would need to
handle that too ...

Let me know what you think of these two issues, then I can try
to create a patch that does this ... 

Kanoj
kanoj@engr.sgi.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
