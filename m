Return-Path: <SRS0=L2Uh=RS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0DDE5C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 17:21:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B401E21019
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 17:21:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="TY8hhFfb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B401E21019
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 45AE36B0294; Fri, 15 Mar 2019 13:21:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 409ED6B0296; Fri, 15 Mar 2019 13:21:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2F9876B0297; Fri, 15 Mar 2019 13:21:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id EAF0A6B0294
	for <linux-mm@kvack.org>; Fri, 15 Mar 2019 13:21:50 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id e12so4250616otl.9
        for <linux-mm@kvack.org>; Fri, 15 Mar 2019 10:21:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=rV3K8PnVom4USqT3Gzf7IMcpT4mAIhVLDbNscsln/e4=;
        b=hOVTpuj3SAIZvIOP/Jp0Rzgnr92m6qk5F7UJr61KBK5126yVpSMCVU7MXOvzLV3Xve
         6UkEgnWYZfdp7XA+k3ctMUN6Sk+RxOcui+dj6cfnBMdb47VYp4OusoDF/3+AAnCWV/GA
         4Gqgupn8YcEzcaa4j2kb42aXH//ETb7WZcaWc6nF3XTjNpvhDsQuXS4WJBnECFiOgMMV
         yCLR+m7lqOnfNYyuWd8rz0SC55aLdtSFAa33CmU0z+zr/mvotUEjGd9y42R6GaNPsMZr
         C0KE2/Vtb/27XjlzlHM8c6VtyMqkdxVY3Fcb/nuv+FlSBqc/cbFgJC+J3sIYtm34FqPS
         LUoA==
X-Gm-Message-State: APjAAAUs0Nh7rdBPV1jr5Ac1F3l8sKhReS0Nn1U/TZQ5DPBiMV+wwtRJ
	q2WcECj/SOOWfuIA69tlmrtYYhsdc8y3Fh47qtctXKSkTuHawgTJMSuixtzXC0QIxTA5641VDOK
	o+YzUSIH2tHM2yLfPje5p2m54GsE/iE3QWN6rmXUhKWkLVMMyC/HPcveq2dz+cP78CA==
X-Received: by 2002:a9d:6f0e:: with SMTP id n14mr2728287otq.156.1552670510547;
        Fri, 15 Mar 2019 10:21:50 -0700 (PDT)
X-Received: by 2002:a9d:6f0e:: with SMTP id n14mr2728250otq.156.1552670509655;
        Fri, 15 Mar 2019 10:21:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552670509; cv=none;
        d=google.com; s=arc-20160816;
        b=M8UanBaAY3qXYhTbtSz4JoRpxeBChsJAhgpB135/QsR+qDk0XFkc2yzbWnYMl/tymW
         3BHFeYP2q3nEbbp1BqEqVOvvmJ8t/070mugwjPD23EsK/NpMQMGaSx6pBg6ooTCyslJs
         2dzNX4dBpfAsorGr7FXcNN5eP0nbHQYKcBucDKAf10MNRUm8w0O+hCpaVz1LpWya/Cob
         NrTJjO73Qzn03QNEF6WtPc94rkbUNdATFAoTLd8658K/DI6SiZRUCOzZ2W7fKBLnnrqn
         +2rXiNCqcGO5zr15tdO73QfynBNHLWv01IE4SPXnsYhUbiCIAQke5c1nmU8De+qoZacr
         +gWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=rV3K8PnVom4USqT3Gzf7IMcpT4mAIhVLDbNscsln/e4=;
        b=B0zzpQDYyYdRUWFnl0QXYQ23fmLbdNVaAInYwHV/39z9c7MMIXIZ81NQyA2is3YfoW
         YwXRS8kddMjQFlI9Y2Xq3jGfqIjXmu4cShtTg/t8gCGIRjJka1mT7r9ix2+pV8evd5bm
         ejWiLhtwFWtD2TjiD0W9vPauBOnzuRc6LOKKad6iO82Zrv/Em2Az6ciArsV/QjFHOuWz
         2Kg2LHbpnv+cxNzLo6c250EJZdwr5CCtnYTPHGm7co5DJ8qHkfo8XZ1nBs5Q6SqcsXyK
         r+MufOU3pekD+bgm/wPe0luBOE0Z/KmMZQKu8LBLsmnxHzhRMPyhsXQnsa7wyTJ6pqu8
         NthQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=TY8hhFfb;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p9sor1423477otq.94.2019.03.15.10.21.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Mar 2019 10:21:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=TY8hhFfb;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=rV3K8PnVom4USqT3Gzf7IMcpT4mAIhVLDbNscsln/e4=;
        b=TY8hhFfbk1i53/4fH5sKe15+nweaFTVhdIk/aMuUgTg4aQH7BGOHw+1HsUL2bsFSd5
         hzY8zV9j1VpZRMMRTKvrvrnHCIeRKvCCLFqgNwxqjLn/iwjDyeNN6RI0+WWrz5hxfyR7
         2HM6lEptgtV2XiRqodQwftKrNu4QmLZMyG9S7Aq2/vO7bu69jJOzsmvuCVSYZZ1wv5cO
         3nCPMKLHFC+owGZrkZ9ewd1SR0arWxz363VTHWPBRqFY/u0YcKGje59fLxjfcnj+TcfC
         M9/FR8fIve0cLLvbyZBcM4mklV782/7M7BK80Mfr7cAvoesGYIYTcFYun8NVeAAPz4Wd
         IbgA==
