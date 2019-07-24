Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0E4B1C7618B
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 08:08:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CE40B21873
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 08:08:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CE40B21873
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 70E506B0005; Wed, 24 Jul 2019 04:08:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6BF326B0006; Wed, 24 Jul 2019 04:08:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5D4256B0007; Wed, 24 Jul 2019 04:08:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3DD3F6B0005
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 04:08:08 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id d26so40806615qte.19
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 01:08:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to;
        bh=/MFYQFzENwHk5G46kOvOVKTzaxjp4jXpKM7WypPWBDc=;
        b=m75OzfQpc8LyjJcIyFXI4564I3JBwAkDubdIlirZAP/z/+Fgll0kz1J1q/FS+IZO+0
         7BUDINwf8NH+lQp+B0lYKeRhEs7OGOrytwzVYUUqksTDhHziC5ySdKPo0fMs849aPMps
         QlcO56NqANuUQVisb5NAVtCNDlZtLQsgKUsOUs65ri7ed67EUakiPcYFrwB/uTDAeJPt
         rNg/XMmn4Rs/qo8isqkglH2rlpqvSJxJAmWDe2gAWxCOiYBT8TkESruBVrh9PWnJipYF
         vRsDC/eXrbxBUtULcF7iRdhisij36A8pSAJJ1OKzdy+0ihisjfihWypzVfW8KWkwtRDX
         Kavw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAU1ov29IR4bvujX5i2qjK1RV0Ef0ymEzMqOfOhCU16lVJuxz3B+
	QSL5xEd43qYFGEsHnenCcQC5F7J/9zHR7faqkPt3u4bSv3JEz23fcvAZVW5HcSUQGg3tjJk274O
	8Cdv0r/dpCDftyOONX1qdR/+UepeERe4Yaa4NxXx/jlJxQWPDTrTPduutwS80wkaiGg==
X-Received: by 2002:aed:3ed5:: with SMTP id o21mr56720395qtf.369.1563955688034;
        Wed, 24 Jul 2019 01:08:08 -0700 (PDT)
X-Received: by 2002:aed:3ed5:: with SMTP id o21mr56720372qtf.369.1563955687484;
        Wed, 24 Jul 2019 01:08:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563955687; cv=none;
        d=google.com; s=arc-20160816;
        b=AEIRJcrRFmeVxz3TXvaDv4CpzT3K3MFslAIiH1KP/Bo9tyNt45IPMYX1jEMih5bWyG
         u3lAnpMJ57N+51uwnwAFcLicv52TXQfJlXA6/Qlnt11aEFSTaeHfYjaWnsgBLRYp8K4Y
         VEgMsoPwJjzcjSrL3rEkp7M+rSJZrKhtRcWPyZKi0nw9cQ9ISUOMI+SsWozo55jwFZy6
         RhuWOVnVeA/hdRupJjHAzC4COilY55jMdvhEoqqLH7oonZvRvS0VMOe+kbssSHZdsA8G
         Vxjfh4af0QBCsGiHR29L/wSzbwm13j1Ntm32tR++aD30Y6m1WoRFwLIhNsRvvgAFiJ7f
         Vg6Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :mime-version:references:message-id:subject:cc:to:from:date;
        bh=/MFYQFzENwHk5G46kOvOVKTzaxjp4jXpKM7WypPWBDc=;
        b=ANmpYV6u2eCFpRu25lhv2FQ021x8RaQEL3vd1qOQJkWtYcJwoxXcEVlY0XaLi/UAKP
         4OImSbt5phvSxplWJgFQPMA5A6ZqJuZ2gAvO18WADSXYGKrk5Xn7wmypQjU7LcrXIAp0
         nVXoFsyL3gDZMY0j/wvHHsvEa2/+TcwjbxZHtmZ/YcJBQ62GTQBMLHUotsomA7DMF3EZ
         Erccwo7mH/D5DRqoziRR5DKkO0ydChgeC1jgH4EuumawroV/+aaBTDrSZVvNNq03BeJ/
         AoZmlaz2lJ7MzDWxKyuNNUvqMu+i0JvQ+Mw830yDgWmRHnioEAg90nwRvcgh2CZPD1kP
         udxA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c191sor25720828qke.78.2019.07.24.01.08.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jul 2019 01:08:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqyqOJ7xj5WyBSGnSKw6r+fHzKSSQgggyWILPC/N5KbhyvrIGi3wpGDnO2q6i0xNWsrtSCd37A==
X-Received: by 2002:a05:620a:31b:: with SMTP id s27mr17648521qkm.264.1563955687250;
        Wed, 24 Jul 2019 01:08:07 -0700 (PDT)
