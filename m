Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id E2DAB6B0037
	for <linux-mm@kvack.org>; Fri, 20 Jun 2014 14:39:20 -0400 (EDT)
Received: by mail-ob0-f173.google.com with SMTP id va2so1510038obc.18
        for <linux-mm@kvack.org>; Fri, 20 Jun 2014 11:39:20 -0700 (PDT)
Received: from g4t3425.houston.hp.com (g4t3425.houston.hp.com. [15.201.208.53])
        by mx.google.com with ESMTPS id ci3si10716827oec.83.2014.06.20.11.39.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 20 Jun 2014 11:39:20 -0700 (PDT)
Message-ID: <1403289003.25108.3.camel@misato.fc.hp.com>
Subject: Re: [PATCH 2/2] x86,mem-hotplug: modify PGD entry when removing
 memory
From: Toshi Kani <toshi.kani@hp.com>
Date: Fri, 20 Jun 2014 12:30:03 -0600
In-Reply-To: <53A133ED.2090005@jp.fujitsu.com>
References: <53A132E2.9000605@jp.fujitsu.com>
	 <53A133ED.2090005@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: akpm@linux-foundation.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, tangchen@cn.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, guz.fnst@cn.fujitsu.com, zhangyanfei@cn.fujitsu.com

On Wed, 2014-06-18 at 15:38 +0900, Yasuaki Ishimatsu wrote:
 :
> @@ -186,7 +186,12 @@ void sync_global_pgds(unsigned long start, unsigned long end)
>  		const pgd_t *pgd_ref = pgd_offset_k(address);
>  		struct page *page;
> 
> -		if (pgd_none(*pgd_ref))
> +		/*
> +		 * When it is called after memory hot remove, pgd_none()
> +		 * returns true. In this case (removed == 1), we must clear
> +		 * the PGD entries in the local PGD level page.
> +		 */
> +		if (pgd_none(*pgd_ref) && !removed)
>  			continue;
> 
>  		spin_lock(&pgd_lock);
> @@ -199,12 +204,18 @@ void sync_global_pgds(unsigned long start, unsigned long end)
>  			pgt_lock = &pgd_page_get_mm(page)->page_table_lock;
>  			spin_lock(pgt_lock);
> 
> -			if (pgd_none(*pgd))
> -				set_pgd(pgd, *pgd_ref);
> -			else
> +			if (!pgd_none(*pgd_ref) && !pgd_none(*pgd))
>  				BUG_ON(pgd_page_vaddr(*pgd)
>  				       != pgd_page_vaddr(*pgd_ref));
> 
> +			if (removed) {

Shouldn't this condition be "else if"?

Thanks,
-Toshi

> +				if (pgd_none(*pgd_ref) && !pgd_none(*pgd))
> +					pgd_clear(pgd);
> +			} else {
> +				if (pgd_none(*pgd))
> +					set_pgd(pgd, *pgd_ref);
> +			}
> +
>  			spin_unlock(pgt_lock);
>  		}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
