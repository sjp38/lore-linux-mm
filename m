Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8E7E56B0266
	for <linux-mm@kvack.org>; Sun,  1 Jul 2018 22:18:48 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id d7-v6so16931461qth.21
        for <linux-mm@kvack.org>; Sun, 01 Jul 2018 19:18:48 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id g3-v6si651154qva.235.2018.07.01.19.18.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Jul 2018 19:18:47 -0700 (PDT)
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w622DQNB081735
	for <linux-mm@kvack.org>; Mon, 2 Jul 2018 02:18:46 GMT
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp2120.oracle.com with ESMTP id 2jx2gpthfk-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Mon, 02 Jul 2018 02:18:46 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w622IjDj014623
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Mon, 2 Jul 2018 02:18:45 GMT
Received: from abhmp0002.oracle.com (abhmp0002.oracle.com [141.146.116.8])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w622Ijj1010800
	for <linux-mm@kvack.org>; Mon, 2 Jul 2018 02:18:45 GMT
Received: by mail-oi0-f45.google.com with SMTP id i12-v6so9146716oik.2
        for <linux-mm@kvack.org>; Sun, 01 Jul 2018 19:18:44 -0700 (PDT)
MIME-Version: 1.0
References: <20180702020417.21281-1-pasha.tatashin@oracle.com>
 <20180702020417.21281-2-pasha.tatashin@oracle.com> <20180702021121.GL3223@MiWiFi-R3L-srv>
In-Reply-To: <20180702021121.GL3223@MiWiFi-R3L-srv>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Sun, 1 Jul 2018 22:18:08 -0400
Message-ID: <CAGM2rebY1_-3hvp_+kqF==nLawC0FN6Q1J5X5pm5qxHdDJzjiQ@mail.gmail.com>
Subject: Re: [PATCH v3 1/2] mm/sparse: add sparse_init_nid()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bhe@redhat.com
Cc: Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, kirill.shutemov@linux.intel.com, Michal Hocko <mhocko@suse.com>, Linux Memory Management List <linux-mm@kvack.org>, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, Souptick Joarder <jrdr.linux@gmail.com>, gregkh@linuxfoundation.org, Vlastimil Babka <vbabka@suse.cz>, Wei Yang <richard.weiyang@gmail.com>, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org, osalvador@techadventures.net

> Here, I think it might be not right to jump to 'failed' directly if one
> section of the node failed to populate memmap. I think the original code
> is only skipping the section which memmap failed to populate by marking
> it as not present with "ms->section_mem_map = 0".
>

Hi Baoquan,

Thank you for a careful review. This is an intended change compared to
the original code. Because we operate per-node now, if we fail to
allocate a single section, in this node, it means we also will fail to
allocate all the consequent sections in the same node and no need to
check them anymore. In the original code we could not simply bailout,
because we still might have valid entries in the following nodes.
Similarly, sparse_init() will call sparse_init_nid() for the next node
even if previous node failed to setup all the memory.

Pavel
