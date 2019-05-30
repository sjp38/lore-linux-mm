Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5347C28CC2
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 02:42:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 46C1F2441F
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 02:42:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="B6mihvkl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 46C1F2441F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9EF1F6B0010; Wed, 29 May 2019 22:42:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 99F0C6B026D; Wed, 29 May 2019 22:42:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8B4C66B026E; Wed, 29 May 2019 22:42:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 537806B0010
	for <linux-mm@kvack.org>; Wed, 29 May 2019 22:42:37 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id x5so3492455pfi.5
        for <linux-mm@kvack.org>; Wed, 29 May 2019 19:42:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=cAqqipIPGzpGmQv8QEqqienVSy4sBtVzv6/oGKxRvNw=;
        b=R1tgCCqxSqSGDluMsXxcLKw4OArV1C5xoMZ9kaXu1DGdMLBvWkBm41MlE7WcMMhMWS
         ck7I0q1UOtZ472ucQvSh7YFZ0qMIa1cDrJR5Zm0J337pkQuaJeqbv4pezKvHIAnjHOTC
         jP9T/bfQLfAuzRs4uuurNOphnE2DNCC7r2K6W5zLU/6eJu76YPon3cc+EEP8Z6//PRfp
         4+hKfDdoqA7zWYkSjrZ9hbUykFd+OvTMDOyrZ3kAUU+/XpQJbE4WKjYOuFaau28s9c5M
         TFzWJj91wWGZZRj7N40L+eDmyzB4xAIyuECE4/bTnbJL3MxEIE/XuCHgEK4DV4SyekLy
         ZROA==
X-Gm-Message-State: APjAAAUZ+1+LXVmlDcHHNRmXqW+vATzVCBnGchV2BSm9fK4J8joIEj4g
	0MBGmptUNJLt1Cce+AqKhtY5zSbv9KKrjZd9l2zzXQ5vtMCg25IT7cibeIOgEOXmpDpmuhHb2Tq
	nypndiQLi3sL8PUPaTfjceGF61HYRPMIodeXnwZe6UsQhSe1Fx4fYa3NWH0n7Z+c=
X-Received: by 2002:a63:130d:: with SMTP id i13mr1439841pgl.396.1559184156986;
        Wed, 29 May 2019 19:42:36 -0700 (PDT)
X-Received: by 2002:a63:130d:: with SMTP id i13mr1439723pgl.396.1559184155376;
        Wed, 29 May 2019 19:42:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559184155; cv=none;
        d=google.com; s=arc-20160816;
        b=C2/wB078kvWiVBOGSjL68JtORkIsBJy7xmCB5aHBocVkqty7i+a+smrNzWmjF3Rtmf
         PNDpc0bxWaE7L7rNZDqPfo6zqNFoXF+hDRS7BLFSnHw6ywAmCWc6x3o1ur3u+/MAIibO
         C0nMEvEh9ck4ehvxuJBXeZHed5UH+E+IsFSH2MCeAiUzODMk0zllMyPcNYNepJxJ3uJz
         mWAxOBVr6z+gPSKTo7xxgw4Vf2qPKPHkuHRhIHpNdB4OZ/UqIxolP0ppebcFQ6rZS3Sf
         nmcKhmI0A6GkqYPDYn7EV39uD1W1HIyUg2bqNS3fDDnOWNDjIu/U1I5qVmjaB4K5jF22
         u5DQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=cAqqipIPGzpGmQv8QEqqienVSy4sBtVzv6/oGKxRvNw=;
        b=Z4/g9O4sbwXyq4gu8KLYeEJWUDMg+T9fvFxF3RboikYT4r83aX2B0TAQ0FYcCItETy
         6cyp6n0v+4cBusDFqDjnU3tXD5XlR7BbXz+6qPsItYgocwzzY8zc+EVMG2eYim6FDjcf
         otAP6eOLcB3hHAmE9cNCyU/I9hAIQgvR6UwIqVgRCfyxKKH/i8vQe6qBM+5zsqDWOOWW
         B36uM+p68mEigrDoVka38DUClViCR6Q/lWRnqRvx41WAY7oX2C2FEWfJBPGZekQ628kd
         p3ukWDb9/cz+RZNkHyWima4H7qPEKzArSFP2WghMK6kw2vW0KTkZNgaThGW6ki8C7PtU
         l0VA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=B6mihvkl;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w25sor1685566pfg.23.2019.05.29.19.42.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 May 2019 19:42:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=B6mihvkl;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=cAqqipIPGzpGmQv8QEqqienVSy4sBtVzv6/oGKxRvNw=;
        b=B6mihvkll3Cv/asD+7MCKFcDmWqt5uSxKQQ3LSzu1iASiaf06/7zkpIngAFvLAv0bl
         B+aYF5ytYSaFHBbIGadVj2ljU+kQ0s5yUrKycApUHcYdY4X5BTsiGFUhrjugH4FhzscK
         zpb6NywD0+vPRFEeKhapl0tQVhw0TQv1oLH0sDr1ARE2mlIHBZF/3j88OZ9yt6L9WunP
         s4yjNO8ZH4K1xHVn0CbW7cc6T5p8SkxLfV68bdo+tUZ4B/R8v1OZbhjUKhIXHQF5EsJu
         aO9lB+uNI2MhMvFqE7MGcBlSgy6WEK+DFAhmKdCOtVw8y6jo3RmOeh4wYCGzIwbXduDl
         I+dg==
