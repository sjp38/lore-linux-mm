Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5A1B5C2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 14:25:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2C9F520657
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 14:25:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2C9F520657
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C1E8E6B000C; Fri,  7 Jun 2019 10:25:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BA7F46B000E; Fri,  7 Jun 2019 10:25:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A96346B0266; Fri,  7 Jun 2019 10:25:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5799B6B000C
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 10:25:39 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id f15so3414016ede.8
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 07:25:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=IQrpfQ+m1NZt4S5yJ9zkkEMPXPEj51lrA5OK0uHFPuM=;
        b=GhCSL1A091eE6FjHERykLAdiQiU//+btJylqKl5QtKa7mB1t5aNyXMgKwzXbiOVaAj
         AgT7ZCq0DfeM7U1lZrq44W4OV1zohDweaEULe5ZKDtMKliShS+0JXNu2+2WpUiYbC1gi
         q90QM2Xb8Qi/YNaFki6XdXiA4BamA3AgKj1KaiDdA8x0B8wBDhY5Ncl46ijZQUn90sQR
         i5R0wj3JCKWZoIUDT5pTxqX8i+53UY2YQKAY5g5vTslrr03SERgGBejKKnwIWeUFKbBl
         bT9OFoZJjSsKA8Ywmym3vl5CR0V7zrruz1cfPVTmG19aXfVbmvvwGX6Q+56WkAO0XPWy
         puMw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWXhv+3SRabnFnVqxdUJItpFd0afVZf+PKgWLr1NWwnPGX6/j8v
	Ydl0vccDxgkB0t59ZsZ5wTqhuXtOqBqrQYh4ea2G6Clxh/nqD8kCI+qY1YrDkgHBRGg+Aa9jWzo
	MgvMRQnsjPXR2KciERtuBIiU+OKmkytng0rGHLPp7XIGqM/uGbevmjLUVfjDqiek=
X-Received: by 2002:a50:b48f:: with SMTP id w15mr9526235edd.260.1559917538924;
        Fri, 07 Jun 2019 07:25:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzN60MO5/r/z4eKE45Y0fjb5cTvCyAL4jdzlzaN9IXZSqVMWIRYDmjsCQZlcdg5BUCvCTi2
X-Received: by 2002:a50:b48f:: with SMTP id w15mr9526075edd.260.1559917537421;
        Fri, 07 Jun 2019 07:25:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559917537; cv=none;
        d=google.com; s=arc-20160816;
        b=tJOkR1wAhS2MtopDHFafUd/Tq3IOhf0tSXzbNItnu/AU7Q8ERuj1qGJx1QK6Im4dw/
         Byxvaj4Wg9lV7J/Y/yhQWis7i5JGkz8/1D3rHAwCbVgYUmiCR3hPnbHD8W4O7TiUzE0X
         SvGgMeveQ1pH/9h9z0L6J7Cg19cjeMtNdjbuPioG4x9uO4RFO5bW6KG9EOOi/1FOAPmg
         dhk4pNxX2+upeMOEZJflvHYP6p3w9ADMmDS7MAcc5AGqA3gasU8W1sF7VNiFELW20CXs
         2pt9T2CRykwXsguf1YURNpTB2PRx7WqkWnPrcFqdvY0c0lyMiohW0+Uf6xKyXcP8xxwd
         iUfw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=IQrpfQ+m1NZt4S5yJ9zkkEMPXPEj51lrA5OK0uHFPuM=;
        b=R27NbupM4UaYksncQ2fxv6SCprgcdnppl7aInIrxE2GC/M99PB09+HNgcJqxALvWop
         z5GZ7l6E3I7cuO+DViUGH2g7ed/WSnp1RJNdTr/W0rbI3pbNOUjah5LtFWtUxzyojCBH
         +7E3o+Q4a2tSLIYhXyNN+9p7dqIpGaVMD9zU/GT9nnARt5pExtNBp9E+vfm3hJNkul13
         nf7x19tSr5GJIv+ln/Y/1831Hw3Tbf8ik8jP7/VRKPKIfoOroGeTbCPnS1Ng7gsB+sMm
         JUhACobQb7PguSP6/bmcdo9y6jWxkjdu4E1BGA1FRbtpSPopvzwfA0oqDoJWN3qCgEYY
         NWnw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x23si1454062edb.431.2019.06.07.07.25.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 07:25:37 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 94217AF05;
	Fri,  7 Jun 2019 14:25:36 +0000 (UTC)
Date: Fri, 7 Jun 2019 16:25:25 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Hugh Dickins <hughd@google.com>
Cc: Yang Shi <yang.shi@linux.alibaba.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	vbabka@suse.cz, rientjes@google.com, kirill@shutemov.name,
	akpm@linux-foundation.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [v2 PATCH] mm: thp: fix false negative of shmem vma's THP
 eligibility
Message-ID: <20190607142525.GH18435@dhcp22.suse.cz>
References: <1556037781-57869-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190423175252.GP25106@dhcp22.suse.cz>
 <5a571d64-bfce-aa04-312a-8e3547e0459a@linux.alibaba.com>
 <859fec1f-4b66-8c2c-98ee-2aee9358a81a@linux.alibaba.com>
 <20190507104709.GP31017@dhcp22.suse.cz>
 <ec8a65c7-9b0b-9342-4854-46c732c99390@linux.alibaba.com>
 <217fc290-5800-31de-7d46-aa5c0f7b1c75@linux.alibaba.com>
 <alpine.LSU.2.11.1906070314001.1938@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1906070314001.1938@eggly.anvils>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 07-06-19 03:57:18, Hugh Dickins wrote:
[...]
> The addition of "THPeligible" without an "Anon" in its name was
> unfortunate. I suppose we're two releases too late to change that.

Well, I do not really see any reason why THPeligible should be Anon
specific at all. Even if ...

> Applying process (PR_SET_THP_DISABLE) and mm (MADV_*HUGEPAGE)
> limitations to shared filesystem objects doesn't work all that well.

... this is what we are going with then it is really important to have a
single place to query the eligibility IMHO.

> I recommend that you continue to treat shmem objects separately from
> anon memory, and just make the smaps "THPeligible" more often accurate.

Agreed on this.

-- 
Michal Hocko
SUSE Labs

