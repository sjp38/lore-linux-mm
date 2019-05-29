Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 78642C28CC0
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 21:49:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2C08524233
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 21:49:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="Wf55BD5K"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2C08524233
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A2CB66B026A; Wed, 29 May 2019 17:49:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9DFCC6B026D; Wed, 29 May 2019 17:49:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8CCFB6B026E; Wed, 29 May 2019 17:49:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 541296B026A
	for <linux-mm@kvack.org>; Wed, 29 May 2019 17:49:12 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id o12so2435454pll.17
        for <linux-mm@kvack.org>; Wed, 29 May 2019 14:49:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=dgjJaXJPVsrVv2lY7IEt+Kdm/on9SCFJE7O5oW/AEeE=;
        b=UvnVqdC8vS/au6LtWIFvTGEpEcNQ6EzZQnt4vTedcTsUwY5CAj74v2QSPzxWXiHt8E
         pNCsNmxX0OHyNuv5fvvD2cIuzUEbF+kTiJcrQOHw9OKl6A8fj5ytfiblAMm6q+qT8W8S
         SHHdJ6OW3r3/WDTibl5iWGoi9YJCPULxl3yRnWnE4ZoNpqwU1lHGjydLmWRGUu87o0zu
         GIkYsIcJVOVGr5MXJPDxrE8S3WBRwAVKjKXd3W4LZq20FTEJb3ncnPg37XyGLleVem22
         9l38Ufm4P7MpO9VVrvxwrFrX62lwgsyXA1WFTIsMkpe+gbfOdH4WEDwbriycRAnlT0Af
         RFqQ==
X-Gm-Message-State: APjAAAURxc8ADSirU3fotmd1WV5lGUvne1sH9cvNNIh0ndHuS6uvYgZ0
	BBgwfRU4m1WwknK4nCnQOCE7yy8EHvIzCidaFz7iP1aYKVTHwNBvMMozyC9x1mGw/57d9GotQ6v
	V8DcDlj8/PFHileC3XaVKaey6Ib2NYIjQ2Ky5VXBy/AYoOCU4wHO+7ZZLcQxhh93FgQ==
X-Received: by 2002:a62:1d48:: with SMTP id d69mr48667693pfd.200.1559166552001;
        Wed, 29 May 2019 14:49:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyphrMFk1TOrF689wjNbg/fVUzG8QGUlKivAU2Uf7NqBqqZJDRbo49ejs1aAFqz4qIWr6r3
X-Received: by 2002:a62:1d48:: with SMTP id d69mr48667610pfd.200.1559166551245;
        Wed, 29 May 2019 14:49:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559166551; cv=none;
        d=google.com; s=arc-20160816;
        b=lxf7ato35MmiRj1Y5R+yAIB+YGl5koMr4Vnciu0Q9tb3sI5IzX2cxRXSrrVhsZ8SD1
         UleNa98LTN+lYdXJPyzKz2mtEuVIJMxsLJQhRus4CNhTaxfeYr7Sx6bEj7hwpT/+DeTh
         SSkkIEOkfbbjrZGRSso/SahwGisV9ZUsXApJhfGah5DAuDv2GmdlGW4CANz4WyR0K1gp
         gZtWlCQtd4jIOPi4JdKMha2eRS9WSsQLMsoL34fyvlJTjKzZwQHa310bAPsvIe6XL2je
         16DIlTMubifsMUQOOjjMrk1JbWGK7NL5oLas7cUav/DoIQQM2bDzeoEjFG4vvhOes01I
         Bypw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=dgjJaXJPVsrVv2lY7IEt+Kdm/on9SCFJE7O5oW/AEeE=;
        b=cyOJQwuAhqlvqinu0s9vWXTZ6ai8cpwuznRxQzccOpGo5Lth4y3pI7nJXc5+eIp6UO
         D8pVMVHtKmtE8X6jTZ7bto9H79d76l0ntB51GO1TLSNihiAdBofDUg/83Pj3NruDhlaU
         S7ica9r+GMiAD7FCh0qxZSuZjfDD1E/Ak1ZoPdhk0KiV159xqmAIkvTeYaHS+zMaUN6M
         p+d4fgsAiX+ZdL0meSqAFy+4XnOyFbH8YrlbOx5FOEZXPJAK7Qw+VFK0sD9Ntkx+WzFb
         +4PsfRYIy7MpLr3LuSbyxRKQJv9eDdWTsF2i/vrrj2U4/IGmG0FfUMdMkAujvYGVz9YF
         KV6Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Wf55BD5K;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id q20si1082589pfn.139.2019.05.29.14.49.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 May 2019 14:49:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Wf55BD5K;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 9963F2423C;
	Wed, 29 May 2019 21:49:10 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559166550;
	bh=FVH6NNAi5HO6QsvJGY18Plh92DIzDmt5SHysKjb8+bU=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=Wf55BD5Ktdw3sjWJ2veiKFOOq0aFCPmEDFNzHNcitEp6FJCgRVTUN8O1zxWXqqUuN
	 Rdxb7iJibqvgbq1txp+3TfHc+ms5VJoz5kd1pel4yZn/pa3euMyLnONnwymUx5PJuW
	 HGJzTKE+MNnJYcU6goT8RycOZtCDEKWHkgAmqRjg=
