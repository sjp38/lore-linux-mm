Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C386C76192
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 06:59:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C7C6120838
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 06:59:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="t/+vMyBo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C7C6120838
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 760206B0007; Mon, 15 Jul 2019 02:59:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7108A6B0008; Mon, 15 Jul 2019 02:59:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6272B6B000A; Mon, 15 Jul 2019 02:59:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2DF246B0007
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 02:59:38 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id y9so7881946plp.12
        for <linux-mm@kvack.org>; Sun, 14 Jul 2019 23:59:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=IwKOrj6wOs1CFDvdOT5gCaug974d+VVC2EWPEZyUC1Y=;
        b=IKhQfW+Beq+J/YKo9WKafHeaDxrHnd3EP68xhIq0eX6afpSX2aW/dg6uwqMZ6L158m
         ZD5ymDLD/E77vqYrpzPyVEW2u02ZUPZlhUzlHpctSVsPpvKgUPmplUr1BlwbD1ieTk28
         EENhmOeVqT13DJh3/7VuqkOGYuXDLovyJNtsRvbuHlJsB1rdZZdioSSB/t1FkMbjq+ha
         AX5XleEBxeP9KqOgBzpcKhpiq02/i7LS46Z/dfS7lp9IR1xVcJlF5GB4IDsmwqiGflkk
         ZEcxu0BogRMvissazi95s5y5VV/owHAIITWcv+ohjmyYCoyg3jRaRaaHOgOYERh7v9/1
         B7ug==
X-Gm-Message-State: APjAAAUnVh/oOk/XGhdTaKLLEVp2IJQuAzDqJVHjUATY4s8d9A2RiIH3
	K2hUWCX87lJoNGrRu2NkLARzrO1l7CnMkOHDpqT9iEb2qRmfQg0jUSzjcAnN3WPH3TyKXtzcfXy
	Px6kKLv8xsZ6YRV9BoitlMrQooHq1iYJqANAXJd9Rt4RYee3WOgKqftcC4uuNstqKgw==
X-Received: by 2002:a17:902:740a:: with SMTP id g10mr26729741pll.82.1563173977815;
        Sun, 14 Jul 2019 23:59:37 -0700 (PDT)
X-Received: by 2002:a17:902:740a:: with SMTP id g10mr26729707pll.82.1563173977247;
        Sun, 14 Jul 2019 23:59:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563173977; cv=none;
        d=google.com; s=arc-20160816;
        b=SJXzLBplt23sh3ODOEXElzZjjrrOeyovUuOi/Bg4JULULY0dj3hxDRBMoJcjUrDj+m
         ygTYVc/4phV+GSKNDCaIH19HeyuLi3HvK6PNAw+yqf//vSfCGrY4DAbEORXkd1GcFSIx
         gDXirXovCCW1QdcYyY/SJ1Dagrl/OM9QxWB86BVpOwsyvzTNMsoYQupaPmn0f5L8ywMR
         CmlB6jg3vRYpyTb2HlEVSWVIix8zVRKMa7LxSxWmt6HmINR1hZwDAyPFfeYxlzh9PX++
         ve3tzQCT6lSGsOsGIMRZ96HNnblw6IEzPAGWpM7nHCBkXJRIRj+YnXABRxayxIjqBZ3n
         4BeA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=IwKOrj6wOs1CFDvdOT5gCaug974d+VVC2EWPEZyUC1Y=;
        b=pLbryiyOzuygxpJPQwKe7OzbKuE15dhycVUDabnMoQy8npGdHUuhrdt43pjKBiJ+oH
         8XCbcJJL/OpffETbvZQDvM/vSC7jZ3hBIoncQ96+S4vJeREifegOB5ic+YWt8+9crRYx
         72wVTWjnDUoYS/h0ThPeEm5Iq7jY6v09ECIh29jyK/VMtTq/KHL6/XVZ1JW3ardkIcyD
         XWlA13tr1xVI8HyXzkMD79UYYkDYgS8wjePgVJPqgedh82gx7xxKny6pC1sgsMu/JPxl
         UwA8A6Kt8K5j7ApVOBgsrLzMpDkoheMscQXUgTagotXZrTy0f/N/of4GDKXqtssZQ+Ce
         g1rA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="t/+vMyBo";
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b1sor8499990pfi.46.2019.07.14.23.59.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 14 Jul 2019 23:59:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="t/+vMyBo";
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=IwKOrj6wOs1CFDvdOT5gCaug974d+VVC2EWPEZyUC1Y=;
        b=t/+vMyBobZw0yRt1qj7jE3Hv3+ghewmbrlf1rvJGn+lPMgvyfvDx6cugAWNVxd8j97
         hVwx5mP2evT4/5buRUfwS8eLDCxI+aBX3bgCz20FFQApUJ56xzyc13BmxDzwNYE8jtdP
         5kVdnTfQCP2I6xoQWTBcnZRuiq5fxBeBK5pJ+ztIPKWpUD5GeFX4RFrdyOjovs9+vR3V
         xRzXOvvIagWzbmeCdNDvSLmFsoun9S1NnAZximqWbTF5UJU/N+cTCzk3SV4cVA5ph1fI
         G8NDPKhHyemJg5LOOz3NLKuEXNeAogyGjjXQq8sWXD2JtdeO3CnG6GLJ2pe09Z64g0rL
         eB3w==
