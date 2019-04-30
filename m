Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9B19C43219
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 12:03:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 416152075E
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 12:03:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="JV95Zyez"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 416152075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C52EC6B0003; Tue, 30 Apr 2019 08:03:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BDBF46B0005; Tue, 30 Apr 2019 08:03:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A7D116B0007; Tue, 30 Apr 2019 08:03:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6BB536B0003
	for <linux-mm@kvack.org>; Tue, 30 Apr 2019 08:03:28 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id v9so8899037pgg.8
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 05:03:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=E0exx3n0C2XJl2Hl8nf22jaGDtmhUa6UxBmXJxo+I2o=;
        b=qvDVC1Enbtjm9jbI/eO3XKZwCyUeHjtdhd7wD6Y6ruxPQqW3K8e6yKxUPUNSVV2THd
         H4nAhEFEHMCjXJZA4Mv+J4R13EHz3JRx/smzLw0iHbUZMbk3MwPs+CMCpqa++NTLXr1d
         3O3mDXqqGyhfUia5qB61tUBzOCmYl5P5nrgY7amYjXXvFl1icXeNUPHPkau5EK0VbGA5
         W1Zsf+1kL9aY48KINB3vRJYKVLEPM2AkwwSY+iAjVAoKLWAEQkVYSh5ZoiofuBITnwHs
         Yav89ZrEvtmcy9GABQs0BvTuOEwWljCbs+eGtU/qtA3HPvnEbvJq5JpffxOvUmvVQlUe
         TMHg==
X-Gm-Message-State: APjAAAVzOznu1tnR1/3uICN6ol5Ls1BjGcurwfjduuEnzlCHJh2QR5Mj
	as7swWp5kr5/4nffCgZpaL4KqPoN5sBGegZ7hk7RR5yQG/zC4PCywegubUkPii+ExXErvuGpzr4
	opKQb3KsahBcksX5dxqYa7iQOUa8TntJNKNy20vvkS2xTeAX0tRbTsCpd5aNoPPBUpA==
X-Received: by 2002:aa7:924a:: with SMTP id 10mr24135596pfp.15.1556625807974;
        Tue, 30 Apr 2019 05:03:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyXFxX47XOHfas4dnZNJ0grPuvUyZhc5FKRr1QhPptD4E9rVxfHD890lpPKg2KRW9azRsW5
