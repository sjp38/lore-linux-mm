From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199906301805.LAA09251@google.engr.sgi.com>
Subject: Re: filecache/swapcache questions [RFC] [RFT] [PATCH] kanoj-mm12-2.3.8 Fix swapoff races
Date: Wed, 30 Jun 1999 11:05:57 -0700 (PDT)
In-Reply-To: <14202.21461.422665.925464@dukat.scot.redhat.com> from "Stephen C. Tweedie" at Jun 30, 99 06:28:53 pm
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
> On Tue, 29 Jun 1999 15:01:24 -0700 (PDT), kanoj@google.engr.sgi.com
> (Kanoj Sarcar) said:
> 
> > To know whether there are any more references left to be eliminated
> > on a swap page, we can not tolerate a SWAP_MAP_MAX concept; else we
> > can never determine whether there are processes still referencing the
> > swap page. Removing SWAP_MAP_MAX is a good thing in itself. The 
> > swap_map[] array needs to be declared as an array of elements of the 
> > same size as the page->count field, ie an atomic_t (since there can be
> > no more references to the swap page than there can be on the physical
> > page).
> 
> Yes there can...

I don't know how, but if this is true, and we do not have a
theoretical upper bound on the swap_count, then we will have to 
preserve SWAP_MAP_MAX ... which will render your proposal 
unachieveable ...

> 
> > Also, I am not sure why you say that fork can not keep ahead of
> > the swapoff sweep forever. 
> 
> Hmm, maybe..
> 
> > Are you saying it is okay not to guarantee forward progress of swapoff
> > while a program that keeps on forking (and the children exit almost
> > immediately) is running? 
> 
> There are a lot of things which don't make forward progress in such a
> situation already.  Put a lock on dup_mm() if it worries you that much.

That's basically what my solution does ... adds in a lock point
in copy_mm.

> 
> > Then there's the complexity of clone(CLONE_PID), which creates task
> > structures with the same pid, so the pid fencepost algorithm would
> > need to handle that too ...
> 
> Sure.  I never said that I had a complete solution: I just don't believe
> that a new mm lock on all the faulting paths is necessary for a complete
> solution.  

Hmmm, did you look at my solution in detail ... no locks are taken
on the page fault paths, other than mmap_sem, which the current code
already takes ...

Thanks.

Kanoj
kanoj@engr.sgi.com
> 
> --Stephen
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
