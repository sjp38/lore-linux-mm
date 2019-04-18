Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BBB17C10F14
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 20:30:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6DD8F214C6
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 20:30:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="SwnFKNon"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6DD8F214C6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 10A906B026B; Thu, 18 Apr 2019 16:30:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0BC8E6B026C; Thu, 18 Apr 2019 16:30:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F120C6B026D; Thu, 18 Apr 2019 16:30:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id B8A246B026B
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 16:30:32 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id g1so2073897pfo.2
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 13:30:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:dkim-signature;
        bh=T3JD0sgSOXk1vRSr1uVe9SorhMd4n+SS+HWTi6IFNCc=;
        b=BcFzkWm93k7VwTiu6quOXT2eXcWvpY4nzVAiVbTIgkoQMEuT4SWo7yrrBqldEH8HjU
         eRXDNEqCGbYMp6UqXzVBEk1cigF6cHEUjhXJpiYN9hTl7xTCc20K0DrsyNEaf6vsinzt
         6XXIx1rhGLzD1qulXa7wpWHKJjOEdZQ+l50BuMjnimNh1CO3h5Rwk7FzKV2p+FPbFVIg
         ehqOgoW1SxDR5KocsThy8KDJuBgvHhTSLl3szDLaS5GrVEs7I/9fzMYDAAbotDkSc2jT
         7n/3pCzVIVL0mRqZy6zbHmyEFj7qPmhXj96/G0UL5r/eUUjPIhs12kzxLjpPBlFQPIFV
         BzLg==
X-Gm-Message-State: APjAAAUbWQbwIzrUHeFJhX4C4zfi8DoGn8fNOXVvex1VuFwHusYZ8MkJ
	DRTfPh+wfQ8spjG4eD6NPdLWpUsQ4dIEOcta1SZtdVQZazy0kbI4DkcI7EFfh1SRhgS2n5LThmy
	OcMT7CQvknDdIh2z81k1SthwKe8iyg3KEDF322YP9hQ3cRPLLBYr6XT5RrRfdMj7rAQ==
X-Received: by 2002:aa7:86ce:: with SMTP id h14mr99232947pfo.84.1555619432345;
        Thu, 18 Apr 2019 13:30:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy/l7C4IvN7w5AjQBtmV+Fc5JLiMnzxUPAMX/aZMM6jbj7caC9vzdSSVOJhIrr+RWkkSaOq
