Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 92E4E6B29B3
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 00:27:44 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id e68so12822243plb.3
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 21:27:44 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id f184-v6si37084426pfc.224.2018.11.21.21.27.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Nov 2018 21:27:43 -0800 (PST)
Date: Wed, 21 Nov 2018 21:27:40 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Make  __memblock_free_early a wrapper of memblock_free rather
 dup it
Message-Id: <20181121212740.84884a0c4532334d81fc6961@linux-foundation.org>
In-Reply-To: <C8ECE1B7A767434691FEEFA3A01765D72AFB8E78@MX203CL03.corp.emc.com>
References: <C8ECE1B7A767434691FEEFA3A01765D72AFB8E78@MX203CL03.corp.emc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wang, Matt" <Matt.Wang@Dell.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, 22 Nov 2018 04:01:53 +0000 "Wang, Matt" <Matt.Wang@Dell.com> wrote:

> Subject: [PATCH] Make __memblock_free_early a wrapper of memblock_free rather
>  than dup it
> 
> Signed-off-by: Wentao Wang <witallwang@gmail.com>
> ---
>  mm/memblock.c | 7 +------
>  1 file changed, 1 insertion(+), 6 deletions(-)
> 
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 9a2d5ae..08bf136 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -1546,12 +1546,7 @@ void * __init memblock_alloc_try_nid(
>   */
>  void __init __memblock_free_early(phys_addr_t base, phys_addr_t size)
>  {
> -	phys_addr_t end = base + size - 1;
> -
> -	memblock_dbg("%s: [%pa-%pa] %pF\n",
> -		     __func__, &base, &end, (void *)_RET_IP_);
> -	kmemleak_free_part_phys(base, size);
> -	memblock_remove_range(&memblock.reserved, base, size);
> +	memblock_free(base, size);
>  }

hm, I suppose so.  The debug messaging becomes less informative but the
duplication is indeed irritating and if we really want to show the
different caller info in the messages, we could do it in a smarter
fashion.
