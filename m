Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f50.google.com (mail-ee0-f50.google.com [74.125.83.50])
	by kanga.kvack.org (Postfix) with ESMTP id 13CC16B0278
	for <linux-mm@kvack.org>; Fri, 21 Mar 2014 02:22:44 -0400 (EDT)
Received: by mail-ee0-f50.google.com with SMTP id c13so1402764eek.23
        for <linux-mm@kvack.org>; Thu, 20 Mar 2014 23:22:44 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id l41si6295350eef.8.2014.03.20.23.22.41
        for <linux-mm@kvack.org>;
        Thu, 20 Mar 2014 23:22:42 -0700 (PDT)
Date: Fri, 21 Mar 2014 02:22:24 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <532bdab2.c15d0e0a.6d87.ffff9130SMTPIN_ADDED_BROKEN@mx.google.com>
In-Reply-To: <alpine.LSU.2.11.1403202159190.1488@eggly.anvils>
References: <1392068676-30627-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1392068676-30627-9-git-send-email-n-horiguchi@ah.jp.nec.com>
 <532B9A18.8020606@oracle.com>
 <532ba74e.48c70e0a.7b9e.119cSMTPIN_ADDED_BROKEN@mx.google.com>
 <alpine.LSU.2.11.1403202159190.1488@eggly.anvils>
Subject: Re: [PATCH] madvise: fix locking in force_swapin_readahead() (Re:
 [PATCH 08/11] madvise: redefine callback functions for page table walker)
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hughd@google.com
Cc: shli@kernel.org, sasha.levin@oracle.com, linux-mm@kvack.org, akpm@linux-foundation.org, mpm@selenic.com, cpw@sgi.com, kosaki.motohiro@jp.fujitsu.com, hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suse.cz, aneesh.kumar@linux.vnet.ibm.com, xemul@parallels.com, riel@redhat.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org

On Thu, Mar 20, 2014 at 10:16:21PM -0700, Hugh Dickins wrote:
> On Thu, 20 Mar 2014, Naoya Horiguchi wrote:
> > On Thu, Mar 20, 2014 at 09:47:04PM -0400, Sasha Levin wrote:
> > > On 02/10/2014 04:44 PM, Naoya Horiguchi wrote:
> > > >swapin_walk_pmd_entry() is defined as pmd_entry(), but it has no code
> > > >about pmd handling (except pmd_none_or_trans_huge_or_clear_bad, but the
> > > >same check are now done in core page table walk code).
> > > >So let's move this function on pte_entry() as swapin_walk_pte_entry().
> > > >
> > > >Signed-off-by: Naoya Horiguchi<n-horiguchi@ah.jp.nec.com>
> > > 
> > > This patch seems to generate:
> > 
> > Sasha, thank you for reporting.
> > I forgot to unlock ptlock before entering read_swap_cache_async() which
> > holds page lock in it, as a result lock ordering rule (written in mm/rmap.c)
> > was violated (we should take in the order of mmap_sem -> page lock -> ptlock.)
> > The following patch should fix this. Could you test with it?
> > 
> > ---
> > From c0d56af5874dc40467c9b3a0f9e53b39b3c4f1c5 Mon Sep 17 00:00:00 2001
> > From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > Date: Thu, 20 Mar 2014 22:30:51 -0400
> > Subject: [PATCH] madvise: fix locking in force_swapin_readahead()
> > 
> > We take mmap_sem and ptlock in walking over ptes with swapin_walk_pte_entry(),
> > but inside it we call read_swap_cache_async() which holds page lock.
> > So we should unlock ptlock to call read_swap_cache_async() to meet lock order
> > rule (mmap_sem -> page lock -> ptlock).
> > 
> > Reported-by: Sasha Levin <sasha.levin@oracle.com>
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> 
> NAK.  You are now unlocking and relocking the spinlock, good; but on
> arm frv or i386 CONFIG_HIGHPTE you are leaving the page table atomically
> kmapped across read_swap_cache_async(), which (never mind lock ordering)
> is quite likely to block waiting to allocate memory.

Thanks for pointing out, you're right.
walk_pte_range() doesn't fit to pte loop in original swapin_walk_pmd_entry(),
so I should not have changed this code.

> I do not see
> madvise-redefine-callback-functions-for-page-table-walker.patch
> as an improvement.  I can see what's going on in Shaohua's original
> code, whereas this style makes bugs more likely.  Please drop it.

OK, I agree that.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
