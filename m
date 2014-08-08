Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7D7346B0035
	for <linux-mm@kvack.org>; Fri,  8 Aug 2014 09:39:40 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id ey11so7260797pad.24
        for <linux-mm@kvack.org>; Fri, 08 Aug 2014 06:39:40 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id bm15si2528805pdb.173.2014.08.08.06.39.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Aug 2014 06:39:39 -0700 (PDT)
Message-ID: <53E4D312.5000601@codeaurora.org>
Date: Fri, 08 Aug 2014 19:09:30 +0530
From: Chintan Pandya <cpandya@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [PATCH]  export the function kmap_flush_unused.
References: <3C85A229999D6B4A89FA64D4680BA6142C7DFA@SHSMSX101.ccr.corp.intel.com>
In-Reply-To: <3C85A229999D6B4A89FA64D4680BA6142C7DFA@SHSMSX101.ccr.corp.intel.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Sha, Ruibin" <ruibin.sha@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "a.p.zijlstra@chello.nl" <a.p.zijlstra@chello.nl>, "mgorman@suse.de" <mgorman@suse.de>, "mingo@redhat.com" <mingo@redhat.com>, "Zhang, Yanmin" <yanmin.zhang@intel.com>, "He, Bo" <bo.he@intel.com>

On 08/08/2014 02:46 PM, Sha, Ruibin wrote:
> export the function kmap_flush_unused.
>
> Scenario: When graphic driver need high memory spece, we use alloc_pages()
> to allocate. But if the allocated page has just been
> mapped in the KMAP space(like first kmap then kunmap) and
> no flush page happened on PKMAP, the page virtual address is
> not NULL.Then when we get that page and set page attribute like
> set_memory_uc and set_memory_wc, we hit error.

Could you explain your scenario with more details ? set_memory_* should 
be applied on mapped address. And in attempt to map your page (which was 
just kmap and kunmap'ed), it will overwrite the previous mappings.

Moreover, in my view, kmap_flush_unused is just helping us in keeping 
the cache clean for kmap virtual addresses if they are unmapped. Is it 
serving any more purpose here ?

>
> fix: For that scenario,when we get the allocated page and its virtual
> address is not NULL, we would like first flush that page.
> So need export that function kmap_flush_unused.
>
> Signed-off-by: sha, ruibin <ruibin.sha@intel.com>
>
> ---
> mm/highmem.c | 1 +
> 1 file changed, 1 insertion(+)
>
> diff --git a/mm/highmem.c b/mm/highmem.c
> index b32b70c..511299b 100644
> --- a/mm/highmem.c
> +++ b/mm/highmem.c
> @@ -156,6 +156,7 @@ void kmap_flush_unused(void)
> flush_all_zero_pkmaps();
> unlock_kmap();
> }
> +EXPORT_SYMBOL(kmap_flush_unused);
This symbol is already extern'ed. Is it not sufficient for your case ?
>
> static inline unsigned long map_new_virtual(struct page *page)
> {
> --
> 1.7.9.5
>
> Best Regards
>
> ---------------------------------------------------------------
>
> Sha, Rui bin ( Robin )
>
> +86 13817890945
>
> Android System Integration Shanghai
>


-- 
Chintan Pandya

QUALCOMM INDIA, on behalf of Qualcomm Innovation Center, Inc. is a
member of the Code Aurora Forum, hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
