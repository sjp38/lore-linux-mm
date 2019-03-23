Return-Path: <SRS0=0AWy=R2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9A863C10F05
	for <linux-mm@archiver.kernel.org>; Sat, 23 Mar 2019 17:21:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 428B7218A2
	for <linux-mm@archiver.kernel.org>; Sat, 23 Mar 2019 17:21:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="0WytAG4W"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 428B7218A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 94CF86B0003; Sat, 23 Mar 2019 13:21:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8FC7E6B0006; Sat, 23 Mar 2019 13:21:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7ED476B0007; Sat, 23 Mar 2019 13:21:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 538856B0003
	for <linux-mm@kvack.org>; Sat, 23 Mar 2019 13:21:43 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id s65so2100491oie.7
        for <linux-mm@kvack.org>; Sat, 23 Mar 2019 10:21:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=eeq8w5UoZqtPwtYCuvSGobWdwSJ7TL9pAZbFIGCz8uc=;
        b=JaDB6MWFY8Un1wztx5txV1FIvccvRbpG3tX3A8gIMFDn6ZLGcgWUSkmtlSp8gWZgAU
         hTxaL7gLYmJ4yw45mjBNauQgKNKAEFZRTbG9qz5tvzjZ2BkSl3n9VPswqsP2B3/GdipT
         vN0T7oaQRRNmeFD4g8HntpzB28CuFh4vEQutObZpsFkO3KZHTLC5/bklE/tho7CjPeqf
         U19NvZWQ1rqVCOAopbSR4HnuQ8H9lIVl36hgax1BkLgH6vHN2YIUW43H+EQeYl1D8FZX
         SeeoUFUPAU0PqZy+xTZz1VEsRBiJ+shTUrPLu6Gt/vdtpHPrf4YLJSZX5paG0r36VKlY
         kh8Q==
X-Gm-Message-State: APjAAAVNNd//wznZ9jWXPQTwoJTJLvdxipIkseWlgxiH3tjFBXzkJPV3
	PROythVyNB4O3wSZHQLYJtk6EulCnYA7uxbqzowHWi/ILicuLniA4k6DT45dHhGhHFduXWcH1s6
	UB9vS/Ktl3cZdgluy5zcXj8QibkLCoda2CFBS8jNkaCRl4e0H42Akb9E0X2+GJjaTCw==
X-Received: by 2002:a9d:77da:: with SMTP id w26mr11283218otl.17.1553361702945;
        Sat, 23 Mar 2019 10:21:42 -0700 (PDT)
X-Received: by 2002:a9d:77da:: with SMTP id w26mr11283185otl.17.1553361702187;
        Sat, 23 Mar 2019 10:21:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553361702; cv=none;
        d=google.com; s=arc-20160816;
        b=uAKqbES+v+F644aW9CJA2CpNIzqh45TO10v14bK/pIox8z4Lqrl14VYbPcqLksBnLv
         U7eNQ5RnhTpRhZw7tatHcC+sSV2W/YEbBcruSOcyLLsiYy1fS4I7zGDMYM0VDyRnWzjZ
         6JuTkYlQ03ZJkVbRNsLSisIyEGoqh19JNyV1n/W058k0OdgokNpYUm9IAm1Ck1xixUfT
         Mphj4Zr5lB2kBDCl+EU3Fppv7DPcqQvQsF3OOC9kwyCaW9L9Hzq4e9Mqxyc2Ye9ncagj
         z6rah/GGZNHwMWUfSCX/iR/Rq9LfKQB7eA4SgKvK6kTvomOCwTH45WbQ12jiCj34Shvn
         /1PA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=eeq8w5UoZqtPwtYCuvSGobWdwSJ7TL9pAZbFIGCz8uc=;
        b=amGzDmm0gqMpETb3V7vxRRTdMKGwLsygleZedlpcwCwcorGOKWYYVWRu60zeLn7pWr
         CsJ8UNZIJqbbMp1aTn2agLpZgVvAbKUNRqo7Xw8ijTSrruEq30hSjoUK/bACzZm8BRUd
         YhBgYOhpaYkSRXGLl4OaH24C8xMLtilOi6DJBrS2ZU3MHLPxzSOFp5czh8MCb0t7YRUq
         e/k9Sn1tucrG5n/SyCJDxFZU0oFgLwyHK6huhh4506kx2DMg1uaMYDWf0/v1hNk1fnrW
         ZQ2lbKLaq/i4JJba5daq1FjX3njjPnWOUBt7pa6/NvkacDqYxVwSzNm9ju7vi46LbTnf
         xCew==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=0WytAG4W;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g92sor5296528otg.28.2019.03.23.10.21.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 23 Mar 2019 10:21:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=0WytAG4W;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=eeq8w5UoZqtPwtYCuvSGobWdwSJ7TL9pAZbFIGCz8uc=;
        b=0WytAG4Wk5Oi/5ukZGTkMMCTVXUHPt5wKd8CN4IlVakyDUknYU9gO2o6YmgrDc0Gh2
         tFh8Q2WR+/Zv1avHHPlkNOvZXziHzve4udgLrND2cPRcYjN5Bz77mTSPku6TGZkiOGiP
         6fdnK7E5tPWQjgNTaaAo+qd9hXJnKNbTPXdb7niW9u0Gc66Qo8YQdrsyLvzTloD35bCz
         Wojma7Mf9Ou1KeogCH0lqVyOvWMPNmzT4YVID4HGYCoU0GAWQVFHvTJlpRIBgyTyLaVh
         ktFFHNrQzSkhMUkFxzcOpb3g3/7CWDRXpFfCSDA2Go9IS5uDo6mFzp+pn66Qv4in6Ums
         Yg6A==
