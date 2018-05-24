Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1449A6B000A
	for <linux-mm@kvack.org>; Thu, 24 May 2018 10:39:59 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id p19-v6so1108450plo.14
        for <linux-mm@kvack.org>; Thu, 24 May 2018 07:39:59 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t1-v6si21850380plb.90.2018.05.24.07.39.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 24 May 2018 07:39:58 -0700 (PDT)
Date: Thu, 24 May 2018 16:39:53 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v1 09/10] mm/memory_hotplug: teach offline_pages() to not
 try forever
Message-ID: <20180524143953.GK20441@dhcp22.suse.cz>
References: <20180523151151.6730-1-david@redhat.com>
 <20180523151151.6730-10-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180523151151.6730-10-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rashmica Gupta <rashmica.g@gmail.com>, Balbir Singh <bsingharora@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Dan Williams <dan.j.williams@intel.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>

[I didn't really go through other patch but this one caught my eyes just
 because of the similar request proposed yesterday]

On Wed 23-05-18 17:11:50, David Hildenbrand wrote:
[...]
> @@ -1686,6 +1686,10 @@ static int __ref __offline_pages(unsigned long start_pfn,
>  	pfn = scan_movable_pages(start_pfn, end_pfn);
>  	if (pfn) { /* We have movable pages */
>  		ret = do_migrate_range(pfn, end_pfn);
> +		if (ret && !retry_forever) {
> +			ret = -EBUSY;
> +			goto failed_removal;
> +		}
>  		goto repeat;
>  	}
>  

Btw. this will not work in practice. Even a single temporary pin on a page
will fail way too easily. If you really need to control this then make
it a retry counter with default -1UL.

We really do need a better error reporting from do_migrate_range and
distinguish transient from permanent failures. In general we shouldn't
even get here for pages which are not migrateable...
-- 
Michal Hocko
SUSE Labs
