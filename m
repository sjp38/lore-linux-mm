Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id E8B266B00AA
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 03:17:58 -0400 (EDT)
Date: Fri, 18 Sep 2009 08:17:09 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH 2/4] send callback when swap slot is freed
In-Reply-To: <1253256805.4959.8.camel@penberg-laptop>
Message-ID: <Pine.LNX.4.64.0909180809290.2882@sister.anvils>
References: <1253227412-24342-1-git-send-email-ngupta@vflare.org>
 <1253227412-24342-3-git-send-email-ngupta@vflare.org> <1253256805.4959.8.camel@penberg-laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Nitin Gupta <ngupta@vflare.org>, Greg KH <greg@kroah.com>, Andrew Morton <akpm@linux-foundation.org>, Ed Tomlinson <edt@aei.ca>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-mm-cc <linux-mm-cc@laptop.org>, kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp
List-ID: <linux-mm.kvack.org>

On Fri, 18 Sep 2009, Pekka Enberg wrote:
> On Fri, 2009-09-18 at 04:13 +0530, Nitin Gupta wrote:
> > +EXPORT_SYMBOL_GPL(set_swap_free_notify);
> > +
> >  static int swap_entry_free(struct swap_info_struct *p,
> >  			   swp_entry_t ent, int cache)
> >  {
> > @@ -585,6 +617,8 @@ static int swap_entry_free(struct swap_info_struct *p,
> >  			swap_list.next = p - swap_info;
> >  		nr_swap_pages++;
> >  		p->inuse_pages--;
> > +		if (p->swap_free_notify_fn)
> > +			p->swap_free_notify_fn(p->bdev, offset);
> >  	}
> >  	if (!swap_count(count))
> >  		mem_cgroup_uncharge_swap(ent);
> 
> OK, this hits core kernel code so we need to CC some more mm/swapfile.c
> people. The set_swap_free_notify() API looks strange to me. Hugh, I
> think you mentioned that you're okay with an explicit hook. Any
> suggestions how to do this cleanly?

No, no better suggestion.  I quite see Nitin's point that ramzswap
would benefit significantly from a callback here, though it's not a
place (holding swap_lock) where we'd like to offer a callback at all.

I think I would prefer the naming to make it absolutely clear that
it's a special for ramzswap or compcache, rather than dressing it
up in the grand generality of a swap_free_notify_fn: giving our
hacks fancy names doesn't really make them better.

(Does the bdev matching work out if there are any regular swapfiles
around? I've not checked, might or might not need refinement there.)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
