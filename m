Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_2 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CA096C7618B
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 14:11:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8DBB421BF6
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 14:11:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="gTXhj9Zq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8DBB421BF6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 33CD66B000E; Wed, 24 Jul 2019 10:11:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2ED7C8E0006; Wed, 24 Jul 2019 10:11:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1DBEC8E0002; Wed, 24 Jul 2019 10:11:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id F1D3E6B000E
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 10:11:08 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id k125so39355350qkc.12
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 07:11:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=XSMSBO973DfvMeeteXqgGKF7W2+Loe7uKWtbLSmRJp4=;
        b=eSSkBzWZIgrr/C4kr3VCPAHnbBU9NGEB/s8tLd897ofZU8z6ZW8uX6fBRbN7bbTiQD
         z/hyMuo3grndhVMkm4cM/UQcsuPLZMmOSAFGCf3+1JGJwWHbgH/bewvx7ALJi37/SjCL
         16LuESYCqXnhePeUdWmS2bCHAHicX7cyv4+W3p7HC1zk5Aglo2EuWUXDN5k5oZXTAPjI
         sVJeFoPm7XAkv8pUQLSkWtu2sHc2SbBezNLJdwRuwuekvCECh1gZyHSttFNb9mlQwMxM
         Ko1iMTvO7+Aj90Mu8poLjrg2D0rSYe8N1+OCHd4qC4Lnv2DOCacqKleBDGZwq4Z3LHO9
         FbNA==
X-Gm-Message-State: APjAAAVC2smDSf0qm/LUy7L/EoYzOD6RHfpzyam+hRpRfrDCD71H97ui
	OIR+bqtVEMLW3Sn01kcqJ+tzmUNJFGBs40ht45yoN3UFzQSTAXmx4zTE3nQp/2mJE131nLnzxwf
	giOVaudh03y1c/G/JvVSfJc5mOC+YrESJTlc20gCvL+vumaoe1rv7ApNWur9WIIGD1Q==
X-Received: by 2002:ac8:244f:: with SMTP id d15mr55437732qtd.32.1563977468722;
        Wed, 24 Jul 2019 07:11:08 -0700 (PDT)
X-Received: by 2002:ac8:244f:: with SMTP id d15mr55437667qtd.32.1563977467938;
        Wed, 24 Jul 2019 07:11:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563977467; cv=none;
        d=google.com; s=arc-20160816;
        b=NKwfLIaMazTbxmlASKXvdjZl5UljCpukJ427YEuKRAeA3vZofdlhUsfwl43PDCCLvF
         gEHwTwyaq1FJ/BaX8gH07PTUp4CFNJm0w7iHMzRZh6NYZ1uQchWb9ARL9JjDbTVmq7y0
         REXP3FPaYjD5U6JW04EKuo+Wu8+eoSp18lwxE7aTqLIfUeOxPssN0EP8eYNuXwkxMlkq
         R1EVxsmfEVF7TS4SuqmTPr944Sljzuly3K54fjYetEF+/jW7wQtKE8tY5T/JxuxNZR7r
         dVF/2J/7EzXekOtJ3FNxtnk8JN/oVM68f0CxttONgtzMVoPCbS+Qd2PwkY80yILZIMYn
         nVYg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=XSMSBO973DfvMeeteXqgGKF7W2+Loe7uKWtbLSmRJp4=;
        b=vDA5gJruTxBTIz5iAR+RH+l7OEbfCwa4KP/cMOQV6eUpm+r8NW0HhWWc13u6tuABzm
         sgWzuly3l+/UYyORKtOUdX5yEYfFTs2dnqeRFatRSPVcy9WSQGtgRo8iQMBoOzbK/BoF
         hGDU51IkvLdmus48IFUHrntiIRzlyYplXgAJclsJlgXDkjLgUtY23RlMPA+BeYewoPBc
         j5+G/I6EhWrTAEQXDotEfpxO+Yu77IAjlWWQw/PjhjvbBREP4xoBtw170fQp/sRu40fi
         ZL1EPXCzd1oeqAkOWJbZ4T9U9NUbWqUgQ5S5ioLdc2G35nKTFXHbkl/Zapx4seyKNDUh
         LCRA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=gTXhj9Zq;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x19sor61700406qtq.45.2019.07.24.07.11.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jul 2019 07:11:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=gTXhj9Zq;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=XSMSBO973DfvMeeteXqgGKF7W2+Loe7uKWtbLSmRJp4=;
        b=gTXhj9ZqVqh/c1Tlp0kQKLmIeOJZ9I0W7iJFijeEbYc2pw5WqfBaHyQhl/qzepZJlM
         infzsQJLb6v93ckbqBV7S4YQa39ItbL+e6nnT2zbh2KV3vK9UtV6EzNmp94ycAMB1PUP
         atzF38AlS0gWScipZSZVHIq9i57oaULt3ldLlCTsYx28piF73voCpHpl7b/DOKE6ELrD
         mwIezPCPGgOTGcpKkEbaGHZHCB2MeHoJxwuArMiAJFxhHUOmsSfckuqq/kkciwpYzhlD
         CNSrJEALAFWZKGCY85HLPMPi/4ZUb1MQOZuknR+CuwqWRTiFtOj9ESf4E4PNr9UjN6kR
         aNFA==
X-Google-Smtp-Source: APXvYqy0tj9o47/lvntHG1UXs42ZsSWDwBvJZWHf+0IOq45oHpMmcsWa56sAZ9oeA906uiVqylpMDQ==
X-Received: by 2002:ac8:2642:: with SMTP id v2mr55104887qtv.333.1563977467644;
        Wed, 24 Jul 2019 07:11:07 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id r36sm24461459qte.71.2019.07.24.07.11.06
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 07:11:07 -0700 (PDT)
Message-ID: <1563977465.11067.9.camel@lca.pw>
Subject: Re: [PATCH] mm/mmap.c: silence variable 'new_start' set but not used
From: Qian Cai <cai@lca.pw>
To: YueHaibing <yuehaibing@huawei.com>, akpm@linux-foundation.org, 
	kirill.shutemov@linux.intel.com, mhocko@suse.com, vbabka@suse.cz, 
	yang.shi@linux.alibaba.com, jannh@google.com, walken@google.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Date: Wed, 24 Jul 2019 10:11:05 -0400
In-Reply-To: <20190724140739.59532-1-yuehaibing@huawei.com>
References: <20190724140739.59532-1-yuehaibing@huawei.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2019-07-24 at 22:07 +0800, YueHaibing wrote:
> 'new_start' is used in is_hugepage_only_range(),
> which do nothing in some arch. gcc will warning:
> 
> mm/mmap.c: In function acct_stack_growth:
> mm/mmap.c:2311:16: warning: variable new_start set but not used [-Wunused-but-
> set-variable]

Nope. Convert them to inline instead.

> 
> Reported-by: Hulk Robot <hulkci@huawei.com>
> Signed-off-by: YueHaibing <yuehaibing@huawei.com>
> ---
>  mm/mmap.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/mmap.c b/mm/mmap.c
> index e2dbed3..56c2a92 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -2308,7 +2308,7 @@ static int acct_stack_growth(struct vm_area_struct *vma,
>  			     unsigned long size, unsigned long grow)
>  {
>  	struct mm_struct *mm = vma->vm_mm;
> -	unsigned long new_start;
> +	unsigned long __maybe_unused new_start;
>  
>  	/* address space limit tests */
>  	if (!may_expand_vm(mm, vma->vm_flags, grow))

