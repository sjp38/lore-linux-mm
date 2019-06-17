Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6D1DDC31E44
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 07:26:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1DDB2219BE
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 07:26:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1DDB2219BE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AD4638E0003; Mon, 17 Jun 2019 03:26:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A85B08E0001; Mon, 17 Jun 2019 03:26:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 94C478E0003; Mon, 17 Jun 2019 03:26:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 732888E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 03:26:31 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id t196so8449426qke.0
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 00:26:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=wjDbOzLRsQ6fwGRzf7UxdfEp+l3E1+qNED9n9UgVewg=;
        b=pqlALzDVX2yPK18DuoFJFA+4G9SSWtnOEihC6VJbd40scvhq9P8UEijltGTPbdM4DR
         C8sf8L/BqHfLaeVllByUwm33uc/oqDv1gxEK8X3CpkvwGA+csWONYzoqfN6V3CO6b3Lw
         ulwfJk9zv9Q4nlWspvdliOip0TW0mY9bx7u8JZxN5LmEhIgL3cip/4d3/79fVu7tjlUZ
         nsgnot060Ia2J6O6bwgToDGaUBem6E6t9g38L/Y9+u3vEv/YQAzczaiwmRy2M05Q5oMi
         A1iVxpwC38A2A0myVGKSUnDrzX3UVc5Y3NVorbNQxPvCSBREq8VOaTHyL3jnxC31/3f/
         7uvg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXIcUTKliiZOWvDg3Y7gfPsP8al56mSdHmR6SFXoaj7eoDL3RTj
	S239vABEtT777+I//n+1KSO1WC+zFho/IPPo1dC+51AET0oynQGALybNRRG0NspMYMEaX9Jw6pM
	Xo4bn3ciPx2ZOE6FpfCUMe1dDfNSbCPq2W/PJKL6tsqgTNLh34vn6cdtNovc7uvMlTA==
X-Received: by 2002:a0c:b90a:: with SMTP id u10mr19928322qvf.201.1560756391273;
        Mon, 17 Jun 2019 00:26:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwRZnWWfkX2TyzLXfhFmF0oHnbtToHZDwkrIHUbGr0pbLq1217vOsj1+nshVLu6pne0/Qzv
X-Received: by 2002:a0c:b90a:: with SMTP id u10mr19928292qvf.201.1560756390794;
        Mon, 17 Jun 2019 00:26:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560756390; cv=none;
        d=google.com; s=arc-20160816;
        b=zlVSAOjI/MMjlkpE0t/KYmApZR9Jz4n828a1lPieuVUMJor4yXOP37NhEr+VqTp8Ad
         FB6IdJVa5nZ2m5aDDOx4F9GpP7FLJ+gpeoXftF5wX4oLKXZgawTONXpop2jBYCIFiqZ1
         y4822Zg5aJ5oplItMfTLNZWwqerzKCZCPiqgQKAxelAaHnes/ixFyvrT5NYWBZKGyTqG
         nTBarlkzpATFu2au4nmBrubEuc0iE9xK+z9TJcXJvpxAancddVdJsW1kgLcgFzErXsdN
         NJJe56MXcvzOHWhdNi2tKn05+E/gcsSrOw4oQyZe6YsfmV3TPh8vP/38Vx6jPwk8w6d9
         MvBw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=wjDbOzLRsQ6fwGRzf7UxdfEp+l3E1+qNED9n9UgVewg=;
        b=dIu1Fr2Ua9pWn4ReXh4uvjousWTstQEF1EgLDNwLarnTiNQh8wonGAiCMmjqFln90Y
         M0bLkXRGkf5CcMWk24xPQBB3q49DPXljGLumH11VbbLWMYsiaGzS7OBp/HuNJdh+3Pkh
         +tIhai+6bH6E3RqZ0dRPoFY/8+Wsyrhger/wwOQ+yT+KS/Ho1GTTd19e404srfRnGlhB
         uz+8/7e8E3Tw023wkTUJfYN7vWVHmLRyBIxSc0bwiJCHjcV61k04a26Dg6mIN4+2+INz
         rpxW48dGX7zzIUc9o3TtHh2Jjc3tQoKtyeEMmoaQRigv84ZtU2xP4J92UlMXPYEU6sIE
         W/Mw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 31si6775818qvt.57.2019.06.17.00.26.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 00:26:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B45FA30872F1;
	Mon, 17 Jun 2019 07:26:17 +0000 (UTC)
