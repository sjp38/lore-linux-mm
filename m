Return-Path: <SRS0=L2Uh=RS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B0E17C10F00
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 14:33:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 758BF21871
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 14:33:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 758BF21871
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 17E406B0283; Fri, 15 Mar 2019 10:33:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 106FE6B0284; Fri, 15 Mar 2019 10:33:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F38556B0285; Fri, 15 Mar 2019 10:33:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id B061B6B0283
	for <linux-mm@kvack.org>; Fri, 15 Mar 2019 10:33:10 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id u12so3957787edo.5
        for <linux-mm@kvack.org>; Fri, 15 Mar 2019 07:33:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=PDuNZJJaM2ucli/Inxe8k/OKlaR+FNf1hjQTAhVGVvs=;
        b=JHRiKOO1ww+yKoWEr5ap1FgNyhQtBpYMbBMds11CYWLhH+oL3p4zll//alFdcHkhrF
         vmL7b2g+9wf1qVx6yi/mKe8swkLjuPjyIkL1LRde/0Cg1rnvG9eKHu2Cz7qEEQJ/pOMg
         uvMq/B3ugUJcCEpm9F48GTz8ZmbMoE/lbyJGQ6VP3t+N6zvawq0b3tjjyLC/a7mJ0CWQ
         eYO+WzG99kYlPG0AjFarZD4LE/C+mPqnPsRfHIuCJrNJGrUPiSC/oXgtxTkBSVpQu9sZ
         jI+o6fSTl4GAoFCZ9uZrv+vjgEeIrI+A3JTCfgZPPCVCSzx6NtJ2b/A6SFpcINX6jB+O
         psJg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAXyWF4TwUIMaYglZPWtTOz4suixMwL90w6uyPT5aUbYYUt/m0zc
	i1nNm54E9bbk7dnqr3EpLuZnhMFcsZtL9QbcWjKx/k4pYB33xQfeZZ8n/S41zu3tODUtf6gcO38
	MZneyOq2lqPXpuaDnQpONxCuAecmZq3eP3vx8qyRPSxatJEzNj1X299xlaEXQQEB70w==
X-Received: by 2002:a50:b285:: with SMTP id p5mr1635690edd.239.1552660390301;
        Fri, 15 Mar 2019 07:33:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxECAt5D3Ng6jS7VKeyxCSfTxVqpQ+bPtCsAlixhuGh98xPFSVb4vPjrOrP7lWn/tjb0sMw
X-Received: by 2002:a50:b285:: with SMTP id p5mr1635633edd.239.1552660389256;
        Fri, 15 Mar 2019 07:33:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552660389; cv=none;
        d=google.com; s=arc-20160816;
        b=RC825ZyltIzU4bAyBN7Dc/Pa3ARs6TeU24rLcfmyytWZIiQT6cQFUTP/f1jQ7kjJDC
         7xvIQyffATclG+Y7BSBpyH2aqyZynmGHOgZ7gMvLeXDa5TlxUyHVn9lis0D44PQGPW1U
         uTjbgiYUnyMNp8Ig1+3ddp6LGA2Uw5HTvkmYvL2zvWEfe5KCLc0NGNR88yYW4KXmOEiM
         d6xZ4hfVUVfLcIXVXxvSZ3gI4iCu3p0ohTuifkJBNsUp3/azV6Vku5aJ5gZ0t4XAuC+h
         8yQH8MQtvxCSk767qR4s+nikzvPayymNIfEt+SctnqeEdqor51y+sfgU87ufQIcMy1zS
         ZPOg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=PDuNZJJaM2ucli/Inxe8k/OKlaR+FNf1hjQTAhVGVvs=;
        b=Y1Atddk5BMbf9UQpYuGu421pn7BILdtmesCtckKqHcOe1St9mQHjDusDcN2ZP0jpH/
         dKaKPEJV5fEDbOJvZi1hPCvG2yZMc/byuHj/bnMBtDenmp6VGuR0PkKkhHGrN0EvCgsB
         irZonrs/SrpHLHwhmv84iAY2hlAR7MKu8mQJ2XVKWxovXE3PFsSB6XWB2qqYVRX9FX5M
         kkK3i7FPkBWobENxrcQBvrwGJFzzYWEfCPvvt556B+pawfMF2FY+hU6s6sAjnvzxE/Oo
         UuVWFLCk4kaygc53i4SHR5W6QrK+BcEqHk/vtxNKkkmtIALAufK/BJRU2XxpCPjPfAW8
         UVHA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (nat.nue.novell.com. [195.135.221.2])
        by mx.google.com with ESMTP id z7si698319edl.67.2019.03.15.07.33.09
        for <linux-mm@kvack.org>;
        Fri, 15 Mar 2019 07:33:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) client-ip=195.135.221.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id D4ADD459A; Fri, 15 Mar 2019 15:33:07 +0100 (CET)
Date: Fri, 15 Mar 2019 15:33:07 +0100
From: Oscar Salvador <osalvador@suse.de>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, anshuman.khandual@arm.com,
	william.kucharski@oracle.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Jan Kara <jack@suse.cz>,
	Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: Fix __dump_page when mapping->host is not set
Message-ID: <20190315143304.pkuvj4qwtlzgm7iq@d104.suse.de>
References: <20190315121826.23609-1-osalvador@suse.de>
 <20190315124733.GE15672@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190315124733.GE15672@dhcp22.suse.cz>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 15, 2019 at 01:47:33PM +0100, Michal Hocko wrote:
> diff --git a/mm/debug.c b/mm/debug.c
> index 1611cf00a137..499c26d5ebe5 100644
> --- a/mm/debug.c
> +++ b/mm/debug.c
> @@ -78,6 +78,9 @@ void __dump_page(struct page *page, const char *reason)
>  	else if (PageKsm(page))
>  		pr_warn("ksm ");
>  	else if (mapping) {
> +		if (PageSwapCache(page))
> +			mapping = page_swap_info(page)->swap_file->f_mapping;
> +
>  		pr_warn("%ps ", mapping->a_ops);
>  		if (mapping->host->i_dentry.first) {
>  			struct dentry *dentry;

This looks like a much nicer fix, indeed.
I gave it a spin and it works.

Since the mapping is set during the swapon, I would assume that this should
always work for swap.
Although I am not sure if once you start playing with e.g zswap the picture can
change.

Let us wait for Hugh and Jan.

Thanks Michal

-- 
Oscar Salvador
SUSE L3

