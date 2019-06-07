Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 77C57C2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 12:34:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 23854208E3
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 12:34:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="cejnsklT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 23854208E3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B10586B000C; Fri,  7 Jun 2019 08:34:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AC1186B000E; Fri,  7 Jun 2019 08:34:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9AF466B0266; Fri,  7 Jun 2019 08:34:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 77B7C6B000C
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 08:34:34 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id a18so1681634qtj.18
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 05:34:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=A2FbqDaOIm85eFPjOPRRz/esCZO+J4vaz7zIDfIOxvA=;
        b=HW530Kj8DzDmPHzQQQq+LoIzFvpMwo2uoHW/DTsx/Zk1aBUtFu96sFWeh8mryqJoBv
         3f6jtRB2YNccBr3iP+ObrsG78ZGmQJ/qHbIIYAv0Jj6FnZkQ9+pqk2m6QraaMZXQuJc+
         O/FdrOxCtOsd093T0tX/+5oVnp7aGK7INCVehs9Z/s79B93ZLS6ozaTz24yUpSHj3dbh
         aNvcRaun/BOJ8KsuLcO3tGxpvezBGM0nHe0J/0glM9gZ5/VeHPxqPTL7OpOXWW15Ioxw
         8RU28jaeIWGSf0j9hzdTPyx4IreZgiZWQCJTGuHiSUVmDhsvrbX0FMulQhePTpT+BOPE
         hvew==
X-Gm-Message-State: APjAAAWUpRwk2Q9m8ako8pSw74wFXCQDQ3Nppoc6hohAMvRULWixvLGn
	JeYYk51n3pWQvGAT1gmqop9Lh7jqdboHHe9xLrmFCLAOvKKwEO3QB2DaLRVwkaRCFM+Facr1A2R
	szXUKHOk3ybwPq+E0GEnqS8/AXrfuIOUXSxVG2NyiLLYhhirWqAAYi3TKVps2boh6uw==
X-Received: by 2002:a0c:b79d:: with SMTP id l29mr44085767qve.179.1559910874231;
        Fri, 07 Jun 2019 05:34:34 -0700 (PDT)
X-Received: by 2002:a0c:b79d:: with SMTP id l29mr44085707qve.179.1559910873589;
        Fri, 07 Jun 2019 05:34:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559910873; cv=none;
        d=google.com; s=arc-20160816;
        b=j3q644jDMAVe+nLolsTsLbu5qI3uLlBoSAKjVV/GJu4ojKTPhXW+cBct9os2tL2HgF
         BRE6L9rz8sJWwy71ctiClERhz7pXNytgzFZxPdXNItoRc7iHKx6kumUU1yHbBSKpUEhJ
         +YurjKyFBnJfJs1tYtYjVeyzpEDkGWGBc13VxgPVDPwsa6u1oN6P7Ic6UhQMmh7eT/Ho
         hMsZ8k+4REEPvBAyntwSVXNQJHZeEyya7126UCgEtOU2DyipuzuH2ooYXBHWyY6Lh2YJ
         1tlnd1D574YAIcRAzkzTMLOTB5SYsXqOAdy4bE3QE6cR/ZyY/M7AlaF6FqasmCklIhX1
         sAPg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=A2FbqDaOIm85eFPjOPRRz/esCZO+J4vaz7zIDfIOxvA=;
        b=USds69xa7rrYjsfN6UHx8wvtn8HXqmNgXfuXF8VdplzY2SzOvVy8QbuWIJv/65qM9b
         jRsQ3JliVpX92Nvnqrm2cNgr3mmPnRlNtSm3rCsuWBKLPIuMYU3nhSTpURlSOf4zffxD
         y12gEmQe+1mi4MHlA48O5TBkHoJsHwK7Ln/nAm3lEi/PLyz+F6mCxpw4no1w94WLIpQl
         NRkLlBsb12++O85Y7goBLizhPakHqsh/ou1sbSCt513FJGvzJvHG5RAWt3QN5Sk91fpE
         F5MGKAaQSwLUn12PvjEhViwFiVpE7outFScTjhW/3crz+02Q3nWUB/V8u83QpzlpYxKI
         mDPg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=cejnsklT;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x19sor995054qka.111.2019.06.07.05.34.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Jun 2019 05:34:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=cejnsklT;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=A2FbqDaOIm85eFPjOPRRz/esCZO+J4vaz7zIDfIOxvA=;
        b=cejnsklTN8gSa78nEyihP29Lx9J/VrusPGqXCyf5Rd+9hsmueFkxF1/YWmjS5sZO9/
         HH7v0sLRxeqlre/3LEQrtuC+ECX1CoDlHi7RjWJwsqX6IeTPRlBpObDM60nJLr+PMIIZ
         uzHsDgz4cQDDPKWcxBmzLfOKqAFg0G5K+NTmL3XYc/xpH9SNkaui88s0XGcmaj3ydsNz
         lFmSis1GsZQ0McoTZeDRJxbCFy9jepSrW5xnowcXy9X8ErbPrOuk0a0CsrL2yro8PtIO
         QOyIHW79VvRsPULJ5mPeQG+Tpqjmic/6xvxDcab8YmZz75UNLwahdhxIcfW61W60/Fm1
         QZ3w==
