Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id D8D7C6B0007
	for <linux-mm@kvack.org>; Fri,  6 Apr 2018 10:50:21 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id g61-v6so1044439plb.10
        for <linux-mm@kvack.org>; Fri, 06 Apr 2018 07:50:21 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id k5si7166867pgr.143.2018.04.06.07.50.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Apr 2018 07:50:20 -0700 (PDT)
Subject: Re: [PATCH v3 4/4] mm/sparse: Optimize memmap allocation during
 sparse_init()
References: <20180228032657.32385-1-bhe@redhat.com>
 <20180228032657.32385-5-bhe@redhat.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <5dd3942a-cf66-f749-b1c6-217b0c3c94dc@intel.com>
Date: Fri, 6 Apr 2018 07:50:18 -0700
MIME-Version: 1.0
In-Reply-To: <20180228032657.32385-5-bhe@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baoquan He <bhe@redhat.com>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, pagupta@redhat.com
Cc: linux-mm@kvack.org, kirill.shutemov@linux.intel.com

I'm having a really hard time tying all the pieces back together.  Let
me give it a shot and you can tell me where I go wrong.

On 02/27/2018 07:26 PM, Baoquan He wrote:
> In sparse_init(), two temporary pointer arrays, usemap_map and map_map
> are allocated with the size of NR_MEM_SECTIONS.

In sparse_init(), two temporary pointer arrays, usemap_map and map_map
are allocated to hold the maps for every possible memory section
(NR_MEM_SECTIONS).  However, we obviously only need the array sized for
nr_present_sections (introduced in patch 1).

The reason this is a problem is that, with 5-level paging,
NR_MEM_SECTIONS (8M->512M) went up dramatically and these temporary
arrays can eat all of memory, like on kdump kernels.

This patch does two things: it makes sure to give usemap_map/mem_map a
less gluttonous size on small systems, and it changes the map allocation
and handling to handle the now more compact, less sparse arrays.

---

The code looks fine to me.  It's a bit of a shame that there's no
verification to ensure that idx_present never goes beyond the shiny new
nr_present_sections.


> @@ -583,6 +592,7 @@ void __init sparse_init(void)
>  	unsigned long *usemap;
>  	unsigned long **usemap_map;
>  	int size;
> +	int idx_present = 0;

I wonder whether idx_present is a good name.  Isn't it the number of
consumed mem_map[]s or usemaps?

> 
>  		if (!map) {
>  			ms->section_mem_map = 0;
> +			idx_present++;
>  			continue;
>  		}
>  


This hunk seems logically odd to me.  I would expect a non-used section
to *not* consume an entry from the temporary array.  Why does it?  The
error and success paths seem to do the same thing.
