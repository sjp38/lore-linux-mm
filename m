Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 91DB7C10F03
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 19:22:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4C90D2075E
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 19:22:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="CE2GKuJp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4C90D2075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DFBB36B0005; Tue, 19 Mar 2019 15:22:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DAA546B0006; Tue, 19 Mar 2019 15:22:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C4CCC6B0007; Tue, 19 Mar 2019 15:22:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 899806B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 15:22:36 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id z12so110008pgs.4
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 12:22:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=LsViNz3EuXSVXAyDl+lEov/0/hqmOHSRj7WYM60oPCc=;
        b=JqCkoy5Gzr8MkglOkrDgSYkfqohZb0jAC/w8pUQhRXwoZE57v/2Ll2Nga9YlOmA6+a
         vzGTYmx4tad9j/J/YprTND7Be7e4qPtCfKGqUd3wyf56rMpURv1fJtPGRsWljR5VYIo5
         08TuhAWZ4tAMKsyWhjfjBu6BwagF9Uu+10fYUw9khdObLWrur27kAytpbC2/MLDcQkK/
         zVbLwlJMsBVPzSjL8O5arMkBpYDYG4RNxVh3jEXpJoEC1WP46w5Xr3aQkaYdfUjcGATa
         zqemlWAhgV1dKXDdLDVllkTtieqVwH24fdd/D9I22+fzDtt55RihVXg2G3KMdE6Ri5wR
         OTMg==
X-Gm-Message-State: APjAAAXuA/IgO+r7MehRkwk0hfvlbgtKggRp7ci5BCid792CtVqQdJgA
	ER64Ibk4PFCxOBdjoHMZyEDNfpX/AvX/q+ak8u+RFoVDKseflB0eZmxPcuFqFa2yC5GSv14oTx0
	cYcwPSNS01Z8umigiAKyM6gU+iV77thSbL6whCVyELLx/QRz4bAV0a/4DPwl8sd0BZA==
X-Received: by 2002:a62:1e82:: with SMTP id e124mr3539893pfe.258.1553023356239;
        Tue, 19 Mar 2019 12:22:36 -0700 (PDT)
X-Received: by 2002:a62:1e82:: with SMTP id e124mr3539788pfe.258.1553023355070;
        Tue, 19 Mar 2019 12:22:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553023355; cv=none;
        d=google.com; s=arc-20160816;
        b=Rnygoq+9j35DaTRO3XWfRH9fmZGrgF5fOUiZPnMeneRl4G5YSvvc5G4GB4mCh9g5oI
         4ecQ6cBZ+RpVRwbrm10ZXbqi9VFK0btvDpnMPDM2jsK2eEqdZhffK4JSYuq3GHo8WbnP
         MAbzgvH3NH11c47lpT+Ulq2KXTkOh+sHX20rqUWSzufU/oRXbLklr9k561ftqeO1/XVN
         jHjYnGxE2Jpmj4YcD3dR0yBOI4I2oR0XZHoEJHR9IW66VuYSmqjrZED1jWEJ3fb9eJlm
         W345HETXe8m+8/PAagcYxADKAWzeRhLep3icicULijWRAqA8DfL9krPbeF3ImA2jpKwK
         /8dw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=LsViNz3EuXSVXAyDl+lEov/0/hqmOHSRj7WYM60oPCc=;
        b=j5HfxCEguCIYFiWzfA262w9UdCdV3aXUs/z7UYURx+18WPc9KJpc75U/nqAePEtIMw
         CScN0/ItqUffr0Ql3WaaTOxs7PweU6C9c6GgrR59S4bl8laqpRzm3mDlXcqqFGcuNTcc
         3T1qh7BE/ta3ecFKbBPxQA3qCghVvZeUppyLJ6dZwhHLSjoF3kfYhylsu4b1QbYVT1BQ
         4DIAhVDeDpZGYILat82c0hrPqdG7vARdLZhfunYBL+AnywuNAV3fjZO6kitKwQw64fjH
         7yiHnJiGYZyTLdnTFaXDJHsY6xjaU/YlYG6CiIqlV2JLN5s8S1i5CTdoWbJCwVFDnT56
         bHuw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=CE2GKuJp;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i2sor20933607plt.57.2019.03.19.12.22.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Mar 2019 12:22:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=CE2GKuJp;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=LsViNz3EuXSVXAyDl+lEov/0/hqmOHSRj7WYM60oPCc=;
        b=CE2GKuJpTbcy2TUHrTiiun8dDGL1rW45+DZMmrEGD4r6ZJgZlAa36cOuBA2NbzQ9L3
         S42b64WR+Z5PF5A0L09qsSTSiTJBHaFINH+sFjo1+mcDWMrNdfF1hJIzEwNyxL+QLbJy
         X5dyz8pIrBH5e72nhnIMr0CJsdm7xf9Qj+XyHH16T2rR3xh0GIkllGo0s8k8zzAk9CmY
         EszVjc8X2HTXOJhUrWDcn3HjZwX1iDftEqOayG7kXVaeLnTCCZ1y1xtU9uc/XWLp495+
         Vu+CzxgpKsSmuRdnzra6ClSuVmRW944auQDAEN4p8Com+YxwrwjmZa014ddbKkiQ6ZOR
         vM7w==
X-Google-Smtp-Source: APXvYqxgyCmovfKD9DGAqfbwODVoI0aQiskbj5d5lqwiTMoYBhWKpgA8ZFbTlU+vA314q8BQ2Iymyw==
X-Received: by 2002:a17:902:8b83:: with SMTP id ay3mr3754394plb.1.1553023354294;
        Tue, 19 Mar 2019 12:22:34 -0700 (PDT)
Received: from [100.112.89.103] ([104.133.8.103])
        by smtp.gmail.com with ESMTPSA id m13sm26742042pff.175.2019.03.19.12.22.32
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 19 Mar 2019 12:22:33 -0700 (PDT)
Date: Tue, 19 Mar 2019 12:21:51 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
X-X-Sender: hugh@eggly.anvils
To: Oscar Salvador <osalvador@suse.de>
cc: akpm@linux-foundation.org, mhocko@suse.com, anshuman.khandual@arm.com, 
    william.kucharski@oracle.com, hughd@google.com, jack@suse.cz, 
    linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2] mm: Fix __dump_page when mapping->host is not set
In-Reply-To: <20190318072931.29094-1-osalvador@suse.de>
Message-ID: <alpine.LSU.2.11.1903191215190.1113@eggly.anvils>
References: <20190318072931.29094-1-osalvador@suse.de>
User-Agent: Alpine 2.11 (LSU 23 2013-08-11)
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 18 Mar 2019, Oscar Salvador wrote:

> Swap mapping->host is NULL, so let us protect __dump_page() for such cases.

Thanks :)

> 
> Fixes: 1c6fb1d89e73c ("mm: print more information about mapping in __dump_page")
> Signed-off-by: Oscar Salvador <osalvador@suse.de>
> Acked-by: Michal Hocko <mhocko@suse.com>

Acked-by: Hugh Dickins <hughd@google.com>
Cc: stable@vger.kernel.org

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

