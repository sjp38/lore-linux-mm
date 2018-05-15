Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 45F7A6B0005
	for <linux-mm@kvack.org>; Tue, 15 May 2018 05:10:44 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id f35-v6so13534235plb.10
        for <linux-mm@kvack.org>; Tue, 15 May 2018 02:10:44 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f69-v6si5608226plb.503.2018.05.15.02.10.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 15 May 2018 02:10:43 -0700 (PDT)
Date: Tue, 15 May 2018 11:10:36 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm: allow deferred page init for vmemmap only
Message-ID: <20180515091036.GC12670@dhcp22.suse.cz>
References: <20180510115356.31164-1-pasha.tatashin@oracle.com>
 <20180510123039.GF5325@dhcp22.suse.cz>
 <CAGM2reZbYR96_uv-SB=5eL6tt0OSq9yXhtA-B2TGHbRQtfGU6g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGM2reZbYR96_uv-SB=5eL6tt0OSq9yXhtA-B2TGHbRQtfGU6g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, tglx@linutronix.de, Linux Memory Management List <linux-mm@kvack.org>, mgorman@techsingularity.net, mingo@kernel.org, peterz@infradead.org, Steven Rostedt <rostedt@goodmis.org>, Fengguang Wu <fengguang.wu@intel.com>, Dennis Zhou <dennisszhou@gmail.com>

On Fri 11-05-18 10:17:55, Pavel Tatashin wrote:
> > Thanks that helped me to see the problem. On the other hand isn't this a
> > bit of an overkill? AFAICS this affects only NEED_PER_CPU_KM which is !SMP
> > and DEFERRED_STRUCT_PAGE_INIT makes only very limited sense on UP,
> > right?
> 
> > Or do we have more such places?
> 
> I do not know other places, but my worry is that trap_init() is arch
> specific and we cannot guarantee that arches won't do virt to phys in
> trap_init() in other places. Therefore, I think a proper fix is simply
> allow DEFERRED_STRUCT_PAGE_INIT when it is safe to do virt to phys without
> accessing struct pages, which is with SPARSEMEM_VMEMMAP.

You are now disabling a potentially useful feature to SPARSEMEM users
without having any evidence that they do suffer from the issue which is
kinda sad. Especially when the only known offender is a UP pcp allocator
implementation.

I will not insist of course but it seems like your fix doesn't really
prevent virt_to_page or other direct page access either.
-- 
Michal Hocko
SUSE Labs
