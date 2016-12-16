Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 617936B0038
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 04:02:00 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id bk3so32714523wjc.4
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 01:02:00 -0800 (PST)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id ja7si6138961wjb.23.2016.12.16.01.01.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 01:01:59 -0800 (PST)
Received: by mail-wm0-f65.google.com with SMTP id a20so3971609wme.2
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 01:01:58 -0800 (PST)
Date: Fri, 16 Dec 2016 10:01:57 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/4] [RFC!] mm: 'struct mm_struct' reference counting
 debugging
Message-ID: <20161216090157.GA13940@dhcp22.suse.cz>
References: <20161216082202.21044-1-vegard.nossum@oracle.com>
 <20161216082202.21044-4-vegard.nossum@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161216082202.21044-4-vegard.nossum@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vegard Nossum <vegard.nossum@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Fri 16-12-16 09:22:02, Vegard Nossum wrote:
> Reference counting bugs are hard to debug by their nature since the actual
> manifestation of one can occur very far from where the error is introduced
> (e.g. a missing get() only manifest as a use-after-free when the reference
> count prematurely drops to 0, which could be arbitrarily long after where
> the get() should have happened if there are other users). I wrote this patch
> to try to track down a suspected 'mm_struct' reference counting bug.

I definitely agree that hunting these bugs is a royal PITA, no question
about that. I am just wondering whether this has been motivated by any
particular bug recently. I do not seem to remember any such an issue for
quite some time.

> The basic idea is to keep track of all references, not just with a reference
> counter, but with an actual reference _list_. Whenever you get() or put() a
> reference, you also add or remove yourself, respectively, from the reference
> list. This really helps debugging because (for example) you always put a
> specific reference, meaning that if that reference was not yours to put, you
> will notice it immediately (rather than when the reference counter goes to 0
> and you still have an active reference).

But who is the owner of the reference? A function/task? It is not all
that uncommon to take an mm reference from one context and release it
from a different one. But I might be missing your point here.

> The main interface is in <linux/mm_ref_types.h> and <linux/mm_ref.h>, while
> the implementation lives in mm/mm_ref.c. Since 'struct mm_struct' has both
> ->mm_users and ->mm_count, we introduce helpers for both of them, but use
> the same data structure for each (struct mm_ref). The low-level rules (i.e.
> the ones we have to follow, but which nobody else should really have to
> care about since they use the higher-level interface) are:
> 
>  - after incrementing ->mm_count you also have to call get_mm_ref()
> 
>  - before decrementing ->mm_count you also have to call put_mm_ref()
> 
>  - after incrementing ->mm_users you also have to call get_mm_users_ref()
> 
>  - before decrementing ->mm_users you also have to call put_mm_users_ref()
> 
> The rules that most of the rest of the kernel will care about are:
> 
>  - functions that acquire and return a mm_struct should take a
>    'struct mm_ref *' which it can pass on to mmget()/mmgrab()/etc.
> 
>  - functions that release an mm_struct passed as a parameter should also
>    take a 'struct mm_ref *' which it can pass on to mmput()/mmdrop()/etc.
> 
>  - any function that temporarily acquires a mm_struct reference should
>    use MM_REF() to define an on-stack reference and pass it on to
>    mmget()/mmput()/mmgrab()/mmdrop()/etc.
> 
>  - any structure that holds an mm_struct pointer must also include a
>    'struct mm_ref' member; when the mm_struct pointer is modified you
>    would typically also call mmget()/mmgrab()/mmput()/mmdrop() and they
>    should be called with this mm_ref
> 
>  - you can convert (for example) an on-stack reference to an in-struct
>    reference using move_mm_ref(). This is semantically equivalent to
>    (atomically) taking the new reference and dropping the old one, but
>    doesn't actually need to modify the reference count

This all sounds way too intrusive to me so I am not really sure this is
something we really want. A nice thing for debugging for sure but I am
somehow skeptical whether it is really worth it considering how many
those ref. count bugs we've had.

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
