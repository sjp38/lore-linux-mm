Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 34F9A6B0008
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 21:19:56 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id u22-v6so5217952qkk.10
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 18:19:56 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id a63-v6si1436364qkh.63.2018.07.24.18.19.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jul 2018 18:19:55 -0700 (PDT)
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w6P1Js4X154204
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 01:19:54 GMT
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by userp2120.oracle.com with ESMTP id 2kbwfpuby8-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 01:19:54 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w6P1JqPw018295
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 01:19:53 GMT
Received: from abhmp0019.oracle.com (abhmp0019.oracle.com [141.146.116.25])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w6P1Jq7x002839
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 01:19:52 GMT
Received: by mail-oi0-f53.google.com with SMTP id i12-v6so11019148oik.2
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 18:19:52 -0700 (PDT)
MIME-Version: 1.0
References: <20180724235520.10200-1-pasha.tatashin@oracle.com>
 <20180724235520.10200-3-pasha.tatashin@oracle.com> <20180724181218.13a1ed1d7a3e9a37e35707a9@linux-foundation.org>
In-Reply-To: <20180724181218.13a1ed1d7a3e9a37e35707a9@linux-foundation.org>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Tue, 24 Jul 2018 21:19:11 -0400
Message-ID: <CAGM2reb9CLpq1cqPLVqYXEfUqBtCt4V0OL_F=CKCyJXqV88NcQ@mail.gmail.com>
Subject: Re: [PATCH 2/3] mm: calculate deferred pages after skipping mirrored memory
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, LKML <linux-kernel@vger.kernel.org>, kirill.shutemov@linux.intel.com, Michal Hocko <mhocko@suse.com>, Linux Memory Management List <linux-mm@kvack.org>, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, Souptick Joarder <jrdr.linux@gmail.com>, bhe@redhat.com, gregkh@linuxfoundation.org, Vlastimil Babka <vbabka@suse.cz>, Wei Yang <richard.weiyang@gmail.com>, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org, osalvador@techadventures.net, abdhalee@linux.vnet.ibm.com, mpe@ellerman.id.au

On Tue, Jul 24, 2018 at 9:12 PM Andrew Morton <akpm@linux-foundation.org> wrote:
>
> On Tue, 24 Jul 2018 19:55:19 -0400 Pavel Tatashin <pasha.tatashin@oracle.com> wrote:
>
> > update_defer_init() should be called only when struct page is about to be
> > initialized. Because it counts number of initialized struct pages, but
> > there we may skip struct pages if there is some mirrored memory.
>
> What are the runtime effects of this error?

I found this bug by reading the code. The effect is that fewer than
expected struct pages are initialized early in boot, and it is
possible that in some corner cases we may fail to boot when mirrored
pages are used. The deferred on demand code should somewhat mitigate
this. But, this still brings some inconsistencies compared to when
booting without mirrored pages, so it is better to fix.

Pavel
