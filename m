Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 163976B0253
	for <linux-mm@kvack.org>; Wed, 10 Feb 2016 13:58:47 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id yy13so15995347pab.3
        for <linux-mm@kvack.org>; Wed, 10 Feb 2016 10:58:47 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id m81si6696633pfi.201.2016.02.10.10.58.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Feb 2016 10:58:46 -0800 (PST)
Date: Wed, 10 Feb 2016 10:58:45 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 3/3] mm/compaction: speed up pageblock_pfn_to_page()
 when zone is contiguous
Message-Id: <20160210105845.973cecc56906ed950fbdd8ba@linux-foundation.org>
In-Reply-To: <56BB3E61.50707@suse.cz>
References: <1454566775-30973-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1454566775-30973-3-git-send-email-iamjoonsoo.kim@lge.com>
	<20160204164929.a2f12b8a7edcdfa596abd850@linux-foundation.org>
	<CAAmzW4Pps1gSXb5qCvbkC=wNjcySgVYZu1jLeBWy31q7RNWVYg@mail.gmail.com>
	<56BA28C8.3060903@suse.cz>
	<20160209125301.c7e6067558c321cfb87602b5@linux-foundation.org>
	<56BB3E61.50707@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Joonsoo Kim <js1304@gmail.com>, Aaron Lu <aaron.lu@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Wed, 10 Feb 2016 14:42:57 +0100 Vlastimil Babka <vbabka@suse.cz> wrote:

> > --- a/mm/memory_hotplug.c
> > +++ b/mm/memory_hotplug.c
> > @@ -509,6 +509,8 @@ int __ref __add_pages(int nid, struct zone *zone, unsigned long phys_start_pfn,
> >  	int start_sec, end_sec;
> >  	struct vmem_altmap *altmap;
> >  
> > +	clear_zone_contiguous(zone);
> > +
> >  	/* during initialize mem_map, align hot-added range to section */
> >  	start_sec = pfn_to_section_nr(phys_start_pfn);
> >  	end_sec = pfn_to_section_nr(phys_start_pfn + nr_pages - 1);
> > @@ -540,6 +542,8 @@ int __ref __add_pages(int nid, struct zone *zone, unsigned long phys_start_pfn,
> >  	}
> >  	vmemmap_populate_print_last();
> >  
> > +	set_zone_contiguous(zone);
> > +
> >  	return err;
> >  }
> >  EXPORT_SYMBOL_GPL(__add_pages);
> 
> Between the clear and set, __add_pages() might return with -EINVAL,
> leaving the flag cleared potentially forever. Not critical, probably
> rare, but it should be possible to avoid this by moving the clear below
> the altmap check?

um, yes.  return-in-the-middle-of-a-function strikes again.

--- a/mm/memory_hotplug.c~mm-compaction-speed-up-pageblock_pfn_to_page-when-zone-is-contiguous-fix
+++ a/mm/memory_hotplug.c
@@ -526,7 +526,8 @@ int __ref __add_pages(int nid, struct zo
 		if (altmap->base_pfn != phys_start_pfn
 				|| vmem_altmap_offset(altmap) > nr_pages) {
 			pr_warn_once("memory add fail, invalid altmap\n");
-			return -EINVAL;
+			err = -EINVAL;
+			goto out;
 		}
 		altmap->alloc = 0;
 	}
@@ -544,9 +545,8 @@ int __ref __add_pages(int nid, struct zo
 		err = 0;
 	}
 	vmemmap_populate_print_last();
-
+out:
 	set_zone_contiguous(zone);
-
 	return err;
 }
 EXPORT_SYMBOL_GPL(__add_pages);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
