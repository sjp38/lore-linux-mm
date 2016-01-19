Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 4CFA76B0005
	for <linux-mm@kvack.org>; Tue, 19 Jan 2016 17:21:30 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id cy9so458489010pac.0
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 14:21:30 -0800 (PST)
Received: from mail-pf0-x22b.google.com (mail-pf0-x22b.google.com. [2607:f8b0:400e:c00::22b])
        by mx.google.com with ESMTPS id 67si50254740pfc.15.2016.01.19.14.21.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jan 2016 14:21:29 -0800 (PST)
Received: by mail-pf0-x22b.google.com with SMTP id n128so182350692pfn.3
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 14:21:29 -0800 (PST)
Date: Tue, 19 Jan 2016 14:21:27 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: make apply_to_page_range more robust
In-Reply-To: <5698866F.1070802@nextfour.com>
Message-ID: <alpine.DEB.2.10.1601191420030.7346@chino.kir.corp.google.com>
References: <5698866F.1070802@nextfour.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="397176738-944296575-1453242064=:7346"
Content-ID: <alpine.DEB.2.10.1601191421060.7346@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Mika_Penttil=C3=A4?= <mika.penttila@nextfour.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--397176738-944296575-1453242064=:7346
Content-Type: TEXT/PLAIN; CHARSET=UTF-8
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.DEB.2.10.1601191421061.7346@chino.kir.corp.google.com>

On Fri, 15 Jan 2016, Mika PenttilA? wrote:

> Recent changes (4.4.0+) in module loader triggered oops on ARM. While
> loading a module, size in :
> 
> apply_to_page_range(struct mm_struct *mm, unsigned long addr,   unsigned
> long size, pte_fn_t fn, void *data);
> 
> can be 0 triggering the bug  BUG_ON(addr >= end);.
> 
> Fix by letting call with zero size succeed.
> 
> --Mika
> 
> Signed-off-by: mika.penttila@nextfour.com
> ---
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index c387430..c3d1a2e 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1884,6 +1884,9 @@ int apply_to_page_range(struct mm_struct *mm,
> unsigned long addr,
>         unsigned long end = addr + size;
>         int err;
> 
> +       if (!size)
> +               return 0;
> +
>         BUG_ON(addr >= end);
>         pgd = pgd_offset(mm, addr);
>         do {

What is calling apply_to_page_range() with size == 0?  I'm not sure we 
should be adding "robust"ness here and that size == 0 is actually an 
indication of a bug somewhere else that we want to know about.

Btw, your patch is line-wrapped and your sign-off-line doesn't include 
your full name.
--397176738-944296575-1453242064=:7346--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
