Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id DCF526B0253
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 12:29:25 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id y134so49407763pfg.1
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 09:29:25 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id tz3si5260456pab.81.2016.07.13.09.29.25
        for <linux-mm@kvack.org>;
        Wed, 13 Jul 2016 09:29:25 -0700 (PDT)
Subject: Re: [PATCH 4/4] x86: use pte_none() to test for empty PTE
References: <20160708001909.FB2443E2@viggo.jf.intel.com>
 <20160708001915.813703D9@viggo.jf.intel.com>
 <20160713151820.GA20693@dhcp22.suse.cz>
 <alpine.DEB.2.10.1607131746570.2959@hadrien>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <57866C22.4040402@intel.com>
Date: Wed, 13 Jul 2016 09:28:18 -0700
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1607131746570.2959@hadrien>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Julia Lawall <julia.lawall@lip6.fr>, Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, bp@alien8.de, ak@linux.intel.com, dave.hansen@intel.com, David Howells <dhowells@redhat.com>

On 07/13/2016 08:49 AM, Julia Lawall wrote:
> My results are below.  There are a couple of cases in arch/mn10300/mm that
> were not in the original patch.

Yeah, so mn10300 is obviously unaffected by the erratum in question, and
I didn't look for non-x86 architectures for this patch.

But, this code definitely _looks_ like it should be using pte_none(),
especially since mn10300 defines it the same way as x86 (well, as x86
_did_ before this series).

	#define pte_none(x)		(!pte_val(x))

> diff -u -p a/arch/mn10300/mm/cache-inv-icache.c b/arch/mn10300/mm/cache-inv-icache.c
> --- a/arch/mn10300/mm/cache-inv-icache.c
> +++ b/arch/mn10300/mm/cache-inv-icache.c
> @@ -45,11 +45,11 @@ static void flush_icache_page_range(unsi
>  		return;
> 
>  	pud = pud_offset(pgd, start);
> -	if (!pud || !pud_val(*pud))
> +	if (!pud || pud_none(*pud))
>  		return;
> 
>  	pmd = pmd_offset(pud, start);
> -	if (!pmd || !pmd_val(*pmd))
> +	if (!pmd || pmd_none(*pmd))
>  		return;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
