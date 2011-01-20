Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 294E28D003A
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 12:22:21 -0500 (EST)
Received: from d01dlp02.pok.ibm.com (d01dlp02.pok.ibm.com [9.56.224.85])
	by e4.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p0KH3wrC015305
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 12:04:04 -0500
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 17B384DE80AA
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 12:17:38 -0500 (EST)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p0KHKvB8398276
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 12:20:57 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p0KHKvKp006016
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 15:20:57 -0200
Subject: Re: [PATCH] ARM: mm: Regarding section when dealing with meminfo
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <1295516739-9839-1-git-send-email-pullip.cho@samsung.com>
References: <1295516739-9839-1-git-send-email-pullip.cho@samsung.com>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Thu, 20 Jan 2011 09:20:47 -0800
Message-ID: <1295544047.9039.609.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KyongHo Cho <pullip.cho@samsung.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-samsung-soc@vger.kernel.org, Kukjin Kim <kgene.kim@samsung.com>, Ilho Lee <ilho215.lee@samsung.com>, KeyYoung Park <keyyoung.park@samsung.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2011-01-20 at 18:45 +0900, KyongHo Cho wrote:
> Sparsemem allows that a bank of memory spans over several adjacent
> sections if the start address and the end address of the bank
> belong to different sections.
> When gathering statictics of physical memory in mem_init() and
> show_mem(), this possiblity was not considered.
> 
> This patch guarantees that simple increasing the pointer to page
> descriptors does not exceed the boundary of a section
...
> diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
> index 57c4c5c..6ccecbe 100644
> --- a/arch/arm/mm/init.c
> +++ b/arch/arm/mm/init.c
> @@ -93,24 +93,38 @@ void show_mem(void)
> 
>  		pfn1 = bank_pfn_start(bank);
>  		pfn2 = bank_pfn_end(bank);
> -
> +#ifndef CONFIG_SPARSEMEM
>  		page = pfn_to_page(pfn1);
>  		end  = pfn_to_page(pfn2 - 1) + 1;
> -
> +#else
> +		pfn2--;
>  		do {
> -			total++;
> -			if (PageReserved(page))
> -				reserved++;
> -			else if (PageSwapCache(page))
> -				cached++;
> -			else if (PageSlab(page))
> -				slab++;
> -			else if (!page_count(page))
> -				free++;
> -			else
> -				shared += page_count(page) - 1;
> -			page++;
> -		} while (page < end);
> +			page = pfn_to_page(pfn1);
> +			if (pfn_to_section_nr(pfn1) < pfn_to_section_nr(pfn2)) {
> +				pfn1 += PAGES_PER_SECTION;
> +				pfn1 &= PAGE_SECTION_MASK;
> +			} else {
> +				pfn1 = pfn2;
> +			}
> +			end = pfn_to_page(pfn1) + 1;
> +#endif

This problem actually exists without sparsemem, too.  Discontigmem (at
least) does it as well.

The x86 version of show_mem() actually manages to do this without any
#ifdefs, and works for a ton of configuration options.  It uses
pfn_valid() to tell whether it can touch a given pfn.

Long-term, it might be a good idea to convert arm's show_mem() over to
use pgdat's like everything else.  But, for now, you should just be able
to do something roughly like this:

-               page = pfn_to_page(pfn1);
-               end  = pfn_to_page(pfn2 - 1) + 1;
-
-               do {
+		for (pfn = pfn1; pfn < pfn2; pfn++) {
+			if (!pfn_valid(pfn))
+				continue;
+			page = pfn_to_page(pfn);
+
                        total++;
                        if (PageReserved(page))
                                reserved++;
                        else if (PageSwapCache(page))
                                cached++;
                        else if (PageSlab(page))
                                slab++;
                        else if (!page_count(page))
                                free++;
                        else
                                shared += page_count(page) - 1;
                        page++;
-               } while (page < end);
+		}

That should work for sparsemem, or any other crazy memory models that we
come up with.  pfn_to_page() is pretty quick, especially when doing it
in a tight loop like that.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
