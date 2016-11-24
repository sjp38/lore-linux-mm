Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id BA99C6B0069
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 09:22:29 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id y71so105961074pgd.0
        for <linux-mm@kvack.org>; Thu, 24 Nov 2016 06:22:29 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d75si8848510wmd.3.2016.11.24.06.22.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 24 Nov 2016 06:22:28 -0800 (PST)
Subject: Re: [PATCH] proc: mm: export PTE sizes directly in smaps (v2)
References: <20161117002851.C7BACB98@viggo.jf.intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <8769d52a-de0b-8c98-1e0b-e5305c5c02f3@suse.cz>
Date: Thu, 24 Nov 2016 15:22:23 +0100
MIME-Version: 1.0
In-Reply-To: <20161117002851.C7BACB98@viggo.jf.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>, linux-kernel@vger.kernel.org
Cc: hch@lst.de, akpm@linux-foundation.org, dan.j.williams@intel.com, khandual@linux.vnet.ibm.com, linux-mm@kvack.org

On 11/17/2016 01:28 AM, Dave Hansen wrote:
> Changes from v1:
>  * Do one 'Pte' line per pte size instead of mashing on one line
>  * Use PMD_SIZE for pmds instead of PAGE_SIZE, whoops
>  * Wrote some Documentation/
>
> --
>
> /proc/$pid/smaps has a number of fields that are intended to imply the
> kinds of PTEs used to map memory.  "AnonHugePages" obviously tells you
> how many PMDs are being used.  "MMUPageSize" along with the "Hugetlb"
> fields tells you how many PTEs you have for a huge page.
>
> The current mechanisms work fine when we have one or two page sizes.
> But, they start to get a bit muddled when we mix page sizes inside
> one VMA.  For instance, the DAX folks were proposing adding a set of
> fields like:
>
> 	DevicePages:
> 	DeviceHugePages:
> 	DeviceGiganticPages:
> 	DeviceGinormousPages:
>
> to unmuddle things when page sizes get mixed.  That's fine, but
> it does require userspace know the mapping from our various
> arbitrary names to hardware page sizes on each architecture and
> kernel configuration.  That seems rather suboptimal.
>
> What folks really want is to know how much memory is mapped with
> each page size.  How about we just do *that*?
>
> Patch attached.  Seems harmless enough.  Seems to compile on a
> bunch of random architectures.  Makes smaps look like this:
>
> Private_Hugetlb:       0 kB
> Swap:                  0 kB
> SwapPss:               0 kB
> KernelPageSize:        4 kB
> MMUPageSize:           4 kB
> Locked:                0 kB
> Ptes@4kB:	      32 kB
> Ptes@2MB:	    2048 kB
>
> The format I used here should be unlikely to break smaps parsers
> unless they're looking for "kB" and now match the 'Ptes@4kB' instead
> of the one at the end of the line.
>
> 1. I'd like to thank Dan Williams for showing me a mirror as I
>    complained about the bozo that introduced 'AnonHugePages'.
>
> Cc: Christoph Hellwig <hch@lst.de>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>
> Cc: linux-mm@kvack.org

Hmm, why not, I guess. But are HugeTLBs handled correctly?

> @@ -702,11 +707,13 @@ static int smaps_hugetlb_range(pte_t *pt
>  	}
>  	if (page) {
>  		int mapcount = page_mapcount(page);
> +		unsigned long hpage_size = huge_page_size(hstate_vma(vma));
>
> +		mss->rss_pud += hpage_size;

This hardcoded pud doesn't look right, doesn't the pmd/pud depend on 
hpage_size?

>  		if (mapcount >= 2)
> -			mss->shared_hugetlb += huge_page_size(hstate_vma(vma));
> +			mss->shared_hugetlb += hpage_size;
>  		else
> -			mss->private_hugetlb += huge_page_size(hstate_vma(vma));
> +			mss->private_hugetlb += hpage_size;
>  	}
>  	return 0;
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
