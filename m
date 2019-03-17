Return-Path: <SRS0=9bJk=RU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01494C43381
	for <linux-mm@archiver.kernel.org>; Sun, 17 Mar 2019 18:31:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 829CB206DF
	for <linux-mm@archiver.kernel.org>; Sun, 17 Mar 2019 18:31:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="YvwQjpyZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 829CB206DF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E7E466B0003; Sun, 17 Mar 2019 14:31:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E2CA86B0005; Sun, 17 Mar 2019 14:31:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CCEEF6B0006; Sun, 17 Mar 2019 14:31:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 717DB6B0003
	for <linux-mm@kvack.org>; Sun, 17 Mar 2019 14:31:18 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id z22so1463119wmf.3
        for <linux-mm@kvack.org>; Sun, 17 Mar 2019 11:31:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=BXWMF2so+GLHhzxMK3cXtfcsNw0MoLzViFfxI4ru5i8=;
        b=A+R+MPGGSCY2G0vQiSbdHEakShmhsBPkffIBgerskd9fFUTnECkNRIFc1hWG3bsu0E
         7hXedZdSHk/QEJ/DuKSgcmt/DXTKFdErdTACaL79yb3QM0GoN6yZ09ksapoe2NqrUWWK
         xPmlOZRwrGACTW5MYYqdBs0IWALum0CD/hurPoAEMxogwJX6ceyyZPrhZaASEr/1wr3i
         mYQmomrbrADhYnoHv3xG0lv/t9WrCUGc2Cn0kORuD/yi+kuIByMM5VwOm3D7sCDYOmpb
         oYqwBDqNRUbXT5q+aSwTWp4nU9llL2upMAYPzCIOb8/PJSX+RmhuMXHt+xLoVdhzr8ae
         9jxQ==
X-Gm-Message-State: APjAAAVP7QNkD7iQAHhLUwU24/qegmE0VDN/VEMEQbS0rGNInyZQv8gA
	/Viy/SI6AauaGXmivkBikfVf9S1ZQKZojaA2RJswOa+oxF5g53Th/5nb5eYy7Iz3L6WZ3PoGCXL
	XA4KCbr+eNlGMiob3cwDeUFvAbfZEGirJ2YoJegctWjac/g0X1knrsEGFNWupTedRew==
X-Received: by 2002:a05:600c:cd:: with SMTP id u13mr126496wmm.49.1552847477727;
        Sun, 17 Mar 2019 11:31:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzJDHrULpqCNUMqAdcbTm7IZDjxojsLY1Dv4907CBPek4aiOmALAI/z65BU0S8WqTxRU0E+
X-Received: by 2002:a05:600c:cd:: with SMTP id u13mr126452wmm.49.1552847476566;
        Sun, 17 Mar 2019 11:31:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552847476; cv=none;
        d=google.com; s=arc-20160816;
        b=cYJXk0EXyja63b9BbDSjda7VSfTKadhJumyD3wYV+uqgHpqT4ZnkBCX22ngS1Rgoec
         ZaVgrFTqN3WeguC7xCjv+QDXGdTYmoyerXvQYAWXDsaFykerrqiJl6rmAEKrTTEisngm
         CnJLwaQd3+hNQiHFX0ude0mRJB9z2xH4fTCCR3J5Whd/lv6D2M2q0gQMkLscPQeP/jCq
         m+69QL51+C+G9qqDSQkCDKTOdHYDZf2JlaAOJwB9J/46bqm+nv50zMhxtzMjyGmIxMfu
         HP3jGJC5ATh6O9cTO4DpfT+6UyVJPz0DUJwF1darwRmFMDJb97t9uV+YQHhCXE5q6k+k
         CotQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:to:subject
         :dkim-signature;
        bh=BXWMF2so+GLHhzxMK3cXtfcsNw0MoLzViFfxI4ru5i8=;
        b=lohiPmUReZ+0qjuTO8rok0yAhV7p/t0olpB9JL8PShcgxfWAwip6LhnpSg6gJKdTjM
         ub15SDkKcGxB3r2DPpGy6eJSqDfuFjKs19YZyLlJ5iyasS74xJ6Yatm6tsYNM5iLmnIl
         J9+H+ZcTsvMlxrFr5pURStQujjLG0C7y4QibSSFJ38WV0jDlwWsWFWNSwvpdd/IX6bRP
         nHl7l3UTqAKLGothka06LeYI3zx2Z7hc0S4c47ovb0s6wvcnySGeCS9JZSpdEB/2ZOhk
         eWgbo+p8Z6K6kyoe/dVIi0kNbHD6QmHylTwGISLu8lt0yHzE9XtW5EoHaNu7PHwy8zFz
         bfoA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=YvwQjpyZ;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id h8si5159917wre.223.2019.03.17.11.31.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Mar 2019 11:31:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=YvwQjpyZ;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 44MnvN2V0Qz9vRZS;
	Sun, 17 Mar 2019 19:31:12 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=YvwQjpyZ; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id JVw08tBD8Gwx; Sun, 17 Mar 2019 19:31:12 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 44MnvN15cKz9vRZR;
	Sun, 17 Mar 2019 19:31:12 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1552847472; bh=BXWMF2so+GLHhzxMK3cXtfcsNw0MoLzViFfxI4ru5i8=;
	h=Subject:To:References:From:Date:In-Reply-To:From;
	b=YvwQjpyZoMN/ofSSY26zJgdbyA2a0Fdv/idbTQ6ve1SVr0vjTC20l/cgySuLaXF+w
	 sBNsozz5jNWIuUX2VFJFtr1Yme5JnXfQP5Dps3uL2P3CjEpE1UgWNGk+GFVrnalDOv
	 R/eIwZ7KV70PPTrXczk3tfNozRQ8JC357GmuvVsc=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id A25F58B84D;
	Sun, 17 Mar 2019 19:31:15 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id mKLCnS-MMo5Y; Sun, 17 Mar 2019 19:31:15 +0100 (CET)
