Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DB414C2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 12:58:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 86F1C206BB
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 12:58:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="N80l5v8n"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 86F1C206BB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0C6106B000C; Fri,  7 Jun 2019 08:58:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 04F9B6B000E; Fri,  7 Jun 2019 08:58:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E30E66B0266; Fri,  7 Jun 2019 08:58:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id C15556B000C
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 08:58:44 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id s67so1494570qkc.6
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 05:58:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=XZLOMkYs5vXjMI8Dkpaj3wAhdY/xEzfilUkvJL4EXH4=;
        b=ok9pTEuLoDoWoRM1TKAHv/9S0owaOxps+fUnPjdXOxYtTYZC1qA+h3oi75TcUVSRD6
         wpV8Wc2td6HogKUjPe78As1WCSTmCgEpL5wXEzZHSReC2H0OEXOc1/our3Sxk+Uq7LFL
         rnYde4pHaPQAlEcJm1LYXItmg9OWKiaOSMjiOIoQ5i3WrN4Q2JbTvz+DptKpX7yvaIWA
         XUllSbPHi8NfOnlFsRNejw6GVtzfv+7EEt91SNsU9sDpSx44XTzVyjOs4by1k1Kbeouz
         NJIXfdawOR74FRhMi13158ciEOvKMeqO2poqMAKWlOT02EgwFgITubU6PgzkZ4vHEB8s
         RCDQ==
X-Gm-Message-State: APjAAAVYssbd6Mm3wsRemcMt6GdtDoGyGFAEHxHkMcL2frYUuUGsZHcw
	P4Q7JqnR+obj0wNDe5lbpHSNnGSOFYchFWs7yZe0Cw7/I1I7nA6iKeYfE0ucozTmfsR1cfkiwpA
	7MQtN96iSm4gXT8Ohev/cAtTWbM6Jo9wpo6/eXuD8kEdkMtqzOJWJGXsMQ60hf88B/Q==
X-Received: by 2002:ac8:17a5:: with SMTP id o34mr46489747qtj.232.1559912324578;
        Fri, 07 Jun 2019 05:58:44 -0700 (PDT)
X-Received: by 2002:ac8:17a5:: with SMTP id o34mr46489688qtj.232.1559912323753;
        Fri, 07 Jun 2019 05:58:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559912323; cv=none;
        d=google.com; s=arc-20160816;
        b=HbzOfB2Un4kyRavyCuP8hMBFDuuB0FIi4DG3GOjnsz4KwkgE09sgRoCDqVF2JdVQyE
         uDfp+sw9pYpE0V2c6zcNpknoCLTgProrXAikFhc3cq5qOLQhxtnp4xQLo25AIst74/gp
         MZ6kjvipMmSOQFk9JqjE/zJc9m2jpxsl4n4ysmtld9ISLIIiVdwhMzrjh3ZVfRcjY/DW
         ytJMNGc9uuSLUrpz19oQzdr+ER4eR2MpOrsY3tT9OXreYSJB/mPBDfleIET3XPVJ4bn3
         f0NhIYkNobTF3jiTva6ICo/cN3IVIiDUdG/BSaTDQMCF+8AHboI/I8BDEWXSb2KJXi+4
         eFkg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=XZLOMkYs5vXjMI8Dkpaj3wAhdY/xEzfilUkvJL4EXH4=;
        b=t2mlqAzsNi4bVI0hvLeZ2tdKh5FpDsIf3kCLSEYwCmAa5Q4XwJvkoRIXUaN7TG/kEb
         WV/m0vApFg54AbtmuDvhZ1stGW1nK9bXwlf4mBSy1QaOHLKsGl5tjKhZv1sExweAaJX4
         fm0k2Xq7uYoxb4iCOW8O9ErYGDx2Gv9atMy36FtdTOh4oGYWWwFxmTpFaYu5bI18rgrB
         sxuaIvj41qnTLQGppU+gW2GnELiuc8G1PLy7Rro+Z0e0p8LET6Fvas8Xi6W+tPUxuv6/
         CqT0yPLzqpC4WqRUVCvbSGg5Y7i4TKE/EgEHxAKhbkNNpVyiuiExw1fZ7bBroBYwhBbd
         mpmQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=N80l5v8n;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j12sor1033834qkg.98.2019.06.07.05.58.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Jun 2019 05:58:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=N80l5v8n;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=XZLOMkYs5vXjMI8Dkpaj3wAhdY/xEzfilUkvJL4EXH4=;
        b=N80l5v8nv6hIG51GGBM5+5TLSkvUjSSCa9Cn4MGZUpD+wY28VR23asHPPM24ICOwL2
         nAbR23abB3zKIl8/4vBjtjhFTTbIPzEqJYil1OYzPPhROYxXgqqdNOuNSancrYWXqewx
         BnOcJSJOWmic6p2onjwo9+ZCZdNNNr4DcNaiX2EqP7jgfF8/mbDYj0Z94+7C0i3GdDBI
         zT37XTlbwh3fm0/MZZEKJkZRVsb/IAcRWwlHOUDFHaMaYFqITiRjZIAd1IGyPQGV5mA7
         00nLqMYxsjqP5MczltRg1QpmNV4fmex4E92/bFXMahKwHP+EKfNY+zQ4QqMf53bT1nRI
         Zm2Q==
