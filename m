Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 735CEC10F00
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 05:02:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2E99C218AE
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 05:02:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="oKW6wLL8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2E99C218AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AD04B6B0003; Thu, 21 Mar 2019 01:02:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A7FEC6B0006; Thu, 21 Mar 2019 01:02:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 96FBC6B0007; Thu, 21 Mar 2019 01:02:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5A10A6B0003
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 01:02:02 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id m10so4606106pfj.4
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 22:02:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:dkim-signature;
        bh=bJW1lfibx460GLs7/4kPxeRLZSQu6jNulRoV/YOOYrA=;
        b=NFwTWCSmJZx/SayUx45xNNT2K88FwCYuePqylzj8uwfG7YYyj+m175opUSFetBnCIL
         scL5/xYRr6X1ZAjpbCrnlpx/gBdtG2ZOKKtFoumcFs0Bs6CnmJW5ljx/IMP3Dlwy552d
         jzH7Xo50DioZL+zZkd8pS/gVNv2pIiRo4AAEEFavROW6JzwqlmxKgk2WSFJD00Nbvba3
         8XaLpH8JD7DQgW48Jrv40JuIxrJic8EB15qyCGAUvH+vj8Xel/gNbVd20ihIDkvTDAc5
         CG31L7S4kV8D3XkeNGazBHYBZeUxteR/ejAfXF1Sh4tzQa8iduSkHaU7LOolfAc5Qynr
         iICw==
X-Gm-Message-State: APjAAAWE5uJhnfmIRM8ZcLKMUBgw6ePJpTDX2DEWv861q7zAVJEls3td
	dxA6x6c4yVkVBaNxhmk3aytaUI5cqM84P0BAeATs8Fjslco4v35XNQqPb4D4TVYolUPoGdui1wb
	ShDB69t2ukp0k+zKKTV9YCsvE1vOV4DpH5jQqxnQmYPvbkHYxNw3I4aGxW+yUYB5S9Q==
X-Received: by 2002:a63:e845:: with SMTP id a5mr1637608pgk.246.1553144521928;
        Wed, 20 Mar 2019 22:02:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyesaKra8If6nRaYSmmaASuaRwEa1yoczM9iZ5+hO+41kzE4AtD8ZwHpgexYG3tz1mmZ+5m
