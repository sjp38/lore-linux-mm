Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4AD1BC282DD
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 15:32:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 05F712175B
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 15:32:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 05F712175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 921C56B0271; Thu, 23 May 2019 11:32:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8D20C6B0272; Thu, 23 May 2019 11:32:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 79A2C6B0273; Thu, 23 May 2019 11:32:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 574C36B0271
	for <linux-mm@kvack.org>; Thu, 23 May 2019 11:32:00 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id w34so5640459qtc.16
        for <linux-mm@kvack.org>; Thu, 23 May 2019 08:32:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=lEVfPkVfbwccBniTLIDBnpF3OcPrQhqGvlqNpb+wuV0=;
        b=X+Zj6bJPAM5Pieaq3sOeI7AZn7HefzHoTTM/WlL+e3VURWDRjHeXzdB9/tnY0Nrml7
         LFZvlAUc+7k+tz3tPVgBC//Ogfkw+FA/v33ACaTU38riYbHd1D0WwWjJ4VF+h5BL+lnw
         uCS6wwcLh4LmmTUs+uezmFyenbl9a6sbZ5ATB5NGHafyAXubTstxvDBDUOXweAROF+wE
         TPG5RRnHLNapLV3XRw7gze0FpXn/cRCT62+z6/IGUi9o6h9h8xWD6xKDaM+mOAVRh1UP
         bdHg+8ykHbA1KgZeyAi6EaazOROv+lwHdhvAMNZ7/smYga005v6BrAfd0xWILzD95H6z
         F7rQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUtTZqHo+0UV0IiJGUxHKTocM7g9BJ54P5reJci+9jG+jVvOFVA
	JLKbfwxYv+Ke1ERMngj+fHAcGN5U/v0zquXJLxad6qrgK8fvyL1Qj7QKldIiyTaIwcLhLuDm80/
	337EOBuYse4UXoHCxcLE/y4VN2QjhEgQp9VRi3vphjOm6eVPmSRn+9bhR9Avcc/RfHA==
X-Received: by 2002:ac8:8fd:: with SMTP id y58mr82756439qth.375.1558625520058;
        Thu, 23 May 2019 08:32:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxPxqXDKzTiYPdNY1oB/WDcVBl1DwFnE2uZjzGHPAXiPoWiHoQ0dN163LYAcUlzZc3CLlrB
X-Received: by 2002:ac8:8fd:: with SMTP id y58mr82756360qth.375.1558625519432;
        Thu, 23 May 2019 08:31:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558625519; cv=none;
        d=google.com; s=arc-20160816;
        b=EtJBlTWFRJOH+Nz7czdTaOuqQIg85Qq+a3eF4i3F6LO29nh0RCvG5DA7XH/f5luTOM
         pve9pNEHMqo+8g7GyaPSzqc7/F/Uzxsq6v4uBrpO5kIPXDrI8x3T5vdpJkG4qEMi1g/+
         YBCAFHcKiNJIprls8A9VHbOxuhKsgeA4TEREouq7cmdBzuIwQVIwqqdjsQofX5fK5K4K
         MyK8Q5buFxNdHXYSThRsSWA51b1CFFLKDTsF0o83sTGCNWVKCEYkaF1FX+zn2+8YomXY
         3yyDhp4hTGQD74nAZZoTH+0QKShe8JK/bgWFZzBPY9clBomHx5ygJfNo11/6WZ9hzIXo
         A4Lw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=lEVfPkVfbwccBniTLIDBnpF3OcPrQhqGvlqNpb+wuV0=;
        b=u9LkHxYFqxLFc6ZnibPgZ0H3vurwSxeyIVMazE49xN8Bf/8ClpNzjFWWZQsKQs2nP3
         ZROwTnI4QJHlqhdbUNk3RBCBAynE4k6zFBGLkl7uejUAN2EHuicaw1NS1vbfbvZPZ+S2
         OI1m/Wja4++3PFo9Uc2pEuWMP99Hgkx7+yKYwlk5Y/NhOm4lLrzuGREZO516YnG5GKJZ
         QKqnMFrKJ+cbu1nGI3kKOhgKv5GP9UmnebXodh/jMAZDGlfbUOc3oF1FkZEyh6QdwYfF
         VdApju3lkE2AOwL77Em+cHIVzjXuHlhUvI8SSi/YwL4xDmrDKu9ufL3zcTHqdbQ36eR8
         CFXw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v7si2600444qvc.122.2019.05.23.08.31.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 May 2019 08:31:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A6B89C05B038;
	Thu, 23 May 2019 15:31:39 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.178])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 461DB79599;
	Thu, 23 May 2019 15:31:35 +0000 (UTC)
