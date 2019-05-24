Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9E4D7C072B5
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 18:32:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 337E020673
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 18:32:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="YWqynlFN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 337E020673
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BDC9F6B0269; Fri, 24 May 2019 14:32:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B65AD6B026F; Fri, 24 May 2019 14:32:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A058F6B0272; Fri, 24 May 2019 14:32:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f71.google.com (mail-ua1-f71.google.com [209.85.222.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7828A6B0269
	for <linux-mm@kvack.org>; Fri, 24 May 2019 14:32:28 -0400 (EDT)
Received: by mail-ua1-f71.google.com with SMTP id a6so2418617uah.3
        for <linux-mm@kvack.org>; Fri, 24 May 2019 11:32:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=NBNyc5CPAmbiINPqRu6KqRyhmB4w6u5PfIg88eslVLU=;
        b=c5871jw3kQ/XTN/fSAvwWnnV9DPsWBQyIohOt4LMUVD9e9tTagniB/OAsBZEM5IyPz
         Z7MAJtDVE157CjSZjSddYFNFsfFFFxlEbTDG56h3eijJG12ZT882TDV9rRwsh0/RKyy3
         gq/PYWJq47U0kT26vgp74a2BZ5UbTsr2s3NejfyS0yDMDr/vlHwbY+FvqNeTzAn103Xz
         axx11vICibqwk6vRotP/xCL13GqrpzfgV6idEtvxDba5CAzNLFz4f48GxbTrIiKa2wor
         y6yFgke5RcVgeVR8in3j+nt+JN0xSs5ceMh56/uJRvUVAmbD1wL/RS4wWWOtxreZpZSH
         PnOg==
X-Gm-Message-State: APjAAAXCGtltPHJe78ns58QQppgtNIYJthoIfaOWBXL/akdKNzBEjS25
	2X7MI6DawKymTTIpOSqUEzDgwR9k3h8tkkIXf/F+ADFwXS9g07VnxW/L9SUM4qopff2Q8wIFf/d
	C82ayaGdyCzV0lZvObhO39sXD8eF0hDwRRzqdTO77E0IiabjIV4C1lU/6Z9ZQIio/7Q==
X-Received: by 2002:ab0:5ad0:: with SMTP id x16mr5216024uae.124.1558722748125;
        Fri, 24 May 2019 11:32:28 -0700 (PDT)
X-Received: by 2002:ab0:5ad0:: with SMTP id x16mr5215930uae.124.1558722747199;
        Fri, 24 May 2019 11:32:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558722747; cv=none;
        d=google.com; s=arc-20160816;
        b=X6SYOp5tSp/8qyCT7Ds5rr3wQxOTFDE2z06GAnQVV/rcS8eNgGvNHQ3+BNGbMPTqtg
         0GbojXRXaLKDYxCN6Wv2vM3lu56rm6lldO2AwlYkNUh5JlRipXGTrg1hAGdq9Ss0XSIs
         EbSxogBS2fYTbY4r4g8tAH5j5xnwwDAvc/o6VAqoa+HbME+EXFcufUeTnOKTecXo//T/
         MF06I08Zg/UJR9eYRRKjdxnWnZRAymcsRlXUqYvyqQzOy6HA9KoI4VaEfVRAZlo3hGlc
         9/P5o86KIhy+70MRXPj0w2JRnpJhfaNGtlMBvYElEQvz4yoGISgdIA3yFuftF/En4fhY
         qlAw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=NBNyc5CPAmbiINPqRu6KqRyhmB4w6u5PfIg88eslVLU=;
        b=sQNNbMsog4ODHN/bAx1vfe8DbCbGYVAG1XPcWTSC461r/ZtZHmGFxq93Iy8HJaOD0x
         D0QHq/FzrojTfA6z84DjR10tttSuQ8ea+u2pKSqPEbCH8P9BILgjNTex04tkhaVsUA8t
         L1WELQCrGmF5HisgJoWC9NUq9eYXRSENz3AeJQ4wTxgUW0J229JnYRAE7HiNKCAcCDkR
         aRAIPYDCZ01ZSRyJcW9TSvVPBFkhSF09dhxkS1TU7tvOOge3vtfiayVbIiuUYqT3Z8OR
         vBXN6fclVvslPxQkL6wf+xONhsZrbED88Kh7OaHCCjVRhJ4X85e2jYwgMRqsfBRrH6l8
         2HSA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=YWqynlFN;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t14sor1372151vso.96.2019.05.24.11.32.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 24 May 2019 11:32:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=YWqynlFN;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=NBNyc5CPAmbiINPqRu6KqRyhmB4w6u5PfIg88eslVLU=;
        b=YWqynlFNBAug8jIE3xWfAsUD1mrEFp3uP2s0S6tSFMnUEtHGtcNr3gsx0andO6mBgy
         NW/5KXSlHz7Z4L1yax8bFrA8IGBTqNj43ApkimJyhaKaP/M1VmwshfglfzLWC8IyjhZN
         CAtnN2kKvokGYdJT3osURqKYzm1R2IL3v7GfXs7eRJZR+hPtOIcDzSI2+JdEcyEAP6AX
         GygnQNgyl08CKqZWpSLtDs0zEpPwRcQ8KYZ/XNdt8nyilkepgqI6XDeM6Ye2qOq2/8CF
         kFRdnWgjJ7MEfLX86cxYJAD1A4qCD2E9tx4H+ShKQON8sz0qoahPUTWslPSkwuDzVll8
         wHkw==
X-Google-Smtp-Source: APXvYqza6sK27lcJnthNOQYY1zw+bnSzJJDiypReLkD4CroSrCQz+RqGyNwe6stEQGandHXFmqNMEg==
X-Received: by 2002:a67:fc51:: with SMTP id p17mr18214640vsq.159.1558722746706;
        Fri, 24 May 2019 11:32:26 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-49-251.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.49.251])
        by smtp.gmail.com with ESMTPSA id e76sm2223442vke.54.2019.05.24.11.32.26
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 24 May 2019 11:32:26 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hUEzR-0001Jh-IP; Fri, 24 May 2019 15:32:25 -0300
Date: Fri, 24 May 2019 15:32:25 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>
Subject: Re: [RFC PATCH 00/11] mm/hmm: Various revisions from a locking/code
 review
