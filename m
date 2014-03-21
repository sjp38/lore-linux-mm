Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f44.google.com (mail-ee0-f44.google.com [74.125.83.44])
	by kanga.kvack.org (Postfix) with ESMTP id 0E0926B0262
	for <linux-mm@kvack.org>; Thu, 20 Mar 2014 22:43:27 -0400 (EDT)
Received: by mail-ee0-f44.google.com with SMTP id e49so1306534eek.31
        for <linux-mm@kvack.org>; Thu, 20 Mar 2014 19:43:27 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id w48si5599110een.44.2014.03.20.19.43.25
        for <linux-mm@kvack.org>;
        Thu, 20 Mar 2014 19:43:26 -0700 (PDT)
Date: Thu, 20 Mar 2014 22:43:06 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <532ba74e.48c70e0a.7b9e.119cSMTPIN_ADDED_BROKEN@mx.google.com>
In-Reply-To: <532B9A18.8020606@oracle.com>
References: <1392068676-30627-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1392068676-30627-9-git-send-email-n-horiguchi@ah.jp.nec.com>
 <532B9A18.8020606@oracle.com>
Subject: [PATCH] madvise: fix locking in force_swapin_readahead() (Re: [PATCH
 08/11] madvise: redefine callback functions for page table walker)
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sasha.levin@oracle.com
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mpm@selenic.com, cpw@sgi.com, kosaki.motohiro@jp.fujitsu.com, hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suse.cz, aneesh.kumar@linux.vnet.ibm.com, xemul@parallels.com, riel@redhat.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org


On Thu, Mar 20, 2014 at 09:47:04PM -0400, Sasha Levin wrote:
> On 02/10/2014 04:44 PM, Naoya Horiguchi wrote:
> >swapin_walk_pmd_entry() is defined as pmd_entry(), but it has no code
> >about pmd handling (except pmd_none_or_trans_huge_or_clear_bad, but the
> >same check are now done in core page table walk code).
> >So let's move this function on pte_entry() as swapin_walk_pte_entry().
> >
> >Signed-off-by: Naoya Horiguchi<n-horiguchi@ah.jp.nec.com>
> 
> This patch seems to generate:

Sasha, thank you for reporting.
I forgot to unlock ptlock before entering read_swap_cache_async() which
holds page lock in it, as a result lock ordering rule (written in mm/rmap.c)
was violated (we should take in the order of mmap_sem -> page lock -> ptlock.)
The following patch should fix this. Could you test with it?

---
