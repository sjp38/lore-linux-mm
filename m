Return-Path: <SRS0=L2Uh=RS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 79989C10F00
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 12:47:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 33EF220854
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 12:47:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 33EF220854
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C07966B027F; Fri, 15 Mar 2019 08:47:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B8E9D6B0280; Fri, 15 Mar 2019 08:47:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A58526B0281; Fri, 15 Mar 2019 08:47:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 47F2A6B027F
	for <linux-mm@kvack.org>; Fri, 15 Mar 2019 08:47:38 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id t4so3687294eds.1
        for <linux-mm@kvack.org>; Fri, 15 Mar 2019 05:47:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=eZBtUAJr3wktdAqHIEK90tllrFtORHScIG821hL0ZGc=;
        b=CGMxXgJUrrHZmcs5LVKnOnv12DNYuUqV97PopjrxyEUDhQHcS4xeqbJk3iEhGMFwZX
         Ot0zzupciQJc3FIpQ7guZ41J9TBSu3V2pMZnNKyOmEEOXxBrT0HsQD029r2hIi0FkSAz
         GUEmnBQHWyMZDx+OBX+HDuVZ1/QbjnRnFrQcHb65etavcgrLO4uu0NN0SbwCxQpMAHP5
         L4ku373DNbiNvUKTqVF/Xwk76xBgvlFGxeIbPceZUB5g1SIMx5ku2imDtGEV0p1iNvtt
         JQqKSdl05zJ2TrXIUVAJYLanGiN8gUj/aDlK6dDnIGXlUoN5Ysdmy6ekZg3L3u0UTOdp
         e6Uw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVDRMk+ysAgpv1yTACMRN05ZsFX4NtQ5KJSRIisaPtOwYqzbn26
	09fg9eAWY0IOllprx9y9ynRq0XcsY+E+WNpvi7Td8LlbBTGUtcolk92L35weK/5vw0wM9GeOSf8
	e8lLhTZSRMNhFcUIXE3l2jQysw6ESce/DXtKh9yqTvZ/sXmponUd7MSJM9fgjy2s=
X-Received: by 2002:aa7:da09:: with SMTP id r9mr2731026eds.7.1552654057854;
        Fri, 15 Mar 2019 05:47:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzbytQxGQgisu1hywDxqw414YJpSb+xMlItU9btfcEwhXM3FWP5/GLzCQjjIXdUFsieJKyg
X-Received: by 2002:aa7:da09:: with SMTP id r9mr2730963eds.7.1552654056481;
        Fri, 15 Mar 2019 05:47:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552654056; cv=none;
        d=google.com; s=arc-20160816;
        b=F4mXBvXOSdAk3JjJiOZY6oi1UJqUmJCdLzIhZIGJVaMVjgJYsu0LpMl0GV212GQFFj
         8PJ1BWK0hwNhZ12pjmVZo1aIuBY+TgA/GCm+vTRqExVV1Q6oDkH2ond4TWMt+s+RsUj2
         vLvF8N/K7bDdxOmqIzMAHbxLWSQdP3YxP3D9b/36CNS7rraoXmqF8fK/vfsTLQywlUOs
         8t0aYUOVTLNw1tFoRu/hsQ9DxuS6TmyqF/cxayBPp/U1VMDrHHgj0Nn0fOy3mtdtoJ+O
         X9PAoVD0ecV8Qdh3Ow2/0ZYY+kxo4z4BNwyVniAM/aegfAnf8DX2GBch/FyU4p3AeHcg
         gGxg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=eZBtUAJr3wktdAqHIEK90tllrFtORHScIG821hL0ZGc=;
        b=Algx/O+Sz7F6rxI8PFemg+lPeLsDtk1ytqvHBHGewLfN4TCTmhlf8uxtHQ5yFUbV/C
         TR81mxOM2FDmBl5TSrGBxM6NQY4HZeVCWJfaoIdUe7Wmq1lFcXTEaqCd/KfozotpHm9j
         Ryl+Zi0raIBy/av82NKPEBPgpi8nr4NSmhTRYqrMLZmKAPrn2oBBwybz5eOw1nSYaVSP
         rcfsdA7XcS2wXk7wsZRxhr/J64tR6hgh5n1VMOB1MRdPUL2hQAlM9L/2KOVNYSasB49U
         R2hF03vItABU+Cyw/5lqYodLiSeeyqEmPiBRw8nA4LwJEAYt1JHkHHy6ZhBp9IDJS1h2
         WRGA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j8si787639ejd.249.2019.03.15.05.47.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Mar 2019 05:47:36 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id C9C45AFCC;
	Fri, 15 Mar 2019 12:47:35 +0000 (UTC)
