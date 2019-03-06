Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E8898C43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 18:45:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AF5782063F
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 18:45:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="V2pQCRMH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AF5782063F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 54D588E0003; Wed,  6 Mar 2019 13:45:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4FD2D8E0002; Wed,  6 Mar 2019 13:45:57 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 413D28E0003; Wed,  6 Mar 2019 13:45:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1BBC98E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 13:45:57 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id b6so10724108qkg.4
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 10:45:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=wP4x1hH9ASA25vStqJ3tJGCz2jYo8u6wNo9sRUut+8M=;
        b=IHpNONe2pv3ZT7B5pDbrcO3aqZUrBfAt+RLA9xXabpP0MkvBVKK1a0qGdCwFJPtT+h
         zEOqOorM+GcgP+O/mN+aPXeVUs6lyK1CK0L1mmopDjr586Smjxgjdo9zBiU6U9wVJ3z7
         PgWti/U4wMK2J+nvGFlrbF6bTsnl4yCsf5XMM4udbRzLDOevjYebO+dDam0Fu3JSmCR8
         T8a3PZwkgOFgWwHK7CP+8Q+2jvcMPTsemg7Ky9Fhj9LSn6YugySS3ZSJWtMUOD9GQAiX
         8y3bKoNh5tzNYsr2LR1/T/oVxBDrND/uFIHlqsfT39RQc+prCrU7EPCp7CN/BkR+EkrM
         JE8w==
X-Gm-Message-State: APjAAAVRbarKNs6dpQTYU3McQSVVc5Vrz9jLol/lU8mgRmCccT52zFpd
	T4Cd35QBgED1mWGFO3B/zBz3XD+Kj+ANMnRRN/kwjZ7rnPrA+ZStiFT01KZK5u/X0sREKo3Yeuo
	2in/fbCUf2GCxhn3m72EHzJdSqs0CwwF3phWl0cKuLZcq7cJpTR2EZ+2zYct7Fvf3u7xMG+MoyV
	J04gYinH5HPssUt+aPznH36Gfxdizk7yxxtocQw2arw2Qk7B/gB5if2H7iTQIYQoT2H7AUdtYjA
	r/wV180xsCZNjXnwJqNSCTxWSRWG96Trh5d95LiLC37pogTnUazG3Ai1VaXiNERoxXlmCiyD1AC
	fq4FnWfLI5zkiek7qIUqUkACzVzyMHKkZII/PO0PY6OMOQQb/lXAs/No/x6ZMYrM1daFHv9ycc/
	W
X-Received: by 2002:a37:a4c2:: with SMTP id n185mr6769609qke.152.1551897956785;
        Wed, 06 Mar 2019 10:45:56 -0800 (PST)
