From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199906282125.OAA06661@google.engr.sgi.com>
Subject: Re: filecache/swapcache questions [RFC] [RFT] [PATCH] kanoj-mm12-2.3.8
Date: Mon, 28 Jun 1999 14:25:30 -0700 (PDT)
In-Reply-To: <Pine.BSO.4.10.9906281648010.24888-100000@funky.monkey.org> from "Chuck Lever" at Jun 28, 99 05:14:17 pm
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chuck Lever <cel@monkey.org>
Cc: sct@redhat.com, andrea@suse.de, torvalds@transmeta.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> the eventual goal of my adventure is to drop the kernel lock while doing
> the page COW in do_wp_page, since in 2.3.6+, the COW is again protected
> because of race conditions with kswapd.  this "protection" serializes all
> page faults behind a very expensive memory copy.  what other ways are
> there to protect the COW operation while allowing some parallelism?  it
> seems like this is worth a little complexity, IMO.
>

I have already commented on my reservations about holding mmap_sem
in kswapd/try_to_free_pages. 

Just thought I would point out that I have been thinking on the
lines of eliminating kernel_lock from the vm code (experimentally
initially under a CONFIG option), but I am yet to come up with
a complete design. My current ideas involve a per mm spinning pte 
lock, a sleeping vmalist mutex (which processes never go to sleep
holding). I am still struggling to understand whether a per
page lock is needed or swapcache lock will do.

In any case, if someone on the list is working on something
similar, maybe we can exchange notes offline. Of course, we can
not perturb performance for kernels which does not have the 
CONFIG option set. And Linus has to agree its worthwhile doing
this work ....

Thanks.

Kanoj
kanoj@engr.sgi.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
