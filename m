Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7687C6B005A
	for <linux-mm@kvack.org>; Mon, 28 Sep 2009 22:56:35 -0400 (EDT)
Date: Tue, 29 Sep 2009 12:03:48 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][PATCH 8/10] memcg: clean up charge/uncharge anon
Message-Id: <20090929120348.0bcb17d1.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090929111828.6f9148d6.nishimura@mxp.nes.nec.co.jp>
References: <20090925171721.b1bbbbe2.kamezawa.hiroyu@jp.fujitsu.com>
	<20090925172850.265abe78.kamezawa.hiroyu@jp.fujitsu.com>
	<20090929092413.9526de0b.nishimura@mxp.nes.nec.co.jp>
	<20090929102653.612cc2a4.kamezawa.hiroyu@jp.fujitsu.com>
	<20090929111828.6f9148d6.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Just to make sure.

> > Maybe there is something I don't understand..
> > IIUC, when page_remove_rmap() is called by do_wp_page(),
> > there must be pte(s) which points to the page and a pte is guarded by
> > page table lock. So, I think page_mapcount() > 0 before calling page_remove_rmap()
> > because there must be a valid pte, at least.
> > 
> > Can this scenario happen ?
> I think so. I intended to mention this case :)
> I'm sorry for my vague explanation.
> 
> > ==
> >     Thread A.                                      Thread B.
> > 
> >     do_wp_page()                                 do_swap_page()
> >        PageAnon(oldpage)                         
> >          lock_page()                             lock_page()=> wait.
> >          reuse = false.
> >          unlock_page()                           get lock.      
> >        do copy-on-write
> >        pte_same() == true
> >          page_remove_rmap(oldpage) (mapcount goes to -1)
> >                                                  page_set_anon_rmap() (new anon rmap again)
> > ==
> > Then, oldpage's mapcount goes down to 0 and up to 1 immediately.
> > 
I meant "process" not "thread".
I think this cannot happen in the case of threads, because these page_remove_rmap()
and page_set_anon_rmap() are called under pte lock(they share the pte).


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
