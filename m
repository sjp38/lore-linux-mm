Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 591D76B003D
	for <linux-mm@kvack.org>; Fri,  1 May 2009 15:34:12 -0400 (EDT)
Message-ID: <49FB4EBB.3030404@redhat.com>
Date: Fri, 01 May 2009 15:34:19 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] vmscan: evict use-once pages first (v2)
References: <20090428044426.GA5035@eskimo.com> <1240987349.4512.18.camel@laptop> 	<20090429114708.66114c03@cuia.bos.redhat.com> <20090430072057.GA4663@eskimo.com> 	<20090430174536.d0f438dd.akpm@linux-foundation.org> <20090430205936.0f8b29fc@riellaptop.surriel.com> 	<20090430181340.6f07421d.akpm@linux-foundation.org> <20090430215034.4748e615@riellaptop.surriel.com> 	<20090430195439.e02edc26.akpm@linux-foundation.org> <49FB01C1.6050204@redhat.com> <2c0942db0905011104u4e6df9ap9d95fa30b1284294@mail.gmail.com>
In-Reply-To: <2c0942db0905011104u4e6df9ap9d95fa30b1284294@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ray Lee <ray-lk@madrabbit.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, elladan@eskimo.com, peterz@infradead.org, linux-kernel@vger.kernel.org, tytso@mit.edu, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ray Lee wrote:

> Said way #3: We desktop users really want a way to say "Please don't
> page my executables out when I'm running a system with 3gig of RAM." I
> hate knobs, but I'm willing to beg for one in this case. 'cause
> mlock()ing my entire working set into RAM seems pretty silly.
> 
> Does any of that make sense, or am I talking out of an inappropriate orifice?

The "don't page my executables out" part makes sense.

However, I believe that kind of behaviour should be the
default.  Desktops and servers alike have a few different
kinds of data in the page cache:
1) pages that have been frequently accessed at some point
    in the past and got promoted to the active list
2) streaming IO

I believe that we want to give (1) absolute protection from
(2), provided there are not too many pages on the active file
list.  That way we will provide executables, cached indirect
and inode blocks, etc. from streaming IO.

Pages that are new to the page cache start on the inactive
list.  Only if they get accessed twice while on that list,
they get promoted to the active list.

Streaming IO should normally be evicted from memory before
it can get accessed again.  This means those pages do not
get promoted to the active list and the working set is
protected.

Does this make sense?

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
