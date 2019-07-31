Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E7C45C41514
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 12:41:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AD086206B8
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 12:41:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="CV7jH3ve"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AD086206B8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 407108E000B; Wed, 31 Jul 2019 08:41:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3B7A48E0001; Wed, 31 Jul 2019 08:41:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 27F958E000B; Wed, 31 Jul 2019 08:41:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 07FC88E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:41:26 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id x1so61541043qts.9
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 05:41:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=ssT+JujOxDwS6NEpfq2Ge7MRteKET9yZx/jW5aTaxrI=;
        b=BNSneiRdLx56/YLKk7LuKXcpI+bl9b6bhXXu5iNXtJ7Qa2Ug4pBLPTZ6/qM0QC9OUG
         G3N3nLvjID/+CWTcB2RLSgU/Ae6r0OnX5sdpCaRhUd12w2IibPmBHgeALZRNbrzuHfp3
         dz8NxHxaghS5/gbFF9sc2rrypbmivKchh8jq+DY6oy6OZum+hoXBy9WP28TZttduKdAx
         QWDTi/aZwWg4iefZWnrDN6v9kykIA2CUR6cNuhzXgIU31E2utYq5wXg5W4nnE+Rf8akn
         XFS7TIFpQAtRzRKx6RUWDLLrgaqnT8u1wnqoIyp/4IH8MnZPt7LRLBvDhk64wp2zvaUk
         AElQ==
X-Gm-Message-State: APjAAAVY1cwWdvRYFqNoOyBevovngdathE6RCwLBf3T2umqJy61A3kBw
	y//oYjus/+2u9t2ieRKFUqaZpkxV2KobpQZDcFUhyyn1IuwEBszl71u/WBwm/jFhEedJckKO4wI
	lI8AjCI2UuWo9bZqd+MCc4XoKtov7cJ7azboDBWi9CShkGQl05E+8EYAUCeyvs3Ud0A==
X-Received: by 2002:a37:c408:: with SMTP id d8mr64845796qki.18.1564576885826;
        Wed, 31 Jul 2019 05:41:25 -0700 (PDT)
X-Received: by 2002:a37:c408:: with SMTP id d8mr64845752qki.18.1564576885261;
        Wed, 31 Jul 2019 05:41:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564576885; cv=none;
        d=google.com; s=arc-20160816;
        b=rq6PNJAg83G0OvdCWNr8FCHnz75K+hjR+t0ukTkwGRRGQr3QG315OQS9LAQfMoeoQW
         S8miRXUOhl4KRJbXw+OFE7Ha3OBkMOP9BRmxPWdRRe1PfV75raBoz2T7TZ/waKsdA/zU
         rR8i3NDH7QLX15ndXH8XGkLDdwXWZFkjDhMsHKSutN0wQybZm2OGwe43BU/W5Lysmk4m
         XYeFMlsT0cNTLOizM5/TlSWng939NGvkdqMOG7O/oxcA3CEiUNfq5vBgiH4OzaX9hA+9
         M9ITzMq+DOb5jJ/DWFlj1xDmD0WNoh7p6f88JdcsyvUAdY1cK3i6aj/+/KSCeNnq6W8T
         97jQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=ssT+JujOxDwS6NEpfq2Ge7MRteKET9yZx/jW5aTaxrI=;
        b=o954B1NWt6eVtLwR51x2n+bLepP1l66iQA3oADBi3JYkemXLqFEehXz0upx04bFge2
         6TCOIb08QAor5btGaVw9LNDflzBK7NBqgNWL9l6cYO5i+Pv4j9bFfGjKb1b1zoQcQ3yL
         vvH91X3lxBCn+wSPvZl+S5uiHC2jdtoSdbDc6q4234STf4XQkkVNaqXYCsWzuedkup1M
         7fUkuOLC+jHZUEsYs7z6M5kSogmbU2+qZ/nAnM0dh8Ck/gYVryO6vnT+jiDdUkBkjZEs
         Az30rsqVfIkYKkHPbSeowk2INrjWm0OXKEdeG6Ny0vGFq+6HY8HwzWk0BpQDLIuTYy8s
         on6w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=CV7jH3ve;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v12sor58069440qvj.22.2019.07.31.05.41.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 05:41:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=CV7jH3ve;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=ssT+JujOxDwS6NEpfq2Ge7MRteKET9yZx/jW5aTaxrI=;
        b=CV7jH3veMykUxgu+H5gGaJEiM7dHfRA3AWXtjSYfzu48EjQ0oDP+S8cs1UxQbidp/W
         MqKLYekmIDfV2RBQHTtrwRlnUCc5krtCPt3AASFeznsZkr+ipQT/XuC+Xn6vABBkKIFP
         enujxa2gQmDcqqBPQMXqNzw5a+lpfG5eB2A37iznAHNxxA9jQHhaTnP+cwJR1UO9lidY
         SP65bUUa5WqhqoZCyAGPCKh7SUkgLjT8qHxGXbgc7GA59ln/8F06imsHF08LgdqgZvE2
         /+AQjQMxZnEgE6iMjDFEfdphXGCtwyg1L1ebJpvApgpgereLtbGxAEtwqnD5666T6XAv
         R7qA==
X-Google-Smtp-Source: APXvYqwbN0Zcgw/rqJW/uUJyj5pJV/gEvjkDyEf6dYni+Q8BnL4R5HKzXod/DVe6ENOwDm8+CZT9Rw==
X-Received: by 2002:a0c:acab:: with SMTP id m40mr88924921qvc.52.1564576884920;
        Wed, 31 Jul 2019 05:41:24 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id u4sm29623865qkb.16.2019.07.31.05.41.24
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 31 Jul 2019 05:41:24 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hsnv2-0006PN-6Q; Wed, 31 Jul 2019 09:41:24 -0300
Date: Wed, 31 Jul 2019 09:41:24 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Jason Wang <jasowang@redhat.com>
Cc: mst@redhat.com, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH V2 4/9] vhost: reset invalidate_count in
 vhost_set_vring_num_addr()
Message-ID: <20190731124124.GD3946@ziepe.ca>
References: <20190731084655.7024-1-jasowang@redhat.com>
 <20190731084655.7024-5-jasowang@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190731084655.7024-5-jasowang@redhat.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 31, 2019 at 04:46:50AM -0400, Jason Wang wrote:
> The vhost_set_vring_num_addr() could be called in the middle of
> invalidate_range_start() and invalidate_range_end(). If we don't reset
> invalidate_count after the un-registering of MMU notifier, the
> invalidate_cont will run out of sync (e.g never reach zero). This will
> in fact disable the fast accessor path. Fixing by reset the count to
> zero.
> 
> Reported-by: Michael S. Tsirkin <mst@redhat.com>

Did Michael report this as well?

> Fixes: 7f466032dc9e ("vhost: access vq metadata through kernel virtual address")
> Signed-off-by: Jason Wang <jasowang@redhat.com>
>  drivers/vhost/vhost.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> index 2a3154976277..2a7217c33668 100644
> +++ b/drivers/vhost/vhost.c
> @@ -2073,6 +2073,10 @@ static long vhost_vring_set_num_addr(struct vhost_dev *d,
>  		d->has_notifier = false;
>  	}
>  
> +	/* reset invalidate_count in case we are in the middle of
> +	 * invalidate_start() and invalidate_end().
> +	 */
> +	vq->invalidate_count = 0;
>  	vhost_uninit_vq_maps(vq);
>  #endif
>  