X-Received: by 2002:a37:a4c2:: with SMTP id n185mr6769573qke.152.1551897956184;
        Wed, 06 Mar 2019 10:45:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551897956; cv=none;
        d=google.com; s=arc-20160816;
        b=j00uc0sInBLo0tl924RUiB8iewLYVjuIx6nJZT6WVLQC2uWutYKutK94cLnx6jA2lE
         cYAQ0StYeM5QlxtK9JJg4uiE0nipecrEkKhEeL4QV79tcyOU/Z7K8tsQ1Cu4sby6zZhK
         Ckxp4XvFj9UWpIlIn9z1Ou71AIxIC5B2lzIr+7dAvdb4hEhELIvvR22kOEdcpKysWcvQ
         zWXzWdZrlbwXOgEY57Z3qxyup+mOvfO+pYOndh9P+N95Bs0ZB+XfxuFaWU6ors+2qmxB
         GNXu4CmOKpKrgU/zFTkNXg+LWFbjnFoHEsCGJEXnQu0ErWAuf1B1cyLw1RM6GfHnfyJH
         kwiw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=wP4x1hH9ASA25vStqJ3tJGCz2jYo8u6wNo9sRUut+8M=;
        b=QLFWLdR2kG2/rVZoXt6cn1BF3Q+AGUJw1vkhBldVd5DwSuz7rtNZAcCWyq60hyqOfw
         2OApdh+qrSlOyA/t0y6sFWaGK92UMR5hEaKLGhOfKk8sOPzJTMYXrjwUIqPsfd8DGi+R
         0AnaiEGm5z77Rjyg5YXBsxnLfsPLSt2WoebPOTHGRbopSFMIXA05gQn+fqX8SmEFAYNC
         tcNQQJK8N+6IHFSN1C6Gtr2myBZiR2+7R7EQSsK8jm1rsgWK1euCGNORDoTG+UhLW0Oq
         QNQaft47HO1WizrMXYisYNAN+oZunRcTsAQfBBv1doM0u+OI4GW5MOtzP9eHONwCU88t
         Mg6Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=V2pQCRMH;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l42sor2974594qta.50.2019.03.06.10.45.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Mar 2019 10:45:56 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=V2pQCRMH;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=wP4x1hH9ASA25vStqJ3tJGCz2jYo8u6wNo9sRUut+8M=;
        b=V2pQCRMHS1s6mmiWLTMzw9Ywz9BxY16RXHVXGkV3niNlpnB+mFV1VLlsophkQdsLKY
         2zX0WGYf21kPzTFJEHFymHSgJjUicWqvFegXwI7dJ02ONdTgbXy8tPVUnToWmvQiNmzv
         rr2w+eDAEDUk/TK4zkgOlp8tmeFWv141l7cZMMxV75Vlz/U+Nd0Glre4EuLwuQBs1Y+W
         RQTVaVh1CQS8BZ5RgDF3FPTsGhDR6WCsaWQQ82Ik2Fd0K1PVjkPmZqoHlrG5XVGyxcaF
         TWAh0xgJf8AHJBXBdy45No4KJa8kIvApq90vDKVujmF91qYNn1ZAJO9/izATrWi3xpHe
         sJjA==
X-Google-Smtp-Source: APXvYqxJhjubnP2c5kwOcRCIALiz3FeIJ/AsJUODcIi8OSpPh57S2nc20GPqu2e0uRk2rhdoVnXYzw==
X-Received: by 2002:ac8:148b:: with SMTP id l11mr6577506qtj.290.1551897955580;
        Wed, 06 Mar 2019 10:45:55 -0800 (PST)
Received: from ziepe.ca ([24.137.65.181])
        by smtp.gmail.com with ESMTPSA id l31sm1519876qtb.20.2019.03.06.10.45.54
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 06 Mar 2019 10:45:54 -0800 (PST)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1h1bYA-00079W-2T; Wed, 06 Mar 2019 14:45:54 -0400
Date: Wed, 6 Mar 2019 14:45:54 -0400
From: Jason Gunthorpe <jgg@ziepe.ca>
To: john.hubbard@gmail.com
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>,
	Artemy Kovalyov <artemyko@mellanox.com>,
	Leon Romanovsky <leon@kernel.org>, Ira Weiny <ira.weiny@intel.com>,
	Doug Ledford <dledford@redhat.com>, linux-rdma@vger.kernel.org
Subject: Re: [PATCH] RDMA/umem: updated bug fix in error handling path
Message-ID: <20190306184554.GG1662@ziepe.ca>
References: <20190306020022.21828-1-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190306020022.21828-1-jhubbard@nvidia.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 05, 2019 at 06:00:22PM -0800, john.hubbard@gmail.com wrote:
> From: John Hubbard <jhubbard@nvidia.com>
> 
> The previous attempted bug fix overlooked the fact that
> ib_umem_odp_map_dma_single_page() was doing a put_page()
> upon hitting an error. So there was not really a bug there.
> 
> Therefore, this reverts the off-by-one change, but
> keeps the change to use release_pages() in the error path.
> 
> Fixes: commit xxxxxxxxxxxx ("RDMA/umem: minor bug fix in error handling path")
> Suggested-by: Artemy Kovalyov <artemyko@mellanox.com>
> 
> Cc: Leon Romanovsky <leon@kernel.org>
> Cc: Ira Weiny <ira.weiny@intel.com>
> Cc: Jason Gunthorpe <jgg@ziepe.ca>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Doug Ledford <dledford@redhat.com>
> Cc: linux-rdma@vger.kernel.org
> Cc: linux-mm@kvack.org
> Signed-off-by: John Hubbard <jhubbard@nvidia.com>
> ---
>  drivers/infiniband/core/umem_odp.c | 9 ++++++---
>  1 file changed, 6 insertions(+), 3 deletions(-)

Applied to for-next, thanks

Jason

