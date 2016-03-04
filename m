Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id DD41A6B007E
	for <linux-mm@kvack.org>; Fri,  4 Mar 2016 09:11:55 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id p65so30886722wmp.0
        for <linux-mm@kvack.org>; Fri, 04 Mar 2016 06:11:55 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ld8si4199069wjc.77.2016.03.04.06.11.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 04 Mar 2016 06:11:54 -0800 (PST)
Subject: Re: [PATCH v2] mm: exclude ZONE_DEVICE from GFP_ZONE_TABLE
References: <20160302002829.38211.89593.stgit@dwillia2-desk3.amr.corp.intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56D997A6.7070200@suse.cz>
Date: Fri, 4 Mar 2016 15:11:50 +0100
MIME-Version: 1.0
In-Reply-To: <20160302002829.38211.89593.stgit@dwillia2-desk3.amr.corp.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, akpm@linux-foundation.org
Cc: Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Mark <markk@clara.co.uk>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Sudip Mukherjee <sudipm.mukherjee@gmail.com>

On 03/02/2016 01:32 AM, Dan Williams wrote:
> ZONE_DEVICE (merged in 4.3) and ZONE_CMA (proposed) are examples of new
> mm zones that are bumping up against the current maximum limit of 4
> zones, i.e. 2 bits in page->flags for the GFP_ZONE_TABLE.
> 
> The GFP_ZONE_TABLE poses an interesting constraint since
> include/linux/gfp.h gets included by the 32-bit portion of a 64-bit
> build.  We need to be careful to only build the table for zones that
> have a corresponding gfp_t flag.  GFP_ZONES_SHIFT is introduced for this
> purpose.  This patch does not attempt to solve the problem of adding a
> new zone that also has a corresponding GFP_ flag.
> 
> Vlastimil points out that ZONE_DEVICE, by depending on x86_64 and
> SPARSEMEM_VMEMMAP implies that SECTIONS_WIDTH is zero.  In other words

                                                       ^ by default

Because CONFIG_SPARSEMEM_VMEMMAP can still be disabled by the user.

> even though ZONE_DEVICE does not fit in GFP_ZONE_TABLE it is free to
> consume another bit in page->flags (expand ZONES_WIDTH) with room to
> spare.

So it's still possible to configure the x86_64 kernel such that you get
"#warning Unfortunate NUMA and NUMA Balancing config". But it requires
some effort to override the defaults, and it's not breaking build or
runtime. BTW I was able to get that warning even with your previous
patch that limited NODES_WIDTH, so that wasn't a solution for this
anyway. This patch is simpler and better.

> Link: https://bugzilla.kernel.org/show_bug.cgi?id=110931
> Fixes: 033fbae988fc ("mm: ZONE_DEVICE for "device memory"")
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
> Reported-by: Mark <markk@clara.co.uk>
> Reported-by: Vlastimil Babka <vbabka@suse.cz>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
