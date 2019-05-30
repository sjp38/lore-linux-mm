Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B774DC28CC0
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 12:08:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 783672054F
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 12:08:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="zXrO8KZU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 783672054F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1DCA76B026B; Thu, 30 May 2019 08:08:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 18D3F6B026C; Thu, 30 May 2019 08:08:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0A3936B026D; Thu, 30 May 2019 08:08:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id B03F66B026B
	for <linux-mm@kvack.org>; Thu, 30 May 2019 08:08:23 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id k15so7450190eda.6
        for <linux-mm@kvack.org>; Thu, 30 May 2019 05:08:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=pTUXDtN/G8tAI7G/XWKZT9rjJMafN/rAkwsNs0hRrJ8=;
        b=UlijBII+h7BYScoEiho0t7Zrw1IaKEKuM5S+Ht/OX/iDflTTnoUOpI3PKnV8jgb50A
         gUZmJhVVxCKMl9C56+1XVuusGdOvDL8MahhYxy/YG2I2tFKt2BOk/Ym3bSc4h6D0OQPy
         7eb8u9sY04ofaKVxzhCjSQLsTaNiKe9Wx7xWWP0ce6yDU3C6mjyX7TQM5gBgTxXE0jXQ
         HpbL8IymEFl4OqHKpzr/PDpSaJX9KFELdZpf+UFxaJjG3bugP/9PQYnCMmXFMZsqQb86
         V2e0DAf7YLnY4jlnxFsJxE/jQqbzmliAnIXc5NelQpUoblOFj2T2BB1p5QewscCmL4Ol
         7SQQ==
X-Gm-Message-State: APjAAAXTvesZWE/RnFBycA53McurpVb/pfAgRladEH2wunBp4KI2hvXB
	f/g8g+qRbsa9w551/Qq6AkTe0TqmH0S9qJASl1Dpv0IBkYItIsOPfpfr41ESKqLmABJPz73rwl1
	5id+XweOC+DZYmt1UZ+M8CXtEcfl2XFXF/JoSaFV7jd392Hq1LHB3GSXEd+clXANa1g==
X-Received: by 2002:aa7:c554:: with SMTP id s20mr2475409edr.15.1559218103305;
        Thu, 30 May 2019 05:08:23 -0700 (PDT)
X-Received: by 2002:aa7:c554:: with SMTP id s20mr2475331edr.15.1559218102639;
        Thu, 30 May 2019 05:08:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559218102; cv=none;
        d=google.com; s=arc-20160816;
        b=BHNQ1cmF/8VQ8jt4EuzJwb0l0RAj9/YE3xQS455MlYodHLQh2tPzPzKaKfqVCy47OB
         92+ZxDU6lpve6TQRFclANG+Vme3iww+r7hxcusBLklzDQO/xilSHGSi41Icq/O7VuLUO
         nhoVXHUboajeGYLaTyBLMYMFpDjVz5stKWOF6YVbmA23git7PujWs0o2JvHESUAzdzBr
         Vwbt2QbOoBI+f4PII/TNpJ0VT0vfziJWS7h2VLBJGmZWfYhu/rfAMlRzVYv6wPHNuvEy
         uyYHnYh+YxsWdpXYGoceJc4oBk5zi5cue12018K2ONuh21o79dmakpbVGznBq25iNSZG
         i1Bw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=pTUXDtN/G8tAI7G/XWKZT9rjJMafN/rAkwsNs0hRrJ8=;
        b=oD/UF1J/I2otfP23UF9IkcZar5x0UdD3aRxhqXx4zQT3ligXINhVYFL05RbEZIVRV7
         7kU0CneFk1bCXPxvMxmNifmI8fLXxUGqKrgZE6Mm2pxaFrfDUD6ppHxGjgVmTCOF3T8r
         ItzRsxV+iTYXhY8jL/O127hqKWrbJ9uDTZ0QuCJN9geGL2r30Is+uZyeo+9bACFl+Rap
         wgeWqmcaXhzfPRp6FpvubsDxV5BpnkTh8xEE9yGh9evEvukLYoOFuG8VoAlO6SI9fPIx
         Shnafl4mTQ4RYAUhxUBdGSm9ay0qz98SpK45tmSj9mNmfizK5Kii1LTbljei5/dBnnQh
         8mZg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=zXrO8KZU;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z13sor762225ejq.62.2019.05.30.05.08.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 30 May 2019 05:08:22 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=zXrO8KZU;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=pTUXDtN/G8tAI7G/XWKZT9rjJMafN/rAkwsNs0hRrJ8=;
        b=zXrO8KZU/bIpALQ5nQ7nlUslj6ODQZSWnIyQchfuY9cAMGZ6QY9HVEbpN44ZVtsAtY
         UcSf2lRJYAfprTOv2qmbx5dCYaJeK2Fv0x9uGw9JH7dQnmjw6YQVVE7aKd08Nlg2knEE
         opr44llZBxLoORCxnLzANIKsBMHOI44URrT5ObPeEdkHJgOqQhYmoyrZ9WWZ+gVAKfpJ
         jNlu3NTUpT93k9miVXATJVKEk6pFx2oJu91CNQu3OreOVJHN7y0EYVRnhdJ5FiIKNqdR
         Ent82r0XiPyT3XwYoZM5/j7npQnH8q9TneS+HpniB0NkkWt80uVODvzr9oD2RJR54Ha0
         M7qQ==
X-Google-Smtp-Source: APXvYqzKJsNIKOFT+ULZ9yJACrnn3QN4bI+DsmkrXTovJ/S8j3DqZH7dMiwGajoNuYn3Y8aUpYhN8w==
X-Received: by 2002:a17:906:470a:: with SMTP id y10mr3092113ejq.238.1559218102315;
        Thu, 30 May 2019 05:08:22 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id p27sm401293ejf.65.2019.05.30.05.08.21
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 05:08:21 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 6FB831041ED; Thu, 30 May 2019 15:08:20 +0300 (+03)
Date: Thu, 30 May 2019 15:08:20 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: ktkhai@virtuozzo.com, hannes@cmpxchg.org, mhocko@suse.com,
	kirill.shutemov@linux.intel.com, hughd@google.com,
	shakeelb@google.com, akpm@linux-foundation.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 3/3] mm: shrinker: make shrinker not depend on memcg kmem
Message-ID: <20190530120820.l5crrblgybcii63f@box>
References: <1559047464-59838-1-git-send-email-yang.shi@linux.alibaba.com>
 <1559047464-59838-4-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1559047464-59838-4-git-send-email-yang.shi@linux.alibaba.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000002, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 28, 2019 at 08:44:24PM +0800, Yang Shi wrote:
> @@ -81,6 +79,7 @@ struct shrinker {
>  /* Flags */
>  #define SHRINKER_NUMA_AWARE	(1 << 0)
>  #define SHRINKER_MEMCG_AWARE	(1 << 1)
> +#define SHRINKER_NONSLAB	(1 << 3)

Why 3?

-- 
 Kirill A. Shutemov

