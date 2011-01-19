Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2CFC76B0092
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 20:49:03 -0500 (EST)
Date: Tue, 18 Jan 2011 17:48:26 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4] mm: add replace_page_cache_page() function
Message-Id: <20110118174826.4c6d47a3.akpm@linux-foundation.org>
In-Reply-To: <AANLkTimh7jq7HLjfxVX0XKdhOhWEQtDn-faGc+iJ-ykd@mail.gmail.com>
References: <E1Pf9Zj-0002td-Ct@pomaz-ex.szeredi.hu>
	<20110118152844.88cfdc2c.akpm@linux-foundation.org>
	<AANLkTimh7jq7HLjfxVX0XKdhOhWEQtDn-faGc+iJ-ykd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Miklos Szeredi <miklos@szeredi.hu>, kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 19 Jan 2011 10:24:09 +0900 Minchan Kim <minchan.kim@gmail.com> wrote:

> >
> > This is all pretty ugly and inefficient.
> >
> > We call __remove_from_page_cache() which does a radix-tree lookup and
> > then fiddles a bunch of accounting things.
> >
> > Then we immediately do the same radix-tree lookup and then undo the
> > accounting changes which we just did. __And we do it in an open-coded
> > fashion, thus giving the kernel yet another code site where various
> > operations need to be kept in sync.
> >
> > Would it not be better to do a single radix_tree_lookup_slot(),
> > overwrite the pointer therein and just leave all the ancilliary
> > accounting unaltered?
> 
> I agree single radix_tree_lookup but accounting still is needed since
> newpage could be on another zone. What we can remove is just only
> mapping->nrpages.

Well.  We only need to do inc/dec_zone_state if the zones are
different.  Perhaps the zones-equal case is worth optimising for,
dunno.

Also, the radix_tree_preload() should be unneeded.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