Received: from [192.168.232.53] (unknown [192.168.232.53])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 213188B750;
	Sun, 17 Mar 2019 19:31:14 +0100 (CET)
Subject: Re: [PATCH v7 4/4] hugetlb: allow to free gigantic pages regardless
 of the configuration
To: Alexandre Ghiti <alex@ghiti.fr>, aneesh.kumar@linux.ibm.com,
 mpe@ellerman.id.au, Andrew Morton <akpm@linux-foundation.org>,
 Vlastimil Babka <vbabka@suse.cz>, Catalin Marinas <catalin.marinas@arm.com>,
 Will Deacon <will.deacon@arm.com>,
 Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Paul Mackerras <paulus@samba.org>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>,
 Heiko Carstens <heiko.carstens@de.ibm.com>,
 Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>,
 "David S . Miller" <davem@davemloft.net>,
 Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
 Borislav Petkov <bp@alien8.de>, "H . Peter Anvin" <hpa@zytor.com>,
 x86@kernel.org, Dave Hansen <dave.hansen@linux.intel.com>,
 Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>,
 Mike Kravetz <mike.kravetz@oracle.com>,
 linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
 linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org
References: <20190317162847.14107-1-alex@ghiti.fr>
 <20190317162847.14107-5-alex@ghiti.fr>
From: christophe leroy <christophe.leroy@c-s.fr>
Message-ID: <f434892d-80b2-f09d-31d6-754a1be0b97a@c-s.fr>
Date: Sun, 17 Mar 2019 19:31:13 +0100
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.3
MIME-Version: 1.0
In-Reply-To: <20190317162847.14107-5-alex@ghiti.fr>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: fr
Content-Transfer-Encoding: 8bit
X-Antivirus: Avast (VPS 190317-2, 17/03/2019), Outbound message
X-Antivirus-Status: Clean
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



Le 17/03/2019 à 17:28, Alexandre Ghiti a écrit :
> On systems without CONTIG_ALLOC activated but that support gigantic pages,
> boottime reserved gigantic pages can not be freed at all. This patch
> simply enables the possibility to hand back those pages to memory
> allocator.
> 
> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
> Acked-by: David S. Miller <davem@davemloft.net> [sparc]
> ---
>   arch/arm64/Kconfig                           |  2 +-
>   arch/arm64/include/asm/hugetlb.h             |  4 --
>   arch/powerpc/include/asm/book3s/64/hugetlb.h |  7 ---
>   arch/powerpc/platforms/Kconfig.cputype       |  2 +-
>   arch/s390/Kconfig                            |  2 +-
>   arch/s390/include/asm/hugetlb.h              |  3 --
>   arch/sh/Kconfig                              |  2 +-
>   arch/sparc/Kconfig                           |  2 +-
>   arch/x86/Kconfig                             |  2 +-
>   arch/x86/include/asm/hugetlb.h               |  4 --
>   include/asm-generic/hugetlb.h                | 14 +++++
>   include/linux/gfp.h                          |  2 +-
>   mm/hugetlb.c                                 | 54 ++++++++++++++------
>   mm/page_alloc.c                              |  4 +-
>   14 files changed, 61 insertions(+), 43 deletions(-)
> 

