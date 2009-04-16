Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 9BB975F0001
	for <linux-mm@kvack.org>; Thu, 16 Apr 2009 02:30:38 -0400 (EDT)
Date: Thu, 16 Apr 2009 14:30:24 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC][PATCH] proc: export more page flags in /proc/kpageflags
Message-ID: <20090416063024.GA5803@localhost>
References: <20090414071159.GV14687@one.firstfloor.org> <20090415131800.GA11191@localhost> <20090416111108.AC55.A69D9226@jp.fujitsu.com> <20090416034918.GB20162@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090416034918.GB20162@localhost>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Apr 16, 2009 at 11:49:18AM +0800, Wu Fengguang wrote:
> On Thu, Apr 16, 2009 at 10:26:51AM +0800, KOSAKI Motohiro wrote:
> > tatus: RO
> > Content-Length: 13245
> > Lines: 380
> > 
> > Hi
> > 
> > > > > > On Tue, Apr 14, 2009 at 12:37:10PM +0800, KOSAKI Motohiro wrote:
> > > > > > > > Export the following page flags in /proc/kpageflags,
> > > > > > > > just in case they will be useful to someone:
> > > > > > > >
> > > > > > > > - PG_swapcache
> > > > > > > > - PG_swapbacked
> > > > > > > > - PG_mappedtodisk
> > > > > > > > - PG_reserved
> > > >
> > > > PG_reserved should be exported as PG_KERNEL or somesuch.
> > >
> > > PG_KERNEL could be misleading. PG_reserved obviously do not cover all
> > > (or most) kernel pages. So I'd prefer to export PG_reserved as it is.
> > >
> > > It seems that the vast amount of free pages are marked PG_reserved:
> > 
> > Can I review the document at first?
> > if no good document for administrator, I can't ack exposing PG_reserved.
> 
> btw, is this the expected behavior to mark so many free pages as PG_reserved?
> Last time I looked at it, in 2.6.27, the free pages simply don't have
> any flags set.
> 
> //Or maybe it's a false reporting of my tool. Will double check.

Ah it's my fault. Something goes wrong when I convert the page-types data
structure from a huge array to hash table. Here is the correct output:

# echo 1 > /proc/sys/vm/drop_caches 
# ./page-types                      
         flags  page-count       MB  symbolic-flags                     long-symbolic-flags
0x000000000000      479149     1871  ___________________________        
0x000000004000       19258       75  ______________r____________        reserved
0x000000008000          16        0  _______________o___________        compound
0x004000008000        3655       14  _______________o__________T        compound,compound_tail
0x000000008014           1        0  __R_D__________o___________        referenced,dirty,compound
0x004000008014           4        0  __R_D__________o__________T        referenced,dirty,compound,compound_tail
0x000000000020           1        0  _____l_____________________        lru
0x000000000028          58        0  ___U_l_____________________        uptodate,lru
0x00000000203c          17        0  __RUDl_______b_____________        referenced,uptodate,dirty,lru,swapbacked
0x000200000064          20        0  __R__lA______________P_____        referenced,lru,active,private
0x000200000068           5        0  ___U_lA______________P_____        uptodate,lru,active,private
0x00000000006c          17        0  __RU_lA____________________        referenced,uptodate,lru,active
0x00020000006c           2        0  __RU_lA______________P_____        referenced,uptodate,lru,active,private
0x000000002078           1        0  ___UDlA______b_____________        uptodate,dirty,lru,active,swapbacked
0x000000000228           1        0  ___U_l___x_________________        uptodate,lru,reclaim
0x000000000400        3600       14  __________B________________        buddy
0x000000000804           1        0  __R________m_______________        referenced,mmap
0x000000002808           6        0  ___U_______m_b_____________        uptodate,mmap,swapbacked
0x000000002828         974        3  ___U_l_____m_b_____________        uptodate,lru,mmap,swapbacked
0x00000000082c           1        0  __RU_l_____m_______________        referenced,uptodate,lru,mmap
0x000000000868        1501        5  ___U_lA____m_______________        uptodate,lru,active,mmap
0x000000002868        2696       10  ___U_lA____m_b_____________        uptodate,lru,active,mmap,swapbacked
0x00000000086c         969        3  __RU_lA____m_______________        referenced,uptodate,lru,active,mmap
0x00000000286c          17        0  __RU_lA____m_b_____________        referenced,uptodate,lru,active,mmap,swapbacked
0x000000002878           2        0  ___UDlA____m_b_____________        uptodate,dirty,lru,active,mmap,swapbacked
0x000000008880         694        2  _______S___m___o___________        slab,mmap,compound
0x000000000880        1183        4  _______S___m_______________        slab,mmap
0x0000000088c0          62        0  ______AS___m___o___________        active,slab,mmap,compound
0x0000000008c0          57        0  ______AS___m_______________        active,slab,mmap
         total      513968     2007

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
