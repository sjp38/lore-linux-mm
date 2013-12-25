Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 4C5ED6B0035
	for <linux-mm@kvack.org>; Tue, 24 Dec 2013 20:07:53 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id z10so6728932pdj.16
        for <linux-mm@kvack.org>; Tue, 24 Dec 2013 17:07:52 -0800 (PST)
Received: from e28smtp03.in.ibm.com (e28smtp03.in.ibm.com. [122.248.162.3])
        by mx.google.com with ESMTPS id zq7si16859562pac.72.2013.12.24.17.07.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 24 Dec 2013 17:07:51 -0800 (PST)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 25 Dec 2013 06:37:48 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 6C8173940023
	for <linux-mm@kvack.org>; Wed, 25 Dec 2013 06:37:46 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBP17gu132964642
	for <linux-mm@kvack.org>; Wed, 25 Dec 2013 06:37:42 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBP17jjD007919
	for <linux-mm@kvack.org>; Wed, 25 Dec 2013 06:37:45 +0530
Date: Wed, 25 Dec 2013 09:07:44 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: mm: kernel BUG at include/linux/swapops.h:131!
Message-ID: <52ba2fe7.47fc420a.0e92.ffff9008SMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <52B1C143.8080301@oracle.com>
 <52B871B2.7040409@oracle.com>
 <20131224025127.GA2835@lge.com>
 <52B8F8F6.1080500@oracle.com>
 <20131224060705.GA16140@lge.com>
 <20131224074546.GB27156@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131224074546.GB27156@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <bob.liu@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, khlebnikov@openvz.org, LKML <linux-kernel@vger.kernel.org>

Hi Joonsoo,
On Tue, Dec 24, 2013 at 04:45:46PM +0900, Joonsoo Kim wrote:
>On Tue, Dec 24, 2013 at 03:07:05PM +0900, Joonsoo Kim wrote:
>> On Mon, Dec 23, 2013 at 10:01:10PM -0500, Sasha Levin wrote:
>> > On 12/23/2013 09:51 PM, Joonsoo Kim wrote:
>> > >On Mon, Dec 23, 2013 at 12:24:02PM -0500, Sasha Levin wrote:
>> > >>>Ping?
>> > >>>
>> > >>>I've also Cc'ed the "this page shouldn't be locked at all" team.
>> > >Hello,
>> > >
>> > >I can't find the reason of this problem.
>> > >If it is reproducible, how about bisecting?
>> > 
>> > While it reproduces under fuzzing it's pretty hard to bisect it with
>> > the amount of issues uncovered by trinity recently.
>> > 
>> > I can add any debug code to the site of the BUG if that helps.
>> 
>> Good!
>> It will be helpful to add dump_page() in migration_entry_to_page().
>> 
>> Thanks.
>> 
>
>Minchan teaches me that there is possible race condition between
>fork and migration.
>
>Please consider following situation.
>
>
>Process A (do migration)			Process B (parents) Process C (child)
>
>try_to_unmap() for migration <begin>		fork
>setup migration entry to B's vma
>...
>try_to_unmap() for migration <end>
>move_to_new_page()
>
>						link new vma
>						    into interval tree
>remove_migration_ptes() <begin>
>check and clear migration entry on C's vma
>...						copy_one_pte:
>...						    now, B and C have migration entry
>...

>From Sasha's report:

| [ 3800.520039] page:ffffea0000245800 count:12 mapcount:4 mapping:ffff88001d0c3668 index:0x7de
| [ 3800.521404] page flags: 0x1fffff8038003c(referenced|uptodate|dirty|lru|swapbacked|unevictable|mlocked)
| [ 3800.522585] pc:ffff88001ed91600 pc->flags:2 pc->mem_cgroup:ffffc90000c0a000

IIUC, C's mapcount should be 0 as B's in the race condition you mentioned. 

Regards,
Wanpeng Li 

>...
>check and clear migration entry on B's vma
>...
>...
>remove_migration_ptes() <end>
>
>
>Eventually, migration entry on C's vma is left.
>And then, when C exits, above BUG_ON() can be triggered.
>
>I'm not sure the I am right, so please think of it together. :)
>And I'm not sure again that above assumption is related to this trigger report,
>since this may exist for a long time.
>
>So my question to mm folks is is above assumption possible and do we have
>any protection mechanism on this race?
>
>Thanks.
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