Received: from [10.36.116.141] (ovpn-116-141.ams2.redhat.com [10.36.116.141])
	by smtp.corp.redhat.com (Postfix) with ESMTP id E866468405;
	Mon, 17 Jun 2019 07:26:07 +0000 (UTC)
Subject: Re: [PATCH 2/5] mm: don't hide potentially null memmap pointer in
 sparse_remove_one_section
To: Alastair D'Silva <alastair@au1.ibm.com>, alastair@d-silva.org
Cc: Andrew Morton <akpm@linux-foundation.org>,
 Oscar Salvador <osalvador@suse.com>, Michal Hocko <mhocko@suse.com>,
 Pavel Tatashin <pasha.tatashin@soleen.com>,
 Wei Yang <richard.weiyang@gmail.com>, Juergen Gross <jgross@suse.com>,
 Qian Cai <cai@lca.pw>, Thomas Gleixner <tglx@linutronix.de>,
 Ingo Molnar <mingo@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>,
 Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Jiri Kosina
 <jkosina@suse.cz>, Peter Zijlstra <peterz@infradead.org>,
 Mukesh Ojha <mojha@codeaurora.org>, Arun KS <arunks@codeaurora.org>,
 Mike Rapoport <rppt@linux.vnet.ibm.com>, Baoquan He <bhe@redhat.com>,
 Logan Gunthorpe <logang@deltatee.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <20190617043635.13201-1-alastair@au1.ibm.com>
 <20190617043635.13201-3-alastair@au1.ibm.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <e3dd8031-2091-4d65-7c76-0ec7283f92f5@redhat.com>
Date: Mon, 17 Jun 2019 09:26:07 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190617043635.13201-3-alastair@au1.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.47]); Mon, 17 Jun 2019 07:26:24 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 17.06.19 06:36, Alastair D'Silva wrote:
> From: Alastair D'Silva <alastair@d-silva.org>
> 
> By adding offset to memmap before passing it in to clear_hwpoisoned_pages,
> is hides a potentially null memmap from the null check inside
> clear_hwpoisoned_pages.
> 
> This patch passes the offset to clear_hwpoisoned_pages instead, allowing
> memmap to successfully peform it's null check.
> 
> Signed-off-by: Alastair D'Silva <alastair@d-silva.org>
> ---
>  mm/sparse.c | 12 +++++++-----
>  1 file changed, 7 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/sparse.c b/mm/sparse.c
> index 104a79fedd00..66a99da9b11b 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -746,12 +746,14 @@ int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
>  		kfree(usemap);
>  		__kfree_section_memmap(memmap, altmap);
>  	}
> +
>  	return ret;
>  }
>  
>  #ifdef CONFIG_MEMORY_HOTREMOVE
>  #ifdef CONFIG_MEMORY_FAILURE
> -static void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
> +static void clear_hwpoisoned_pages(struct page *memmap,
> +		unsigned long map_offset, int nr_pages)
>  {
>  	int i;
>  
> @@ -767,7 +769,7 @@ static void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
>  	if (atomic_long_read(&num_poisoned_pages) == 0)
>  		return;
>  
> -	for (i = 0; i < nr_pages; i++) {
> +	for (i = map_offset; i < nr_pages; i++) {
>  		if (PageHWPoison(&memmap[i])) {
>  			atomic_long_sub(1, &num_poisoned_pages);
>  			ClearPageHWPoison(&memmap[i]);
> @@ -775,7 +777,8 @@ static void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
>  	}
>  }
>  #else
> -static inline void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
> +static inline void clear_hwpoisoned_pages(struct page *memmap,
> +		unsigned long map_offset, int nr_pages)

I somewhat dislike that map_offset modifies nr_pages internally.

I would prefer decoupling both and passing the actual number of pages to
clear instead:

clear_hwpoisoned_pages(memmap, map_offset,
		       PAGES_PER_SECTION - map_offset);


>  {
>  }
>  #endif
> @@ -822,8 +825,7 @@ void sparse_remove_one_section(struct zone *zone, struct mem_section *ms,
>  		ms->pageblock_flags = NULL;
>  	}
>  
> -	clear_hwpoisoned_pages(memmap + map_offset,
> -			PAGES_PER_SECTION - map_offset);
> +	clear_hwpoisoned_pages(memmap, map_offset, PAGES_PER_SECTION);
>  	free_section_usemap(memmap, usemap, altmap);
>  }
>  #endif /* CONFIG_MEMORY_HOTREMOVE */
> 


-- 

Thanks,

David / dhildenb