[...]

> diff --git a/include/asm-generic/hugetlb.h b/include/asm-generic/hugetlb.h
> index 71d7b77eea50..aaf14974ee5f 100644
> --- a/include/asm-generic/hugetlb.h
> +++ b/include/asm-generic/hugetlb.h
> @@ -126,4 +126,18 @@ static inline pte_t huge_ptep_get(pte_t *ptep)
>   }
>   #endif
>   
> +#ifndef __HAVE_ARCH_GIGANTIC_PAGE_RUNTIME_SUPPORTED
> +#ifdef CONFIG_ARCH_HAS_GIGANTIC_PAGE
> +static inline bool gigantic_page_runtime_supported(void)
> +{
> +	return true;
> +}
> +#else
> +static inline bool gigantic_page_runtime_supported(void)
> +{
> +	return false;
> +}
> +#endif /* CONFIG_ARCH_HAS_GIGANTIC_PAGE */

What about the following instead:

static inline bool gigantic_page_runtime_supported(void)
{
	return IS_ENABLED(CONFIG_ARCH_HAS_GIGANTIC_PAGE);
}


> +#endif /* __HAVE_ARCH_GIGANTIC_PAGE_RUNTIME_SUPPORTED */
> +
>   #endif /* _ASM_GENERIC_HUGETLB_H */
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 1f1ad9aeebb9..58ea44bf75de 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -589,8 +589,8 @@ static inline bool pm_suspended_storage(void)
>   /* The below functions must be run on a range from a single zone. */
>   extern int alloc_contig_range(unsigned long start, unsigned long end,
>   			      unsigned migratetype, gfp_t gfp_mask);
> -extern void free_contig_range(unsigned long pfn, unsigned nr_pages);
>   #endif
> +extern void free_contig_range(unsigned long pfn, unsigned int nr_pages);

'extern' is unneeded and should be avoided (iaw checkpatch)

Christophe

