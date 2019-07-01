Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9BBE2C06511
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 17:43:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 626BE21721
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 17:43:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="QnUrJklG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 626BE21721
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=roeck-us.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D94518E0003; Mon,  1 Jul 2019 13:43:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D45008E0002; Mon,  1 Jul 2019 13:43:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C32FB8E0003; Mon,  1 Jul 2019 13:43:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f205.google.com (mail-pg1-f205.google.com [209.85.215.205])
	by kanga.kvack.org (Postfix) with ESMTP id 899558E0002
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 13:43:41 -0400 (EDT)
Received: by mail-pg1-f205.google.com with SMTP id d187so5383724pga.7
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 10:43:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=HhNv+wbN0VpJBBUB5um1iIUQWl9GFxBZ8169m9nMh1Q=;
        b=TKcK90IfGKEep6dE4SXWu8/HtIbWGApV05buiTkYTfZ65dtIHEfJHFVVK+MY9V7Mq3
         nEtpNsNtldqUPZjaGlMR4Z6awWxx6CJ9uNNZOEbRsIho7aHF+QsoCqpr0Sg6wZBRdW2u
         j/53bpmBcEAoqjfpe0bOt7iUztDC4BW9IqAdV4arffLqWb1xLUQ2Gv1hdmFgcInoMBSl
         aHqpD+k1cIvZax92krAGhWNwGSHqcoG3kyvXbBlSvnet7VwSl/+N0IrX+iaDdcOuvw4Y
         X1/u65OuuzavvYlbtS5lVypcu1vvCQ4odqlresk6TwzphDMwwtosAxiYjrR5Z3sZwxib
         8lWA==
X-Gm-Message-State: APjAAAVc8fqX6KFZombztmPH8VWojqlPtqMdzJ3gPCarCdFChw0LWDlQ
	unEmtTqYSl9dHarwuAla+WVM0edkMW9JuDLAIAic+KYIVrrkN1WviC1dbt9Xtlc2Ck0FUJzl3jI
	TUjDHbxrdT/5o1vPOhpYqhuH3LVF6V30FhRAFVMytkk2fMafNDrdi5x6W47Qpkhk=
X-Received: by 2002:a63:db49:: with SMTP id x9mr25153980pgi.93.1562003020687;
        Mon, 01 Jul 2019 10:43:40 -0700 (PDT)
