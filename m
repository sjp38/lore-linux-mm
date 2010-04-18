Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 624956B01EF
	for <linux-mm@kvack.org>; Sun, 18 Apr 2010 15:10:02 -0400 (EDT)
Date: Sun, 18 Apr 2010 15:10:07 -0400
Subject: Re: [PATCH] mm: disallow direct reclaim page writeback
From: "Sorin Faibish" <sfaibish@emc.com>
Content-Type: text/plain; format=flowed; delsp=yes; charset=iso-8859-15
Message-ID: <op.vbdgq3hhrwwil4@sfaibish1.corp.emc.com>
MIME-Version: 1.0
References: <20100413202021.GZ13327@think> <20100414014041.GD2493@dastard>
 <20100414155233.D153.A69D9226@jp.fujitsu.com> <20100414072830.GK2493@dastard>
 <20100414085132.GJ25756@csn.ul.ie> <20100415013436.GO2493@dastard>
 <20100415102837.GB10966@csn.ul.ie> <20100416041412.GY2493@dastard>
 <20100416151403.GM19264@csn.ul.ie>
 <20100417203239.dda79e88.akpm@linux-foundation.org>
In-Reply-To: <20100417203239.dda79e88.akpm@linux-foundation.org>
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>
Cc: Dave Chinner <david@fromorbit.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Chris Mason <chris.mason@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 17 Apr 2010 20:32:39 -0400, Andrew Morton
<akpm@linux-foundation.org> wrote:

>
> There are two issues here: stack utilisation and poor IO patterns in
> direct reclaim.  They are different.
>
> The poor IO patterns thing is a regression.  Some time several years
> ago (around 2.6.16, perhaps), page reclaim started to do a LOT more
> dirty-page writeback than it used to.  AFAIK nobody attempted to work
> out why, nor attempted to try to fix it.
I for one am looking very seriously at this problem together with Bruce.
We plan to have a discussion on this topic at the next LSF meeting
in Boston.


>
>
> Doing writearound in pageout() might help.  The kernel was in fact was
> doing that around 2.5.10, but I took it out again because it wasn't
> obviously beneficial.
>
> Writearound is hard to do, because direct-reclaim doesn't have an easy
> way of pinning the address_space: it can disappear and get freed under
> your feet.  I was able to make this happen under intense MM loads.  The
> current page-at-a-time pageout code pins the address_space by taking a
> lock on one of its pages.  Once that lock is released, we cannot touch
> *mapping.
>
> And lo, the pageout() code is presently buggy:
>
> 		res = mapping->a_ops->writepage(page, &wbc);
> 		if (res < 0)
> 			handle_write_error(mapping, page, res);
>
> The ->writepage can/will unlock the page, and we're passing a hand
> grenade into handle_write_error().
>
> Any attempt to implement writearound in pageout will need to find a way
> to safely pin that address_space.  One way is to take a temporary ref
> on mapping->host, but IIRC that introduced nasties with inode_lock.
> Certainly it'll put more load on that worrisomely-singleton lock.
>
>
> Regarding simply not doing any writeout in direct reclaim (Dave's
> initial proposal): the problem is that pageout() will clean a page in
> the target zone.  Normal writeout won't do that, so we could get into a
> situation where vast amounts of writeout is happening, but none of it
> is cleaning pages in the zone which we're trying to allocate from.
> It's quite possibly livelockable, too.
>
> Doing writearound (if we can get it going) will solve that adequately
> (assuming that the target page gets reliably written), but it won't
> help the stack usage problem.
>
>
> To solve the IO-pattern thing I really do think we should first work
> out ytf we started doing much more IO off the LRU.  What caused it?  Is
> it really unavoidable?
>
>
> To solve the stack-usage thing: dunno, really.  One could envisage code
> which skips pageout() if we're using more than X amount of stack, but
> that sucks.  Another possibility might be to hand the target page over
> to another thread (I suppose kswapd will do) and then synchronise with
> that thread - get_page()+wait_on_page_locked() is one way.  The helper
> thread could of course do writearound.
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>



-- 
Best Regards
Sorin Faibish
Corporate Distinguished Engineer
Network Storage Group

         EMC2
where information lives

Phone: 508-435-1000 x 48545
Cellphone: 617-510-0422
Email : sfaibish@emc.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