Date: Wed, 29 May 2019 14:49:09 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: kbuild test robot <lkp@intel.com>
Cc: Robin Murphy <robin.murphy@arm.com>, kbuild-all@01.org, Johannes Weiner
 <hannes@cmpxchg.org>, Linux Memory Management List <linux-mm@kvack.org>
Subject: Re: [liu-song6-linux:uprobe-thp 92/185]
 arch/arm64/include/asm/pgtable.h:93:27: error: expected identifier or '('
 before '!' token
Message-Id: <20190529144909.5611892fc595554301780597@linux-foundation.org>
In-Reply-To: <201905291549.xlVZd4Ss%lkp@intel.com>
References: <201905291549.xlVZd4Ss%lkp@intel.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 29 May 2019 15:54:52 +0800 kbuild test robot <lkp@intel.com> wrote:

> tree:   https://github.com/liu-song-6/linux.git uprobe-thp
> head:   950e997c620db50b4f7e578631f6c8b0e1315778
> commit: 5760548d3bd197b0858ccaf3ec8039aedba5832f [92/185] arm64: mm: Implement pte_devmap support
> config: arm64-allnoconfig (attached as .config)
> compiler: aarch64-linux-gcc (GCC) 7.4.0
> reproduce:
>         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         git checkout 5760548d3bd197b0858ccaf3ec8039aedba5832f
>         # save the attached .config to linux build tree
>         GCC_VERSION=7.4.0 make.cross ARCH=arm64 
> 
> If you fix the issue, kindly add following tag
> Reported-by: kbuild test robot <lkp@intel.com>
> 
> All error/warnings (new ones prefixed by >>):
> 
>    In file included from include/linux/mm.h:99:0,
>                     from arch/arm64/kernel/asm-offsets.c:23:
> >> arch/arm64/include/asm/pgtable.h:93:27: error: expected identifier or '(' before '!' token
>     #define pte_devmap(pte)  (!!(pte_val(pte) & PTE_DEVMAP))
>                               ^
> >> arch/arm64/include/asm/pgtable.h:390:26: note: in expansion of macro 'pte_devmap'
>     #define pmd_devmap(pmd)  pte_devmap(pmd_pte(pmd))
>                              ^~~~~~~~~~
> >> include/linux/mm.h:540:19: note: in expansion of macro 'pmd_devmap'
>     static inline int pmd_devmap(pmd_t pmd)
>                       ^~~~~~~~~~
>    In file included from arch/arm64/kernel/asm-offsets.c:23:0:
> >> include/linux/mm.h:544:19: error: redefinition of 'pud_devmap'
>     static inline int pud_devmap(pud_t pud)
>                       ^~~~~~~~~~
>    In file included from include/linux/mm.h:99:0,
>                     from arch/arm64/kernel/asm-offsets.c:23:
>    arch/arm64/include/asm/pgtable.h:549:19: note: previous definition of 'pud_devmap' was here
>     static inline int pud_devmap(pud_t pud)
>                       ^~~~~~~~~~
>    In file included from arch/arm64/kernel/asm-offsets.c:23:0:
> >> include/linux/mm.h:548:19: error: redefinition of 'pgd_devmap'
>     static inline int pgd_devmap(pgd_t pgd)
>                       ^~~~~~~~~~
>    In file included from include/linux/mm.h:99:0,
>                     from arch/arm64/kernel/asm-offsets.c:23:
>    arch/arm64/include/asm/pgtable.h:641:19: note: previous definition of 'pgd_devmap' was here
>     static inline int pgd_devmap(pgd_t pgd)
>                       ^~~~~~~~~~

Thanks.  I guess we need some `#if defined(CONFIG_ARCH_HAS_PTE_DEVMAP)
&& defined(CONFIG_TRANSPARENT_HUGEPAGE)' sprinkled around.  I'll drop
this copy.