X-Google-Smtp-Source: APXvYqxI/TyfpdbcSgqn9sKIr9VnkGP9ptLAdKMEHZOdln61IUI0xQz7xzNTofy2+O4N3EPhoLjKRqdzP1P/Ka5palk=
X-Received: by 2002:a9d:6a4f:: with SMTP id h15mr1290088otn.353.1553361701390;
 Sat, 23 Mar 2019 10:21:41 -0700 (PDT)
MIME-Version: 1.0
References: <1553316275-21985-1-git-send-email-yang.shi@linux.alibaba.com> <1553316275-21985-2-git-send-email-yang.shi@linux.alibaba.com>
In-Reply-To: <1553316275-21985-2-git-send-email-yang.shi@linux.alibaba.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Sat, 23 Mar 2019 10:21:30 -0700
Message-ID: <CAPcyv4g5RoHhXhkKQaYkqYLN1y3KavbGeM1zVus-3fY5Q+JdxA@mail.gmail.com>
Subject: Re: [PATCH 01/10] mm: control memory placement by nodemask for two
 tier main memory
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, 
	Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, 
	Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, 
	Keith Busch <keith.busch@intel.com>, Fengguang Wu <fengguang.wu@intel.com>, 
	"Du, Fan" <fan.du@intel.com>, "Huang, Ying" <ying.huang@intel.com>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 22, 2019 at 9:45 PM Yang Shi <yang.shi@linux.alibaba.com> wrote:
>
> When running applications on the machine with NVDIMM as NUMA node, the
> memory allocation may end up on NVDIMM node.  This may result in silent
> performance degradation and regression due to the difference of hardware
> property.
>
> DRAM first should be obeyed to prevent from surprising regression.  Any
> non-DRAM nodes should be excluded from default allocation.  Use nodemask
> to control the memory placement.  Introduce def_alloc_nodemask which has
> DRAM nodes set only.  Any non-DRAM allocation should be specified by
> NUMA policy explicitly.
>
> In the future we may be able to extract the memory charasteristics from
> HMAT or other source to build up the default allocation nodemask.
> However, just distinguish DRAM and PMEM (non-DRAM) nodes by SRAT flag
> for the time being.
>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> ---
>  arch/x86/mm/numa.c     |  1 +
>  drivers/acpi/numa.c    |  8 ++++++++
>  include/linux/mmzone.h |  3 +++
>  mm/page_alloc.c        | 18 ++++++++++++++++--
>  4 files changed, 28 insertions(+), 2 deletions(-)
>
> diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
> index dfb6c4d..d9e0ca4 100644
> --- a/arch/x86/mm/numa.c
> +++ b/arch/x86/mm/numa.c
> @@ -626,6 +626,7 @@ static int __init numa_init(int (*init_func)(void))
>         nodes_clear(numa_nodes_parsed);
>         nodes_clear(node_possible_map);
>         nodes_clear(node_online_map);
> +       nodes_clear(def_alloc_nodemask);
>         memset(&numa_meminfo, 0, sizeof(numa_meminfo));
>         WARN_ON(memblock_set_node(0, ULLONG_MAX, &memblock.memory,
>                                   MAX_NUMNODES));
> diff --git a/drivers/acpi/numa.c b/drivers/acpi/numa.c
> index 867f6e3..79dfedf 100644
> --- a/drivers/acpi/numa.c
> +++ b/drivers/acpi/numa.c
> @@ -296,6 +296,14 @@ void __init acpi_numa_slit_init(struct acpi_table_slit *slit)
>                 goto out_err_bad_srat;
>         }
>
> +       /*
> +        * Non volatile memory is excluded from zonelist by default.
> +        * Only regular DRAM nodes are set in default allocation node
> +        * mask.
> +        */
> +       if (!(ma->flags & ACPI_SRAT_MEM_NON_VOLATILE))
> +               node_set(node, def_alloc_nodemask);

Hmm, no, I don't think we should do this. Especially considering
current generation NVDIMMs are energy backed DRAM there is no
performance difference that should be assumed by the non-volatile
flag.

Why isn't default SLIT distance sufficient for ensuring a DRAM-first
default policy?

