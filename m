Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 48EFB6B004F
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 01:52:22 -0400 (EDT)
Subject: Re: [PATCH] Hugepages should be accounted as unevictable pages.
From: Alok Kataria <akataria@vmware.com>
Reply-To: akataria@vmware.com
In-Reply-To: <20090623141147.8f2cef18.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090623093459.2204.A69D9226@jp.fujitsu.com>
	 <1245732411.18339.6.camel@alok-dev1>
	 <20090623135017.220D.A69D9226@jp.fujitsu.com>
	 <20090623141147.8f2cef18.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain
Date: Mon, 22 Jun 2009 22:54:01 -0700
Message-Id: <1245736441.18339.21.camel@alok-dev1>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


On Mon, 2009-06-22 at 22:11 -0700, KAMEZAWA Hiroyuki wrote:
> On Tue, 23 Jun 2009 14:05:47 +0900 (JST)
> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> > I'm not sure this unevictable definition is good idea or not. currently
> > hugepage isn't only non-account memory, but also various kernel memory doesn't
> > account.
> > 
> > one of drawback is that zone_page_state(UNEVICTABLE) lost to mean #-of-unevictable-pages.
Kosaki-san,
I don't see the reason, why is it important to have the count of number
of pages on unevictable-lru. 
Instead zone_page_state(UNEVICTABLE) now correctly tells how many of
these pages from this zone are actually unevictable.

> > e.g.  following patch is wrong?
> > 
> > fs/proc/meminfo.c meminfo_proc_show()
> > ----------------------------
> > -                K(pages[LRU_UNEVICTABLE]),
> > +                K(pages[LRU_UNEVICTABLE]) + hstate->nr_huge_pages,
> > 
> > 
> > Plus, I didn't find any practical benefit in this patch. do you have it?
> > or You only want to natural definition?

Both, while working on an module I noticed that there is no way direct
way to get any information regarding the total number of unrecliamable
(unevictable) pages in the system. While reading through the kernel
sources i came across this unevictalbe LRU framework and thought that
this should actually work towards providing  total unevictalbe pages in
the system irrespective of where they reside.

So both there is a need as well as, (IMO) this should be the natural
definition for unevictable pages.

> > 
> > I don't have any strong oppose reason, but I also don't have any strong
> > agree reason.
> > 
> I think "don't include Hugepage" is sane. Hugepage is something _special_, now.
> 
Kamezawa-san, 

I agree that hugepages are special in the sense that they are
implemented specially and don't actually reside on the LRU like any
other locked memory. But, both of these memory types (mlocked and
hugepages) are actually unevictable and can't be reclaimed back, so i
don't see a reason why should accounting not reflect that.

Thanks,
Alok

> Thanks,
> -Kame
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
