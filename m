Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 14F986B0269
	for <linux-mm@kvack.org>; Sun,  1 Jul 2018 21:47:16 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id d70-v6so6609831itd.1
        for <linux-mm@kvack.org>; Sun, 01 Jul 2018 18:47:16 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id i83-v6si4706929ita.117.2018.07.01.18.47.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Jul 2018 18:47:15 -0700 (PDT)
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w621kto1099064
	for <linux-mm@kvack.org>; Mon, 2 Jul 2018 01:47:14 GMT
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by aserp2120.oracle.com with ESMTP id 2jx1tnthby-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Mon, 02 Jul 2018 01:47:14 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w621lDuG000683
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Mon, 2 Jul 2018 01:47:13 GMT
Received: from abhmp0010.oracle.com (abhmp0010.oracle.com [141.146.116.16])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w621lDFq015824
	for <linux-mm@kvack.org>; Mon, 2 Jul 2018 01:47:13 GMT
Received: by mail-oi0-f53.google.com with SMTP id w126-v6so6180041oie.7
        for <linux-mm@kvack.org>; Sun, 01 Jul 2018 18:47:12 -0700 (PDT)
MIME-Version: 1.0
References: <20180630030944.9335-1-pasha.tatashin@oracle.com>
 <20180630030944.9335-3-pasha.tatashin@oracle.com> <20180702013918.GJ3223@MiWiFi-R3L-srv>
In-Reply-To: <20180702013918.GJ3223@MiWiFi-R3L-srv>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Sun, 1 Jul 2018 21:46:36 -0400
Message-ID: <CAGM2reYRYNOe0nweMrSxLZ_RRQbu500iSRKWrbO4_CzyWTEtjQ@mail.gmail.com>
Subject: Re: [PATCH v2 2/2] mm/sparse: start using sparse_init_nid(), and
 remove old code
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bhe@redhat.com
Cc: Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, kirill.shutemov@linux.intel.com, Michal Hocko <mhocko@suse.com>, Linux Memory Management List <linux-mm@kvack.org>, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, Souptick Joarder <jrdr.linux@gmail.com>, gregkh@linuxfoundation.org, Vlastimil Babka <vbabka@suse.cz>, Wei Yang <richard.weiyang@gmail.com>, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org, osalvador@techadventures.net

                         ~~~
> Here, node id passed to sparse_init_nid() should be 'nid_begin', but not
> 'nid'. When you found out the current section's 'nid' is diferent than
> 'nid_begin', handle node 'nid_begin', then start to next node 'nid'.

Thank you for reviewing this work. Here nid equals to nid_begin:

See, "if" at 501, and this call is at 505.

492 void __init sparse_init(void)
493 {
494         unsigned long pnum_begin = first_present_section_nr();
495         int nid_begin = sparse_early_nid(__nr_to_section(pnum_begin));
496         unsigned long pnum_end, map_count = 1;
497
498         for_each_present_section_nr(pnum_begin + 1, pnum_end) {
499                 int nid = sparse_early_nid(__nr_to_section(pnum_end));
500
501                 if (nid == nid_begin) {
502                         map_count++;
503                         continue;
504                 }
505                 sparse_init_nid(nid, pnum_begin, pnum_end, map_count);
506                 nid_begin = nid;
507                 pnum_begin = pnum_end;
508                 map_count = 1;
509         }
510         sparse_init_nid(nid_begin, pnum_begin, pnum_end, map_count);
511         vmemmap_populate_print_last();
512 }

Thank you,
Pavel
