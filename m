Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id D6F1B6B004F
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 01:05:43 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5N55mCq022051
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 23 Jun 2009 14:05:50 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 96BDA45DD7E
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 14:05:48 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5EDA945DD7C
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 14:05:48 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3D4FB1DB803C
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 14:05:48 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id EA1211DB8038
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 14:05:47 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] Hugepages should be accounted as unevictable pages.
In-Reply-To: <1245732411.18339.6.camel@alok-dev1>
References: <20090623093459.2204.A69D9226@jp.fujitsu.com> <1245732411.18339.6.camel@alok-dev1>
Message-Id: <20090623135017.220D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 23 Jun 2009 14:05:47 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: akataria@vmware.com
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> > > Unevictable:           0 kB
> > > Mlocked:               0 kB
> > > HugePages_Total:      20
> > > HugePages_Free:       20
> > > HugePages_Rsvd:        0
> > > HugePages_Surp:        0
> > > 
> > > After the patch:
> > > 
> > > Unevictable:       81920 kB
> > > Mlocked:               0 kB
> > > HugePages_Total:      20
> > > HugePages_Free:       20
> > > HugePages_Rsvd:        0
> > > HugePages_Surp:        0
> > 
> > At first, We should clarify the spec of unevictable.
> > Currently, Unevictable field mean the number of pages in unevictable-lru
> > and hugepage never insert any lru.
> > 
> > I think this patch will change this rule.
> 
> I agree, and that's why I added a comment to the documentation file to
> that effect. If you think its not explicit or doesn't explain what its
> supposed to we can add something more there.
> 
> IMO, the proc output should give the total number of unevictable pages
> in the system and, since hugepages are also in fact unevictable so I
> don't see a reason why they shouldn't be accounted accordingly.
> What do you think ? 

ummm...

I'm not sure this unevictable definition is good idea or not. currently
hugepage isn't only non-account memory, but also various kernel memory doesn't
account.

one of drawback is that zone_page_state(UNEVICTABLE) lost to mean #-of-unevictable-pages.
e.g.  following patch is wrong?

fs/proc/meminfo.c meminfo_proc_show()
----------------------------
-                K(pages[LRU_UNEVICTABLE]),
+                K(pages[LRU_UNEVICTABLE]) + hstate->nr_huge_pages,


Plus, I didn't find any practical benefit in this patch. do you have it?
or You only want to natural definition?

I don't have any strong oppose reason, but I also don't have any strong
agree reason.


Lee, What do you think?




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
