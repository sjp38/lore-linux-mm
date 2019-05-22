Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9CE7AC46460
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 22:06:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3451D21883
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 22:06:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3451D21883
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 071976B0007; Wed, 22 May 2019 18:06:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 022926B0008; Wed, 22 May 2019 18:06:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E7B5B6B000A; Wed, 22 May 2019 18:06:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id C83566B0007
	for <linux-mm@kvack.org>; Wed, 22 May 2019 18:06:53 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id l185so3625897qkd.14
        for <linux-mm@kvack.org>; Wed, 22 May 2019 15:06:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=furJZsBkysu5Czb2j86yg0KMByNjjEio2eWS5nRd5EM=;
        b=URcFU4U679gmmizAyOpN40bO80Uk3yT025aJvJCpvSVVdk2uWJSTM473W636MZPsPu
         cqXJI2hiZFfMdnYi6Ux/YiBzC1iuxQwv+qHuSzmRIFLHs+c0LmDdHEkvRmUzdx18oc2q
         j7UC+r3p8uM9bsoLWXU7GfFR7MBCt9crdOUb+4ntIhtxltuIWactoIJJ4v+TifrC8rVI
         lRo+Rx0f2zDBaL9LnefN70/7g86TDNkpuWMWtX+nby0unp0N5KYZEk7ujyCUQy34pgfg
         V767oiRZG7dyE9fMluganNOCK/HDRGCES6y8dd8+rYSRlPnccXc2osqu8ecdMxzkJEYC
         cyLA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXE8ed8sNaGES1uEZJmtm6ykdBJ5xVFrxQlURHIzofkJVGddDs7
	dFGupTPvmoFVOmZvqxRfFKDzOmBgPApl/RZeMalO5BVCsdaWkYRuvFIV4w+33Fd7hzckdFnze+Y
	EypWfMMOvrKSKZfG8taykXlRRpd3aiXzatHQtyVOs3iLqoyUPJy5QBlIg8iOiOWQlNw==
X-Received: by 2002:ac8:384f:: with SMTP id r15mr75848992qtb.290.1558562813615;
        Wed, 22 May 2019 15:06:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz7sTM9CfwHpVI+SDYXAyczzMSgmnmU0h9FmKxHlbj1gDRbFJMEVOvV0Nk+xH9K2vH3UGAM
X-Received: by 2002:ac8:384f:: with SMTP id r15mr75848959qtb.290.1558562813172;
        Wed, 22 May 2019 15:06:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558562813; cv=none;
        d=google.com; s=arc-20160816;
        b=Xns1zCm3971XdF5DUA9PaYpi4sDojw3PEg7ahOklBDh3SCRwMG7TLfsRYuHev0Jab6
         8IEZi35YCpvPrh46GsNltYyiU+ZH4LH+j7O35PslTes4ADRuHd7RW06WBW0exD3QE2Pv
         35MXWCDce/bKV6DOGwCOESU/ScvYH2cGdktA2OdRjU0Bkpx7oeRszu0B0sBWgAETM6Dz
         kskdr9xssFv5TFBu6FejHcqH5g/ph8gA+EfTUoE05fDFbQYzUvxxesz9S3zWfQeJc8z/
         zm14OdAWCNUTYGoE1GhDJbNe/yBogFLo1TwEVGJcv1ta0AUPOkbEuBYeuNlKrn5EnJO0
         eSQQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=furJZsBkysu5Czb2j86yg0KMByNjjEio2eWS5nRd5EM=;
        b=vpWV283nVaLfSPJ/lWWt/I4Jid3f+YkwIAU3eLCxFDj0LICDLCt0Q7XZAk091g/B/X
         ImFSh8EHv9N4QY0pCmKra0fDK8iMOBF6sCIL0vDl/oEcmZZ1sXCozOycbDw/uNcbOOLV
         2WrmWqgjd30DX/8iPia9zjtMuuQoqTsIRR4YnmTAjrvFwDfzg/FYmmVoZn0PDzS7q+4N
         edL585CoMil3IiCKe9xYatQxPum3NGpgRczX4exLtIRyaUgosxEf6o+0tGAk6MFl3Mfq
         r6od5++/zcf8ukrfdaGb5D/8rE5fOTHRhPn3qI/FaQiAqmhBl72gBjA8fDH7pqKOB/6P
         PISg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t2si255782qkd.225.2019.05.22.15.06.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 May 2019 15:06:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 430608553D;
	Wed, 22 May 2019 22:06:52 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.178])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 3DC6218205;
	Wed, 22 May 2019 22:06:51 +0000 (UTC)
Date: Wed, 22 May 2019 18:06:49 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Ralph Campbell <rcampbell@nvidia.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, linux-rdma@vger.kernel.org,
	Leon Romanovsky <leonro@mellanox.com>,
	Doug Ledford <dledford@redhat.com>,
	Artemy Kovalyov <artemyko@mellanox.com>,
	Moni Shoua <monis@mellanox.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Kaike Wan <kaike.wan@intel.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>
Subject: Re: [PATCH v4 0/1] Use HMM for ODP v4
Message-ID: <20190522220649.GC20179@redhat.com>
References: <20190411181314.19465-1-jglisse@redhat.com>
 <20190506195657.GA30261@ziepe.ca>
 <20190521205321.GC3331@redhat.com>
 <20190522005225.GA30819@ziepe.ca>
 <20190522174852.GA23038@redhat.com>
 <20190522201247.GH6054@ziepe.ca>
 <05e7f491-b8a4-4214-ab75-9ecf1128aaa6@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <05e7f491-b8a4-4214-ab75-9ecf1128aaa6@nvidia.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Wed, 22 May 2019 22:06:52 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 22, 2019 at 02:12:31PM -0700, Ralph Campbell wrote:
> 
> On 5/22/19 1:12 PM, Jason Gunthorpe wrote:
> > On Wed, May 22, 2019 at 01:48:52PM -0400, Jerome Glisse wrote:
> > 
> > >   static void put_per_mm(struct ib_umem_odp *umem_odp)
> > >   {
> > >   	struct ib_ucontext_per_mm *per_mm = umem_odp->per_mm;
> > > @@ -325,9 +283,10 @@ static void put_per_mm(struct ib_umem_odp *umem_odp)
> > >   	up_write(&per_mm->umem_rwsem);
> > >   	WARN_ON(!RB_EMPTY_ROOT(&per_mm->umem_tree.rb_root));
> > > -	mmu_notifier_unregister_no_release(&per_mm->mn, per_mm->mm);
> > > +	hmm_mirror_unregister(&per_mm->mirror);
> > >   	put_pid(per_mm->tgid);
> > > -	mmu_notifier_call_srcu(&per_mm->rcu, free_per_mm);
> > > +
> > > +	kfree(per_mm);
> > 
> > Notice that mmu_notifier only uses SRCU to fence in-progress ops
> > callbacks, so I think hmm internally has the bug that this ODP
> > approach prevents.
> > 
> > hmm should follow the same pattern ODP has and 'kfree_srcu' the hmm
> > struct, use container_of in the mmu_notifier callbacks, and use the
> > otherwise vestigal kref_get_unless_zero() to bail:
> 
> You might also want to look at my patch where
> I try to fix some of these same issues (5/5).
> 
> https://marc.info/?l=linux-mm&m=155718572908765&w=2

I need to review the patchset but i do not want to invert referencing
ie having mm hold reference on hmm. Will review tommorrow. I wanted to
do that today but did not had time.

