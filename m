Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 10B4E900194
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 10:22:43 -0400 (EDT)
Date: Wed, 22 Jun 2011 16:22:39 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/3] mm: completely disable THP by
 transparent_hugepage=never
Message-ID: <20110622142239.GV20843@redhat.com>
References: <4DFF7F0A.8090604@redhat.com>
 <4DFF8106.8090702@redhat.com>
 <4DFF8327.1090203@redhat.com>
 <4DFF84BB.3050209@redhat.com>
 <4DFF8848.2060802@redhat.com>
 <20110620182558.GF4749@redhat.com>
 <20110620192117.GG20843@redhat.com>
 <4E00192E.70901@redhat.com>
 <20110621144346.GQ20843@redhat.com>
 <4E0159E9.10800@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <4E0159E9.10800@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cong Wang <amwang@redhat.com>
Cc: Vivek Goyal <vgoyal@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

On Wed, Jun 22, 2011 at 10:56:41AM +0800, Cong Wang wrote:
> ao? 2011a1'06ae??21ae?JPY 22:43, Andrea Arcangeli a??e??:
> > On Tue, Jun 21, 2011 at 12:08:14PM +0800, Cong Wang wrote:
> >> The thing is that we can save ~10K by adding 3 lines of code as this
> >> patch showed, where else in kernel can you save 10K by 3 lines of code?
> >> (except some kfree() cases, of course) So, again, why not have it? ;)
> >
> > Because you could save it with a more complicated patch that doesn't
> > cripple down functionality.
> 
> 
> Why do you prefer "more complicated" things to simple ones? ;-)

If they offer more features yes. Allowing to tune the size of the has
will also allow to increase it, not only to decrease it. It's also not
significantly more complicated.

> I realized this patch changed the original behavior of "=never",
> thus proposed a new "=0" parameter.
> 
> But to be honest, "=never" should be renamed to "=disable".

So in turn you're saying "=always" should be renamed to "=enabled". So
your preference would be enabled=enabled and enabled=disabled and
enabled=madvise? I think the current wording is nicer and breaking
kabi just for this sounds bad.

> Not only such things, the more serious thing is that you are
> enforcing a policy to users, as long as I enable THP in Kconfig,
> I have no way to disable it.
> 
> Why are you so sure that every user who has no chance to change
> .config likes THP?
> 
> And, what can I do if I want to prevent any process from having
> a chance to enable THP? Because as long as THP exists in /sys,
> any process has the right privilege can change it.

You must be root to have the privilege to enable it, root also has the
privilege to enable THP by writing in /dev/mem or by loading a kernel
module to do it.

I already told you how to save hundred kbytes of ram from you kernel
setting dhash_entries=1 and ihash_entries=1 and how to achieve the ~8k
ram saving in THP and KSM without crippling functionality with a patch
that is more complex than your three liner, but not much more complex,
and that it will _improve_ (not cripple down) functionality.

I'm also not interested into making the 512M param configurable. If
you want to add a "=force" parameter ok but I doubt you will ever gain
anything significant on a system with 512M of ram where each process
will likely be smaller than 512M and 100M would get used by the
anti-frag logic (reducing it to 400m).

I suggest just cleaning up the printk and if you want you can add a
__setup("thp_mm_slots_hash_heads=", set_thp_mm_slots_hash_heads) but
no other change needed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
