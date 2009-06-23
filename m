Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 255976B004F
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 08:25:22 -0400 (EDT)
Subject: Re: [PATCH] Hugepages should be accounted as unevictable pages.
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20090623135017.220D.A69D9226@jp.fujitsu.com>
References: <20090623093459.2204.A69D9226@jp.fujitsu.com>
	 <1245732411.18339.6.camel@alok-dev1>
	 <20090623135017.220D.A69D9226@jp.fujitsu.com>
Content-Type: text/plain
Date: Tue, 23 Jun 2009 08:26:03 -0400
Message-Id: <1245759963.1944.11.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: akataria@vmware.com, LKML <linux-kernel@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2009-06-23 at 14:05 +0900, KOSAKI Motohiro wrote:
> > > > Unevictable:           0 kB
> > > > Mlocked:               0 kB
> > > > HugePages_Total:      20
> > > > HugePages_Free:       20
> > > > HugePages_Rsvd:        0
> > > > HugePages_Surp:        0
> > > > 
> > > > After the patch:
> > > > 
> > > > Unevictable:       81920 kB
> > > > Mlocked:               0 kB
> > > > HugePages_Total:      20
> > > > HugePages_Free:       20
> > > > HugePages_Rsvd:        0
> > > > HugePages_Surp:        0
> > > 
> > > At first, We should clarify the spec of unevictable.
> > > Currently, Unevictable field mean the number of pages in unevictable-lru
> > > and hugepage never insert any lru.
> > > 
> > > I think this patch will change this rule.
> > 
> > I agree, and that's why I added a comment to the documentation file to
> > that effect. If you think its not explicit or doesn't explain what its
> > supposed to we can add something more there.
> > 
> > IMO, the proc output should give the total number of unevictable pages
> > in the system and, since hugepages are also in fact unevictable so I
> > don't see a reason why they shouldn't be accounted accordingly.
> > What do you think ? 
> 
> ummm...
> 
> I'm not sure this unevictable definition is good idea or not. currently
> hugepage isn't only non-account memory, but also various kernel memory doesn't
> account.
> 
> one of drawback is that zone_page_state(UNEVICTABLE) lost to mean #-of-unevictable-pages.
> e.g.  following patch is wrong?
> 
> fs/proc/meminfo.c meminfo_proc_show()
> ----------------------------
> -                K(pages[LRU_UNEVICTABLE]),
> +                K(pages[LRU_UNEVICTABLE]) + hstate->nr_huge_pages,
> 
> 
> Plus, I didn't find any practical benefit in this patch. do you have it?
> or You only want to natural definition?
> 
> I don't have any strong oppose reason, but I also don't have any strong
> agree reason.
> 
> 
> Lee, What do you think?
> 

Alok asked me about this off-list.  Like you, I have no strong feelings
either way.  Before this patch, yes, the Unevictable meminfo item does
correspond to the number of pages on the unevictable lru.  However, I
don't know that this is all that useful to an administrator.  And, I
don't think we depend on this count anywhere in the code.  So, perhaps
having the system "do the math" to add the unevictable huge pages to
this item is more useful.  Then, again, as you point out, there is a lot
of kernel memory that is also unevictable that would not be accounted
here.  

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