>   
>   #ifdef CONFIG_CMA
>   /* CMA stuff */
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index afef61656c1e..4e55aa38704f 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1058,6 +1058,7 @@ static void free_gigantic_page(struct page *page, unsigned int order)
>   	free_contig_range(page_to_pfn(page), 1 << order);
>   }
>   
> +#ifdef CONFIG_CONTIG_ALLOC
>   static int __alloc_gigantic_page(unsigned long start_pfn,
>   				unsigned long nr_pages, gfp_t gfp_mask)
>   {
> @@ -1142,11 +1143,20 @@ static struct page *alloc_gigantic_page(struct hstate *h, gfp_t gfp_mask,
>   
>   static void prep_new_huge_page(struct hstate *h, struct page *page, int nid);
>   static void prep_compound_gigantic_page(struct page *page, unsigned int order);
> +#else /* !CONFIG_CONTIG_ALLOC */
> +static struct page *alloc_gigantic_page(struct hstate *h, gfp_t gfp_mask,
> +					int nid, nodemask_t *nodemask)
> +{
> +	return NULL;
> +}
> +#endif /* CONFIG_CONTIG_ALLOC */
>   
>   #else /* !CONFIG_ARCH_HAS_GIGANTIC_PAGE */
> -static inline bool gigantic_page_supported(void) { return false; }
>   static struct page *alloc_gigantic_page(struct hstate *h, gfp_t gfp_mask,
> -		int nid, nodemask_t *nodemask) { return NULL; }
> +					int nid, nodemask_t *nodemask)
> +{
> +	return NULL;
> +}
>   static inline void free_gigantic_page(struct page *page, unsigned int order) { }
>   static inline void destroy_compound_gigantic_page(struct page *page,
>   						unsigned int order) { }
> @@ -1156,7 +1166,7 @@ static void update_and_free_page(struct hstate *h, struct page *page)
>   {
>   	int i;
>   
> -	if (hstate_is_gigantic(h) && !gigantic_page_supported())
> +	if (hstate_is_gigantic(h) && !gigantic_page_runtime_supported())
>   		return;
>   
>   	h->nr_huge_pages--;
> @@ -2276,13 +2286,27 @@ static int adjust_pool_surplus(struct hstate *h, nodemask_t *nodes_allowed,
>   }
>   
>   #define persistent_huge_pages(h) (h->nr_huge_pages - h->surplus_huge_pages)
> -static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
> -						nodemask_t *nodes_allowed)
> +static int set_max_huge_pages(struct hstate *h, unsigned long count,
> +			      nodemask_t *nodes_allowed)
>   {
>   	unsigned long min_count, ret;
>   
> -	if (hstate_is_gigantic(h) && !gigantic_page_supported())
> -		return h->max_huge_pages;
> +	spin_lock(&hugetlb_lock);
> +
> +	/*
> +	 * Gigantic pages runtime allocation depend on the capability for large
> +	 * page range allocation.
> +	 * If the system does not provide this feature, return an error when
> +	 * the user tries to allocate gigantic pages but let the user free the
> +	 * boottime allocated gigantic pages.
> +	 */
> +	if (hstate_is_gigantic(h) && !IS_ENABLED(CONFIG_CONTIG_ALLOC)) {
> +		if (count > persistent_huge_pages(h)) {
> +			spin_unlock(&hugetlb_lock);
> +			return -EINVAL;
> +		}
> +		/* Fall through to decrease pool */
> +	}
>   
>   	/*
>   	 * Increase the pool size
> @@ -2295,7 +2319,6 @@ static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
>   	 * pool might be one hugepage larger than it needs to be, but
>   	 * within all the constraints specified by the sysctls.
>   	 */
> -	spin_lock(&hugetlb_lock);
>   	while (h->surplus_huge_pages && count > persistent_huge_pages(h)) {
>   		if (!adjust_pool_surplus(h, nodes_allowed, -1))
>   			break;
> @@ -2350,9 +2373,10 @@ static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
>   			break;
>   	}
>   out:
> -	ret = persistent_huge_pages(h);
> +	h->max_huge_pages = persistent_huge_pages(h);
>   	spin_unlock(&hugetlb_lock);
> -	return ret;
> +
> +	return 0;
>   }
>   
>   #define HSTATE_ATTR_RO(_name) \
> @@ -2404,7 +2428,7 @@ static ssize_t __nr_hugepages_store_common(bool obey_mempolicy,
>   	int err;
>   	NODEMASK_ALLOC(nodemask_t, nodes_allowed, GFP_KERNEL | __GFP_NORETRY);
>   
> -	if (hstate_is_gigantic(h) && !gigantic_page_supported()) {
> +	if (hstate_is_gigantic(h) && !gigantic_page_runtime_supported()) {
>   		err = -EINVAL;
>   		goto out;
>   	}
> @@ -2428,15 +2452,13 @@ static ssize_t __nr_hugepages_store_common(bool obey_mempolicy,
>   	} else
>   		nodes_allowed = &node_states[N_MEMORY];
>   
> -	h->max_huge_pages = set_max_huge_pages(h, count, nodes_allowed);
> +	err = set_max_huge_pages(h, count, nodes_allowed);
>   
> +out:
>   	if (nodes_allowed != &node_states[N_MEMORY])
>   		NODEMASK_FREE(nodes_allowed);
>   
> -	return len;
> -out:
> -	NODEMASK_FREE(nodes_allowed);
> -	return err;
> +	return err ? err : len;
>   }
>   
>   static ssize_t nr_hugepages_store_common(bool obey_mempolicy,
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index ac9c45ffb344..a4547d90fa7a 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -8234,8 +8234,9 @@ int alloc_contig_range(unsigned long start, unsigned long end,
>   				pfn_max_align_up(end), migratetype);
>   	return ret;
>   }
> +#endif /* CONFIG_CONTIG_ALLOC */
>   
> -void free_contig_range(unsigned long pfn, unsigned nr_pages)
> +void free_contig_range(unsigned long pfn, unsigned int nr_pages)
>   {
>   	unsigned int count = 0;
>   
> @@ -8247,7 +8248,6 @@ void free_contig_range(unsigned long pfn, unsigned nr_pages)
>   	}
>   	WARN(count != 0, "%d pages are still in use!\n", count);
>   }
> -#endif
>   
>   #ifdef CONFIG_MEMORY_HOTPLUG
>   /*
> 

---
L'absence de virus dans ce courrier électronique a été vérifiée par le logiciel antivirus Avast.
https://www.avast.com/antivirus

