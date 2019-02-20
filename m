Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 03EF5C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 22:29:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AE4DB20836
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 22:29:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AE4DB20836
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 56ECB8E0040; Wed, 20 Feb 2019 17:29:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 51D708E0002; Wed, 20 Feb 2019 17:29:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3E6FF8E0040; Wed, 20 Feb 2019 17:29:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 11F948E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 17:29:30 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id q3so24804056qtq.15
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 14:29:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=k/Or7kyaTHDahUXrrf+0V8eHt+W9JWeSIhEpCOohXwk=;
        b=MN2VHOeuKPLIEChzSew/yia6bmRNWfGHmy6f07ks0O65T7G+jGCdtnNnEng9AC41ab
         2vzBm0v+x0y59OUR8iiOIGSb32E/zu7kPWZrbbJs7knCIZzCj6MIsjbq1KZaNLOcvzpi
         saU1TsYHvnAIyR4avSMHcA5MgjAzk8J0QgVzJYTIyDyhGfnlQIfn4hvkkaay59Fhql9g
         6S2GR+0L8lJUiVLkjpEtCZn6XMFy1hT/a9i8tbnIM6lqJm3/ICXjUxpug0y7+lk6jzt5
         0Xcbit7BYli4bCyTBd4PN3gAo7weOg8FGOoboCSUMKgl2OxLQB79SqObLPfJRsqGhfq3
         7ypg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAubxBGTgiU754GgiY8uH5t2SwhH+z+HDqfLgO6S/Im8ySXseFDji
	TPB3eVSDw7UQAnzV9LyFlPTjEm1/gbAt+jN0BRJmCX/VXZ+eO64cRglevyRNPuDY68vypIZWIWN
	DYaM8Qsk2s/szRQ4pCUyZONk3HqPxzyHq+tOF1Vu3NRodQ2L5dLYqqGdjuiF0NNsSxg==
X-Received: by 2002:a0c:9acb:: with SMTP id k11mr26901546qvf.197.1550701769811;
        Wed, 20 Feb 2019 14:29:29 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbxzbyYuRrn747HJ6Wx2tzs7fTawCOt4CcMtk/C4As5jIz7lLRtHZWBkt2c2e+Ln8EuEI7D
X-Received: by 2002:a0c:9acb:: with SMTP id k11mr26901528qvf.197.1550701769193;
        Wed, 20 Feb 2019 14:29:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550701769; cv=none;
        d=google.com; s=arc-20160816;
        b=puQzUcV7HRN9hchi+yX7gBGfE+p+hWf1cZSv+V5yKj7yE1KIS2zJ8yMGp5o+sRec+O
         tGBIzA3q7YclMFcGavWcGK6tDjoTyx2Br2sbWoYEOYKrau9hoF6bYsEEidLfbvTDuQbo
         vu8iyeE3pxKwOpSh8BBbc9a2tYpNe9oYWDnnVAipDmcaNb09IgxUUgIXDIlbakbchWRN
         GQrdxHzomiZ/BCqoGUyzXFw6Mh9xXHZPnrYw1joQMquZN+QhvUU6g8Z1uoZJIy8Dwerd
         ADnS+pow454EJXP/40k1Aae1BiTE++iSsex84bHxh/KLU9MRcC+EC2KZrzwU4YOAybk8
         cbRQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=k/Or7kyaTHDahUXrrf+0V8eHt+W9JWeSIhEpCOohXwk=;
        b=QTtA+LMAZudUkjXBVDyhraexiGkq+TM1LzeOBeIUbwlGqlDUDfxeHewd5ZBySS8UTm
         qLQnHqnFi6JzdYhb+i4Zf14xPAvx+a7eP8GlVGfaAWOMY4PDYIBszISeJynKSSUErVdY
         xg4+iNWCGC6Ib2uUcEz9yU0NDRRoQe46xy5u/1CnIann8cSNATwRbss4O5qBcc6Vt0Lj
         labNArJCePekmZmkpT992kTgTocq6h+W/dkkKMnXTfYX7v1hehkS+ofs3ux6LvpTZYZo
         1bPSDcaJweQniIS55hIkwTr6sYPaJOnf6ngHWr6Hi7rFy04HUpM8wZxK9sEFoxdkdC6R
         dxPg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b51si918255qtc.224.2019.02.20.14.29.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Feb 2019 14:29:29 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 1A1E6368E7;
	Wed, 20 Feb 2019 22:29:28 +0000 (UTC)
Received: from redhat.com (ovpn-121-220.rdu2.redhat.com [10.10.121.220])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 87C871001DC1;
	Wed, 20 Feb 2019 22:29:26 +0000 (UTC)