X-Received: by 2002:a63:db49:: with SMTP id x9mr25153935pgi.93.1562003019784;
        Mon, 01 Jul 2019 10:43:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562003019; cv=none;
        d=google.com; s=arc-20160816;
        b=Qyl+YZFy5B2jwVxJfoCMVV2gwEc0JewpTYdzRPKuuPAfLZcIuRLx55IdbQLVnQPFJc
         fGAVmp+fALjrEKFbwgZ/KYQ6TUUBMXg815FUGTG15u6fQAvIv8c+q1pvkLIhoTMKO+R+
         uglAifaIkpXbgV1n2/LqQU9+ZV4XihvT86MazBzXS4ricpJlhoXRE0wSwhnPp+2ubjH2
         tCUW0yYqwDk3qdv+Z03psUwOlqxB5E1yghMgzhHjTL+vU6aHnI8Kv3cDyRGmyUU/dBoB
         iCpvYkd7M187hcElaVZ2CeQPKgYYswWSOH1AvPxPHKJMiIpfY1Sm7EOPU0VW1tzMQxdp
         jBjQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=HhNv+wbN0VpJBBUB5um1iIUQWl9GFxBZ8169m9nMh1Q=;
        b=0X6arPFP7HNmrcrO9gfnkKxO9lNMdIHi3ct6677B4Ku6XEn+cHDhT5n0LgyCnwdgJQ
         2Odej73jxpNs77ReN9huQVJ6GidamCiLBoUclnoiw+vBvVZByC61761kVihS0DMYkNcJ
         w2pnKugtsh3/0xmyFORaAwo2V/FpuQBpHroQiSOw+BlDgzNTczEbqFD5cO3dFD1B7Y0F
         wO+r9hYX84FBR1zKXvsAHCcnw0n+u809xUPHPOQbW2vRpHCyWrTKYUjYa1XlcjB89WZ8
         R2jvH4NjnPGOy75QvSMfdtyKrttshD0sXx/lYoyX/OvFSR/dzqjFMALYflB0/fisC3rL
         h3uw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=QnUrJklG;
       spf=pass (google.com: domain of groeck7@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=groeck7@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a68sor805722pje.1.2019.07.01.10.43.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 01 Jul 2019 10:43:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of groeck7@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=QnUrJklG;
       spf=pass (google.com: domain of groeck7@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=groeck7@gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=HhNv+wbN0VpJBBUB5um1iIUQWl9GFxBZ8169m9nMh1Q=;
        b=QnUrJklGkONB4oUCSDM4a5/B9AjR3Ueaf5s+tdYxalrXDIZ0GhwPNWh42efZy+I5Xn
         92xwnF53ODnXP+9sgmpHBhOOjpqV26b7+42ZRPRk6xmPRdVvaelDyd3gdjMqsdRq/vVa
         8YXYcTOWru/z0aXw/rgdkrtxHNhCM+U+r4yigeD0tzmNZQ3ULfNBd8aAMi0i3695b5nT
         F1HwO7xsHq4XhurMKHyvX1NEG99wq6nwqu60ustJ17VW/xG90UOMVfp7Ho4LClGJSQ0Z
         QXENjnc9l7y8HixsJptV+PVZ60bswk6qfv+VYe/owAsnVnEH+PPu3khpsm9JBrEGafVn
         zoAw==
X-Google-Smtp-Source: APXvYqyplVhpDW5rDBLRdETRKZqEF+2npSCxstRykGDoDFKPjD1Lu6ZctfD97RsU9C2mhJ/QiLiPig==
X-Received: by 2002:a17:90a:2008:: with SMTP id n8mr536465pjc.4.1562003019392;
        Mon, 01 Jul 2019 10:43:39 -0700 (PDT)
Received: from localhost ([2600:1700:e321:62f0:329c:23ff:fee3:9d7c])
        by smtp.gmail.com with ESMTPSA id x1sm182418pjo.4.2019.07.01.10.43.37
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jul 2019 10:43:38 -0700 (PDT)
Date: Mon, 1 Jul 2019 10:43:37 -0700
From: Guenter Roeck <linux@roeck-us.net>
To: Christoph Hellwig <hch@lst.de>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>, linux-mips@vger.kernel.org,
	linux-sh@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 1/2] sh: stub out pud_page
Message-ID: <20190701174336.GA24848@roeck-us.net>
References: <20190701151818.32227-1-hch@lst.de>
 <20190701151818.32227-2-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190701151818.32227-2-hch@lst.de>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 01, 2019 at 05:18:17PM +0200, Christoph Hellwig wrote:
> There wasn't any actual need to add a real pud_page, as pud_huge
> always returns false on sh.  Just stub it out to fix the sh3
> compile failure.
> 
> Fixes: 937b4e1d6471 ("sh: add the missing pud_page definition")
> Reported-by: Guenter Roeck <linux@roeck-us.net>
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Tested-by: Guenter Roeck <linux@roeck-us.net>

> ---
>  arch/sh/include/asm/pgtable-3level.h | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/sh/include/asm/pgtable-3level.h b/arch/sh/include/asm/pgtable-3level.h
> index 3c7ff20f3f94..779260b721ca 100644
> --- a/arch/sh/include/asm/pgtable-3level.h
> +++ b/arch/sh/include/asm/pgtable-3level.h
> @@ -37,7 +37,9 @@ static inline unsigned long pud_page_vaddr(pud_t pud)
>  {
>  	return pud_val(pud);
>  }
> -#define pud_page(pud)		pfn_to_page(pud_pfn(pud))
> +
> +/* only used by the stubbed out hugetlb gup code, should never be called */
> +#define pud_page(pud)		NULL
>  
>  #define pmd_index(address)	(((address) >> PMD_SHIFT) & (PTRS_PER_PMD-1))
>  static inline pmd_t *pmd_offset(pud_t *pud, unsigned long address)
> -- 
> 2.20.1
> 

