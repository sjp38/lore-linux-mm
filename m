Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C9670C76196
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 19:35:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5E8B82081C
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 19:35:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="h1iujKtQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5E8B82081C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9E3096B0003; Mon, 15 Jul 2019 15:35:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 994926B0005; Mon, 15 Jul 2019 15:35:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 85C9B6B0006; Mon, 15 Jul 2019 15:35:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4D1E76B0003
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 15:35:53 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id a20so10806012pfn.19
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 12:35:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=nFlPxPIFvXTrQSpfVbK2B1XhQ7DW+jLR9XZaKs7UxGI=;
        b=XUtRjGr0ApgFpIOIM38OH2FIwhFeoxBEbiNzL7OaEYqtZvBYdm1y47z4dlRb67ReRh
         Gk8fOcKYaYU/c/eUtNrfPvdJKHaxyDiY071oVSwp5UBqnjtyA0wHyamr6qF6Ewpz+nt7
         t1kDck7a5crdzWMs81Gapbo6O3PyzABYsKUd1q/NamHQHf43vzFzQf53KUfbXfm3oEm5
         +lGY+Ga2e7u2016/F5NlPXSdV4Iy+lyGK7Inu90oU0Hc8TTr8ncvl6IRDo5AZAahHDfA
         8SgyEg/6mlWrtRc56eXcAIBM1o8oN3FCmUlSU9pPWnUDh6e0+x5L6e/kr7JwOamx4+tZ
         Irkg==
X-Gm-Message-State: APjAAAXVSTi0/dLUDkRmoA7AFq4Jg6mJ2hOLV45NwBiwpZJSis3PwnWf
	5rJgCRpd2xUpwDhHNCtGKzHUUR2M2uswEX67AXRiqCRszPsSyAGl7bRTTJkZYc2Eber/F4fp1VQ
	DwAiPwmg/pHLIlLL2yujpTzCSerVCkgxt68lbMX2Rg/ifPD86v897Z3flcq8DMsYCpg==
X-Received: by 2002:a63:3046:: with SMTP id w67mr29343655pgw.37.1563219352832;
        Mon, 15 Jul 2019 12:35:52 -0700 (PDT)
X-Received: by 2002:a63:3046:: with SMTP id w67mr29343558pgw.37.1563219351410;
        Mon, 15 Jul 2019 12:35:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563219351; cv=none;
        d=google.com; s=arc-20160816;
        b=BhaF4iIpKgagvehlMUXm2n8L0oApgyIgUXHZQml0YrYkXvRwyzAgR05yVcFfMAXIRB
         V1yJnx7sBPZxf4XnUby3wslYrOefbvcbdy3KEtZQQhAMNJ6uGgDrj/ZDApTcV07KJRBC
         7V/oyQjXCXYVyUsLGSlErw3b5WVsuOekx1as7hsQOjJ35TQ+eCvMzBM0eV39LNsf8Rao
         /EmCF5kC3KftzlLBTHpP8ouLkkxfmBValaqP9OHCybDpFJegR2zfgofKM1E/oQsAw6NN
         Y2jTuMDdnE5k1PI8on1Yushcufhj3QS8tXTnmWMHr1WXLzPtlAqMJz3q3IlG53O2Cs60
         nnUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=nFlPxPIFvXTrQSpfVbK2B1XhQ7DW+jLR9XZaKs7UxGI=;
        b=sVONIENXM99U+g83ymzmj06NTbSe7XlxNW5n5fBATuAPG5ZtyHGOeOadCTUthuL1xY
         68TgMm/2vgAXeNV+eEMXflCnXBfWXKs1wT9NlZmrzrC/HUtXw7eG9yL1DfY1/bYOnebU
         m//c1Dq7UnBGnztHyAgBn53QcgSxswBcwyC6CYlrTx0551XWj1nrCapT3VyN98wrY2XC
         EtXcMu6R5ZfL++fdrW4q+kTLhJpCwdrZi1QtV/v3tVH6J5R6DuySC8I2U2vOtR7NrzDz
         JyFQ7wq4TWpSUEXspEY+QuSkPGWfMFuJaSVcdrygCnExpUIzNfns5xXqOJ4OLZeQlSey
         8ZwQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=h1iujKtQ;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m65sor9576486pfm.66.2019.07.15.12.35.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 15 Jul 2019 12:35:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=h1iujKtQ;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=nFlPxPIFvXTrQSpfVbK2B1XhQ7DW+jLR9XZaKs7UxGI=;
        b=h1iujKtQBfQXcPN4TwZP8V+ePelk6Jiz4g+GfczipwOzkd2OtWvAMRe9X3WTEYKAwo
         TteNEgFvNomS7IEB23h+5V4szS89jH/poxh+klPCZN1TwpsP3VW/+CS35Xs0XnqJ9Dmu
         /l4FGYKEY7pTETdKGKxOVmSYdePrEDdsT+dmk76cd+JdC4yJhLrEHpTpEhI87WBO4iaT
         /lp2RQjPf4J1uTGQf/lHdckkWK8oAg3tGBEbq1nCRsYda7K67aIxuzZXKhrqsTbGxh2+
         +vUoBdF+kklLd9LUv5ouSjHt8+F5eiY8AgVUAcOVTBZDaolSy7WXN5cruO+XvCXN/HmW
         dY6g==
