Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 626DAC2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 12:36:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EDF17208E3
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 12:36:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="GHaZaDHn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EDF17208E3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 31FF76B000C; Fri,  7 Jun 2019 08:36:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2CF806B000E; Fri,  7 Jun 2019 08:36:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 197576B0266; Fri,  7 Jun 2019 08:36:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id E8BE76B000C
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 08:36:49 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id k13so1456181qkj.4
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 05:36:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=U9t6ZQ44UYTUT/2bmYoJaPHlaVA4zF3kDc6HTj92QLY=;
        b=ouSJpK/mFYKPyhYsBEBXx56KL+e2K1FpG+oTYPko+6xhqWIEfLqQuOJWoj4oN8ndzp
         pWwR9fiVg/Z58Not/sTOAnazt5U+bfi+fqVn6ItqplJVmQbwwsO8B9DgqEXOj2fUJcfs
         ok/GUkeWEoXCOFWHY5+xKxxeElMP1kSRFSRdjc9OVCwkYaMmZfTvOcGuEA3jLm9Ylyl6
         xk7jcmJP1plYVi5zLw5S3fKLH9zfp9rJcteC0WUxU85TnLDGn/5FzKru6lDQNGSeOh48
         sd4IZG70Ris0becu9A0WcMjamoc8jR/To9DHSht5YA7iQoNcr4ROUAiba70CWb0zvJNH
         VoWQ==
X-Gm-Message-State: APjAAAUeFuo7QjMl9sxDTwfsKyoH+NUNgi3jjbU75g+7fOu8InVvwBSB
	uSyFlyZKNh6a1xJ7cU/Lj07GyjrbwfO780PqeQIhbaFDSS3e65mqnRqG9Sh+syjQ+XOmOHE0+YI
	DtaMelljWSvbeRwpH+L/tvPca04W/6ygqimrI+WP4wZz9yxFTtvQcRscgMJa0UF/dOw==
X-Received: by 2002:ac8:183:: with SMTP id x3mr43665718qtf.104.1559911009634;
        Fri, 07 Jun 2019 05:36:49 -0700 (PDT)
X-Received: by 2002:ac8:183:: with SMTP id x3mr43665682qtf.104.1559911009095;
        Fri, 07 Jun 2019 05:36:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559911009; cv=none;
        d=google.com; s=arc-20160816;
        b=Ysp4YZ8asccdu7VsPKDo1VB4Pq4vAWPXp7iNm/pyYamc8x0xWtpZbLMYIthc3SN9Qw
         EhPCai+TL2CgFBkuKJsZDg5x3EVuMzE/5GU8s4A6dnDch3wix+Ggl1gUvE8F7bolHqeJ
         nlPB8GGedmsbtz6nfwHNvYezHqlvKQ0TQgdXWlpbopYAgVj26PvMQVPoGuG3AWqNLJah
         iNdnch42BQjv07JHMNON7+SCk+vb3JUGiU6nAzHor6rhms14wzwKmy7FhpfW4+aF1JUm
         886NRmvvPsZLirwbFs16kdmijqWcQuiZvsEgc6IuvXApUCjiNpkMeF7PI6/c3ML7RQp5
         ZQoQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=U9t6ZQ44UYTUT/2bmYoJaPHlaVA4zF3kDc6HTj92QLY=;
        b=QN0YyHjZIS+34VpQZYlvnmIOQqHgvXtvtoPN76Xv4rl9HO7H2icoKBlZS698FxnVTu
         dtdbhrOxuCJrpGBnqdk0cZOiV0IOddn3rP2y5PkvcgHstP9oLhwYKaSB8njmFoLLMeyO
         pEOAVwtusqnG8UjMgFrVLaNSwPwrjYlGA0SVlUdBcM9ySrF9ejteeFXbWW55v1yPwGpX
         L3k1qPT/bhbAnvQFguc8z0CzPwEJKSfDNlJMUt78wizC9ZLxJ49sZX31qD+svHE3kXqH
         ydjgqY0Jv4erQi0dO9gWR3k3hwSoo8LcdN0N/a/FDG2OflCoQfNhndQB3qCG9hwtzejX
         5t1g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=GHaZaDHn;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t67sor1021446qkh.83.2019.06.07.05.36.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Jun 2019 05:36:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=GHaZaDHn;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=U9t6ZQ44UYTUT/2bmYoJaPHlaVA4zF3kDc6HTj92QLY=;
        b=GHaZaDHn+WrXy9wAWUNhR98Z2ZnPQcEwHBA0fNreTeMFXYMI0TLIdk30sXIfGaoz6Z
         2Wm1tuJvJYWlqm5H0fGGQz48oT3T8YpadC8btMOQB92/NfQmMva+TJZd6EYG9aWCgG26
         VHxwQ3DfM5qDIlpn7ZQApr/l2ZVC97Wts0DZMciAn9C59MY+B2uE/S8xHsY80afFLUwE
         fVTvzqyFZhI3ahb8xUOy+dvzr4y8fvz0m08BooWKjV0QROJkrcKdRBobe7fC7zZwdrvn
         wdtfrz0yNTz3DcVP1O7PZIY5gTipTaSJOWppd9hp9gzmpCYl6I49MMbnYyuKQtl1CqSP
         QnwA==
