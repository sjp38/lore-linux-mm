Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 13E4FC76190
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 00:25:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D335021E6B
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 00:25:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D335021E6B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 65CAD6B0007; Mon, 22 Jul 2019 20:25:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 60DEB8E0003; Mon, 22 Jul 2019 20:25:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 524DF8E0001; Mon, 22 Jul 2019 20:25:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1C82A6B0007
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 20:25:38 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 21so24933079pfu.9
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 17:25:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=KrxkLO/LuqMTzkF7fmYrHUjWl8LiQ5m+fMIjDftW6C4=;
        b=AZZN7TwyGmR6k68VnZZBIunKQi4nM8EH7LSGu/DsccGgtjR0OXCAJY9Mtky/stp7sU
         h90IcCAjdcL2y2qO56dJw5FXfjD2eAidT3ZuIlP2WfJ+KE+galmw/HRUQC911aIFZCtl
         cZCLM9jj0U8j/hGXIMNrVz7Up6INCkISbLIPqGlrR99sfXcnhoEhr94zCdxbqisTYj90
         Cl0SgEGhCFzbYlaqX6hXxFjCQkuIulmVstFV8PPlkNlIXKPlpQ5c/QSUqySrmVPEeIdR
         IPM1HsjzsQYS18Nfb9KrZa2sRBntJLLOM9tZfgihLtapZhaxVwyd0etly/vDUxYsWdAJ
         +vzQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWJxFUMHoi7jHVIyh9DOjZoGuQ/QYoXHTEBvEyakko8JbSQx2lG
	lYCdYdiRBT7Rc7MBXcPrQkt62AcWKFtCet3Lfsx0+YY1WF/wwTk0I8MjN3cHqWNweqyplQpBigS
	Qx33WWHyhPvOvew0HOKWpxjQAvH2seWkX/SMGuaFgLch15RgjlZHU4EJWyoHTu/Pqqw==
X-Received: by 2002:a17:90a:8688:: with SMTP id p8mr80678402pjn.57.1563841537799;
        Mon, 22 Jul 2019 17:25:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzBKTeyRbGYIbZUmGkppx7tb2lbH2uebZ45MhuhFs2qu88hAzf29qdMc3qEBdmsyiIi07Ut
X-Received: by 2002:a17:90a:8688:: with SMTP id p8mr80678368pjn.57.1563841537160;
        Mon, 22 Jul 2019 17:25:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563841537; cv=none;
        d=google.com; s=arc-20160816;
        b=nzG8mI6H5Mw00Sf6cWjZUJN1tphE/ewP+c5Q3E0ltr75RZS2iU7C1AqCOJs6bvw9pZ
         0BO7Ntwmr5NhG7H5GN9YRQaWFYA605ZZ/XMI1RWkf2iM7d911mC2ZtCrSC0BkcLm2kwg
         NQdYEHMxm09OD03FkwE8vKwQKAx/P2N3rBL7IhMrLvRrcJ3NhsmGK8sFuR0eO/rW71LY
         43yRFfueYThUykOdFPtFnC1kibjbB0u2cRZBQ9Q37yMZgOw9LogtqRni/ZvcIVuvg5UW
         Io1r/+imwgcadJZNybssLj4e9AplXf6RfAhj37DCGTnLMLZ5MY8UaOWEK8DQU+uKOvvV
         Z3lw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=KrxkLO/LuqMTzkF7fmYrHUjWl8LiQ5m+fMIjDftW6C4=;
        b=rQWSe+tQsqJZGMdsr9hznNpBQSA2TrpAIXvb/bIq3jYqk3dVaZDj9U09WVxnFkZYZ4
         1MhUyYvAS/H5+aln/okpZt8gdrbr+2lJukwGbVfW5JQDXg4IIRbw19cIG/qeCi3P5kKu
         wRn7qD7GjOj04DRWbZv6DPLk2V79wA9w74s13MnH9J1nD2icbJR96FQnjfUxNgGaBceK
         3DH8UJMJV2Ihdt1EdXfdfFnmyso9kTJ6tLUFRe6NvgdnBMhTcAp+Mv8+vy5V3FrEfyls
         ZP4KsrYdOw2tZWpJydC5WHsveEP0+6uVsmQPBeBoOZJvzM3X/Pm6Y5u4qGnV8CTJhwDE
         0C6g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id p17si5437935pgm.238.2019.07.22.17.25.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jul 2019 17:25:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 22 Jul 2019 17:25:36 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,297,1559545200"; 
   d="scan'208";a="180568074"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga002.jf.intel.com with ESMTP; 22 Jul 2019 17:25:34 -0700