X-Google-Smtp-Source: APXvYqxIGDlSFub6D2MZgeFN+mM5z0qNWtolTi4QKIyeLDX/QxxKp8cHd7JLtlWzrg2flcUszC6KvQ==
X-Received: by 2002:a9d:67d3:: with SMTP id c19mr2769706otn.300.1552670508834;
        Fri, 15 Mar 2019 10:21:48 -0700 (PDT)
Received: from eggly.attlocal.net (172-10-233-147.lightspeed.sntcca.sbcglobal.net. [172.10.233.147])
        by smtp.gmail.com with ESMTPSA id h138sm1230701oic.8.2019.03.15.10.21.46
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 15 Mar 2019 10:21:47 -0700 (PDT)
Date: Fri, 15 Mar 2019 10:21:18 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
X-X-Sender: hugh@eggly.anvils
To: Oscar Salvador <osalvador@suse.de>
cc: Michal Hocko <mhocko@kernel.org>, akpm@linux-foundation.org, 
    anshuman.khandual@arm.com, william.kucharski@oracle.com, 
    linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jan Kara <jack@suse.cz>, 
    Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: Fix __dump_page when mapping->host is not set
In-Reply-To: <20190315143304.pkuvj4qwtlzgm7iq@d104.suse.de>
Message-ID: <alpine.LSU.2.11.1903150952270.2934@eggly.anvils>
References: <20190315121826.23609-1-osalvador@suse.de> <20190315124733.GE15672@dhcp22.suse.cz> <20190315143304.pkuvj4qwtlzgm7iq@d104.suse.de>
User-Agent: Alpine 2.11 (LSU 23 2013-08-11)
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 15 Mar 2019, Oscar Salvador wrote:
> On Fri, Mar 15, 2019 at 01:47:33PM +0100, Michal Hocko wrote:
> > diff --git a/mm/debug.c b/mm/debug.c
> > index 1611cf00a137..499c26d5ebe5 100644
> > --- a/mm/debug.c
> > +++ b/mm/debug.c
> > @@ -78,6 +78,9 @@ void __dump_page(struct page *page, const char *reason)
> >  	else if (PageKsm(page))
> >  		pr_warn("ksm ");
> >  	else if (mapping) {
> > +		if (PageSwapCache(page))
> > +			mapping = page_swap_info(page)->swap_file->f_mapping;
> > +
> >  		pr_warn("%ps ", mapping->a_ops);
> >  		if (mapping->host->i_dentry.first) {
> >  			struct dentry *dentry;
> 
> This looks like a much nicer fix, indeed.
> I gave it a spin and it works.
> 
> Since the mapping is set during the swapon, I would assume that this should
> always work for swap.
> Although I am not sure if once you start playing with e.g zswap the picture can
> change.
> 
> Let us wait for Hugh and Jan.
> 
> Thanks Michal

Sorry, I don't agree that Michal's more sophisticated patch is nicer:
the appropriate patch was your original, just checking for NULL.

Though, would I be too snarky to suggest that your patch description
would be better at 2 lines than 90?  Swap mapping->host is NULL,
so of course __dump_page() needs to be careful about that.

I was a little disturbed to see __dump_page() now getting into dentries,
but admit that it can sometimes be very helpful to see the name of the
file involved; so if that is not in danger of breaking anything, okay.

It is very often useful to see if a page is PageSwapCache (typically
because that should account for 1 of its refcount); I cannot think of
a time when it's been useful to know the name of the underlying swap
device (if that's indeed what f_mapping leads to: it's new to me).
And if you need swp_type and swp_offset, they're in the raw output.

The cleverer __dump_page() tries to get, the more likely that it will
itself crash just when you need it most. Please just keep it simple.

Thanks,
Hugh

