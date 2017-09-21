Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 23DF96B02E9
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 20:03:34 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id y29so7130547pff.6
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 17:03:34 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id m26si99004pgd.469.2017.09.20.17.03.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Sep 2017 17:03:32 -0700 (PDT)
Subject: Re: [PATCH v6 03/11] mm, x86: Add support for eXclusive Page Frame
 Ownership (XPFO)
References: <20170907173609.22696-1-tycho@docker.com>
 <20170907173609.22696-4-tycho@docker.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <55fa9707-a623-90bd-a0a1-e45920e94103@intel.com>
Date: Wed, 20 Sep 2017 17:03:28 -0700
MIME-Version: 1.0
In-Reply-To: <20170907173609.22696-4-tycho@docker.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tycho Andersen <tycho@docker.com>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, x86@kernel.org

On 09/07/2017 10:36 AM, Tycho Andersen wrote:
> +		/*
> +		 * Map the page back into the kernel if it was previously
> +		 * allocated to user space.
> +		 */
> +		if (test_and_clear_bit(XPFO_PAGE_USER, &xpfo->flags)) {
> +			clear_bit(XPFO_PAGE_UNMAPPED, &xpfo->flags);
> +			set_kpte(page_address(page + i), page + i,
> +				 PAGE_KERNEL);
> +		}
> +	}

It might also be a really good idea to clear the page here.  Otherwise,
the page still might have attack code in it and now it is mapped into
the kernel again, ready to be exploited.

Think of it this way: pages either trusted data and are mapped all the
time, or they have potentially bad data and are unmapped mostly.  If we
want to take a bad page and map it always, we have to make sure the
contents are not evil.  0's are not evil.

>  static inline void *kmap(struct page *page)
>  {
> +	void *kaddr;
> +
>  	might_sleep();
> -	return page_address(page);
> +	kaddr = page_address(page);
> +	xpfo_kmap(kaddr, page);
> +	return kaddr;
>  }

The time between kmap() and kunmap() is potentially a really long
operation.  I think we, for instance, keep some pages kmap()'d while we
do I/O to them, or wait for I/O elsewhere.

IOW, this will map predictable data at a predictable location and it
will do it for a long time.  While that's better than the current state
(mapped always), it still seems rather risky.

Could you, for instance, turn kmap(page) into vmap(&page, 1, ...)?  That
way, at least the address may be different each time.  Even if an
attacker knows the physical address, they don't know where it will be
mapped.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
