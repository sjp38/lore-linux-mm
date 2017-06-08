Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 36C5A6B0279
	for <linux-mm@kvack.org>; Thu,  8 Jun 2017 13:19:56 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id a70so13025672pge.8
        for <linux-mm@kvack.org>; Thu, 08 Jun 2017 10:19:56 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id i79si4775190pfj.74.2017.06.08.10.19.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Jun 2017 10:19:55 -0700 (PDT)
Subject: Re: [PATCH v3] mm: huge-vmap: fail gracefully on unexpected huge vmap
 mappings
References: <20170608113548.24905-1-ard.biesheuvel@linaro.org>
 <CAKv+Gu9Wp06Nk33CVFr5W51gnsjaRsf0fQJOS4RWbHfRP+KEcg@mail.gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <2f5358b4-b1a7-f51d-ae47-5faa93e1e1d7@intel.com>
Date: Thu, 8 Jun 2017 10:19:52 -0700
MIME-Version: 1.0
In-Reply-To: <CAKv+Gu9Wp06Nk33CVFr5W51gnsjaRsf0fQJOS4RWbHfRP+KEcg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Zhong Jiang <zhongjiang@huawei.com>, Laura Abbott <labbott@fedoraproject.org>, Mark Rutland <mark.rutland@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On 06/08/2017 04:36 AM, Ard Biesheuvel wrote:
> @@ -287,10 +288,10 @@ struct page *vmalloc_to_page(const void *vmalloc_addr)
>         if (p4d_none(*p4d))
>                 return NULL;
>         pud = pud_offset(p4d, addr);
> -       if (pud_none(*pud))
> +       if (pud_none(*pud) || WARN_ON_ONCE(pud_huge(*pud)))
>                 return NULL;
>         pmd = pmd_offset(pud, addr);
> -       if (pmd_none(*pmd))
> +       if (pmd_none(*pmd) || WARN_ON_ONCE(pmd_huge(*pmd)))
>                 return NULL;

Seems sane to me.  It might be nice to actually comment this, though, on
why huge vmalloc_to_page() is unsupported.

Also, not a big deal, but I tend to filter out the contents of
WARN_ON_ONCE() when trying to figure out what code does, so I think I'd
rather this be:

	WARN_ON_ONCE(pmd_huge(*pmd));
	if (pmd_none(*pmd) || pmd_huge(*pmd))
		...

But, again, not a big deal.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