Date: Mon, 22 Jul 2019 17:25:34 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: john.hubbard@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	=?iso-8859-1?Q?Bj=F6rn_T=F6pel?= <bjorn.topel@intel.com>,
	Boaz Harrosh <boaz@plexistor.com>, Christoph Hellwig <hch@lst.de>,
	Daniel Vetter <daniel@ffwll.ch>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>, David Airlie <airlied@linux.ie>,
	"David S . Miller" <davem@davemloft.net>,
	Ilya Dryomov <idryomov@gmail.com>, Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>, Jens Axboe <axboe@kernel.dk>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Johannes Thumshirn <jthumshirn@suse.de>,
	Magnus Karlsson <magnus.karlsson@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	Miklos Szeredi <miklos@szeredi.hu>, Ming Lei <ming.lei@redhat.com>,
	Sage Weil <sage@redhat.com>,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>,
	Yan Zheng <zyan@redhat.com>, netdev@vger.kernel.org,
	dri-devel@lists.freedesktop.org, linux-mm@kvack.org,
	linux-rdma@vger.kernel.org, bpf@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH 3/3] net/xdp: convert put_page() to put_user_page*()
Message-ID: <20190723002534.GA10284@iweiny-DESK2.sc.intel.com>
References: <20190722223415.13269-1-jhubbard@nvidia.com>
 <20190722223415.13269-4-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190722223415.13269-4-jhubbard@nvidia.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 22, 2019 at 03:34:15PM -0700, john.hubbard@gmail.com wrote:
> From: John Hubbard <jhubbard@nvidia.com>
> 
> For pages that were retained via get_user_pages*(), release those pages
> via the new put_user_page*() routines, instead of via put_page() or
> release_pages().
> 
> This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
> ("mm: introduce put_user_page*(), placeholder versions").
> 
> Cc: Björn Töpel <bjorn.topel@intel.com>
> Cc: Magnus Karlsson <magnus.karlsson@intel.com>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: netdev@vger.kernel.org
> Signed-off-by: John Hubbard <jhubbard@nvidia.com>
> ---
>  net/xdp/xdp_umem.c | 9 +--------
>  1 file changed, 1 insertion(+), 8 deletions(-)
> 
> diff --git a/net/xdp/xdp_umem.c b/net/xdp/xdp_umem.c
> index 83de74ca729a..0325a17915de 100644
> --- a/net/xdp/xdp_umem.c
> +++ b/net/xdp/xdp_umem.c
> @@ -166,14 +166,7 @@ void xdp_umem_clear_dev(struct xdp_umem *umem)
>  
>  static void xdp_umem_unpin_pages(struct xdp_umem *umem)
>  {
> -	unsigned int i;
> -
> -	for (i = 0; i < umem->npgs; i++) {
> -		struct page *page = umem->pgs[i];
> -
> -		set_page_dirty_lock(page);
> -		put_page(page);
> -	}
> +	put_user_pages_dirty_lock(umem->pgs, umem->npgs);

What is the difference between this and

__put_user_pages(umem->pgs, umem->npgs, PUP_FLAGS_DIRTY_LOCK);

?

I'm a bit concerned with adding another form of the same interface.  We should
either have 1 call with flags (enum in this case) or multiple calls.  Given the
previous discussion lets move in the direction of having the enum but don't
introduce another caller of the "old" interface.

So I think on this patch NAK from me.

I also don't like having a __* call in the exported interface but there is a
__get_user_pages_fast() call so I guess there is precedent.  :-/

Ira

>  
>  	kfree(umem->pgs);
>  	umem->pgs = NULL;
> -- 
> 2.22.0
> 

