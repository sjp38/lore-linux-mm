Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 19E8A800D8
	for <linux-mm@kvack.org>; Mon, 22 Jan 2018 15:58:40 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id w102so7441405wrb.21
        for <linux-mm@kvack.org>; Mon, 22 Jan 2018 12:58:40 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id v8si1602838wrd.114.2018.01.22.12.58.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jan 2018 12:58:38 -0800 (PST)
Date: Mon, 22 Jan 2018 12:58:36 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/hmm: fix uninitialized use of 'entry' in
 hmm_vma_walk_pmd()
Message-Id: <20180122125836.1aebb001d4c2c4e93029db35@linux-foundation.org>
In-Reply-To: <20180122185759.26286-1-jglisse@redhat.com>
References: <20180122185759.26286-1-jglisse@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ralph Campbell <rcampbell@nvidia.com>

On Mon, 22 Jan 2018 13:57:59 -0500 jglisse@redhat.com wrote:

> From: Ralph Campbell <rcampbell@nvidia.com>
> 
> The variable 'entry' is used before being initialized in
> hmm_vma_walk_pmd()
> 
> ...
>
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -418,7 +418,7 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
>  		}
>  
>  		if (!pte_present(pte)) {
> -			swp_entry_t entry;
> +			swp_entry_t entry = pte_to_swp_entry(pte);
>  
>  			if (!non_swap_entry(entry)) {
>  				if (hmm_vma_walk->fault)
> @@ -426,8 +426,6 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
>  				continue;
>  			}
>  
> -			entry = pte_to_swp_entry(pte);
> -
>  			/*
>  			 * This is a special swap entry, ignore migration, use
>  			 * device and report anything else as error.

Gee, how did that sneak through.  gcc not clever enough...

I'll add a cc:stable to this, even though the changelog didn't tell us what
the runtime effects of the bug are.  It should do so, so can you please
send us that description and I will add it, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
