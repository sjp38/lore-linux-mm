Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 533BEC43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 09:25:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 14B1D2082C
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 09:25:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 14B1D2082C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D63FA6B0003; Thu, 20 Jun 2019 05:25:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CEC908E0002; Thu, 20 Jun 2019 05:25:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BB4798E0001; Thu, 20 Jun 2019 05:25:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6C8A96B0003
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 05:25:54 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b33so3423065edc.17
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 02:25:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=AV0IQp6Mld/bcXt3kBvRHjbZP2AAJigVmhcpSqZSVIA=;
        b=aokIV6n9qdeSVE5YCHoOpcl036KjY4FrNb4eIGs0HXJGZVesw/8Ap3DYzGTQJjXj5N
         7SZvDkkd3HRspXBD1SSeGTNUZ4l5V+ukJLUrkb5NIzdQnu1mDAzTZA3vBaXA0qIpN+8Y
         7WAbkwaiv3QE02ScmBOP3GS8VQxGHzsKlEQ1wdn2X98KajJp83R4kQ2d/u2vUR6YJcww
         rWH2wBeIFx1UdWmU4e6b8HFWkNBelhKTEBhBIGViE4cKjyurVXnT9kTZZolKnzlsWaEM
         SMyJ/bKnBioOU+WsdB+QNV8bwRdVgE5TbCP3C/fjz3TLXsLLN0FpnVP9J0Tx0JakVJ/+
         iitw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAXsBqIU+v5ARfknneGpNkIIPzJSd2nzfD0BOeYQfomqSkh22Fuy
	1dhN+eUAoV73qigAVNJwMmWUgZgov1Ki8EjlRzya9SzWPsYKXj/aOsMOnAe0h20cgyAjmeyh1Lk
	jHXb9jDhknTaQEY7ghbGDvgD0sT6aWSAz0CqTGjurEeXGq017avNEzbwsqerdgNlbBQ==
X-Received: by 2002:a17:906:d183:: with SMTP id c3mr30828899ejz.149.1561022753992;
        Thu, 20 Jun 2019 02:25:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxaf3H13ZDPVx9gSxwNBj0vlhiJmn7ycMZNXITGbITG86wSOeZhsDTvxBj2JF/bbNSe4Z2v
X-Received: by 2002:a17:906:d183:: with SMTP id c3mr30828855ejz.149.1561022753103;
        Thu, 20 Jun 2019 02:25:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561022753; cv=none;
        d=google.com; s=arc-20160816;
        b=ptqqwmRWp2NCb89pqLco2eeTHd/RD6Pu+XeM/4KYs0G5Tcig/e9VC/PNIjnNeFrtdK
         b04dgxAAJVuYnCkdIipLiz9/Ti3D2v3kFI/ki0S1EZ5+7et9w5NO9oJD+ssEwBKQkd0g
         qw5AjWAycxt0Ya7pT1TdfaqoszPCLaDFPWkSLU+lWGcjHIxn7pTAF3SUbbtnMJW1+u9J
         UcEgk2sZJSCxDjJnD/ihNni3GDi8cMwGE69N33fK5skSq7Xc4wsxVLdg850+HvGlR76U
         YybUfEyg3t4P0qYxEJaKJbfU/DXJX4DUnNyegiDZBOnrCZQyrAEVeMyLIU2+U5BBmGIc
         4EKA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=AV0IQp6Mld/bcXt3kBvRHjbZP2AAJigVmhcpSqZSVIA=;
        b=i1LaWluaqTFtyoNtQo23AQw1Vhdk2Ozjqsxa6MRNLkUs/PSfhj5J0IzhH6GJ460JIN
         8nxed9hH4jO8/sjOIUL5UL9ctxzrEXgLEKfWlH2CBBYKEKHNA8bcHd66Gle+0NYqTLHC
         x6KGBlUSRL7UIvbfcVK6cXib0cyix4pwM0jmwVwjhy53KNPsk4WsvMGkQW1wS+c+3Wq1
         XwhHYeBt+qKcPZ5wq4zf9r7Kq6DC5b4mME5SClb955Yo86S2JaFPPoBisWEiqnkK22iE
         0c7VuieRFEngmRQXJ+/V3THrr87MptonHL64MCsPtO7BSR2akweUts9HuLCk2jU2ushj
         DUZg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p3si7791275eja.2.2019.06.20.02.25.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 02:25:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 771EBAD76;
	Thu, 20 Jun 2019 09:25:52 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 13B0E1E434D; Thu, 20 Jun 2019 11:25:52 +0200 (CEST)