Received: from redhat.com (bzq-79-181-91-42.red.bezeqint.net. [79.181.91.42])
        by smtp.gmail.com with ESMTPSA id t26sm23203051qtc.95.2019.07.24.01.07.58
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 24 Jul 2019 01:08:06 -0700 (PDT)
Date: Wed, 24 Jul 2019 04:07:55 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: john.hubbard@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Anna Schumaker <anna.schumaker@netapp.com>,
	"David S . Miller" <davem@davemloft.net>,
	Dominique Martinet <asmadeus@codewreck.org>,
	Eric Van Hensbergen <ericvh@gmail.com>,
	Jason Gunthorpe <jgg@ziepe.ca>, Jason Wang <jasowang@redhat.com>,
	Jens Axboe <axboe@kernel.dk>, Latchesar Ionkov <lucho@ionkov.net>,
	Miklos Szeredi <miklos@szeredi.hu>,
	Trond Myklebust <trond.myklebust@hammerspace.com>,
	Christoph Hellwig <hch@lst.de>,
	Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org,
	LKML <linux-kernel@vger.kernel.org>, ceph-devel@vger.kernel.org,
	kvm@vger.kernel.org, linux-block@vger.kernel.org,
	linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, samba-technical@lists.samba.org,
	v9fs-developer@lists.sourceforge.net,
	virtualization@lists.linux-foundation.org,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	John Hubbard <jhubbard@nvidia.com>, Jan Kara <jack@suse.cz>,
	Dan Williams <dan.j.williams@intel.com>,
	Johannes Thumshirn <jthumshirn@suse.de>,
	Ming Lei <ming.lei@redhat.com>, Dave Chinner <david@fromorbit.com>,
	Boaz Harrosh <boaz@plexistor.com>,
	Paolo Bonzini <pbonzini@redhat.com>,
	Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [PATCH 07/12] vhost-scsi: convert put_page() to put_user_page*()
Message-ID: <20190724040745-mutt-send-email-mst@kernel.org>
References: <20190724042518.14363-1-jhubbard@nvidia.com>
 <20190724042518.14363-8-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190724042518.14363-8-jhubbard@nvidia.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 23, 2019 at 09:25:13PM -0700, john.hubbard@gmail.com wrote:
> From: Jérôme Glisse <jglisse@redhat.com>
> 
> For pages that were retained via get_user_pages*(), release those pages
> via the new put_user_page*() routines, instead of via put_page().
> 
> This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
> ("mm: introduce put_user_page*(), placeholder versions").
> 
> Changes from Jérôme's original patch:
> 
> * Changed a WARN_ON to a BUG_ON.
> 
> Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
> Signed-off-by: John Hubbard <jhubbard@nvidia.com>
> Cc: virtualization@lists.linux-foundation.org
> Cc: linux-fsdevel@vger.kernel.org
> Cc: linux-block@vger.kernel.org
> Cc: linux-mm@kvack.org
> Cc: Jan Kara <jack@suse.cz>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Alexander Viro <viro@zeniv.linux.org.uk>
> Cc: Johannes Thumshirn <jthumshirn@suse.de>
> Cc: Christoph Hellwig <hch@lst.de>
> Cc: Jens Axboe <axboe@kernel.dk>
> Cc: Ming Lei <ming.lei@redhat.com>
> Cc: Dave Chinner <david@fromorbit.com>
> Cc: Jason Gunthorpe <jgg@ziepe.ca>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Boaz Harrosh <boaz@plexistor.com>
> Cc: Miklos Szeredi <miklos@szeredi.hu>
> Cc: "Michael S. Tsirkin" <mst@redhat.com>
> Cc: Jason Wang <jasowang@redhat.com>
> Cc: Paolo Bonzini <pbonzini@redhat.com>
> Cc: Stefan Hajnoczi <stefanha@redhat.com>

Acked-by: Michael S. Tsirkin <mst@redhat.com>

> ---
>  drivers/vhost/scsi.c | 13 ++++++++++---
>  1 file changed, 10 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/vhost/scsi.c b/drivers/vhost/scsi.c
> index a9caf1bc3c3e..282565ab5e3f 100644
> --- a/drivers/vhost/scsi.c
> +++ b/drivers/vhost/scsi.c
> @@ -329,11 +329,11 @@ static void vhost_scsi_release_cmd(struct se_cmd *se_cmd)
>  
>  	if (tv_cmd->tvc_sgl_count) {
>  		for (i = 0; i < tv_cmd->tvc_sgl_count; i++)
> -			put_page(sg_page(&tv_cmd->tvc_sgl[i]));
> +			put_user_page(sg_page(&tv_cmd->tvc_sgl[i]));
>  	}
>  	if (tv_cmd->tvc_prot_sgl_count) {
>  		for (i = 0; i < tv_cmd->tvc_prot_sgl_count; i++)
> -			put_page(sg_page(&tv_cmd->tvc_prot_sgl[i]));
> +			put_user_page(sg_page(&tv_cmd->tvc_prot_sgl[i]));
>  	}
>  
>  	vhost_scsi_put_inflight(tv_cmd->inflight);
> @@ -630,6 +630,13 @@ vhost_scsi_map_to_sgl(struct vhost_scsi_cmd *cmd,
>  	size_t offset;
>  	unsigned int npages = 0;
>  
> +	/*
> +	 * Here in all cases we should have an IOVEC which use GUP. If that is
> +	 * not the case then we will wrongly call put_user_page() and the page
> +	 * refcount will go wrong (this is in vhost_scsi_release_cmd())
> +	 */
> +	WARN_ON(!iov_iter_get_pages_use_gup(iter));
> +
>  	bytes = iov_iter_get_pages(iter, pages, LONG_MAX,
>  				VHOST_SCSI_PREALLOC_UPAGES, &offset);
>  	/* No pages were pinned */
> @@ -681,7 +688,7 @@ vhost_scsi_iov_to_sgl(struct vhost_scsi_cmd *cmd, bool write,
>  			while (p < sg) {
>  				struct page *page = sg_page(p++);
>  				if (page)
> -					put_page(page);
> +					put_user_page(page);
>  			}
>  			return ret;
>  		}
> -- 
> 2.22.0