Message-ID: <20190524183225.GI16845@ziepe.ca>
References: <20190523153436.19102-1-jgg@ziepe.ca>
 <20190524143649.GA14258@ziepe.ca>
 <20190524164902.GA3346@redhat.com>
 <20190524165931.GF16845@ziepe.ca>
 <20190524170148.GB3346@redhat.com>
 <20190524175203.GG16845@ziepe.ca>
 <20190524180321.GD3346@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190524180321.GD3346@redhat.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 24, 2019 at 02:03:22PM -0400, Jerome Glisse wrote:
> On Fri, May 24, 2019 at 02:52:03PM -0300, Jason Gunthorpe wrote:
> > On Fri, May 24, 2019 at 01:01:49PM -0400, Jerome Glisse wrote:
> > > On Fri, May 24, 2019 at 01:59:31PM -0300, Jason Gunthorpe wrote:
> > > > On Fri, May 24, 2019 at 12:49:02PM -0400, Jerome Glisse wrote:
> > > > > On Fri, May 24, 2019 at 11:36:49AM -0300, Jason Gunthorpe wrote:
> > > > > > On Thu, May 23, 2019 at 12:34:25PM -0300, Jason Gunthorpe wrote:
> > > > > > > From: Jason Gunthorpe <jgg@mellanox.com>
> > > > > > > 
> > > > > > > This patch series arised out of discussions with Jerome when looking at the
> > > > > > > ODP changes, particularly informed by use after free races we have already
> > > > > > > found and fixed in the ODP code (thanks to syzkaller) working with mmu
> > > > > > > notifiers, and the discussion with Ralph on how to resolve the lifetime model.
> > > > > > 
> > > > > > So the last big difference with ODP's flow is how 'range->valid'
> > > > > > works.
> > > > > > 
> > > > > > In ODP this was done using the rwsem umem->umem_rwsem which is
> > > > > > obtained for read in invalidate_start and released in invalidate_end.
> > > > > > 
> > > > > > Then any other threads that wish to only work on a umem which is not
> > > > > > undergoing invalidation will obtain the write side of the lock, and
> > > > > > within that lock's critical section the virtual address range is known
> > > > > > to not be invalidating.
> > > > > > 
> > > > > > I cannot understand how hmm gets to the same approach. It has
> > > > > > range->valid, but it is not locked by anything that I can see, so when
> > > > > > we test it in places like hmm_range_fault it seems useless..
> > > > > > 
> > > > > > Jerome, how does this work?
> > > > > > 
> > > > > > I have a feeling we should copy the approach from ODP and use an
> > > > > > actual lock here.
> > > > > 
> > > > > range->valid is use as bail early if invalidation is happening in
> > > > > hmm_range_fault() to avoid doing useless work. The synchronization
> > > > > is explained in the documentation:
> > > > 
> > > > That just says the hmm APIs handle locking. I asked how the apis
> > > > implement that locking internally.
> > > > 
> > > > Are you trying to say that if I do this, hmm will still work completely
> > > > correctly?
> > > 
> > > Yes it will keep working correctly. You would just be doing potentialy
> > > useless work.
> > 
> > I don't see how it works correctly.
> > 
> > Apply the comment out patch I showed and this trivially happens:
> > 
> >       CPU0                                               CPU1
> >   hmm_invalidate_start()
> >     ops->sync_cpu_device_pagetables()
> >       device_lock()
> >        // Wipe out page tables in device, enable faulting
> >       device_unlock()
> > 
> >                                                        DEVICE PAGE FAULT
> >                                                        device_lock()
> >                                                        hmm_range_register()
> >                                                        hmm_range_dma_map()
> >                                                        device_unlock()
> >   hmm_invalidate_end()
> 
> No in the above scenario hmm_range_register() will not mark the range
> as valid thus the driver will bailout after taking its lock and checking
> the range->valid value.

