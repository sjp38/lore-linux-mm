Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id ACE716B0035
	for <linux-mm@kvack.org>; Sat,  5 Jul 2014 04:13:39 -0400 (EDT)
Received: by mail-ig0-f169.google.com with SMTP id c1so8996945igq.2
        for <linux-mm@kvack.org>; Sat, 05 Jul 2014 01:13:39 -0700 (PDT)
Received: from mx0b-0016f401.pphosted.com (mx0b-0016f401.pphosted.com. [67.231.156.173])
        by mx.google.com with ESMTPS id f1si33121826igq.54.2014.07.05.01.13.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 05 Jul 2014 01:13:38 -0700 (PDT)
Received: from pps.filterd (m0045851.ppops.net [127.0.0.1])
	by mx0b-0016f401.pphosted.com (8.14.5/8.14.5) with SMTP id s658Dbs6012706
	for <linux-mm@kvack.org>; Sat, 5 Jul 2014 01:13:37 -0700
Received: from sc-owa01.marvell.com ([199.233.58.136])
	by mx0b-0016f401.pphosted.com with ESMTP id 1mwtmx9y8q-1
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 05 Jul 2014 01:13:37 -0700
From: Lisa Du <cldu@marvell.com>
Date: Sat, 5 Jul 2014 01:13:17 -0700
Subject: NR_FREE_CMA_PAGES larger than total CMA size
Message-ID: <89813612683626448B837EE5A0B6A7CB455AEB75CF@SC-VEXCH4.marvell.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>

Dear Sir
Recently I met one issue that after system run for a long time, free cma pa=
ges recorded
in vm_stat[NR_FREE_CMA_PAGES] are larger than total CMA size declared.
For example, I declared 64MB CMA size, but found free cma was 70MB.

I added some trace to track how it happen, and found the reason maybe like =
below:
1) alloc_contig_range() want to allocate a range [start, end], for example =
[0x1e040, 0x1e050];

2) start_isolate_page_range() will isolate the range [pfn_max_align_down(st=
art),
  pfn_max_align_up(end)]; for this example it's [0x1e000, 0x1e400] (MAX_ORD=
ER is 11);

3) drain_all_pages() would be called as follows, if there's some pages belo=
ng to the range
  [0x1e000, 0x1e400] was freed from the pcp_list, also if the page was MIGR=
ATE_CMA,
  then vm_stat[NR_FREE_CMA_PAGES] would increase and also NR_FREE_PAGES;

4) if the freed pages in #3 was not the range of [start, end], then at last=
 undo_isolate_page_range()
  will be called, and the pages would be calculated again as free pages in =
unset_migratetype_isolate(),
  and __mod_zone_freepage_state() will increased again for these pages for =
both NR_FREE_CMA_PAGES
  and NR_FREE_PAGES.=20
  The function calling flow as below, the free pages in move_freepages() wa=
s calculated again.
  undo_isolate_page_range()
	--> unset_migratetype_isolate()
		--> move_freepages_block()
			--> move_freepages()
	--> __mod_zone_freepage_state()

Shall we add some check in move_freepages() if the page was already in CMA =
free list,=20
then exclude it from the pages_moved?

I found this issue in kernel v3.4, but seems there's no fix in latest kerne=
l code base.
Not sure if anyone else has met such issue? Anyone would help to comment? T=
hanks a lot!

Thanks!

Best Regards
Lisa Du

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