Date: Fri, 15 Mar 2019 13:47:33 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Oscar Salvador <osalvador@suse.de>
Cc: akpm@linux-foundation.org, anshuman.khandual@arm.com,
	william.kucharski@oracle.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Jan Kara <jack@suse.cz>,
	Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: Fix __dump_page when mapping->host is not set
Message-ID: <20190315124733.GE15672@dhcp22.suse.cz>
References: <20190315121826.23609-1-osalvador@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190315121826.23609-1-osalvador@suse.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[Cc Jack and Hugh - the full patch is http://lkml.kernel.org/r/20190315121826.23609-1-osalvador@suse.de]

On Fri 15-03-19 13:18:26, Oscar Salvador wrote:
> While debugging something, I added a dump_page() into do_swap_page(),
> and I got the splat from below.
> The issue happens when dereferencing mapping->host in __dump_page():
> 
> ...
> else if (mapping) {
> 	pr_warn("%ps ", mapping->a_ops);
> 	if (mapping->host->i_dentry.first) {
> 		struct dentry *dentry;
> 		dentry = container_of(mapping->host->i_dentry.first, struct dentry, d_u.d_alias);
> 		pr_warn("name:\"%pd\" ", dentry);
> 	}
> }
> ...
> 
> Swap address space does not contain an inode information, and so mapping->host
> equals NULL.
> 
> Although the dump_page() call was added artificially into do_swap_page(),
> I am not sure if we can hit this from any other path, so it looks worth
> fixing it.

It is certainly worth fixing. We cannot assume anything about the
calling context for __dump_page

> We can easily do that by cheking mapping->host first.
[...]

The splat is still surprising to me because I thought that all file
backed mappings have a host. Swap file/partition certainly has a
mapping but swapcache mapping is special because the underlying swap
storage is hidden in the swap_info_struct. I am wondering whether we
should do that special casing for PageSwapCache in __dump_page rather
than hid the mapping details instead


diff --git a/mm/debug.c b/mm/debug.c
index 1611cf00a137..499c26d5ebe5 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -78,6 +78,9 @@ void __dump_page(struct page *page, const char *reason)
 	else if (PageKsm(page))
 		pr_warn("ksm ");
 	else if (mapping) {
+		if (PageSwapCache(page))
+			mapping = page_swap_info(page)->swap_file->f_mapping;
+
 		pr_warn("%ps ", mapping->a_ops);
 		if (mapping->host->i_dentry.first) {
 			struct dentry *dentry;

But I am not really sure this will work for all swap cases.

Thanks for reporting this Oscar!

> Fixes: 1c6fb1d89e73c ("mm: print more information about mapping in __dump_page")
> Signed-off-by: Oscar Salvador <osalvador@suse.de>
> ---
>  mm/debug.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/debug.c b/mm/debug.c
> index c0b31b6c3877..7759f12a8fbb 100644
> --- a/mm/debug.c
> +++ b/mm/debug.c
> @@ -79,7 +79,7 @@ void __dump_page(struct page *page, const char *reason)
>  		pr_warn("ksm ");
>  	else if (mapping) {
>  		pr_warn("%ps ", mapping->a_ops);
> -		if (mapping->host->i_dentry.first) {
> +		if (mapping->host && mapping->host->i_dentry.first) {
>  			struct dentry *dentry;
>  			dentry = container_of(mapping->host->i_dentry.first, struct dentry, d_u.d_alias);
>  			pr_warn("name:\"%pd\" ", dentry);
> -- 
> 2.13.7

-- 
Michal Hocko
SUSE Labs

