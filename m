Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id E99716B0003
	for <linux-mm@kvack.org>; Sun,  1 Jul 2018 23:04:03 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id b129-v6so973925iti.4
        for <linux-mm@kvack.org>; Sun, 01 Jul 2018 20:04:03 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id k201-v6si4640062ite.141.2018.07.01.20.04.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Jul 2018 20:04:02 -0700 (PDT)
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w62342eR103778
	for <linux-mm@kvack.org>; Mon, 2 Jul 2018 03:04:02 GMT
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by userp2130.oracle.com with ESMTP id 2jx19sjp9j-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Mon, 02 Jul 2018 03:04:02 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w62341Ha017688
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Mon, 2 Jul 2018 03:04:01 GMT
Received: from abhmp0003.oracle.com (abhmp0003.oracle.com [141.146.116.9])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w62341hw025419
	for <linux-mm@kvack.org>; Mon, 2 Jul 2018 03:04:01 GMT
Received: by mail-oi0-f50.google.com with SMTP id n84-v6so13683057oib.9
        for <linux-mm@kvack.org>; Sun, 01 Jul 2018 20:04:00 -0700 (PDT)
MIME-Version: 1.0
References: <20180702020417.21281-1-pasha.tatashin@oracle.com>
 <20180702020417.21281-2-pasha.tatashin@oracle.com> <20180702021121.GL3223@MiWiFi-R3L-srv>
 <CAGM2rebY1_-3hvp_+kqF==nLawC0FN6Q1J5X5pm5qxHdDJzjiQ@mail.gmail.com>
 <20180702023130.GM3223@MiWiFi-R3L-srv> <CAGM2rebUsJ2r-2F38Vv13zbaEPPgTn0w6H3j6fpg0WVa9wB6Uw@mail.gmail.com>
 <20180702025343.GN3223@MiWiFi-R3L-srv>
In-Reply-To: <20180702025343.GN3223@MiWiFi-R3L-srv>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Sun, 1 Jul 2018 23:03:24 -0400
Message-ID: <CAGM2reatQzroymAb8kaPKgd8sEehtScH9DAELeWpYCaNNnAU6w@mail.gmail.com>
Subject: Re: [PATCH v3 1/2] mm/sparse: add sparse_init_nid()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bhe@redhat.com
Cc: Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, kirill.shutemov@linux.intel.com, Michal Hocko <mhocko@suse.com>, Linux Memory Management List <linux-mm@kvack.org>, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, Souptick Joarder <jrdr.linux@gmail.com>, gregkh@linuxfoundation.org, Vlastimil Babka <vbabka@suse.cz>, Wei Yang <richard.weiyang@gmail.com>, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org, osalvador@techadventures.net

> Ah, yes, I misunderstood it, sorry for that.
>
> Then I have only one concern, for vmemmap case, if one section doesn't
> succeed to populate its memmap, do we need to skip all the remaining
> sections in that node?

Yes, in sparse_populate_node() we have the following:

294         for (pnum = pnum_begin; map_index < map_count; pnum++) {
295                 if (!present_section_nr(pnum))
296                         continue;
297                 if (!sparse_mem_map_populate(pnum, nid, NULL))
298                         break;

So, on the first failure, we even stop trying to populate other
sections. No more memory to do so.

Pavel