Date: Wed, 20 Feb 2019 17:29:24 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Haggai Eran <haggaie@mellanox.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	Leon Romanovsky <leonro@mellanox.com>,
	Doug Ledford <dledford@redhat.com>,
	Artemy Kovalyov <artemyko@mellanox.com>,
	Moni Shoua <monis@mellanox.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Kaike Wan <kaike.wan@intel.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Aviad Yehezkel <aviadye@mellanox.com>
Subject: Re: [PATCH 1/1] RDMA/odp: convert to use HMM for ODP
Message-ID: <20190220222924.GE29398@redhat.com>
References: <20190129165839.4127-1-jglisse@redhat.com>
 <20190129165839.4127-2-jglisse@redhat.com>
 <f48ed64f-22fe-c366-6a0e-1433e72b9359@mellanox.com>
 <20190212161123.GA4629@redhat.com>
 <20190220222020.GE8415@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190220222020.GE8415@mellanox.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Wed, 20 Feb 2019 22:29:28 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 20, 2019 at 10:20:27PM +0000, Jason Gunthorpe wrote:
> On Tue, Feb 12, 2019 at 11:11:24AM -0500, Jerome Glisse wrote:
> > This is what serialize programming the hw and any concurrent CPU page
> > table invalidation. This is also one of the thing i want to improve
> > long term as mlx5_ib_update_xlt() can do memory allocation and i would
> > like to avoid that ie make mlx5_ib_update_xlt() and its sub-functions
> > as small and to the points as possible so that they could only fail if
> > the hardware is in bad state not because of memory allocation issues.
> 
> How can the translation table memory consumption be dynamic (ie use
> tables sized huge pages until the OS breaks into 4k pages) if the
> tables are pre-allocated?

The idea is to have HMM handle DMA mapping so from the DMA
mapping page table (wether you have an IOMMU or not) you
can build the device page table (leveraging contiguous DMA
address into huge dma page for the hardware). This can happen
before calling mlx5_ib_update_xlt(). Then mlx5_ib_update_xlt()
would only need to program the hardware.

> > > 
> > > > +
> > > > +static uint64_t odp_hmm_flags[HMM_PFN_FLAG_MAX] = {
> > > > +	ODP_READ_BIT,	/* HMM_PFN_VALID */
> > > > +	ODP_WRITE_BIT,	/* HMM_PFN_WRITE */
> > > > +	ODP_DEVICE_BIT,	/* HMM_PFN_DEVICE_PRIVATE */
> > > It seems that the mlx5_ib code in this patch currently ignores the 
> > > ODP_DEVICE_BIT (e.g., in umem_dma_to_mtt). Is that okay? Or is it 
> > > handled implicitly by the HMM_PFN_SPECIAL case?
> > 
> > This is because HMM except a bit for device memory as same API is
> > use for GPU which have device memory. I can add a comment explaining
> > that it is not use for ODP but there just to comply with HMM API.
> > 
> > > 
> > > > @@ -327,9 +287,10 @@ void put_per_mm(struct ib_umem_odp *umem_odp)
> > > >  	up_write(&per_mm->umem_rwsem);
> > > >  
> > > >  	WARN_ON(!RB_EMPTY_ROOT(&per_mm->umem_tree.rb_root));
> > > > -	mmu_notifier_unregister_no_release(&per_mm->mn, per_mm->mm);
> > > > +	hmm_mirror_unregister(&per_mm->mirror);
> > > >  	put_pid(per_mm->tgid);
> > > > -	mmu_notifier_call_srcu(&per_mm->rcu, free_per_mm);
> > > > +
> > > > +	kfree(per_mm);
> > > >  }
> > > Previously the per_mm struct was released through call srcu, but now it 
> > > is released immediately. Is it safe? I saw that hmm_mirror_unregister 
> > > calls mmu_notifier_unregister_no_release, so I don't understand what 
> > > prevents concurrently running invalidations from accessing the released 
> > > per_mm struct.
> > 
> > Yes it is safe, the hmm struct has its own refcount and mirror holds a
> > reference on it, the mm struct itself has a reference on the mm
> > struct.
> 
> The issue here is that that hmm_mirror_unregister() must be a strong
> fence that guarentees no callback is running or will run after
> return. mmu_notifier_unregister did not provide that.
> 
> I think I saw locking in hmm that was doing this..

So pattern is:
    hmm_mirror_register(mirror);

    // Safe for driver to call within HMM with mirror no matter what

    hmm_mirror_unregister(mirror)

    // Driver must no stop calling within HMM, it would be a use after
    // free scenario

Cheers,
Jérôme

