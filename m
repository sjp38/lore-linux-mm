Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7DC0B6B0007
	for <linux-mm@kvack.org>; Fri, 27 Jul 2018 10:54:06 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id z9-v6so3777149iom.14
        for <linux-mm@kvack.org>; Fri, 27 Jul 2018 07:54:06 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id f11-v6si2901275ioa.223.2018.07.27.07.54.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Jul 2018 07:54:05 -0700 (PDT)
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w6REiCFN132185
	for <linux-mm@kvack.org>; Fri, 27 Jul 2018 14:54:04 GMT
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp2120.oracle.com with ESMTP id 2kbwfq7hdg-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 27 Jul 2018 14:54:04 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w6REs1wt003152
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 27 Jul 2018 14:54:01 GMT
Received: from abhmp0009.oracle.com (abhmp0009.oracle.com [141.146.116.15])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w6REs0Q7018313
	for <linux-mm@kvack.org>; Fri, 27 Jul 2018 14:54:01 GMT
Received: by mail-oi0-f52.google.com with SMTP id n84-v6so9515382oib.9
        for <linux-mm@kvack.org>; Fri, 27 Jul 2018 07:54:00 -0700 (PDT)
MIME-Version: 1.0
References: <20180726193509.3326-1-pasha.tatashin@oracle.com>
 <20180726193509.3326-3-pasha.tatashin@oracle.com> <20180727115645.GA13637@techadventures.net>
In-Reply-To: <20180727115645.GA13637@techadventures.net>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Fri, 27 Jul 2018 10:53:24 -0400
Message-ID: <CAGM2reZnrwy1Y8MFRgyDLG8VZ6Hf+v-PAmZvUG4H65zunmjWZw@mail.gmail.com>
Subject: Re: [PATCH v2 2/3] mm: calculate deferred pages after skipping
 mirrored memory
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@techadventures.net
Cc: Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, kirill.shutemov@linux.intel.com, Michal Hocko <mhocko@suse.com>, Linux Memory Management List <linux-mm@kvack.org>, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, Souptick Joarder <jrdr.linux@gmail.com>, bhe@redhat.com, gregkh@linuxfoundation.org, Vlastimil Babka <vbabka@suse.cz>, Wei Yang <richard.weiyang@gmail.com>, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org, abdhalee@linux.vnet.ibm.com, mpe@ellerman.id.au

                         unsigned long *nr_initialised)
> > +static bool __meminit
> > +defer_init(int nid, unsigned long pfn, unsigned long end_pfn)
>
> Hi Pavel,
>
> maybe I do not understand properly the __init/__meminit macros, but should not
> "defer_init" be __init instead of __meminit?
> I think that functions marked as __meminit are not freed up, right?

Not exactly. As I understand: __meminit is the same as __init when
CONFIG_MEMORY_HOTPLUG=n. But, when memory hotplug is configured,
__meminit is not freed, because code that adds memory is shared
between boot and hotplug. In this case defer_init() is called only
during boot, and could be __init, but it is called from
memmap_init_zone() which is __meminit and thus section mismatch would
happen.

We could split memmap_init_zone() into two functions: boot and hotplug
variants, or we could use __ref, but I do not think any of that is
really needed. Keeping defer_init() in __meminit is OK, it does not
take that much memory.

>
> Reviewed-by: Oscar Salvador <osalvador@suse.de>

Thank you,
Pavel
