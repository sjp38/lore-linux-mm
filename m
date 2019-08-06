Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 84AA2C31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 09:29:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4B70120B1F
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 09:29:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4B70120B1F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DC3046B027E; Tue,  6 Aug 2019 05:29:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D73B06B027F; Tue,  6 Aug 2019 05:29:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C3C406B0280; Tue,  6 Aug 2019 05:29:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 79CD76B027E
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 05:29:54 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id a5so53433964edx.12
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 02:29:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=T2ELb0ZhBbYWqNNSohuWnmj+NPgNYqQ4wB6/MjFV1gw=;
        b=ce5x8DSV80BRz5ehgJ+1Qr/2nZA/ZDYMBtEetNepprWt+CHDU3tQnh8oyH5s8dWcWA
         moRbW7WkgkSSq4mkhqqs98ZEXoKyswIll6M4NShajlKozAioiZ3CtxL/+53hMoUal+CD
         HxbjRo2ByrCWzw9taH2J3vWJ423Mq3+4GsqOKsn+lBks0+CA0OYQV1q7t0fuYHdaqVqe
         HTQ3NjJ+iikcQZ4oV1n5nmhe0ustRJEwrLAWT0Rl7vzgjpKqMYyFLY5tbAMuQvSA4ppj
         sWwoUTRj4DkCDtBksdIxOAyIjU9GIiSXgJZUu8lrHypwI66BDcQwfme+zqXXQJkhybbK
         ZXLw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAUyytCY38/rPE3apTjE4DB7ky1wZIzJV9/a+BArm1B8Yteb0NBE
	DbhI7VFtOeG8a3GgRGI+7+Na8BnV7bmFFp8Gwz/JGx6ulFY1R2sidxHh2WJdNULDewiBlDoLWHn
	YBt9sLKpyskkqsCASYL1syIsXHfLE7fp5jB9QazOcu4Xtw8rIrzSHZyUaJy+a3Ygg7A==
X-Received: by 2002:a17:906:b6c6:: with SMTP id ec6mr2179119ejb.183.1565083794041;
        Tue, 06 Aug 2019 02:29:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyPqJ3L0jQOmujc/p9iK6fH4lyMOxow+qdSYDqCe23AJ6Sp/uQZkfl9v1tArc0wupBUJanp
X-Received: by 2002:a17:906:b6c6:: with SMTP id ec6mr2179088ejb.183.1565083793331;
        Tue, 06 Aug 2019 02:29:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565083793; cv=none;
        d=google.com; s=arc-20160816;
        b=D05ZwRWtmagtRumgoNvlgyfO3b7nITrXSiguuNdXWhZu6FgcHmtdPMDPMxKFI3m+mK
         s/c+pJZaZwqUIPzPGk7cePhYs7xyNhlVCnJximqzXPhclb0kfYsAudEbuA1FOFZEL7Yp
         NEJplL19qqigRMk4Cesy3U2i7PhIGwoYr4+ROsgbU2RKlQCtSEY0XaQ8U8x7IXHiM++d
         HKBqz1EpzgmYflWgogZ+y/hCrGPP5kJOo7Z9/+kK9wtU2k/wTM1CnQPtRCuoAVwJ7vUe
         m67AlrVH6Jd5JCdABZA+cswAFJTJE1k1279lTktn9ntEA9S/XpHANnfskZV64FKVqmUj
         y8Uw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=T2ELb0ZhBbYWqNNSohuWnmj+NPgNYqQ4wB6/MjFV1gw=;
        b=XpLF441QZFXuVkHfm+uqkBt+Cv4LU83FauZtwWtzlzRLCT89b3HT37gUmV5wQyZL2b
         SNzdlqKlU9t3PUOIuUfZgsS5c7wm+NQFCNZtVqeSXv9QEqhtYxJkEYo+pm8x7zZHAk9x
         SOKrzeKwp2Ml5blKtK7EgBwBXDqv0HthE8zI/xAs4/5ga19/ORc9HLOllics85jvdXLG
         kxCsPxzizUAiwIw5qoMlxEdJg/FFzb0MsC5wV23Qnnc/hMLFZjJDfVRHL3j6p/RDhGkF
         yvJV2eJt4DKP7tb7aXPIzV0ztVBNqN5822BXqLPCiGEAi/XZr9X2zmmTxpphLTdLvr0g
         X7vw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h7si29931591edb.218.2019.08.06.02.29.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 02:29:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id DB23AAE6F;
	Tue,  6 Aug 2019 09:29:52 +0000 (UTC)
Subject: Re: [PATCH] mm/mmap.c: refine data locality of find_vma_prev
To: Wei Yang <richardw.yang@linux.intel.com>, akpm@linux-foundation.org,
 mhocko@suse.com, kirill.shutemov@linux.intel.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <20190806081123.22334-1-richardw.yang@linux.intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <3e57ba64-732b-d5be-1ad6-eecc731ef405@suse.cz>
Date: Tue, 6 Aug 2019 11:29:52 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190806081123.22334-1-richardw.yang@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/6/19 10:11 AM, Wei Yang wrote:
> When addr is out of the range of the whole rb_tree, pprev will points to
> the biggest node. find_vma_prev gets is by going through the right most

s/biggest/last/ ? or right-most?

> node of the tree.
> 
> Since only the last node is the one it is looking for, it is not
> necessary to assign pprev to those middle stage nodes. By assigning
> pprev to the last node directly, it tries to improve the function
> locality a little.

In the end, it will always write to the cacheline of pprev. The caller has most
likely have it on stack, so it's already hot, and there's no other CPU stealing
it. So I don't understand where the improved locality comes from. The compiler
can also optimize the patched code so the assembly is identical to the previous
code, or vice versa. Did you check for differences?

The previous code is somewhat more obvious to me, so unless I'm missing
something, readability and less churn suggests to not change.

> Signed-off-by: Wei Yang <richardw.yang@linux.intel.com>
> ---
>  mm/mmap.c | 7 +++----
>  1 file changed, 3 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 7e8c3e8ae75f..284bc7e51f9c 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -2271,11 +2271,10 @@ find_vma_prev(struct mm_struct *mm, unsigned long addr,
>  		*pprev = vma->vm_prev;
>  	} else {
>  		struct rb_node *rb_node = mm->mm_rb.rb_node;
> -		*pprev = NULL;
> -		while (rb_node) {
> -			*pprev = rb_entry(rb_node, struct vm_area_struct, vm_rb);
> +		while (rb_node && rb_node->rb_right)
>  			rb_node = rb_node->rb_right;
> -		}
> +		*pprev = rb_node ? NULL
> +			 : rb_entry(rb_node, struct vm_area_struct, vm_rb);
>  	}
>  	return vma;
>  }
> 