Date: Thu, 20 Jun 2019 11:25:52 +0200
From: Jan Kara <jack@suse.cz>
To: Ross Zwisler <zwisler@chromium.org>
Cc: linux-kernel@vger.kernel.org, Ross Zwisler <zwisler@google.com>,
	Theodore Ts'o <tytso@mit.edu>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>,
	linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org, Fletcher Woodruff <fletcherw@google.com>,
	Justin TerAvest <teravest@google.com>
Subject: Re: [PATCH 1/3] mm: add filemap_fdatawait_range_keep_errors()
Message-ID: <20190620092552.GK13630@quack2.suse.cz>
References: <20190619172156.105508-1-zwisler@google.com>
 <20190619172156.105508-2-zwisler@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190619172156.105508-2-zwisler@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 19-06-19 11:21:54, Ross Zwisler wrote:
> In the spirit of filemap_fdatawait_range() and
> filemap_fdatawait_keep_errors(), introduce
> filemap_fdatawait_range_keep_errors() which both takes a range upon
> which to wait and does not clear errors from the address space.
> 
> Signed-off-by: Ross Zwisler <zwisler@google.com>

The patch looks good to me. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  include/linux/fs.h |  2 ++
>  mm/filemap.c       | 22 ++++++++++++++++++++++
>  2 files changed, 24 insertions(+)
> 
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index f7fdfe93e25d3..79fec8a8413f4 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -2712,6 +2712,8 @@ extern int filemap_flush(struct address_space *);
>  extern int filemap_fdatawait_keep_errors(struct address_space *mapping);
>  extern int filemap_fdatawait_range(struct address_space *, loff_t lstart,
>  				   loff_t lend);
> +extern int filemap_fdatawait_range_keep_errors(struct address_space *mapping,
> +		loff_t start_byte, loff_t end_byte);
>  
>  static inline int filemap_fdatawait(struct address_space *mapping)
>  {
> diff --git a/mm/filemap.c b/mm/filemap.c
> index df2006ba0cfa5..e87252ca0835a 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -553,6 +553,28 @@ int filemap_fdatawait_range(struct address_space *mapping, loff_t start_byte,
>  }
>  EXPORT_SYMBOL(filemap_fdatawait_range);
>  
> +/**
> + * filemap_fdatawait_range_keep_errors - wait for writeback to complete
> + * @mapping:		address space structure to wait for
> + * @start_byte:		offset in bytes where the range starts
> + * @end_byte:		offset in bytes where the range ends (inclusive)
> + *
> + * Walk the list of under-writeback pages of the given address space in the
> + * given range and wait for all of them.  Unlike filemap_fdatawait_range(),
> + * this function does not clear error status of the address space.
> + *
> + * Use this function if callers don't handle errors themselves.  Expected
> + * call sites are system-wide / filesystem-wide data flushers: e.g. sync(2),
> + * fsfreeze(8)
> + */
> +int filemap_fdatawait_range_keep_errors(struct address_space *mapping,
> +		loff_t start_byte, loff_t end_byte)
> +{
> +	__filemap_fdatawait_range(mapping, start_byte, end_byte);
> +	return filemap_check_and_keep_errors(mapping);
> +}
> +EXPORT_SYMBOL(filemap_fdatawait_range_keep_errors);
> +
>  /**
>   * file_fdatawait_range - wait for writeback to complete
>   * @file:		file pointing to address space structure to wait for
> -- 
> 2.22.0.410.gd8fdbe21b5-goog
> 
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

