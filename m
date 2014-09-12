Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 009206B003C
	for <linux-mm@kvack.org>; Fri, 12 Sep 2014 15:34:00 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id hz1so1942256pad.7
        for <linux-mm@kvack.org>; Fri, 12 Sep 2014 12:34:00 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id m5si9687643pap.159.2014.09.12.12.33.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 12 Sep 2014 12:34:00 -0700 (PDT)
Date: Fri, 12 Sep 2014 15:33:45 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH v2 1/6] x86, mm, pat: Set WT to PA4 slot of PAT MSR
Message-ID: <20140912193345.GH15656@laptop.dumpdata.com>
References: <1410367910-6026-1-git-send-email-toshi.kani@hp.com>
 <1410367910-6026-2-git-send-email-toshi.kani@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1410367910-6026-2-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, hmh@hmh.eng.br, yigal@plexistor.com

> -	/* Set PWT to Write-Combining. All other bits stay the same */
> -	/*
> -	 * PTE encoding used in Linux:
> -	 *      PAT
> -	 *      |PCD
> -	 *      ||PWT
> -	 *      |||
> -	 *      000 WB		_PAGE_CACHE_WB
> -	 *      001 WC		_PAGE_CACHE_WC
> -	 *      010 UC-		_PAGE_CACHE_UC_MINUS
> -	 *      011 UC		_PAGE_CACHE_UC


I think having this nice picture would be beneficial to folks
who want to understand it. And now you can of course expand it with
the slot 7 usage.

> -	 * PAT bit unused
> -	 */
> -	pat = PAT(0, WB) | PAT(1, WC) | PAT(2, UC_MINUS) | PAT(3, UC) |
> -	      PAT(4, WB) | PAT(5, WC) | PAT(6, UC_MINUS) | PAT(7, UC);
> +	if ((c->x86_vendor == X86_VENDOR_INTEL) &&
> +	    (((c->x86 == 0x6) && (c->x86_model <= 0xd)) ||
> +	     ((c->x86 == 0xf) && (c->x86_model <= 0x6)))) {
> +		/*
> +		 * Intel Pentium 2, 3, M, and 4 are affected by PAT errata,
> +		 * which makes the upper four entries unusable.  We do not
> +		 * use the upper four entries for all the affected processor
> +		 * families for safe.
> +		 *
> +		 * PAT 0:WB, 1:WC, 2:UC-, 3:UC, 4-7:unusable
> +		 *
> +		 * NOTE: When WT or WP is used, it is redirected to UC- per
> +		 * the default setup in  __cachemode2pte_tbl[].
> +		 */
> +		pat = PAT(0, WB) | PAT(1, WC) | PAT(2, UC_MINUS) | PAT(3, UC) |
> +		      PAT(4, WB) | PAT(5, WC) | PAT(6, UC_MINUS) | PAT(7, UC);
> +	} else {
> +		/*
> +		 * WT is set to slot 7, which minimizes the risk of using

You say slot 7 here, but the title of the patch says slot 4?

> +		 * the PAT bit as slot 3 is UC and is currently unused.
> +		 * Slot 4 should remain as reserved.
> +		 *
> +		 * PAT 0:WB, 1:WC, 2:UC-, 3:UC, 4-6:reserved, 7:WT
> +		 */
> +		pat = PAT(0, WB) | PAT(1, WC) | PAT(2, UC_MINUS) | PAT(3, UC) |
> +		      PAT(4, WB) | PAT(5, WC) | PAT(6, UC_MINUS) | PAT(7, WT);
> +	}
>  
>  	/* Boot CPU check */
>  	if (!boot_pat_state)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
