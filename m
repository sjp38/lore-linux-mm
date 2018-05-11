Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id ED1CF6B0667
	for <linux-mm@kvack.org>; Fri, 11 May 2018 10:18:37 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id i200-v6so1637922itb.9
        for <linux-mm@kvack.org>; Fri, 11 May 2018 07:18:37 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id l14-v6si2776264iol.88.2018.05.11.07.18.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 May 2018 07:18:36 -0700 (PDT)
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w4BEGvuN097045
	for <linux-mm@kvack.org>; Fri, 11 May 2018 14:18:35 GMT
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp2120.oracle.com with ESMTP id 2hwab5gmxh-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 11 May 2018 14:18:35 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w4BEIXwJ006209
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 11 May 2018 14:18:33 GMT
Received: from abhmp0015.oracle.com (abhmp0015.oracle.com [141.146.116.21])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w4BEIXKP010280
	for <linux-mm@kvack.org>; Fri, 11 May 2018 14:18:33 GMT
Received: by mail-oi0-f41.google.com with SMTP id 11-v6so4835864ois.8
        for <linux-mm@kvack.org>; Fri, 11 May 2018 07:18:32 -0700 (PDT)
MIME-Version: 1.0
References: <20180510115356.31164-1-pasha.tatashin@oracle.com> <20180510123039.GF5325@dhcp22.suse.cz>
In-Reply-To: <20180510123039.GF5325@dhcp22.suse.cz>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Fri, 11 May 2018 10:17:55 -0400
Message-ID: <CAGM2reZbYR96_uv-SB=5eL6tt0OSq9yXhtA-B2TGHbRQtfGU6g@mail.gmail.com>
Subject: Re: [PATCH v2] mm: allow deferred page init for vmemmap only
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, tglx@linutronix.de, Linux Memory Management List <linux-mm@kvack.org>, mgorman@techsingularity.net, mingo@kernel.org, peterz@infradead.org, Steven Rostedt <rostedt@goodmis.org>, Fengguang Wu <fengguang.wu@intel.com>, Dennis Zhou <dennisszhou@gmail.com>

> Thanks that helped me to see the problem. On the other hand isn't this a
> bit of an overkill? AFAICS this affects only NEED_PER_CPU_KM which is !SMP
> and DEFERRED_STRUCT_PAGE_INIT makes only very limited sense on UP,
> right?

> Or do we have more such places?

I do not know other places, but my worry is that trap_init() is arch
specific and we cannot guarantee that arches won't do virt to phys in
trap_init() in other places. Therefore, I think a proper fix is simply
allow DEFERRED_STRUCT_PAGE_INIT when it is safe to do virt to phys without
accessing struct pages, which is with SPARSEMEM_VMEMMAP.
