Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BCF14C43219
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 08:30:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 87CC9206E0
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 08:30:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 87CC9206E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E6A1F6B0282; Fri, 26 Apr 2019 04:30:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E1A766B028B; Fri, 26 Apr 2019 04:30:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D082B6B028D; Fri, 26 Apr 2019 04:30:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 81E866B0282
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 04:30:19 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id 18so1153577eds.5
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 01:30:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=zVfECkxHo+ILyjP+2AITU27+UGl4QNgElYAeRCu1g/E=;
        b=St66vpg1bvnt5vhFXCUQZzJbz//VC4gYxliyFvLgUhqvjmq+Veku9qjqlO96wGZonw
         RDN1tuva9oKBPfDclV87fGAjzphYYs8rJdj4cHUahy4cw6whQl3mNyY1SeOPhpNUT8xU
         02USoeja1StAgGQArbIf+qX27pj5UJxHu8PJSarBGb0BO0WrwO6AshhMg5BlX2xfTW5b
         fnpYYUF9/UN+wLMujvSwy6juqi4NlB1e/6yfMx9B9+l8CIuQI/OBI1w2B43/L6+RJ3SR
         xBrzH6JiS5fnr9P6ix9Bu+ZilAizamk+ovFzl2tEhlltjm1d3x47jlfw8CiXeKm3K0JX
         eyGA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAXoXURbnga/DH+GT2CtMLxtEuX/QUtEY1zg82T3rRvqo6Rl92Gn
	jH+WqwHM5jbv6ipM/nSlql53UTcBo9A5I0++TEU6eqNBjnUnzvBJxLg9cMqznlyoQ+8RAVc7FFe
	9GwjEidaVI1T1jkQkA7zkcQbkzBccSsOo1mZwRWSziOFOroFli3v26dg65pqOiY8X0Q==
X-Received: by 2002:a50:b244:: with SMTP id o62mr27234956edd.224.1556267419061;
        Fri, 26 Apr 2019 01:30:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyjldjgXHUUfA796n+UAeAvYYsrqMlufsgLkmwo0ZP8BCzk1zu4rJbassiLFU7ApDM9lVBm
X-Received: by 2002:a50:b244:: with SMTP id o62mr27234907edd.224.1556267417992;
        Fri, 26 Apr 2019 01:30:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556267417; cv=none;
        d=google.com; s=arc-20160816;
        b=hJKH1ewkjbjs3maBO5uhWGv078ZUFVILC06Ij0iGrc0CuhhtsACzLQvH9QwR7X0Zrk
         8BD9wEQ+qcRLu8wPg0N4VY0/jpoQcnJaT7nheH1SzhfN8wUKd9PjdoUz8p/OS2jU5oOI
         hOdVorrkwdMFlYEXFme5v+15ghhPg2iQ0PwEEjEvbd0t/vnjPObyfoNVHm9VVRtCGGw/
         L0b+t2bfXLyFPfxv5GVO7/2zya5fMLzOzgQEGp2eaRNIGPyj/jdEknUivzNsPFZuYYXV
         ZUkl/QS8H00Lkf6zmJKKarl8xrzFJKDnpTmLcErc+3qQT1B8iOpERvNIq0oG4JfmhslK
         ezyw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=zVfECkxHo+ILyjP+2AITU27+UGl4QNgElYAeRCu1g/E=;
        b=B5ErHYxrlHHiRuSQe7jVrG6YBL7rrLghdmpd8iPjsN/ByueqTx0kKalCWHsjJ7oUVU
         hFJWbJ3rtZOGoR1bfi1cjd9DFqPWpufn08NgEwU27xtww/i1g6+u9wpJCZ6JszoWsL9H
         Tuhs5iULHBmIjkzMs804jN6NUCSbp3b5zvxO0aKWSbHpjIdbzUwcn0xLrJTTiBEtMa4Y
         eUeTXIzqOil8fbm9s9MF0GhRIqBYte7vwBfBP5mbzdtPsKWuLSZU6PkTeuNA7BDY0y/p
         BPIhGUJ1eGHmy4M8z3Ay6oQIF3yCJtjw1ztjZAZ8KtZZDCs8mG93B9x3kFAz+SO7+FKB
         7zCw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f10si1433953edd.87.2019.04.26.01.30.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 01:30:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 66391AE28;
	Fri, 26 Apr 2019 08:30:17 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id E06DB1E3618; Fri, 26 Apr 2019 10:30:16 +0200 (CEST)
Date: Fri, 26 Apr 2019 10:30:16 +0200
From: Jan Kara <jack@suse.cz>
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: cluster-devel@redhat.com, Christoph Hellwig <hch@lst.de>,
	Bob Peterson <rpeterso@redhat.com>, Jan Kara <jack@suse.cz>,
	Dave Chinner <david@fromorbit.com>,
	Ross Lagerwall <ross.lagerwall@citrix.com>,
	Mark Syms <Mark.Syms@citrix.com>,
	Edwin =?iso-8859-1?B?VPZy9ms=?= <edvin.torok@citrix.com>,
	linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH v3 1/2] iomap: Add a page_prepare callback
Message-ID: <20190426083016.GA11637@quack2.suse.cz>
References: <20190425160913.1878-1-agruenba@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190425160913.1878-1-agruenba@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 25-04-19 18:09:12, Andreas Gruenbacher wrote:
> Move the page_done callback into a separate iomap_page_ops structure and
> add a page_prepare calback to be called before a page is written to.  In
> gfs2, we'll want to start a transaction in page_prepare and end it in
> page_done, and other filesystems that implement data journaling will
> require the same kind of mechanism.

...

> @@ -674,9 +675,17 @@ iomap_write_begin(struct inode *inode, loff_t pos, unsigned len, unsigned flags,
>  	if (fatal_signal_pending(current))
>  		return -EINTR;
>  
> +	if (page_ops) {
> +		status = page_ops->page_prepare(inode, pos, len, iomap);
> +		if (status)
> +			return status;
> +	}
> +

Looks OK for now I guess, although I'm not sure if later some fs won't need
to get hold of the actual page in ->page_prepare() and then we will need to
switch to ->page_prepare() returning the page to use. But let's leave that
for a time when such fs wants to use iomap.

> @@ -780,8 +794,8 @@ iomap_write_end(struct inode *inode, loff_t pos, unsigned len,
>  		ret = __iomap_write_end(inode, pos, len, copied, page, iomap);
>  	}
>  
> -	if (iomap->page_done)
> -		iomap->page_done(inode, pos, copied, page, iomap);
> +	if (page_ops)
> +		page_ops->page_done(inode, pos, copied, page, iomap);

Looking at the code now, this is actually flawed (preexisting problem):
__iomap_write_end or generic_write_end() will release the page reference
and so you cannot just pass it to ->page_done(). That is a potential
use-after-free...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

