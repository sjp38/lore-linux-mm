Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A0A36C282E3
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 08:32:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4D306208E4
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 08:32:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4D306208E4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A64896B0005; Thu, 25 Apr 2019 04:32:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A12C06B0006; Thu, 25 Apr 2019 04:32:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 92B566B0007; Thu, 25 Apr 2019 04:32:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3F6196B0005
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 04:32:55 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id p26so11266446edy.19
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 01:32:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=r7HEPcajroqq0XKiFs7F9hfn5iOp7TojsptrAfzwUPY=;
        b=Jlr7GEP9wfIwAWi73/IKitDT/lCXclj9bAeDKwfrPbEGdLAwYByWUXCUZk43YG1RhN
         pBk8RDuTMEgOg2Vlhqr7BdkGCHxa5oNrL4eqBdkP7e4yZg5VZGv0uAUc0gdDMP7A1i75
         DXZ7IqI6PX3bWQlO/uI9XT4CGdivbSZotANsxUPR8nUbeEYJAIAbW09QTt+AkiHqrSTU
         t8o4UrJAUoAFo+wETFl9xPKL6WnoizfdUdX4bg90lVlwI7wLdjXN+QlEMqpvQYj86eb/
         zK3ZZhXBHfBbIBE+zZ9yDcN5DbCV9gnItyLGjli3EKK16wwa3vpLL1lZdhSg7Jpl6DhI
         FBjQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAUthBSL8aDTZct628EriU4qBqY4CuvRImGTSofx7AHzFrrYRnOh
	MAvuX0TkKkuU1HW29JO1IncuPlsq2ofQ20j02hhveMz+FhlZHhFffoYrDiePRguiJJVhPkAI5y8
	kwKjcSTTjG2xrkU/8EdT2BQbe8X5sBoXfrJKr8MKU4gjrC+mrnE/X2gAb9rmVNdUtiw==
X-Received: by 2002:a17:906:1385:: with SMTP id f5mr2307951ejc.193.1556181174697;
        Thu, 25 Apr 2019 01:32:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx2vnLEnRV9U/NTefxINxAdFbINqJYxf87hHqq+39hpLAdjc+B1kJtNVwWinKLYpZOrFGkd
X-Received: by 2002:a17:906:1385:: with SMTP id f5mr2307907ejc.193.1556181173697;
        Thu, 25 Apr 2019 01:32:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556181173; cv=none;
        d=google.com; s=arc-20160816;
        b=jT0T81hK4ULv+8I1DdT67Djy/BqNX+p6xg/HG328CmGp2TfRR05p/NASYcvDbJHLFM
         7H5hiKPxl9UGyDm96TBizRBvU6QMr40BiB/fSKdNaRwHrWDTfFTQPMEZyu+voXJpCaR/
         scXYuwJSTh8xk9pMg5WD82lYwVM1QEycIdG5jqXuk2VwCWI+ft3qCj/cLIeZd65/9dPD
         Eg+BygqvrLkQZlSOp/EisqFTjIUEbhmTEgsPN09aEPOICNA5SwSOXroDTVDjWkghFCgd
         MYbIpF+lslH0pWxWNrKE5TuiXFYQKdbDksWp0zBm6wfSFuJhEzHUq1QJLCHT5jn5WdVI
         Lxqg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=r7HEPcajroqq0XKiFs7F9hfn5iOp7TojsptrAfzwUPY=;
        b=cPqQZYrjS2DXNpMF2RELiuVk3Lm1C4KwUz+W811CMXvoIvOzuL0huMvmZgxvq3ks91
         WZ+BjyUVTm/XnmmmebpH7EK1c1tqekVAyz6mPbGQGjd/JRp+4IwVXCrAUsE5Xo4qdCqu
         iFLeuoka0SQmkoM8jxVWKJVXrTlxVNXtW3zvF4+pQxykia4uXgvJMRzRrEUH9fhb5XTA
         Fn+SyR38Dv8sN32Kr4mksT57b1vTpbQl3wnjxuxsT4xOkoJoJzqcbWiInBbg3hdvxhr8
         Ev1wT3oDp8yYXFrAaNzZu42QJCsPwbMjFb+cvSphO4kJ5I4IZchQPH+2rajWaJpopC0U
         dpUg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g7si2206069edi.95.2019.04.25.01.32.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 01:32:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id C2B20ACA5;
	Thu, 25 Apr 2019 08:32:52 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 0DE601E15BE; Thu, 25 Apr 2019 10:32:52 +0200 (CEST)
Date: Thu, 25 Apr 2019 10:32:52 +0200
From: Jan Kara <jack@suse.cz>
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: cluster-devel@redhat.com, Christoph Hellwig <hch@lst.de>,
	Bob Peterson <rpeterso@redhat.com>, Jan Kara <jack@suse.cz>,
	Dave Chinner <david@fromorbit.com>,
	Ross Lagerwall <ross.lagerwall@citrix.com>,
	Mark Syms <Mark.Syms@citrix.com>,
	Edwin =?iso-8859-1?B?VPZy9ms=?= <edvin.torok@citrix.com>,
	linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH 1/2] iomap: Add a page_prepare callback
Message-ID: <20190425083252.GB21215@quack2.suse.cz>
References: <20190424171804.4305-1-agruenba@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190424171804.4305-1-agruenba@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 24-04-19 19:18:03, Andreas Gruenbacher wrote:
> Add a page_prepare calback that's called before a page is written to.  This
> will be used by gfs2 to start a transaction in page_prepare and end it in
> page_done.  Other filesystems that implement data journaling will require the
> same kind of mechanism.
> 
> Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>

Thanks for the patch. Some comments below.

> diff --git a/fs/iomap.c b/fs/iomap.c
> index 97cb9d486a7d..abd9aa76dbd1 100644
> --- a/fs/iomap.c
> +++ b/fs/iomap.c
> @@ -684,6 +684,10 @@ iomap_write_begin(struct inode *inode, loff_t pos, unsigned len, unsigned flags,
>  		status = __block_write_begin_int(page, pos, len, NULL, iomap);
>  	else
>  		status = __iomap_write_begin(inode, pos, len, page, iomap);
> +
> +	if (likely(!status) && iomap->page_prepare)
> +		status = iomap->page_prepare(inode, pos, len, page, iomap);
> +
>  	if (unlikely(status)) {
>  		unlock_page(page);
>  		put_page(page);

So this gets called after a page is locked. Is it OK for GFS2 to acquire
sd_log_flush_lock under page lock? Because e.g. gfs2_write_jdata_pagevec()
seems to acquire these locks the other way around so that could cause ABBA
deadlocks?

Also just looking at the code I was wondering about the following. E.g. in
iomap_write_end() we have code like:

        if (iomap->type == IOMAP_INLINE) {
		foo
	} else if (iomap->flags & IOMAP_F_BUFFER_HEAD) {
		bar
	} else {
		baz
	}

	if (iomap->page_done)
		iomap->page_done(...);

And now something very similar is in iomap_write_begin(). So won't it be
more natural to just mandate ->page_prepare() and ->page_done() callbacks
and each filesystem would set it to a helper function it needs? Probably we
could get rid of IOMAP_F_BUFFER_HEAD flag that way...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