X-Received: by 2002:a63:e845:: with SMTP id a5mr1637526pgk.246.1553144520700;
        Wed, 20 Mar 2019 22:02:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553144520; cv=none;
        d=google.com; s=arc-20160816;
        b=RnP3P8z3bA2i++rBIahdyOlFdZbqYLnvMVH1C9kMw30Prlxh2pTrf31Frr7FL1uKTJ
         yZO6GjMwkgYHTGDoBx5gBRw66qIpdoWGaM9lYtPanVFXdvjiUMmOM9Hsz1l+TXjZpmHu
         v/JRmHtZLPIMvwpRLBV1TO3S9Y8pQXugsj1OBMau1dmlZkR5NX5Z7BXwj2vMSr/6CE3W
         8r/sNguWRXXlHPi0J8sP/euRNpqOhamZYtB03eE0ztZrCW66Z1RBtqwJPYshdV4zexH9
         3Q5taGWepIWNtph7oB8ItynjbxLpGx/erHBJl014Bo2vCAfn+Japbab8FdD1O/9+IQdZ
         Uraw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from;
        bh=bJW1lfibx460GLs7/4kPxeRLZSQu6jNulRoV/YOOYrA=;
        b=ifzRpjBGXpox/unKZ6kMdV8L18uIT3jKXCKswfLA72Rem8RIy0Qqmq9DLIKL7GxhQM
         w0dais/lDU+/ls5gtaWpgWw4gB3zNWpljuIT9C8bDNLC38vMgX4sh2B6rE07a6uRBB2u
         ggDtXQmf06hbzj6kl/AieqpVoosfIngrmzyDyJfy7e0GlrDL55qrgGcgXknjHMvi7tT7
         /hix+sLNNVJI1dTMnXZRzpFYNyev1DfVpngKwK46nXXBmklr0Z3pPrmjr9I3P5jRMzru
         BEVlJ1tE3u3/ZndUbW03uILIJaDqgFJidOzFEoUylpN+rPsCPPc0b+FQQuBC29oSGkkc
         FIBQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=oKW6wLL8;
       spf=pass (google.com: domain of ziy@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=ziy@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id 61si3802961plr.153.2019.03.20.22.02.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Mar 2019 22:02:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of ziy@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=oKW6wLL8;
       spf=pass (google.com: domain of ziy@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=ziy@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c931ac60002>; Wed, 20 Mar 2019 22:01:58 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Wed, 20 Mar 2019 22:02:00 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Wed, 20 Mar 2019 22:02:00 -0700
Received: from [10.2.174.129] (172.20.13.39) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Thu, 21 Mar
 2019 05:01:59 +0000
From: Zi Yan <ziy@nvidia.com>
To: Anshuman Khandual <anshuman.khandual@arm.com>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>,
	<mike.kravetz@oracle.com>, <osalvador@suse.de>, <mhocko@suse.com>,
	<akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/isolation: Remove redundant pfn_valid_within() in
 __first_valid_page()
Date: Wed, 20 Mar 2019 22:01:58 -0700
X-Mailer: MailMate (1.12.4r5614)
Message-ID: <8AB57711-48C0-4D95-BC5F-26B266DC3AE8@nvidia.com>
In-Reply-To: <1553141595-26907-1-git-send-email-anshuman.khandual@arm.com>
References: <1553141595-26907-1-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL107.nvidia.com (172.20.187.13) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; format=flowed
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1553144518; bh=bJW1lfibx460GLs7/4kPxeRLZSQu6jNulRoV/YOOYrA=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:X-Mailer:Message-ID:
	 In-Reply-To:References:MIME-Version:X-Originating-IP:
	 X-ClientProxiedBy:Content-Type;
	b=oKW6wLL8SIYSOepyx3b14R6kdmqRVehiwOvpA778xqauC1V2upNgcmefC2W+34QbH
	 i+bIcTsBWgXQv1xMFMEH7ELZgKIFp+fquUUZwJXceUlnDLM/oQ+o6omrTppooGA1Nm
	 rToCW7g/6tA2QJR9r6qVQZZdG9ENSxvbLk3MY9PyMSczD0HL1mWFYAvy5O6OayphOC
	 ljEdKmUcXpkAgFyru6rybaIAblEQdoIxe0XGIoSHrNhu0kkxTnUaB5KUdeqgzkwZfs
	 0MXwdxeLIe+RIpfL7V7oKT78FbPe8R4PD8THnBnwfBzUS3jY6UX9p76PkmFJM8OuL1
	 DFysyh2YbZRjA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 20 Mar 2019, at 21:13, Anshuman Khandual wrote:

> pfn_valid_within() calls pfn_valid() when CONFIG_HOLES_IN_ZONE making 
> it
> redundant for both definitions (w/wo CONFIG_MEMORY_HOTPLUG) of the 
> helper
> pfn_to_online_page() which either calls pfn_valid() or 
> pfn_valid_within().
> pfn_valid_within() being 1 when !CONFIG_HOLES_IN_ZONE is irrelevant 
> either
> way. This does not change functionality.
>
> Fixes: 2ce13640b3f4 ("mm: __first_valid_page skip over offline pages")

I would not say this patch fixes the commit 2ce13640b3f4 from 2017,
because the pfn_valid_within() in pfn_to_online_page() was introduced by
a recent commit b13bc35193d9e last month. :)

> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
> ---
>  mm/page_isolation.c | 2 --
>  1 file changed, 2 deletions(-)
>
> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> index ce323e56b34d..d9b02bb13d60 100644
> --- a/mm/page_isolation.c
> +++ b/mm/page_isolation.c
> @@ -150,8 +150,6 @@ __first_valid_page(unsigned long pfn, unsigned 
> long nr_pages)
>  	for (i = 0; i < nr_pages; i++) {
>  		struct page *page;
>
> -		if (!pfn_valid_within(pfn + i))
> -			continue;
>  		page = pfn_to_online_page(pfn + i);
>  		if (!page)
>  			continue;

This makes sense to me. You can add Reviewed-by: Zi Yan 
<ziy@nvidia.com>.

--
Best Regards,
Yan Zi