X-Received: by 2002:aa7:924a:: with SMTP id 10mr24135476pfp.15.1556625806980;
        Tue, 30 Apr 2019 05:03:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556625806; cv=none;
        d=google.com; s=arc-20160816;
        b=xPKglYHB95I3Y1fOobwfwPPHXn2Rg303erHPXo+pfE9TRocLaV08PjBKAzz24EdFvY
         e0zoH+9tI6jjPn5kmMqsSGnnoYBtpDdxHiMInvyeq2fTIBhLL0FV/XAdw7yZh4J0NQbs
         NMG6sUl50RHTKb3ffBeLLC+B0FpmwpKPP1VvwVOdGXZFT8p6NXIkJGDg56eoRD6z5MMV
         Z2DTFsCqGiJNx5MTyjr9Cmtn9kYfFggqCwi4baMBK6QFVCRT72DM1TtzN/7fjUUPaAa6
         LWmISQwn9qXrbwtOGN867HZg+TNTv+CsT0TEGSBMe3kXe8Ru7h4bR5JLKmxLaX7T3L2S
         0HBg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=E0exx3n0C2XJl2Hl8nf22jaGDtmhUa6UxBmXJxo+I2o=;
        b=E8hSref3uenBLC1jTqRM0mW1OPlKfJuYLZRIfODppdX5lNtwaW5D7NcDhtahCqpWEX
         x/PH8wyIDe7rFM5ZFKx+pSnorQtaPhqHhWgk5K0IZq7Uh8HQVtxfgpg2bULoA4yL3XxU
         BLt0W5ccHcDFWhPTaVeT3BTX4tcOOkJp3SmIzLhwBaduQpz4zcjcUbQiKPcLu1UcztAV
         vTuCDk9GhHX8gSoVtpUMi/KrfZEGath18Tv3xcKzLFiG5NVcXPXZ5v4qDoTcPO1s1c1w
         4+O0XOXEiOH/XUgq6bDWastnh53EbIQCHxcKcsmpOR6g8zQAORz+fdtFMzZvwGoo6Bb7
         5jOw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=JV95Zyez;
       spf=pass (google.com: domain of leon@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=leon@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id s205si35289925pgs.467.2019.04.30.05.03.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Apr 2019 05:03:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of leon@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=JV95Zyez;
       spf=pass (google.com: domain of leon@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=leon@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from localhost (unknown [193.47.165.251])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 5781F20835;
	Tue, 30 Apr 2019 12:03:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1556625806;
	bh=vfCr04KFuWTnfRIx5YFbzxFml3k6X036yCo56FLgZHw=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=JV95ZyezEgr2kzNrEuLil5pkzkqEL+QJXmM8eMx0gozO8Hty8hRwiQUnvITXu+MNW
	 /TO4ACMbTIsFza+bLXSh33ZElmvqbbD2Lu+SHn0q83lDt9L5/3rVYfbjuNqGQUI9S+
	 h66Nn25wjDLCBFUhOOXOrUusqUqAiBXR0jRxXwpM=
Date: Tue, 30 Apr 2019 15:03:21 +0300
From: Leon Romanovsky <leon@kernel.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Andrey Konovalov <andreyknvl@google.com>,
	Will Deacon <will.deacon@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Kees Cook <keescook@chromium.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Yishai Hadas <yishaih@mellanox.com>,
	linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	linux-arch@vger.kernel.org, netdev@vger.kernel.org,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v13 16/20] IB/mlx4, arm64: untag user pointers in
 mlx4_get_umem_mr
Message-ID: <20190430120321.GF6705@mtr-leonro.mtl.com>
References: <cover.1553093420.git.andreyknvl@google.com>
 <1e2824fd77e8eeb351c6c6246f384d0d89fd2d58.1553093421.git.andreyknvl@google.com>
 <20190429180915.GZ6705@mtr-leonro.mtl.com>
 <20190430111625.GD29799@arrakis.emea.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190430111625.GD29799@arrakis.emea.arm.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 30, 2019 at 12:16:25PM +0100, Catalin Marinas wrote:
> (trimmed down the cc list slightly as the message bounces)
>
> On Mon, Apr 29, 2019 at 09:09:15PM +0300, Leon Romanovsky wrote:
> > On Wed, Mar 20, 2019 at 03:51:30PM +0100, Andrey Konovalov wrote:
> > > This patch is a part of a series that extends arm64 kernel ABI to allow to
> > > pass tagged user pointers (with the top byte set to something else other
> > > than 0x00) as syscall arguments.
> > >
> > > mlx4_get_umem_mr() uses provided user pointers for vma lookups, which can
> > > only by done with untagged pointers.
> > >
> > > Untag user pointers in this function.
> > >
> > > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> > > ---
> > >  drivers/infiniband/hw/mlx4/mr.c | 7 ++++---
> > >  1 file changed, 4 insertions(+), 3 deletions(-)
> > >
> > > diff --git a/drivers/infiniband/hw/mlx4/mr.c b/drivers/infiniband/hw/mlx4/mr.c
> > > index 395379a480cb..9a35ed2c6a6f 100644
> > > --- a/drivers/infiniband/hw/mlx4/mr.c
> > > +++ b/drivers/infiniband/hw/mlx4/mr.c
> > > @@ -378,6 +378,7 @@ static struct ib_umem *mlx4_get_umem_mr(struct ib_udata *udata, u64 start,
> > >  	 * again
> > >  	 */
> > >  	if (!ib_access_writable(access_flags)) {
> > > +		unsigned long untagged_start = untagged_addr(start);
> > >  		struct vm_area_struct *vma;
> > >
> > >  		down_read(&current->mm->mmap_sem);
> > > @@ -386,9 +387,9 @@ static struct ib_umem *mlx4_get_umem_mr(struct ib_udata *udata, u64 start,
> > >  		 * cover the memory, but for now it requires a single vma to
> > >  		 * entirely cover the MR to support RO mappings.
> > >  		 */
> > > -		vma = find_vma(current->mm, start);
> > > -		if (vma && vma->vm_end >= start + length &&
> > > -		    vma->vm_start <= start) {
> > > +		vma = find_vma(current->mm, untagged_start);
> > > +		if (vma && vma->vm_end >= untagged_start + length &&
> > > +		    vma->vm_start <= untagged_start) {
> > >  			if (vma->vm_flags & VM_WRITE)
> > >  				access_flags |= IB_ACCESS_LOCAL_WRITE;
> > >  		} else {
> > > --
> >
> > Thanks,
> > Reviewed-by: Leon Romanovsky <leonro@mellanox.com>
>
> Thanks for the review.
>
> > Interesting, the followup question is why mlx4 is only one driver in IB which
> > needs such code in umem_mr. I'll take a look on it.
>
> I don't know. Just using the light heuristics of find_vma() shows some
> other places. For example, ib_umem_odp_get() gets the umem->address via
> ib_umem_start(). This was previously set in ib_umem_get() as called from
> mlx4_get_umem_mr(). Should the above patch have just untagged "start" on
> entry?

ODP flows are not applicable to any driver except mlx5.
According to commit message of d8f9cc328c88 ("IB/mlx4: Mark user
MR as writable if actual virtual memory is writable"), the code in its
current form needed to deal with different mappings between RDMA memory
requested and VMA memory underlined.

>
> BTW, what's the provenience of such "start" address here? Is it
> something that the user would have malloc()'ed? We try to impose some
> restrictions one what is allowed to be tagged in user so that we don't
> have to untag the addresses in the kernel. For example, if it was the
> result of an mmap() on the device file, we don't allow tagging.

The *_reg_user_mr() is called from userspace through ibv_reg_mr() call [1]
and this is how "address" and access flags are provided.

Right now, the address should point to memory accessible by
get_user_pages(), however mmap-ed memory uses remap_pfn_range()
to provide such pages which makes them unusable for get_user_pages().

I would be glad to see this is a current limitation of RDMA stack and
not as a final design decision.

[1] https://linux.die.net/man/3/ibv_reg_mr

>
> Thanks.
>
> --
> Catalin

