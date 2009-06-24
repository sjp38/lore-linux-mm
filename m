Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C95E96B004F
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 21:41:47 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5O1h4vq018591
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 24 Jun 2009 10:43:04 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id E3C2C45DE56
	for <linux-mm@kvack.org>; Wed, 24 Jun 2009 10:43:03 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id BE1A245DE53
	for <linux-mm@kvack.org>; Wed, 24 Jun 2009 10:43:03 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id A0E491DB8063
	for <linux-mm@kvack.org>; Wed, 24 Jun 2009 10:43:03 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 362291DB805F
	for <linux-mm@kvack.org>; Wed, 24 Jun 2009 10:43:03 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 0/3] make mapped executable pages the first class citizen
In-Reply-To: <7561.1245768237@redhat.com>
References: <20090620043303.GA19855@localhost> <7561.1245768237@redhat.com>
Message-Id: <20090624104150.2257.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 24 Jun 2009 10:43:02 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Howells <dhowells@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "peterz@infradead.org" <peterz@infradead.org>, "riel@redhat.com" <riel@redhat.com>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

> Wu Fengguang <fengguang.wu@intel.com> wrote:
> 
> > David, could you try running this when it occurred again?
> > 
> >         make Documentation/vm/page-types
> >         Documentation/vm/page-types --raw  # run as root
> 
> Okay.  I managed to catch it between the first and second OOMs, and ran the
> command you asked for.
> 
> David
> ---
>              flags	page-count       MB  symbolic-flags			long-symbolic-flags
> 0x0000000000000000	    142261      555  ________________________________	
> 0x0000000100000000	      5588       21  ____________________r___________	reserved
> 0x0000004000000000	        17        0  __________________________h_____	arch
> 0x0000000800000004	         4        0  __R____________________P________	referenced,private
> 0x0000000800000024	      2073        8  __R__l_________________P________	referenced,lru,private
> 0x0000000400000028	     69911      273  ___U_l________________d_________	uptodate,lru,mappedtodisk
> 0x0001000400000028	        16        0  ___U_l________________d_____I___	uptodate,lru,mappedtodisk,readahead
> 0x0000000800000028	        25        0  ___U_l_________________P________	uptodate,lru,private
> 0x0000000000000028	        11        0  ___U_l__________________________	uptodate,lru
> 0x000000040000002c	      3045       11  __RU_l________________d_________	referenced,uptodate,lru,mappedtodisk
> 0x000000080000002c	         4        0  __RU_l_________________P________	referenced,uptodate,lru,private
> 0x0000000800000034	         9        0  __R_Dl_________________P________	referenced,dirty,lru,private
> 0x0000000800000038	         1        0  ___UDl_________________P________	uptodate,dirty,lru,private
> 0x0000000000004038	        13        0  ___UDl________b_________________	uptodate,dirty,lru,swapbacked
> 0x000000080000003c	         1        0  __RUDl_________________P________	referenced,uptodate,dirty,lru,private
> 0x0000000800000060	       183        0  _____lA________________P________	lru,active,private
> 0x0000000800000064	       982        3  __R__lA________________P________	referenced,lru,active,private
> 0x0000000400000068	       473        1  ___U_lA_______________d_________	uptodate,lru,active,mappedtodisk
> 0x0000000c00000068	         1        0  ___U_lA_______________dP________	uptodate,lru,active,mappedtodisk,private
> 0x000000040000006c	       392        1  __RU_lA_______________d_________	referenced,uptodate,lru,active,mappedtodisk
> 0x0000000c0000006c	         1        0  __RU_lA_______________dP________	referenced,uptodate,lru,active,mappedtodisk,private
> 0x0000000800000070	         1        0  ____DlA________________P________	dirty,lru,active,private
> 0x0000000800000074	        20        0  __R_DlA________________P________	referenced,dirty,lru,active,private
> 0x0000000c00000078	         2        0  ___UDlA_______________dP________	uptodate,dirty,lru,active,mappedtodisk,private
> 0x0000000000004078	         1        0  ___UDlA_______b_________________	uptodate,dirty,lru,active,swapbacked
> 0x000000080000007c	         1        0  __RUDlA________________P________	referenced,uptodate,dirty,lru,active,private
> 0x0000000000000080	     18684       72  _______S________________________	slab
> 0x0000000000000400	      6797       26  __________B_____________________	buddy
> 0x0000000000000804	         1        0  __R________M____________________	referenced,mmap
> 0x0000000400000828	       195        0  ___U_l_____M__________d_________	uptodate,lru,mmap,mappedtodisk
> 0x000000040000082c	        35        0  __RU_l_____M__________d_________	referenced,uptodate,lru,mmap,mappedtodisk
> 0x0000000000004838	         2        0  ___UDl_____M__b_________________	uptodate,dirty,lru,mmap,swapbacked
> 0x0000000400000868	        11        0  ___U_lA____M__________d_________	uptodate,lru,active,mmap,mappedtodisk
> 0x000000040000086c	       274        1  __RU_lA____M__________d_________	referenced,uptodate,lru,active,mmap,mappedtodisk
> 0x0000000800000878	         1        0  ___UDlA____M___________P________	uptodate,dirty,lru,active,mmap,private
> 0x000000080000087c	         2        0  __RUDlA____M___________P________	referenced,uptodate,dirty,lru,active,mmap,private
> 0x0000000000005008	         8        0  ___U________a_b_________________	uptodate,anonymous,swapbacked
> 0x0000000000005808	         6        0  ___U_______Ma_b_________________	uptodate,mmap,anonymous,swapbacked
> 0x0000000000005828	      4325       16  ___U_l_____Ma_b_________________	uptodate,lru,mmap,anonymous,swapbacked
> 0x0000000000005868	       366        1  ___U_lA____Ma_b_________________	uptodate,lru,active,mmap,anonymous,swapbacked
> 0x000000000000586c	         1        0  __RU_lA____Ma_b_________________	referenced,uptodate,lru,active,mmap,anonymous,swapbacked
>              total	    255744      999

reclaimable pages are very few. I don't think we see vmscan issue.
I guess it's memory leak issue.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
