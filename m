Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 2E7A26B0005
	for <linux-mm@kvack.org>; Fri, 22 Jan 2016 16:50:01 -0500 (EST)
Received: by mail-pf0-f180.google.com with SMTP id 65so48365132pff.2
        for <linux-mm@kvack.org>; Fri, 22 Jan 2016 13:50:01 -0800 (PST)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id d66si12004358pfj.173.2016.01.22.13.50.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Jan 2016 13:50:00 -0800 (PST)
Received: by mail-pa0-x22e.google.com with SMTP id yy13so47604139pab.3
        for <linux-mm@kvack.org>; Fri, 22 Jan 2016 13:50:00 -0800 (PST)
Date: Fri, 22 Jan 2016 13:49:58 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH, REGRESSION v4] mm: make apply_to_page_range more
 robust
In-Reply-To: <56A1E147.9050803@nextfour.com>
Message-ID: <alpine.DEB.2.10.1601221347080.27098@chino.kir.corp.google.com>
References: <56A1E147.9050803@nextfour.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="397176738-1958869735-1453499398=:27098"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Mika_Penttil=C3=A4?= <mika.penttila@nextfour.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Rusty Russell <rusty@rustcorp.com.au>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--397176738-1958869735-1453499398=:27098
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT

On Fri, 22 Jan 2016, Mika PenttilA? wrote:

> diff --git a/mm/memory.c b/mm/memory.c
> index 30991f8..9178ee6 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1871,7 +1871,9 @@ int apply_to_page_range(struct mm_struct *mm, unsigned long addr,
>         unsigned long end = addr + size;
>         int err;
>  
> -       BUG_ON(addr >= end);
> +       if (WARN_ON(addr >= end))
> +               return -EINVAL;
> +
>         pgd = pgd_offset(mm, addr);
>         do {
>                 next = pgd_addr_end(addr, end);

This would be fine as a second patch in a 2-patch series.  The first patch 
should fix change_memory_common() for numpages == 0 by returning without 
ever calling this function and triggering the WARN_ON().  Let's fix the 
problem.
--397176738-1958869735-1453499398=:27098--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