X-Google-Smtp-Source: APXvYqzpiodDhC19KrjAAAfJJz5B5HC6YSFCqpiu06yRKe4Odk+Fo+ObevDVElvTks6QKFvGWW236A==
X-Received: by 2002:aa7:8598:: with SMTP id w24mr1198933pfn.160.1559184154693;
        Wed, 29 May 2019 19:42:34 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id j23sm352061pff.90.2019.05.29.19.42.31
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 29 May 2019 19:42:33 -0700 (PDT)
Date: Thu, 30 May 2019 11:42:29 +0900
From: Minchan Kim <minchan@kernel.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	stable@kernel.org, Wu Fangsuo <fangsuowu@asrmicro.com>,
	Pankaj Suryawanshi <pankaj.suryawanshi@einfochips.com>
Subject: Re: [PATCH] mm: fix trying to reclaim unevicable LRU page
Message-ID: <20190530024229.GF229459@google.com>
References: <20190524071114.74202-1-minchan@kernel.org>
 <20190528151407.GE1658@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190528151407.GE1658@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 28, 2019 at 05:14:07PM +0200, Michal Hocko wrote:
> [Cc Pankaj Suryawanshi who has reported a similar problem
> http://lkml.kernel.org/r/SG2PR02MB309806967AE91179CAFEC34BE84B0@SG2PR02MB3098.apcprd02.prod.outlook.com]
> 
> On Fri 24-05-19 16:11:14, Minchan Kim wrote:
> > There was below bugreport from Wu Fangsuo.
> > 
> > 7200 [  680.491097] c4 7125 (syz-executor) page:ffffffbf02f33b40 count:86 mapcount:84 mapping:ffffffc08fa7a810 index:0x24
> > 7201 [  680.531186] c4 7125 (syz-executor) flags: 0x19040c(referenced|uptodate|arch_1|mappedtodisk|unevictable|mlocked)
> > 7202 [  680.544987] c0 7125 (syz-executor) raw: 000000000019040c ffffffc08fa7a810 0000000000000024 0000005600000053
> > 7203 [  680.556162] c0 7125 (syz-executor) raw: ffffffc009b05b20 ffffffc009b05b20 0000000000000000 ffffffc09bf3ee80
> > 7204 [  680.566860] c0 7125 (syz-executor) page dumped because: VM_BUG_ON_PAGE(PageLRU(page) || PageUnevictable(page))
> > 7205 [  680.578038] c0 7125 (syz-executor) page->mem_cgroup:ffffffc09bf3ee80
> > 7206 [  680.585467] c0 7125 (syz-executor) ------------[ cut here ]------------
> > 7207 [  680.592466] c0 7125 (syz-executor) kernel BUG at /home/build/farmland/adroid9.0/kernel/linux/mm/vmscan.c:1350!
> > 7223 [  680.603663] c0 7125 (syz-executor) Internal error: Oops - BUG: 0 [#1] PREEMPT SMP
> > 7224 [  680.611436] c0 7125 (syz-executor) Modules linked in:
> > 7225 [  680.616769] c0 7125 (syz-executor) CPU: 0 PID: 7125 Comm: syz-executor Tainted: G S              4.14.81 #3
> > 7226 [  680.626826] c0 7125 (syz-executor) Hardware name: ASR AQUILAC EVB (DT)
> > 7227 [  680.633623] c0 7125 (syz-executor) task: ffffffc00a54cd00 task.stack: ffffffc009b00000
> > 7228 [  680.641917] c0 7125 (syz-executor) PC is at shrink_page_list+0x1998/0x3240
> > 7229 [  680.649144] c0 7125 (syz-executor) LR is at shrink_page_list+0x1998/0x3240
> > 7230 [  680.656303] c0 7125 (syz-executor) pc : [<ffffff90083a2158>] lr : [<ffffff90083a2158>] pstate: 60400045
> > 7231 [  680.666086] c0 7125 (syz-executor) sp : ffffffc009b05940
> > ..
> > 7342 [  681.671308] c0 7125 (syz-executor) [<ffffff90083a2158>] shrink_page_list+0x1998/0x3240
> > 7343 [  681.679567] c0 7125 (syz-executor) [<ffffff90083a3dc0>] reclaim_clean_pages_from_list+0x3c0/0x4f0
> > 7344 [  681.688793] c0 7125 (syz-executor) [<ffffff900837ed64>] alloc_contig_range+0x3bc/0x650
> > 7347 [  681.717421] c0 7125 (syz-executor) [<ffffff90084925cc>] cma_alloc+0x214/0x668
> > 7348 [  681.724892] c0 7125 (syz-executor) [<ffffff90091e4d78>] ion_cma_allocate+0x98/0x1d8
> > 7349 [  681.732872] c0 7125 (syz-executor) [<ffffff90091e0b20>] ion_alloc+0x200/0x7e0
> > 7350 [  681.740302] c0 7125 (syz-executor) [<ffffff90091e154c>] ion_ioctl+0x18c/0x378
> > 7351 [  681.747738] c0 7125 (syz-executor) [<ffffff90084c6824>] do_vfs_ioctl+0x17c/0x1780
> > 7352 [  681.755514] c0 7125 (syz-executor) [<ffffff90084c7ed4>] SyS_ioctl+0xac/0xc0
> > 
> > Wu found it's due to [1]. Before that, unevictable page goes to cull_mlocked
> > routine so that it couldn't reach the VM_BUG_ON_PAGE line.
> > 
> > To fix the issue, this patch filter out unevictable LRU pages
> > from the reclaim_clean_pages_from_list in CMA.
> 
> The changelog is rather modest on details and I have to confess I have
> little bit hard time to understand it. E.g. why do not we need to handle
> the regular reclaim path?

No need to pass unevictable pages into regular reclaim patch if we are
able to know in advance.

> 
> > [1] ad6b67041a45, mm: remove SWAP_MLOCK in ttu
> > 
> > Cc: <stable@kernel.org>	[4.12+]
> > Reported-debugged-by: Wu Fangsuo <fangsuowu@asrmicro.com>
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> >  mm/vmscan.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index d9c3e873eca6..7350afae5c3c 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -1505,7 +1505,7 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
> >  
> >  	list_for_each_entry_safe(page, next, page_list, lru) {
> >  		if (page_is_file_cache(page) && !PageDirty(page) &&
> > -		    !__PageMovable(page)) {
> > +		    !__PageMovable(page) && !PageUnevictable(page)) {
> >  			ClearPageActive(page);
> >  			list_move(&page->lru, &clean_pages);
> >  		}
> > -- 
> > 2.22.0.rc1.257.g3120a18244-goog
> > 
> 
> -- 
> Michal Hocko
> SUSE Labs

