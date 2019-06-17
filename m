Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 52073C31E44
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 07:17:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0D1E6218EA
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 07:17:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0D1E6218EA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ADA418E0003; Mon, 17 Jun 2019 03:17:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A8B358E0001; Mon, 17 Jun 2019 03:17:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 952808E0003; Mon, 17 Jun 2019 03:17:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7351F8E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 03:17:39 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id 5so8422293qki.2
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 00:17:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=rSLo6dSnbI8gFlAZ1OR3vbHnCbtgKV/Oq7strZdOi40=;
        b=GOfT6uZMS8T+sU5AgDhXrbeI6if40u6B7Y21xNHu0aiVXakOsi9Sw49ryfQPpooTeB
         fYwaOn9TZ8gaLGTvKJedu3rx/RuMzPGZoTWpimCw0tBVjoJV363waWuLoteOQRJ6jkQK
         XSAsVSo58ksgIjEAUgq0jWmoQ6gz7zU+gszcFs7x4yKW8XKyAWCapiYVDlOTWaay4WIy
         sVNZ/KS10A81ZFFS59dwiNN/BZcpOunYXsIN/h8FBE81IDdKZTv19/L0b9xOyKAvrX6I
         7EvC6DO8y+KqimADIQisomp3Fvf1//4fus8zlm0+yTNh8KAjocZRhHojV1UrGtY/hX8t
         xn+A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVcTU0kNU90OZDituvvP0E2ehSf2Gl4oSAR4EEJY+UvzoKCaJ39
	eDqmPUYzdx36NbkvwNQaug6aNyUgL8uVfIcGjAXFwTRbKgFUeS8Rgu1eOQuy9LmMiNOSdcr+BY1
	ziV87NOmuvlMn2mr2NAjEGdPDxjDQe1tJH54YgAaB1ofaC5PQo7KUxlEEfcj8DXDM+A==
X-Received: by 2002:ac8:1c65:: with SMTP id j34mr47723583qtk.323.1560755859276;
        Mon, 17 Jun 2019 00:17:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy9JLp72//PWghZryV0s31gc3JoK5PWqLSOU7BBT6c1AMiEX9Tr16fI9E6MTlAoICXKVoPc
X-Received: by 2002:ac8:1c65:: with SMTP id j34mr47723566qtk.323.1560755858860;
        Mon, 17 Jun 2019 00:17:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560755858; cv=none;
        d=google.com; s=arc-20160816;
        b=0q4JKWQ1eUEbcY5TrmxDFf7a2+Myp/HLMky/ht9RNpROqhZ/FJ0uFcThCvLuKgAF0d
         uLNQByoRcrX8Zg0UDaBgCPdxvIfngitzxUUKote27HYtjQZa3VES9fEiXc4PQ/xfdmBM
         5FPy4WS1ooYgE4WrUMPdhMO2/VP6Ly4gtpGBWIgxgd8fqquUJeEfOESwY5+Or5PSYo4X
         ZZFJR4DCx3VeLNu0pQSDmOIT5LQc0hClEmkgfqIfmAtnI71thlUDqK5j3Wk20GxnQjMI
         iF29yA0wOKc1iSbaKwt7PQTH6afSkcoZFBShQ0a3wWklUO3Eo4+yD2FCn3Pwhmtbpj8l
         iGag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=rSLo6dSnbI8gFlAZ1OR3vbHnCbtgKV/Oq7strZdOi40=;
        b=zwGhmkwjvC4wgilfi+R0Xszj8Jh2/4s0sqcjdDFhbxiKFAuZId+FZiOO5RPUqO472w
         XPb9QM2O8j2BJIFrKdmjDd6nMKINojdHnnYiUrjkStSwwjB7U0SbUrM4begh/haHEKeD
         aps6wRqSpsWHeZIY7O7AGeIW41hA5y5dDIeeBUYWZHsTepecv0pFq5T6yBeO+wwaAjV9
         k8Am6wuO9FMACP4K0DKNrxcGa9/tQeTeGpxsVOqWRIJjyORtZmwm7n98zrOTDGLQGp6J
         LvpQi7uHxFPZqdPtqi+lRizmI1LAH2ZB/t7BsQuqUl5UEdJNYpumOS+kUJkpCKPqBLpY
         Adrg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s190si7254015qke.148.2019.06.17.00.17.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 00:17:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 5F3F730833C1;
	Mon, 17 Jun 2019 07:17:24 +0000 (UTC)
Received: from [10.36.116.141] (ovpn-116-141.ams2.redhat.com [10.36.116.141])
	by smtp.corp.redhat.com (Postfix) with ESMTP id DDFD117F70;
	Mon, 17 Jun 2019 07:17:11 +0000 (UTC)
Subject: Re: [PATCH 3/5] mm: Don't manually decrement num_poisoned_pages
To: Alastair D'Silva <alastair@au1.ibm.com>, alastair@d-silva.org
Cc: Andrew Morton <akpm@linux-foundation.org>,
 Oscar Salvador <osalvador@suse.com>, Michal Hocko <mhocko@suse.com>,
 Pavel Tatashin <pasha.tatashin@soleen.com>,
 Wei Yang <richard.weiyang@gmail.com>, Arun KS <arunks@codeaurora.org>,
 Qian Cai <cai@lca.pw>, Thomas Gleixner <tglx@linutronix.de>,
 Ingo Molnar <mingo@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>,
 Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 Peter Zijlstra <peterz@infradead.org>, Jiri Kosina <jkosina@suse.cz>,
 Mukesh Ojha <mojha@codeaurora.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>,
 Baoquan He <bhe@redhat.com>, Logan Gunthorpe <logang@deltatee.com>,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <20190617043635.13201-1-alastair@au1.ibm.com>
 <20190617043635.13201-4-alastair@au1.ibm.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <65a64309-cfcb-d27f-a054-c541cf3f0d70@redhat.com>
Date: Mon, 17 Jun 2019 09:17:11 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190617043635.13201-4-alastair@au1.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Mon, 17 Jun 2019 07:17:38 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 17.06.19 06:36, Alastair D'Silva wrote:
> From: Alastair D'Silva <alastair@d-silva.org>
> 
> Use the function written to do it instead.
> 
> Signed-off-by: Alastair D'Silva <alastair@d-silva.org>
> ---
>  mm/sparse.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/sparse.c b/mm/sparse.c
> index 66a99da9b11b..e2402937efe4 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -11,6 +11,8 @@
>  #include <linux/export.h>
>  #include <linux/spinlock.h>
>  #include <linux/vmalloc.h>
> +#include <linux/swap.h>
> +#include <linux/swapops.h>
>  
>  #include "internal.h"
>  #include <asm/dma.h>
> @@ -771,7 +773,7 @@ static void clear_hwpoisoned_pages(struct page *memmap,
>  
>  	for (i = map_offset; i < nr_pages; i++) {
>  		if (PageHWPoison(&memmap[i])) {
> -			atomic_long_sub(1, &num_poisoned_pages);
> +			num_poisoned_pages_dec();
>  			ClearPageHWPoison(&memmap[i]);
>  		}
>  	}
> 

Reviewed-by: David Hildenbrand <david@redhat.com>

-- 

Thanks,

David / dhildenb

