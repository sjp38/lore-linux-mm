Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9207F6B0006
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 21:35:05 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id ba8-v6so3730609plb.4
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 18:35:05 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id l65-v6si10859592pfl.155.2018.06.29.18.35.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jun 2018 18:35:04 -0700 (PDT)
Date: Fri, 29 Jun 2018 18:35:01 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC v3 PATCH 4/5] mm: mmap: zap pages with read mmap_sem for
 large mapping
Message-Id: <20180629183501.9e30c26135f11853245c56c7@linux-foundation.org>
In-Reply-To: <1530311985-31251-5-git-send-email-yang.shi@linux.alibaba.com>
References: <1530311985-31251-1-git-send-email-yang.shi@linux.alibaba.com>
	<1530311985-31251-5-git-send-email-yang.shi@linux.alibaba.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: mhocko@kernel.org, willy@infradead.org, ldufour@linux.vnet.ibm.com, peterz@infradead.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, tglx@linutronix.de, hpa@zytor.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org

On Sat, 30 Jun 2018 06:39:44 +0800 Yang Shi <yang.shi@linux.alibaba.com> wrote:


And...

> diff --git a/mm/mmap.c b/mm/mmap.c
> index 87dcf83..d61e08b 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -2763,6 +2763,128 @@ static int munmap_lookup_vma(struct mm_struct *mm, struct vm_area_struct **vma,
>  	return 1;
>  }
>  
> +/* Consider PUD size or 1GB mapping as large mapping */
> +#ifdef HPAGE_PUD_SIZE
> +#define LARGE_MAP_THRESH	HPAGE_PUD_SIZE
> +#else
> +#define LARGE_MAP_THRESH	(1 * 1024 * 1024 * 1024)
> +#endif

So this assumes that 32-bit machines cannot have 1GB mappings (fair
enough) and this is the sole means by which we avoid falling into the
"len >= LARGE_MAP_THRESH" codepath, which will behave very badly, at
least because for such machines, VM_DEAD is zero.

This is rather ugly and fragile.  And, I guess, explains why we can't
give all mappings this treatment: 32-bit machines can't do it.  And
we're adding a bunch of code to 32-bit kernels which will never be
executed.

I'm thinking it would be better to be much more explicit with "#ifdef
CONFIG_64BIT" in this code, rather than relying upon the above magic.

But I tend to think that the fact that we haven't solved anything on
locked vmas or on uprobed mappings is a shostopper for the whole
approach :(