Date: Thu, 23 May 2019 11:31:33 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: john.hubbard@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	Jason Gunthorpe <jgg@ziepe.ca>, LKML <linux-kernel@vger.kernel.org>,
	linux-rdma@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>,
	Doug Ledford <dledford@redhat.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Christian Benvenuti <benve@cisco.com>, Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@mellanox.com>, Ira Weiny <ira.weiny@intel.com>
Subject: Re: [PATCH 1/1] infiniband/mm: convert put_page() to put_user_page*()
Message-ID: <20190523153133.GB5104@redhat.com>
References: <20190523072537.31940-1-jhubbard@nvidia.com>
 <20190523072537.31940-2-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190523072537.31940-2-jhubbard@nvidia.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Thu, 23 May 2019 15:31:58 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 23, 2019 at 12:25:37AM -0700, john.hubbard@gmail.com wrote:
> From: John Hubbard <jhubbard@nvidia.com>
> 
> For infiniband code that retains pages via get_user_pages*(),
> release those pages via the new put_user_page(), or
> put_user_pages*(), instead of put_page()
> 
> This is a tiny part of the second step of fixing the problem described
> in [1]. The steps are:
> 
> 1) Provide put_user_page*() routines, intended to be used
>    for releasing pages that were pinned via get_user_pages*().
> 
> 2) Convert all of the call sites for get_user_pages*(), to
>    invoke put_user_page*(), instead of put_page(). This involves dozens of
>    call sites, and will take some time.
> 
> 3) After (2) is complete, use get_user_pages*() and put_user_page*() to
>    implement tracking of these pages. This tracking will be separate from
>    the existing struct page refcounting.
> 
> 4) Use the tracking and identification of these pages, to implement
>    special handling (especially in writeback paths) when the pages are
>    backed by a filesystem. Again, [1] provides details as to why that is
>    desirable.
> 
> [1] https://lwn.net/Articles/753027/ : "The Trouble with get_user_pages()"
> 
> Cc: Doug Ledford <dledford@redhat.com>
> Cc: Jason Gunthorpe <jgg@ziepe.ca>
> Cc: Mike Marciniszyn <mike.marciniszyn@intel.com>
> Cc: Dennis Dalessandro <dennis.dalessandro@intel.com>
> Cc: Christian Benvenuti <benve@cisco.com>
> 
> Reviewed-by: Jan Kara <jack@suse.cz>
> Reviewed-by: Dennis Dalessandro <dennis.dalessandro@intel.com>
> Acked-by: Jason Gunthorpe <jgg@mellanox.com>
> Tested-by: Ira Weiny <ira.weiny@intel.com>
> Signed-off-by: John Hubbard <jhubbard@nvidia.com>

Reviewed-by: Jérôme Glisse <jglisse@redhat.com>

Between i have a wishlist see below


> ---
>  drivers/infiniband/core/umem.c              |  7 ++++---
>  drivers/infiniband/core/umem_odp.c          | 10 +++++-----
>  drivers/infiniband/hw/hfi1/user_pages.c     | 11 ++++-------
>  drivers/infiniband/hw/mthca/mthca_memfree.c |  6 +++---
>  drivers/infiniband/hw/qib/qib_user_pages.c  | 11 ++++-------
>  drivers/infiniband/hw/qib/qib_user_sdma.c   |  6 +++---
>  drivers/infiniband/hw/usnic/usnic_uiom.c    |  7 ++++---
>  7 files changed, 27 insertions(+), 31 deletions(-)
> 
> diff --git a/drivers/infiniband/core/umem.c b/drivers/infiniband/core/umem.c
> index e7ea819fcb11..673f0d240b3e 100644
> --- a/drivers/infiniband/core/umem.c
> +++ b/drivers/infiniband/core/umem.c
> @@ -54,9 +54,10 @@ static void __ib_umem_release(struct ib_device *dev, struct ib_umem *umem, int d
>  
>  	for_each_sg_page(umem->sg_head.sgl, &sg_iter, umem->sg_nents, 0) {
>  		page = sg_page_iter_page(&sg_iter);
> -		if (!PageDirty(page) && umem->writable && dirty)
> -			set_page_dirty_lock(page);
> -		put_page(page);
> +		if (umem->writable && dirty)
> +			put_user_pages_dirty_lock(&page, 1);
> +		else
> +			put_user_page(page);

Can we get a put_user_page_dirty(struct page 8*pages, bool dirty, npages) ?

It is a common pattern that we might have to conditionaly dirty the pages
and i feel it would look cleaner if we could move the branch within the
put_user_page*() function.

Cheers,
Jérôme

