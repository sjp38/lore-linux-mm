Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id B0B236B004A
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 03:50:34 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o837oVD7003055
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 3 Sep 2010 16:50:31 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8D4E245DE4E
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 16:50:31 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6857745DE55
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 16:50:31 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id DB0FCE18002
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 16:50:30 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 64E081DB8037
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 16:50:30 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] [RFC]Dirty page accounting on lru basis.
In-Reply-To: <1283488982-19361-1-git-send-email-yinghan@google.com>
References: <1283488982-19361-1-git-send-email-yinghan@google.com>
Message-Id: <20100903164142.2F23.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri,  3 Sep 2010 16:50:29 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Ying Han <yinghan@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, riel@redhat.com, minchan.kim@gmail.com, hugh.dickins@tiscali.co.uk, kamezawa.hiroyu@jp.fujitsu.com, fengguang.wu@intel.com, mel@csn.ul.ie, npiggin@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> For each active, inactive and unevictable lru list, we would like to count the
> number of dirty file pages. This becomes useful when we start monitoring and
> tracking the efficiency of page reclaim path while doing some heavy IO workloads.
> 
> We export the new accounting now through global proc/meminfo as well as per-node
> meminfo. Ideally, the accounting should work as:

linux/Documentation/vm/page-types.c ?


% sudo ~/bin/page-types
             flags      page-count       MB  symbolic-flags                     long-symbolic-flags
0x0000000000000000           76660      299  __________________________________
0x0000000000000024           33920      132  __R__l____________________________ referenced,lru
0x0000000000000028           23774       92  ___U_l____________________________ uptodate,lru
0x0001000000000028             378        1  ___U_l________________________I___ uptodate,lru,readahead
0x000000000000002c          160474      626  __RU_l____________________________ referenced,uptodate,lru
0x0000000000004038              21        0  ___UDl________b___________________ uptodate,dirty,lru,swapbacked
0x000000000000003c          124491      486  __RUDl____________________________ referenced,uptodate,dirty,lru
0x000000000000403c               7        0  __RUDl________b___________________ referenced,uptodate,dirty,lru,swapbacked
0x0000000000000060            3521       13  _____lA___________________________ lru,active
0x0000000000000064           12681       49  __R__lA___________________________ referenced,lru,active
0x0000000000000068            5309       20  ___U_lA___________________________ uptodate,lru,active
0x000000000000006c           22840       89  __RU_lA___________________________ referenced,uptodate,lru,active
0x0000000000000074              60        0  __R_DlA___________________________ referenced,dirty,lru,active
0x000000000000007c               3        0  __RUDlA___________________________ referenced,uptodate,dirty,lru,active
0x0000000000000080           33810      132  _______S__________________________ slab
0x0004000000000080             179        0  _______S________________________A_ slab,slub_frozen
0x000000000000012c            7463       29  __RU_l__W_________________________ referenced,uptodate,lru,writeback
0x000000000000012d               2        0  L_RU_l__W_________________________ locked,referenced,uptodate,lru,writeback
0x0000000000000400             683        2  __________B_______________________ buddy
0x0000000000000800              16        0  ___________M______________________ mmap
0x0000000000000804               1        0  __R________M______________________ referenced,mmap
0x0000000000000828              42        0  ___U_l_____M______________________ uptodate,lru,mmap
0x000000000000082c             959        3  __RU_l_____M______________________ referenced,uptodate,lru,mmap
0x0000000000004838               4        0  ___UDl_____M__b___________________ uptodate,dirty,lru,mmap,swapbacked
0x0000000000000868             158        0  ___U_lA____M______________________ uptodate,lru,active,mmap
0x000000000000086c            3091       12  __RU_lA____M______________________ referenced,uptodate,lru,active,mmap
0x0000000000005808               2        0  ___U_______Ma_b___________________ uptodate,mmap,anonymous,swapbacked
0x0000000000005828            2702       10  ___U_l_____Ma_b___________________ uptodate,lru,mmap,anonymous,swapbacked
0x000000000000582c              22        0  __RU_l_____Ma_b___________________ referenced,uptodate,lru,mmap,anonymous,swapbacked
0x0000000000005868            8342       32  ___U_lA____Ma_b___________________ uptodate,lru,active,mmap,anonymous,swapbacked
0x000000000000586c              17        0  __RU_lA____Ma_b___________________ referenced,uptodate,lru,active,mmap,anonymous,swapbacked
             total          521632     2037


That said,

ActiveDirty(file):       240KB
InactiveDirty(file):     486MB




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
