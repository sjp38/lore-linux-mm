Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 46DBC6B002C
	for <linux-mm@kvack.org>; Tue, 11 Oct 2011 17:01:53 -0400 (EDT)
Date: Tue, 11 Oct 2011 23:01:42 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC PATCH] mm: thp: make swap configurable
Message-ID: <20111011210142.GC29866@redhat.com>
References: <1318255086-7393-1-git-send-email-lliubbo@gmail.com>
 <20111010141851.GC17335@redhat.com>
 <CAA_GA1cC=6e6+bFp7on+BtmBp4qgfiyjSzvJQ23F41LobnzNfA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA_GA1cC=6e6+bFp7on+BtmBp4qgfiyjSzvJQ23F41LobnzNfA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, hannes@cmpxchg.org, riel@redhat.com

Hi Bob,

On Tue, Oct 11, 2011 at 05:24:26PM +0800, Bob Liu wrote:
> Thanks for your reply.
> 
> Yes, mlock() can do it but it will require a lot of changes in every
> user application.
> If some of the applications are hugh and complicated(even not opensource), it's
> hard to modify them.
> Add this patch can make things simple and thp more flexible.
> 
> For using swapoff -a, it will disable swap for 4k normal pages.
> 
> A simple use case is like this:
> a lot of swap sensitive apps run on a machine, it will use thp so we
> need to disable swap.
> But  this apps are hugh and complicated, it's hard to modify them by mlock().
> 
> In addition, there are also some normal and not swap sensitive apps
> which don't use thp run on
> the same machine, we can still reclaim their memory by swap when lack
> of memory.

I'm not convinced. If you need to disable swap selectively to certain
apps but you can't modify them I'd suggest to add a
mlock-equal-privileged prctl(PR_SWAP_ENABLE/DISABLE) that applies to
all anonymous memory and tmpfs. Probably not to filebacked memory in
case MAP_SHARED is used for all I/O. This seems too limited, it may
happen to work well for a specific application but it's not generic
enough. Another user could have a binary application with a ton of
tmpfs shared memory that he can't modify (MAP_SHARED on /dev/zero for
example) and he wants to mlock it but he can't. Or maybe another user
has an application with <2M anonymous memory scattered in the middle
of MAP_SHARED segments (so that can't be mapped by THP because of
strict hardware limits) and he wants it to remain locked in ram too
and not be swapped out for that specific app. So I prefer a solution
that threats all anonymous memory and tmpfs memory equal (the only two
entities in the kernel that will be paged out to swap). Or at the very
least all anonymous memory equal... so it remains transparent as much
as possible :).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