X-Google-Smtp-Source: APXvYqxt6cvXSe1Vnp7yMI6I6KtFfMUDzTi4iQ4hvnAcaJXl648GbcSmQKXBch+Om0G7zfr9TuWsKw==
X-Received: by 2002:a05:620a:5b0:: with SMTP id q16mr42567473qkq.212.1559910873269;
        Fri, 07 Jun 2019 05:34:33 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id t29sm1505233qtt.42.2019.06.07.05.34.32
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 07 Jun 2019 05:34:32 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hZE4m-00071G-Dh; Fri, 07 Jun 2019 09:34:32 -0300
Date: Fri, 7 Jun 2019 09:34:32 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>, Felix.Kuehling@amd.com,
	linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org
Subject: Re: [PATCH v2 hmm 01/11] mm/hmm: fix use after free with struct hmm
 in the mmu notifiers
Message-ID: <20190607123432.GB14802@ziepe.ca>
References: <20190606184438.31646-1-jgg@ziepe.ca>
 <20190606184438.31646-2-jgg@ziepe.ca>
 <9c72d18d-2924-cb90-ea44-7cd4b10b5bc2@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9c72d18d-2924-cb90-ea44-7cd4b10b5bc2@nvidia.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 06, 2019 at 07:29:08PM -0700, John Hubbard wrote:
> On 6/6/19 11:44 AM, Jason Gunthorpe wrote:
> > From: Jason Gunthorpe <jgg@mellanox.com>
> ...
> > diff --git a/mm/hmm.c b/mm/hmm.c
> > index 8e7403f081f44a..547002f56a163d 100644
> > +++ b/mm/hmm.c
> ...
> > @@ -125,7 +130,7 @@ static void hmm_free(struct kref *kref)
> >  		mm->hmm = NULL;
> >  	spin_unlock(&mm->page_table_lock);
> >  
> > -	kfree(hmm);
> > +	mmu_notifier_call_srcu(&hmm->rcu, hmm_free_rcu);
> 
> 
> It occurred to me to wonder if it is best to use the MMU notifier's
> instance of srcu, instead of creating a separate instance for HMM.

It *has* to be the MMU notifier SRCU because we are synchornizing
against the read side of that SRU inside the mmu notifier code, ie:

int __mmu_notifier_invalidate_range_start(struct mmu_notifier_range *range)
        id = srcu_read_lock(&srcu);
        hlist_for_each_entry_rcu(mn, &range->mm->mmu_notifier_mm->list, hlist) {
                if (mn->ops->invalidate_range_start) {
                   ^^^^^

Here 'mn' is really hmm (hmm = container_of(mn, struct hmm,
mmu_notifier)), so we must protect the memory against free for the mmu
notifier core.

Thus we have no choice but to use its SRCU.

CH also pointed out a more elegant solution, which is to get the write
side of the mmap_sem during hmm_mirror_unregister - no notifier
callback can be running in this case. Then we delete the kref, srcu
and so forth.

This is much clearer/saner/better, but.. requries the callers of
hmm_mirror_unregister to be safe to get the mmap_sem write side.

I think this is true, so maybe this patch should be switched, what do
you think?

> > @@ -153,10 +158,14 @@ void hmm_mm_destroy(struct mm_struct *mm)
> >  
> >  static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
> >  {
> > -	struct hmm *hmm = mm_get_hmm(mm);
> > +	struct hmm *hmm = container_of(mn, struct hmm, mmu_notifier);
> >  	struct hmm_mirror *mirror;
> >  	struct hmm_range *range;
> >  
> > +	/* hmm is in progress to free */
> 
> Well, sometimes, yes. :)

It think it is in all cases actually.. The only way we see a 0 kref
and still reach this code path is if another thread has alreay setup
the hmm_free in the call_srcu..

> Maybe this wording is clearer (if we need any comment at all):

I always find this hard.. This is a very standard pattern when working
with RCU - however in my experience few people actually know the RCU
patterns, and missing the _unless_zero is a common bug I find when
looking at code.

This is mm/ so I can drop it, what do you think?

Thanks,
Jason