X-Google-Smtp-Source: APXvYqxlTY9pqlj/BPGdaqjVxWccUIuIsUVjY5d4MIOOEnUblRLiyLEc5qKix+00afDAkA/xNHMT2g==
X-Received: by 2002:a63:224a:: with SMTP id t10mr25187948pgm.289.1563173976925;
        Sun, 14 Jul 2019 23:59:36 -0700 (PDT)
Received: from bharath12345-Inspiron-5559 ([103.110.42.33])
        by smtp.gmail.com with ESMTPSA id o130sm27438459pfg.171.2019.07.14.23.59.21
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Jul 2019 23:59:36 -0700 (PDT)
Date: Mon, 15 Jul 2019 12:29:17 +0530
From: Bharath Vedartham <linux.bhar@gmail.com>
To: Jens Axboe <axboe@kernel.dk>
Cc: akpm@linux-foundation.org, ira.weiny@intel.com, jhubbard@nvidia.com,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Dimitri Sivanich <sivanich@sgi.com>, Arnd Bergmann <arnd@arndb.de>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	Cornelia Huck <cohuck@redhat.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	=?iso-8859-1?Q?Bj=F6rn_T=F6pel?= <bjorn.topel@intel.com>,
	Magnus Karlsson <magnus.karlsson@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexei Starovoitov <ast@kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Jakub Kicinski <jakub.kicinski@netronome.com>,
	Jesper Dangaard Brouer <hawk@kernel.org>,
	John Fastabend <john.fastabend@gmail.com>,
	Enrico Weigelt <info@metux.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Alexios Zavras <alexios.zavras@intel.com>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Max Filippov <jcmvbkbc@gmail.com>,
	Matt Sickler <Matt.Sickler@daktronics.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Keith Busch <keith.busch@intel.com>,
	YueHaibing <yuehaibing@huawei.com>, linux-media@vger.kernel.org,
	linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org,
	kvm@vger.kernel.org, linux-block@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, bpf@vger.kernel.org,
	xdp-newbies@vger.kernel.org
Subject: Re: [PATCH] mm/gup: Use put_user_page*() instead of put_page*()
Message-ID: <20190715065917.GB3716@bharath12345-Inspiron-5559>
References: <1563131456-11488-1-git-send-email-linux.bhar@gmail.com>
 <018ee3d1-e2f0-ca12-9f63-945056c09985@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <018ee3d1-e2f0-ca12-9f63-945056c09985@kernel.dk>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Jul 14, 2019 at 08:33:57PM -0600, Jens Axboe wrote:
> On 7/14/19 1:08 PM, Bharath Vedartham wrote:
> > diff --git a/fs/io_uring.c b/fs/io_uring.c
> > index 4ef62a4..b4a4549 100644
> > --- a/fs/io_uring.c
> > +++ b/fs/io_uring.c
> > @@ -2694,10 +2694,9 @@ static int io_sqe_buffer_register(struct io_ring_ctx *ctx, void __user *arg,
> >   			 * if we did partial map, or found file backed vmas,
> >   			 * release any pages we did get
> >   			 */
> > -			if (pret > 0) {
> > -				for (j = 0; j < pret; j++)
> > -					put_page(pages[j]);
> > -			}
> > +			if (pret > 0)
> > +				put_user_pages(pages, pret);
> > +
> >   			if (ctx->account_mem)
> >   				io_unaccount_mem(ctx->user, nr_pages);
> >   			kvfree(imu->bvec);
> 
> You handled just the failure case of the buffer registration, but not
> the actual free in io_sqe_buffer_unregister().
> 
> -- 
> Jens Axboe
Yup got it! Thanks! I won't be sending a patch again as fs/io_uring.c
may have larger local changes for put_user_pages.

Thanks