X-Google-Smtp-Source: APXvYqwhv93s+LMwilO7CxIkwicK65fEWl+ISQNebbXRFFl9Dxpa3uuzcKPo5cx90Yb4NU77Y4QkIw==
X-Received: by 2002:a63:7d49:: with SMTP id m9mr17310021pgn.161.1563219350830;
        Mon, 15 Jul 2019 12:35:50 -0700 (PDT)
Received: from bharath12345-Inspiron-5559 ([103.110.42.33])
        by smtp.gmail.com with ESMTPSA id i3sm19703891pfo.138.2019.07.15.12.35.34
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jul 2019 12:35:50 -0700 (PDT)
Date: Tue, 16 Jul 2019 01:05:31 +0530
From: Bharath Vedartham <linux.bhar@gmail.com>
To: Ira Weiny <ira.weiny@intel.com>
Cc: John Hubbard <jhubbard@nvidia.com>, akpm@linux-foundation.org,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Dimitri Sivanich <sivanich@sgi.com>, Arnd Bergmann <arnd@arndb.de>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	Cornelia Huck <cohuck@redhat.com>, Jens Axboe <axboe@kernel.dk>,
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
	xdp-newbies@vger.kernel.org, Jason Gunthorpe <jgg@ziepe.ca>
Subject: Re: [PATCH] mm/gup: Use put_user_page*() instead of put_page*()
Message-ID: <20190715193531.GB21161@bharath12345-Inspiron-5559>
References: <1563131456-11488-1-git-send-email-linux.bhar@gmail.com>
 <deea584f-2da2-8e1f-5a07-e97bf32c63bb@nvidia.com>
 <20190715065654.GA3716@bharath12345-Inspiron-5559>
 <20190715162952.GA7953@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190715162952.GA7953@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 15, 2019 at 09:29:53AM -0700, Ira Weiny wrote:
> On Mon, Jul 15, 2019 at 12:26:54PM +0530, Bharath Vedartham wrote:
> > On Sun, Jul 14, 2019 at 04:33:42PM -0700, John Hubbard wrote:
> > > On 7/14/19 12:08 PM, Bharath Vedartham wrote:
> > > > This patch converts all call sites of get_user_pages
> > > > to use put_user_page*() instead of put_page*() functions to
> > > > release reference to gup pinned pages.
> > Hi John, 
> > > Hi Bharath,
> > > 
> > > Thanks for jumping in to help, and welcome to the party!
> > > 
> > > You've caught everyone in the middle of a merge window, btw.  As a
> > > result, I'm busy rebasing and reworking the get_user_pages call sites, 
> > > and gup tracking, in the wake of some semi-traumatic changes to bio 
> > > and gup and such. I plan to re-post right after 5.3-rc1 shows up, from 
> > > here:
> > > 
> > >     https://github.com/johnhubbard/linux/commits/gup_dma_core
> > > 
> > > ...which you'll find already covers the changes you've posted, except for:
> > > 
> > >     drivers/misc/sgi-gru/grufault.c
> > >     drivers/staging/kpc2000/kpc_dma/fileops.c
> > > 
> > > ...and this one, which is undergoing to larger local changes, due to
> > > bvec, so let's leave it out of the choices:
> > > 
> > >     fs/io_uring.c
> > > 
> > > Therefore, until -rc1, if you'd like to help, I'd recommend one or more
> > > of the following ideas:
> > > 
> > > 1. Pull down https://github.com/johnhubbard/linux/commits/gup_dma_core
> > > and find missing conversions: look for any additional missing 
> > > get_user_pages/put_page conversions. You've already found a couple missing 
> > > ones. I haven't re-run a search in a long time, so there's probably even more.
> > > 	a) And find more, after I rebase to 5.3-rc1: people probably are adding
> > > 	get_user_pages() calls as we speak. :)
> > Shouldn't this be documented then? I don't see any docs for using
> > put_user_page*() in v5.2.1 in the memory management API section?
> > > 2. Patches: Focus on just one subsystem at a time, and perfect the patch for
> > > it. For example, I think this the staging driver would be perfect to start with:
> > > 
> > >     drivers/staging/kpc2000/kpc_dma/fileops.c
> > > 
> > > 	a) verify that you've really, corrected converted the whole
> > > 	driver. (Hint: I think you might be overlooking a put_page call.)
> > Yup. I did see that! Will fix it!
> > > 	b) Attempt to test it if you can (I'm being hypocritical in
> > > 	the extreme here, but one of my problems is that testing
> > > 	has been light, so any help is very valuable). qemu...?
> > > 	OTOH, maybe even qemu cannot easily test a kpc2000, but
> > > 	perhaps `git blame` and talking to the authors would help
> > > 	figure out a way to validate the changes.
> > Great! I ll do that, I ll mail the patch authors and ask them for help
> > in testing. 
> > > 	Thinking about whether you can run a test that would prove or
> > > 	disprove my claim in (a), above, could be useful in coming up
> > > 	with tests to run.
> > 
> > > In other words, a few very high quality conversions (even just one) that
> > > we can really put our faith in, is what I value most here. Tested patches
> > > are awesome.
> > I understand that! 
> > > 3. Once I re-post, turn on the new CONFIG_DEBUG_GET_USER_PAGES_REFERENCES
> > > and run things such as xfstest/fstest. (Again, doing so would be going
> > > further than I have yet--very helpful). Help clarify what conversions have
> > > actually been tested and work, and which ones remain unvalidated.
> > > Other: Please note that this:
> > Yup will do that.
> > >     https://github.com/johnhubbard/linux/commits/gup_dma_core
> > > 
> > >     a) gets rebased often, and
> > > 
> > >     b) has a bunch of commits (iov_iter and related) that conflict
> > >        with the latest linux.git,
> > > 
> > >     c) has some bugs in the bio area, that I'm fixing, so I don't trust
> > >        that's it's safely runnable, for a few more days.
> > I assume your repo contains only work related to fixing gup issues and
> > not the main repo for gup development? i.e where gup changes are merged?
> 
> We have been using Andrews tree for merging.
> 
> > Also are release_pages and put_user_pages interchangable? 
> 
> Conceptually yes.  But release_pages is more efficient.  There was some
> discussion around this starting here:
> 
> https://lore.kernel.org/lkml/20190523172852.GA27175@iweiny-DESK2.sc.intel.com/
> 
> And a resulting bug fix.
> 
> https://lkml.org/lkml/2019/6/21/95
> 
> Ira
Thanks! Will have a look at these links! 
> > > One note below, for the future:
> > > 
> > > > 
> > > > This is a bunch of trivial conversions which is a part of an effort
> > > > by John Hubbard to solve issues with gup pinned pages and 
> > > > filesystem writeback.
> > > > 
> > > > The issue is more clearly described in John Hubbard's patch[1] where
> > > > put_user_page*() functions are introduced.
> > > > 
> > > > Currently put_user_page*() simply does put_page but future implementations
> > > > look to change that once treewide change of put_page callsites to 
> > > > put_user_page*() is finished.
> > > > 
> > > > The lwn article describing the issue with gup pinned pages and filesystem 
> > > > writeback [2].
> > > > 
> > > > This patch has been tested by building and booting the kernel as I don't
> > > > have the required hardware to test the device drivers.
> > > > 
> > > > I did not modify gpu/drm drivers which use release_pages instead of
> > > > put_page() to release reference of gup pinned pages as I am not clear
> > > > whether release_pages and put_page are interchangable. 
> > > > 
> > > > [1] https://lkml.org/lkml/2019/3/26/1396
> > > 
> > > When referring to patches in a commit description, please use the 
> > > commit hash, not an external link. See Submitting Patches [1] for details.
> > > 
> > > Also, once you figure out the right maintainers and other involved people,
> > > putting Cc: in the commit description is common practice, too.
> > > 
> > > [1] https://www.kernel.org/doc/html/latest/process/submitting-patches.html
> > Will work on that! Thanks!
> > > thanks,
> > > -- 
> > > John Hubbard
> > > NVIDIA
> > > 
> > > > 
> > > > [2] https://lwn.net/Articles/784574/
> > > > 
> > > > Signed-off-by: Bharath Vedartham <linux.bhar@gmail.com>
> > > > ---
> > > >  drivers/media/v4l2-core/videobuf-dma-sg.c | 3 +--
> > > >  drivers/misc/sgi-gru/grufault.c           | 2 +-
> > > >  drivers/staging/kpc2000/kpc_dma/fileops.c | 4 +---
> > > >  drivers/vfio/vfio_iommu_type1.c           | 2 +-
> > > >  fs/io_uring.c                             | 7 +++----
> > > >  mm/gup_benchmark.c                        | 6 +-----
> > > >  net/xdp/xdp_umem.c                        | 7 +------
> > > >  7 files changed, 9 insertions(+), 22 deletions(-)
> > > > 
> > > > diff --git a/drivers/media/v4l2-core/videobuf-dma-sg.c b/drivers/media/v4l2-core/videobuf-dma-sg.c
> > > > index 66a6c6c..d6eeb43 100644
> > > > --- a/drivers/media/v4l2-core/videobuf-dma-sg.c
> > > > +++ b/drivers/media/v4l2-core/videobuf-dma-sg.c
> > > > @@ -349,8 +349,7 @@ int videobuf_dma_free(struct videobuf_dmabuf *dma)
> > > >  	BUG_ON(dma->sglen);
> > > >  
> > > >  	if (dma->pages) {
> > > > -		for (i = 0; i < dma->nr_pages; i++)
> > > > -			put_page(dma->pages[i]);
> > > > +		put_user_pages(dma->pages, dma->nr_pages);
> > > >  		kfree(dma->pages);
> > > >  		dma->pages = NULL;
> > > >  	}
> > > > diff --git a/drivers/misc/sgi-gru/grufault.c b/drivers/misc/sgi-gru/grufault.c
> > > > index 4b713a8..61b3447 100644
> > > > --- a/drivers/misc/sgi-gru/grufault.c
> > > > +++ b/drivers/misc/sgi-gru/grufault.c
> > > > @@ -188,7 +188,7 @@ static int non_atomic_pte_lookup(struct vm_area_struct *vma,
> > > >  	if (get_user_pages(vaddr, 1, write ? FOLL_WRITE : 0, &page, NULL) <= 0)
> > > >  		return -EFAULT;
> > > >  	*paddr = page_to_phys(page);
> > > > -	put_page(page);
> > > > +	put_user_page(page);
> > > >  	return 0;
> > > >  }
> > > >  
> > > > diff --git a/drivers/staging/kpc2000/kpc_dma/fileops.c b/drivers/staging/kpc2000/kpc_dma/fileops.c
> > > > index 6166587..26dceed 100644
> > > > --- a/drivers/staging/kpc2000/kpc_dma/fileops.c
> > > > +++ b/drivers/staging/kpc2000/kpc_dma/fileops.c
> > > > @@ -198,9 +198,7 @@ int  kpc_dma_transfer(struct dev_private_data *priv, struct kiocb *kcb, unsigned
> > > >  	sg_free_table(&acd->sgt);
> > > >   err_dma_map_sg:
> > > >   err_alloc_sg_table:
> > > > -	for (i = 0 ; i < acd->page_count ; i++){
> > > > -		put_page(acd->user_pages[i]);
> > > > -	}
> > > > +	put_user_pages(acd->user_pages, acd->page_count);
> > > >   err_get_user_pages:
> > > >  	kfree(acd->user_pages);
> > > >   err_alloc_userpages:
> > > > diff --git a/drivers/vfio/vfio_iommu_type1.c b/drivers/vfio/vfio_iommu_type1.c
> > > > index add34ad..c491524 100644
> > > > --- a/drivers/vfio/vfio_iommu_type1.c
> > > > +++ b/drivers/vfio/vfio_iommu_type1.c
> > > > @@ -369,7 +369,7 @@ static int vaddr_get_pfn(struct mm_struct *mm, unsigned long vaddr,
> > > >  		 */
> > > >  		if (ret > 0 && vma_is_fsdax(vmas[0])) {
> > > >  			ret = -EOPNOTSUPP;
> > > > -			put_page(page[0]);
> > > > +			put_user_page(page[0]);
> > > >  		}
> > > >  	}
> > > >  	up_read(&mm->mmap_sem);
> > > > diff --git a/fs/io_uring.c b/fs/io_uring.c
> > > > index 4ef62a4..b4a4549 100644
> > > > --- a/fs/io_uring.c
> > > > +++ b/fs/io_uring.c
> > > > @@ -2694,10 +2694,9 @@ static int io_sqe_buffer_register(struct io_ring_ctx *ctx, void __user *arg,
> > > >  			 * if we did partial map, or found file backed vmas,
> > > >  			 * release any pages we did get
> > > >  			 */
> > > > -			if (pret > 0) {
> > > > -				for (j = 0; j < pret; j++)
> > > > -					put_page(pages[j]);
> > > > -			}
> > > > +			if (pret > 0)
> > > > +				put_user_pages(pages, pret);
> > > > +
> > > >  			if (ctx->account_mem)
> > > >  				io_unaccount_mem(ctx->user, nr_pages);
> > > >  			kvfree(imu->bvec);
> > > > diff --git a/mm/gup_benchmark.c b/mm/gup_benchmark.c
> > > > index 7dd602d..15fc7a2 100644
> > > > --- a/mm/gup_benchmark.c
> > > > +++ b/mm/gup_benchmark.c
> > > > @@ -76,11 +76,7 @@ static int __gup_benchmark_ioctl(unsigned int cmd,
> > > >  	gup->size = addr - gup->addr;
> > > >  
> > > >  	start_time = ktime_get();
> > > > -	for (i = 0; i < nr_pages; i++) {
> > > > -		if (!pages[i])
> > > > -			break;
> > > > -		put_page(pages[i]);
> > > > -	}
> > > > +	put_user_pages(pages, nr_pages);
> > > >  	end_time = ktime_get();
> > > >  	gup->put_delta_usec = ktime_us_delta(end_time, start_time);
> > > >  
> > > > diff --git a/net/xdp/xdp_umem.c b/net/xdp/xdp_umem.c
> > > > index 9c6de4f..6103e19 100644
> > > > --- a/net/xdp/xdp_umem.c
> > > > +++ b/net/xdp/xdp_umem.c
> > > > @@ -173,12 +173,7 @@ static void xdp_umem_unpin_pages(struct xdp_umem *umem)
> > > >  {
> > > >  	unsigned int i;
> > > >  
> > > > -	for (i = 0; i < umem->npgs; i++) {
> > > > -		struct page *page = umem->pgs[i];
> > > > -
> > > > -		set_page_dirty_lock(page);
> > > > -		put_page(page);
> > > > -	}
> > > > +	put_user_pages_dirty_lock(umem->pgs, umem->npgs);
> > > >  
> > > >  	kfree(umem->pgs);
> > > >  	umem->pgs = NULL;
> > > > 