X-Google-Smtp-Source: APXvYqwLYhkbnVkO37hDdk1D8+dw0XaaSJbnZghiAkAd4Vn3rUNFhKrdJtv3yRh7yG+5koJqQBqxRg==
X-Received: by 2002:a37:b342:: with SMTP id c63mr44488163qkf.292.1559912323433;
        Fri, 07 Jun 2019 05:58:43 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id p49sm1384966qtb.69.2019.06.07.05.58.42
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 07 Jun 2019 05:58:43 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hZESA-0007KA-Il; Fri, 07 Jun 2019 09:58:42 -0300
Date: Fri, 7 Jun 2019 09:58:42 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>, Felix.Kuehling@amd.com,
	linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org
Subject: Re: [PATCH v2 hmm 11/11] mm/hmm: Remove confusing comment and logic
 from hmm_release
Message-ID: <20190607125842.GE14802@ziepe.ca>
References: <20190606184438.31646-1-jgg@ziepe.ca>
 <20190606184438.31646-12-jgg@ziepe.ca>
 <3edc47bd-e8f6-0e65-5844-d16901890637@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3edc47bd-e8f6-0e65-5844-d16901890637@nvidia.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 06, 2019 at 08:47:28PM -0700, John Hubbard wrote:
> On 6/6/19 11:44 AM, Jason Gunthorpe wrote:
> > From: Jason Gunthorpe <jgg@mellanox.com>
> > 
> > hmm_release() is called exactly once per hmm. ops->release() cannot
> > accidentally trigger any action that would recurse back onto
> > hmm->mirrors_sem.
> > 
> > This fixes a use after-free race of the form:
> > 
> >        CPU0                                   CPU1
> >                                            hmm_release()
> >                                              up_write(&hmm->mirrors_sem);
> >  hmm_mirror_unregister(mirror)
> >   down_write(&hmm->mirrors_sem);
> >   up_write(&hmm->mirrors_sem);
> >   kfree(mirror)
> >                                              mirror->ops->release(mirror)
> > 
> > The only user we have today for ops->release is an empty function, so this
> > is unambiguously safe.
> > 
> > As a consequence of plugging this race drivers are not allowed to
> > register/unregister mirrors from within a release op.
> > 
> > Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
> >  mm/hmm.c | 28 +++++++++-------------------
> >  1 file changed, 9 insertions(+), 19 deletions(-)
> > 
> > diff --git a/mm/hmm.c b/mm/hmm.c
> > index 709d138dd49027..3a45dd3d778248 100644
> > +++ b/mm/hmm.c
> > @@ -136,26 +136,16 @@ static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
> >  	WARN_ON(!list_empty(&hmm->ranges));
> >  	mutex_unlock(&hmm->lock);
> >  
> > -	down_write(&hmm->mirrors_sem);
> > -	mirror = list_first_entry_or_null(&hmm->mirrors, struct hmm_mirror,
> > -					  list);
> > -	while (mirror) {
> > -		list_del_init(&mirror->list);
> > -		if (mirror->ops->release) {
> > -			/*
> > -			 * Drop mirrors_sem so the release callback can wait
> > -			 * on any pending work that might itself trigger a
> > -			 * mmu_notifier callback and thus would deadlock with
> > -			 * us.
> > -			 */
> > -			up_write(&hmm->mirrors_sem);
> > +	down_read(&hmm->mirrors_sem);
> 
> This is cleaner and simpler, but I suspect it is leading to the deadlock
> that Ralph Campbell is seeing in his driver testing. (And in general, holding
> a lock during a driver callback usually leads to deadlocks.)

I think Ralph has never seen this patch (it is new), so it must be one
of the earlier patches..

> Ralph, is this the one? It's the only place in this patchset where I can
> see a lock around a callback to driver code, that wasn't there before. So
> I'm pretty sure it is the one...

Can you share the lockdep report please?

Thanks,
Jason