I see your confusion, I only asked about removing valid from hmm.c,
not the unlocked use of valid in your hmm.rst example. My mistake,
sorry for being unclear.

Here is the big 3 CPU ladder diagram that shows how 'valid' does not
work:

       CPU0                                               CPU1                                          CPU2
                                                        DEVICE PAGE FAULT
                                                        range = hmm_range_register()

   // Overlaps with range
   hmm_invalidate_start()
     range->valid = false
     ops->sync_cpu_device_pagetables()
       take_lock(driver->update);
        // Wipe out page tables in device, enable faulting
       release_lock(driver->update);
												    // Does not overlap with range
												    hmm_invalidate_start()
												    hmm_invalidate_end()
													list_for_each
													    range->valid =  true


                                                        device_lock()
							// Note range->valid = true now
							hmm_range_snapshot(&range);
							take_lock(driver->update);
							if (!hmm_range_valid(&range))
							    goto again
							ESTABLISHE SPTES
                                                        device_unlock()
   hmm_invalidate_end()

And I can make this more complicated (ie overlapping parallel
invalidates, etc) and show any 'bool' valid cannot work.

> > The mmu notifier spec says:
> > 
> >  	 * Invalidation of multiple concurrent ranges may be
> > 	 * optionally permitted by the driver. Either way the
> > 	 * establishment of sptes is forbidden in the range passed to
> > 	 * invalidate_range_begin/end for the whole duration of the
> > 	 * invalidate_range_begin/end critical section.
> > 
> > And I understand "establishment of sptes is forbidden" means
> > "hmm_range_dmap_map() must fail with EAGAIN". 
> 
> No it means that secondary page table entry (SPTE) must not
> materialize thus what hmm_range_dmap_map() is doing if fine and safe
> as long as the driver do not use the result to populate the device
> page table if there was an invalidation for the range.

Okay, so we agree, if there is an invalidate_start/end critical region
then it is OK to *call* hmm_range_dmap_map(), however the driver must
not *use* the result, and you are expecting this bit:

      take_lock(driver->update);
      if (!hmm_range_valid(&range)) {
         goto again

In your hmm.rst to prevent the pfns from being used by the driver?

I think the above ladder shows that hmm_range_valid can return true
during a invalidate_start/end critical region, so this is a problem.

I still think the best solution is to move device_lock() into mirror
and have hmm manage it for the driver as ODP does. It is certainly the
simplest solution to understand.

Jason