X-Received: by 2002:aa7:86ce:: with SMTP id h14mr99232893pfo.84.1555619431710;
        Thu, 18 Apr 2019 13:30:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555619431; cv=none;
        d=google.com; s=arc-20160816;
        b=TFluXYvjUNbLbgiz66xFuxIo0Nf5KXtcNSQ3DYBr0gGl8QtBqXhgFsD67lxls9fR0g
         SmM0BcmboVpU5rxkDrEbmMwWvHFnU193iTb77VxWn3y0oGbU3iGl9e1vhhlC+IehSWXU
         tyeLRSbps4v5s7mB+oWz/hzRlPSsCYS3vCAkPgPGbIRap3mQ66Z9H0/GTBM7KhRLWWUT
         JfZx4q868v7o3MGeQ68e+inNNE3Lup+a77GPG6VRTqZN0OS3b7f+WjAxlWx/mg34Tk+C
         rACx22r9fEifID6D1DZL/L5T7S/+y8eCFQnAru2HLckZ58iB3aBl7b7cQXRcXfaub0jq
         Uc0w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from;
        bh=T3JD0sgSOXk1vRSr1uVe9SorhMd4n+SS+HWTi6IFNCc=;
        b=WI+IdXfYiirqk24kOTj3+vWWjd1nGthlVQb/OcGVBPCfP8q7s2BI1jlo4LVCD6GvBJ
         dtFpRjcwoWELPitu70j3TLLkXTqHbz3h6cpGRcsBPgzKZ3Q9NcjLGjI6U2rHm3xpAn3k
         4tRenIi6ZjYwe/aGJYvQlaAM1Ohv17Ck6TqHJ8yx6QepeDwQn2r2ikPYoe7P4cCFpT1a
         wnkNXjwqIZooTVP+GNtCPilob5bDFuiuS90LCe0L/zfb6wwZeyn2nRfi7FMjPX7kIRmH
         bPKighBwx3TkzhG61841tlrj4WWMen4CFWxZs5t7qIIL5d7YWBG1up/vppkTvcsqo22B
         FhtQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=SwnFKNon;
       spf=pass (google.com: domain of ziy@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=ziy@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id i1si2751602pgb.322.2019.04.18.13.30.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 13:30:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of ziy@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=SwnFKNon;
       spf=pass (google.com: domain of ziy@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=ziy@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5cb8de6c0001>; Thu, 18 Apr 2019 13:30:36 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 18 Apr 2019 13:30:31 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 18 Apr 2019 13:30:31 -0700
Received: from [10.2.163.72] (172.20.13.39) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Thu, 18 Apr
 2019 20:30:29 +0000
From: Zi Yan <ziy@nvidia.com>
To: Yang Shi <yang.shi@linux.alibaba.com>
CC: <mhocko@suse.com>, <kirill.shutemov@linux.intel.com>,
	<rppt@linux.vnet.ibm.com>, <corbet@lwn.net>, <akpm@linux-foundation.org>,
	<linux-doc@vger.kernel.org>, <linux-mm@kvack.org>,
	<linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] doc: mm: migration doesn't use FOLL_SPLIT anymore
Date: Thu, 18 Apr 2019 16:30:27 -0400
X-Mailer: MailMate (1.12.4r5622)
Message-ID: <C8CBF3A3-5ADA-4CA6-8AEB-4836AE9146D7@nvidia.com>
In-Reply-To: <1555618624-23957-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1555618624-23957-1-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL103.nvidia.com (172.20.187.11) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; format=flowed
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1555619436; bh=T3JD0sgSOXk1vRSr1uVe9SorhMd4n+SS+HWTi6IFNCc=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:X-Mailer:Message-ID:
	 In-Reply-To:References:MIME-Version:X-Originating-IP:
	 X-ClientProxiedBy:Content-Type;
	b=SwnFKNonXOE1zQVJWCyAkBVjCLR/gdo0c98WcA4gmTZefaRGQCthtZhxg/jleQzpb
	 9ey3mfNA2l5uwtSrjts4734cmnAQzrvuHJkA0/uVgRhdrUSqaEEH5iSCLqsgZ+z1mf
	 eeg11NLcYkIb/mqsgxPlqRYvLKPIDYGdSbrtnlZUeJ4SkRHOQlXkM81nzq/VmKWoBq
	 F+ZustVToSp/Ww2x7qBHKYszHEDGptzDItgUiSNegC2a4t8wVt2Udzszw5zk7EYoRl
	 T2VVXWCXJVBoGCwEAjqmLJrf4butHZI6agSmOQ0mGBaG9CzXgI07vrYyRDygRIjFSL
	 N81lBCiahYjRw==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 18 Apr 2019, at 16:17, Yang Shi wrote:

> When demonstrating FOLL_SPLIT in transhuge document, migration is used
> as an example.  But, since commit 94723aafb9e7 ("mm: unclutter THP
> migration"), the way of THP migration is totally changed.  FOLL_SPLIT 
> is
> not used by migration anymore due to the change.
>
> Remove the obsolete example to avoid confusion.
>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Zi Yan <ziy@nvidia.com>
> Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> ---
>  Documentation/vm/transhuge.rst | 8 +-------
>  1 file changed, 1 insertion(+), 7 deletions(-)
>
> diff --git a/Documentation/vm/transhuge.rst 
> b/Documentation/vm/transhuge.rst
> index a8cf680..8df3806 100644
> --- a/Documentation/vm/transhuge.rst
> +++ b/Documentation/vm/transhuge.rst
> @@ -55,13 +55,7 @@ prevent page from being split by anyone.
>  In case you can't handle compound pages if they're returned by
>  follow_page, the FOLL_SPLIT bit can be specified as parameter to
>  follow_page, so that it will split the hugepages before returning
> -them. Migration for example passes FOLL_SPLIT as parameter to
> -follow_page because it's not hugepage aware and in fact it can't work
> -at all on hugetlbfs (but it instead works fine on transparent
> -hugepages thanks to FOLL_SPLIT). migration simply can't deal with
> -hugepages being returned (as it's not only checking the pfn of the
> -page and pinning it during the copy but it pretends to migrate the
> -memory in regular page sizes and with regular pte/pmd mappings).
> +them.
>
>  Graceful fallback
>  =================
> -- 
> 1.8.3.1

Thanks for updating the document.

Reviewed-by: Zi Yan <ziy@nvidia.com>



--
Best Regards,
Yan Zi

