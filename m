Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3CD156B0003
	for <linux-mm@kvack.org>; Fri,  6 Apr 2018 12:52:58 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id t4-v6so1300581plo.9
        for <linux-mm@kvack.org>; Fri, 06 Apr 2018 09:52:58 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id n3si7516559pgf.667.2018.04.06.09.52.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 06 Apr 2018 09:52:56 -0700 (PDT)
Subject: Re: [PATCH] swap: divide-by-zero when zero length swap file on ssd
References: <5AC747C1020000A7001FA82C@prv-mh.provo.novell.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <fdca1f72-8e51-7727-d1a0-4ccd60e80bd0@infradead.org>
Date: Fri, 6 Apr 2018 09:52:50 -0700
MIME-Version: 1.0
In-Reply-To: <5AC747C1020000A7001FA82C@prv-mh.provo.novell.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Abraham <tabraham@suse.com>, linux-kernel@vger.kernel.org
Cc: Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

[adding linux-mm and akpm]

On 04/06/2018 07:11 AM, Tom Abraham wrote:
>                                                                                 
> Calling swapon() on a zero length swap file on SSD can lead to a                
> divide-by-zero.                                                                 
>                                                                                 
> Although creating such files isn't possible with mkswap and they woud be        
> considered invalid, it would be better for the swapon code to be more robust    
> and handle this condition gracefully (return -EINVAL). Especially since the fix 
> is small and straight-forward.                                                  
>                                                                                 
> To help with wear leveling on SSD, the swapon syscall calculates a random       
> position in the swap file using modulo p->highest_bit, which is set to          
> maxpages - 1 in read_swap_header.                                               
>                                                                                 
> If the swap file is zero length, read_swap_header sets maxpages=1 and           
> last_page=0, resulting in p->highest_bit=0 and we divide-by-zero when we modulo 
> p->highest_bit in swapon syscall.                                               
>                                                                                 
> This can be prevented by having read_swap_header return zero if last_page is    
> zero.                                                                           
>                                                                                 
> diff --git a/mm/swapfile.c b/mm/swapfile.c                                      
> index c7a33717d079..d6b7bd9f365d 100644                                         
> --- a/mm/swapfile.c                                                             
> +++ b/mm/swapfile.c                                                             
> @@ -2961,6 +2961,10 @@ static unsigned long read_swap_header(struct swap_info_struct *p,
>         maxpages = swp_offset(pte_to_swp_entry(                                 
>                         swp_entry_to_pte(swp_entry(0, ~0UL)))) + 1;             
>         last_page = swap_header->info.last_page;                                
> +       if(!last_page) {                                                        
> +               pr_warn("Empty swap-file\n");                                   
> +               return 0;                                                       
> +       }                                                                       
>         if (last_page > maxpages) {                                             
>                 pr_warn("Truncating oversized swap area, only using %luk out of %luk\n",
>                         maxpages << (PAGE_SHIFT - 10),
> 


-- 
~Randy