X-Google-Smtp-Source: APXvYqypoZ+b6025sI65OH/L42IdhXMlYJe+1m7dJypoBd+4mL7LK+2bgSIQr1nAwsZ9NZSKGMrcsw==
X-Received: by 2002:a37:6601:: with SMTP id a1mr42814748qkc.282.1559911008855;
        Fri, 07 Jun 2019 05:36:48 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id w143sm960651qka.22.2019.06.07.05.36.48
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 07 Jun 2019 05:36:48 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hZE6x-00073H-NM; Fri, 07 Jun 2019 09:36:47 -0300
Date: Fri, 7 Jun 2019 09:36:47 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>, Felix.Kuehling@amd.com,
	linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org
Subject: Re: [PATCH v2 hmm 03/11] mm/hmm: Hold a mmgrab from hmm to mm
Message-ID: <20190607123647.GC14802@ziepe.ca>
References: <20190606184438.31646-1-jgg@ziepe.ca>
 <20190606184438.31646-4-jgg@ziepe.ca>
 <48fcaa19-6ac3-59d0-cd51-455abeca7cdb@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <48fcaa19-6ac3-59d0-cd51-455abeca7cdb@nvidia.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 06, 2019 at 07:44:58PM -0700, John Hubbard wrote:
> On 6/6/19 11:44 AM, Jason Gunthorpe wrote:
> > From: Jason Gunthorpe <jgg@mellanox.com>
> > 
> > So long a a struct hmm pointer exists, so should the struct mm it is
> > linked too. Hold the mmgrab() as soon as a hmm is created, and mmdrop() it
> > once the hmm refcount goes to zero.
> > 
> > Since mmdrop() (ie a 0 kref on struct mm) is now impossible with a !NULL
> > mm->hmm delete the hmm_hmm_destroy().
> > 
> > Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
> > Reviewed-by: Jérôme Glisse <jglisse@redhat.com>
> > v2:
> >  - Fix error unwind paths in hmm_get_or_create (Jerome/Jason)
> >  include/linux/hmm.h |  3 ---
> >  kernel/fork.c       |  1 -
> >  mm/hmm.c            | 22 ++++------------------
> >  3 files changed, 4 insertions(+), 22 deletions(-)
> > 
> > diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> > index 2d519797cb134a..4ee3acabe5ed22 100644
> > +++ b/include/linux/hmm.h
> > @@ -586,14 +586,11 @@ static inline int hmm_vma_fault(struct hmm_mirror *mirror,
> >  }
> >  
> >  /* Below are for HMM internal use only! Not to be used by device driver! */
> > -void hmm_mm_destroy(struct mm_struct *mm);
> > -
> >  static inline void hmm_mm_init(struct mm_struct *mm)
> >  {
> >  	mm->hmm = NULL;
> >  }
> >  #else /* IS_ENABLED(CONFIG_HMM_MIRROR) */
> > -static inline void hmm_mm_destroy(struct mm_struct *mm) {}
> >  static inline void hmm_mm_init(struct mm_struct *mm) {}
> >  #endif /* IS_ENABLED(CONFIG_HMM_MIRROR) */
> >  
> > diff --git a/kernel/fork.c b/kernel/fork.c
> > index b2b87d450b80b5..588c768ae72451 100644
> > +++ b/kernel/fork.c
> > @@ -673,7 +673,6 @@ void __mmdrop(struct mm_struct *mm)
> >  	WARN_ON_ONCE(mm == current->active_mm);
> >  	mm_free_pgd(mm);
> >  	destroy_context(mm);
> > -	hmm_mm_destroy(mm);
> 
> 
> This is particularly welcome, not to have an "HMM is special" case
> in such a core part of process/mm code. 

I would very much like to propose something like 'per-net' for struct
mm, as rdma also need to add some data to each mm to make it's use of
mmu notifiers work (for basically this same reason as HMM)

Thanks,
Jason

