Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6A532C28D16
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 11:21:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 17A6A2089E
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 11:21:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="iEVp+8jM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 17A6A2089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A60366B026A; Mon, 10 Jun 2019 07:21:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9E93E6B026B; Mon, 10 Jun 2019 07:21:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8B1046B026C; Mon, 10 Jun 2019 07:21:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4C6B76B026A
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 07:21:20 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id q6so5561337pll.22
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 04:21:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=TQ3BNHm4HBsU+MK/6HPDmQwS/rOC62UZ81SJs/UsUlo=;
        b=LEYhchEH+9Si0bMmATs7A2hbwRt6Ukf9bqU+XrgVSxOP+C1vIpkJaObFYCzo04m9BU
         jIeNrijP+EBG5po4+pb4BVHcm267jlnQcizyZLt2VJz5kkE8DRj0EvlrrPzW4m/SofZm
         nJiVAj5aXQA0zRZaNPiRzY8MNbf3LRqSuLiiVf8Y+Nd/xLNUPaaNDZ9O4kd8YdQyTwdU
         bRwp6FfsTTOmDXrWScFD+Uax2Ptp329UmAWspkhryAaYp0mOUZ3eBOucivVzrex8Y21a
         ZcJF4ZO8Kxci4e6nKbv0loNyru9j8JiHDDuhxTWu5o9a47lcxfChm1HLp/mmNAd620f5
         gLrg==
X-Gm-Message-State: APjAAAV77i0g+/AU77yovLI5cIfbB+pJUIuRwLYqs6oRa5abx/0RYOw4
	nHUj1cIEb68KbbFawpwtpZqaxdPZVEhpKXD0G0sICj2+XD27p3D+NysKRGwklpUw5bUEiXBE1eh
	5HzVmTOYdz4hX0bxPXWrgrmpxoKqJ/5EnX9yuhrNf31xkkO1jzSIRursvTZiRliE=
X-Received: by 2002:a17:902:e183:: with SMTP id cd3mr34281502plb.164.1560165679926;
        Mon, 10 Jun 2019 04:21:19 -0700 (PDT)
X-Received: by 2002:a17:902:e183:: with SMTP id cd3mr34281437plb.164.1560165678775;
        Mon, 10 Jun 2019 04:21:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560165678; cv=none;
        d=google.com; s=arc-20160816;
        b=SuRSNHxreSSzNNRE9QvvS9scAQOzEN5Ee+A3Wmc4Cay/VHqubM4RADzFwjLR9Iqb51
         wSrZyzXspD34l+Wui1j29QdH20prAw3KHdj0y0oT2ju9JSFHxdX/XBB/eWDkE/c96ljU
         5bmwaLzrOMHUUdbEYi3ru2PeZsqxwQBpwH6jRtJFDv5B5clZZFh47noC7UlfiwnbuSB3
         v5ZQpHetW6OvSgGAhZ++aclkuCzv5J/KukHbR2kq0pYm6z6l7XnShrvPsPVL6rlRzuRG
         hlaOVaG08cxM3hW8qYdTnsnyCdApgwY5t8QHMtMWQSmv7x15MhhbJyz7LiMSW5qb7C7x
         V0VQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=TQ3BNHm4HBsU+MK/6HPDmQwS/rOC62UZ81SJs/UsUlo=;
        b=B86zaqfFOdR4K0pWS2O7ggARPiV0S5zf4zxseQwTYvKZfVKs1QJaS6WN2MatFH1zHj
         wBbhzz7M1nDnr9nrNF5n1fZUaBa/3U/qTVXTqXZCZcvvRIkjRceD3Nx90ggHBQEPXZw6
         sfjy8VYdqM5hpeMC/sDV4VaZnphmaJEX7R7eGDMlBZFMWTCjmmcOxEMLlFd+Q7F6dMZQ
         JQsTeZ4hyLS0WkAu/6f0aWGJ1BeMdUoqv5AWV0xN5BiRF9/7vkFTAwb2f6roigGau7pK
         abDTZhcoBs1oLbiNxzkUeWTuDrRT7CJfFkXb3itnoRasXhqxHzhlP12DTUxeGO66ccYU
         iKbw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=iEVp+8jM;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d4sor8784435pgc.35.2019.06.10.04.21.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 10 Jun 2019 04:21:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=iEVp+8jM;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=TQ3BNHm4HBsU+MK/6HPDmQwS/rOC62UZ81SJs/UsUlo=;
        b=iEVp+8jMVQcIzvPBL4gWGwyNqUvh5BeGA9YqAlxEnD53bAeL0wCTIHc4ESiPtKG2L1
         6GQMJCf3jZURlwy+R6Dj8KwLjGqWcNK/WtXyBXEhKy5gdnX5joCA7aGNf/3ufJWLnrcg
         AAm4aAZ/unWNlSxUpySdMfZULC412+aqjz5u7KcBkoMQhob4aN2gtHICrJH+b8Aq3GlL
         WR90831SaE03RCxkW5qi04QGbbncOO5dvKeYpE4cIXf8umbROITrrDy2/zwy/xufzUSc
         F1gtIHn85aXQ9N9D9SOtSuVoa0k5zY2+B21MA+0WJ2pwuClwXqxJ+4LfjJNIKUPeQHou
         5wDg==
X-Google-Smtp-Source: APXvYqyyMJnnahpyFh9ROPIwRbfBUlK8Ip2WF8TQvFOqWKHUU8dC/k6TuUYAZommSFHhvos8myxRSg==
X-Received: by 2002:a65:42ca:: with SMTP id l10mr14997477pgp.181.1560165678241;
        Mon, 10 Jun 2019 04:21:18 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id a11sm10526127pff.128.2019.06.10.04.21.14
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 10 Jun 2019 04:21:16 -0700 (PDT)
Date: Mon, 10 Jun 2019 20:21:12 +0900
From: Minchan Kim <minchan@kernel.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	stable@kernel.org, Wu Fangsuo <fangsuowu@asrmicro.com>,
	Pankaj Suryawanshi <pankaj.suryawanshi@einfochips.com>
Subject: Re: [PATCH] mm: fix trying to reclaim unevicable LRU page
Message-ID: <20190610112112.GE55602@google.com>
References: <20190524071114.74202-1-minchan@kernel.org>
 <20190528151407.GE1658@dhcp22.suse.cz>
 <20190530024229.GF229459@google.com>
 <20190604122806.GH4669@dhcp22.suse.cz>
 <20190610094222.GA55602@google.com>
 <20190610103946.GE30967@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190610103946.GE30967@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 10, 2019 at 12:39:46PM +0200, Michal Hocko wrote:
> On Mon 10-06-19 18:42:22, Minchan Kim wrote:
> > On Tue, Jun 04, 2019 at 02:28:06PM +0200, Michal Hocko wrote:
> > > On Thu 30-05-19 11:42:29, Minchan Kim wrote:
> > > > On Tue, May 28, 2019 at 05:14:07PM +0200, Michal Hocko wrote:
> > > > > [Cc Pankaj Suryawanshi who has reported a similar problem
> > > > > http://lkml.kernel.org/r/SG2PR02MB309806967AE91179CAFEC34BE84B0@SG2PR02MB3098.apcprd02.prod.outlook.com]
> > > > > 
> > > > > On Fri 24-05-19 16:11:14, Minchan Kim wrote:
> > > > > > There was below bugreport from Wu Fangsuo.
> > > > > > 
> > > > > > 7200 [  680.491097] c4 7125 (syz-executor) page:ffffffbf02f33b40 count:86 mapcount:84 mapping:ffffffc08fa7a810 index:0x24
> > > > > > 7201 [  680.531186] c4 7125 (syz-executor) flags: 0x19040c(referenced|uptodate|arch_1|mappedtodisk|unevictable|mlocked)
> > > > > > 7202 [  680.544987] c0 7125 (syz-executor) raw: 000000000019040c ffffffc08fa7a810 0000000000000024 0000005600000053
> > > > > > 7203 [  680.556162] c0 7125 (syz-executor) raw: ffffffc009b05b20 ffffffc009b05b20 0000000000000000 ffffffc09bf3ee80
> > > > > > 7204 [  680.566860] c0 7125 (syz-executor) page dumped because: VM_BUG_ON_PAGE(PageLRU(page) || PageUnevictable(page))
> > > > > > 7205 [  680.578038] c0 7125 (syz-executor) page->mem_cgroup:ffffffc09bf3ee80
> > > > > > 7206 [  680.585467] c0 7125 (syz-executor) ------------[ cut here ]------------
> > > > > > 7207 [  680.592466] c0 7125 (syz-executor) kernel BUG at /home/build/farmland/adroid9.0/kernel/linux/mm/vmscan.c:1350!
> > > > > > 7223 [  680.603663] c0 7125 (syz-executor) Internal error: Oops - BUG: 0 [#1] PREEMPT SMP
> > > > > > 7224 [  680.611436] c0 7125 (syz-executor) Modules linked in:
> > > > > > 7225 [  680.616769] c0 7125 (syz-executor) CPU: 0 PID: 7125 Comm: syz-executor Tainted: G S              4.14.81 #3
> > > > > > 7226 [  680.626826] c0 7125 (syz-executor) Hardware name: ASR AQUILAC EVB (DT)
> > > > > > 7227 [  680.633623] c0 7125 (syz-executor) task: ffffffc00a54cd00 task.stack: ffffffc009b00000
> > > > > > 7228 [  680.641917] c0 7125 (syz-executor) PC is at shrink_page_list+0x1998/0x3240
> > > > > > 7229 [  680.649144] c0 7125 (syz-executor) LR is at shrink_page_list+0x1998/0x3240
> > > > > > 7230 [  680.656303] c0 7125 (syz-executor) pc : [<ffffff90083a2158>] lr : [<ffffff90083a2158>] pstate: 60400045
> > > > > > 7231 [  680.666086] c0 7125 (syz-executor) sp : ffffffc009b05940
> > > > > > ..
> > > > > > 7342 [  681.671308] c0 7125 (syz-executor) [<ffffff90083a2158>] shrink_page_list+0x1998/0x3240
> > > > > > 7343 [  681.679567] c0 7125 (syz-executor) [<ffffff90083a3dc0>] reclaim_clean_pages_from_list+0x3c0/0x4f0
> > > > > > 7344 [  681.688793] c0 7125 (syz-executor) [<ffffff900837ed64>] alloc_contig_range+0x3bc/0x650
> > > > > > 7347 [  681.717421] c0 7125 (syz-executor) [<ffffff90084925cc>] cma_alloc+0x214/0x668
> > > > > > 7348 [  681.724892] c0 7125 (syz-executor) [<ffffff90091e4d78>] ion_cma_allocate+0x98/0x1d8
> > > > > > 7349 [  681.732872] c0 7125 (syz-executor) [<ffffff90091e0b20>] ion_alloc+0x200/0x7e0
> > > > > > 7350 [  681.740302] c0 7125 (syz-executor) [<ffffff90091e154c>] ion_ioctl+0x18c/0x378
> > > > > > 7351 [  681.747738] c0 7125 (syz-executor) [<ffffff90084c6824>] do_vfs_ioctl+0x17c/0x1780
> > > > > > 7352 [  681.755514] c0 7125 (syz-executor) [<ffffff90084c7ed4>] SyS_ioctl+0xac/0xc0
> > > > > > 
> > > > > > Wu found it's due to [1]. Before that, unevictable page goes to cull_mlocked
> > > > > > routine so that it couldn't reach the VM_BUG_ON_PAGE line.
> > > > > > 
> > > > > > To fix the issue, this patch filter out unevictable LRU pages
> > > > > > from the reclaim_clean_pages_from_list in CMA.
> > > > > 
> > > > > The changelog is rather modest on details and I have to confess I have
> > > > > little bit hard time to understand it. E.g. why do not we need to handle
> > > > > the regular reclaim path?
> > > > 
> > > > No need to pass unevictable pages into regular reclaim patch if we are
> > > > able to know in advance.
> > > 
> > > I am sorry to be dense here. So what is the difference in the CMA path?
> > > Am I right that the pfn walk (CMA) rather than LRU isolation (reclaim)
> > > is the key differentiator?
> > 
> > Yes.
> > We could isolate unevictable LRU pages from the pfn waker to migrate and
> > could discard clean file-backed pages to reduce migration latency in CMA
> > path.
> 
> Please be explicit about that in the changelog. The fact that this is
> not possible from the regular reclaim path is really important and not
> obvious from the first glance.
> 
> Thanks!

Here it goes:

Andrew, could you replace the patch with the below if Michal doesn't have
any suggestion?

Thanks.

From 5cb8958ea240e2580bd2b331448009e8e1854240 Mon Sep 17 00:00:00 2001
From: Minchan Kim <minchan@kernel.org>
Date: Fri, 24 May 2019 15:54:10 +0900
Subject: [PATCH] mm: fix trying to reclaim unevicable LRU page

There was below bugreport from Wu Fangsuo.

In CMA allocation path, isolate_migratepages_range could isolate unevictable
LRU pages and reclaim_clean_page_from_list can try to reclaim them if
they are clean file-backed pages.

7200 [  680.491097] c4 7125 (syz-executor) page:ffffffbf02f33b40 count:86 mapcount:84 mapping:ffffffc08fa7a810 index:0x24
7201 [  680.531186] c4 7125 (syz-executor) flags: 0x19040c(referenced|uptodate|arch_1|mappedtodisk|unevictable|mlocked)
7202 [  680.544987] c0 7125 (syz-executor) raw: 000000000019040c ffffffc08fa7a810 0000000000000024 0000005600000053
7203 [  680.556162] c0 7125 (syz-executor) raw: ffffffc009b05b20 ffffffc009b05b20 0000000000000000 ffffffc09bf3ee80
7204 [  680.566860] c0 7125 (syz-executor) page dumped because: VM_BUG_ON_PAGE(PageLRU(page) || PageUnevictable(page))
7205 [  680.578038] c0 7125 (syz-executor) page->mem_cgroup:ffffffc09bf3ee80
7206 [  680.585467] c0 7125 (syz-executor) ------------[ cut here ]------------
7207 [  680.592466] c0 7125 (syz-executor) kernel BUG at /home/build/farmland/adroid9.0/kernel/linux/mm/vmscan.c:1350!
7223 [  680.603663] c0 7125 (syz-executor) Internal error: Oops - BUG: 0 [#1] PREEMPT SMP
7224 [  680.611436] c0 7125 (syz-executor) Modules linked in:
7225 [  680.616769] c0 7125 (syz-executor) CPU: 0 PID: 7125 Comm: syz-executor Tainted: G S              4.14.81 #3
7226 [  680.626826] c0 7125 (syz-executor) Hardware name: ASR AQUILAC EVB (DT)
7227 [  680.633623] c0 7125 (syz-executor) task: ffffffc00a54cd00 task.stack: ffffffc009b00000
7228 [  680.641917] c0 7125 (syz-executor) PC is at shrink_page_list+0x1998/0x3240
7229 [  680.649144] c0 7125 (syz-executor) LR is at shrink_page_list+0x1998/0x3240
7230 [  680.656303] c0 7125 (syz-executor) pc : [<ffffff90083a2158>] lr : [<ffffff90083a2158>] pstate: 60400045
7231 [  680.666086] c0 7125 (syz-executor) sp : ffffffc009b05940
..
7342 [  681.671308] c0 7125 (syz-executor) [<ffffff90083a2158>] shrink_page_list+0x1998/0x3240
7343 [  681.679567] c0 7125 (syz-executor) [<ffffff90083a3dc0>] reclaim_clean_pages_from_list+0x3c0/0x4f0
7344 [  681.688793] c0 7125 (syz-executor) [<ffffff900837ed64>] alloc_contig_range+0x3bc/0x650
7347 [  681.717421] c0 7125 (syz-executor) [<ffffff90084925cc>] cma_alloc+0x214/0x668
7348 [  681.724892] c0 7125 (syz-executor) [<ffffff90091e4d78>] ion_cma_allocate+0x98/0x1d8
7349 [  681.732872] c0 7125 (syz-executor) [<ffffff90091e0b20>] ion_alloc+0x200/0x7e0
7350 [  681.740302] c0 7125 (syz-executor) [<ffffff90091e154c>] ion_ioctl+0x18c/0x378
7351 [  681.747738] c0 7125 (syz-executor) [<ffffff90084c6824>] do_vfs_ioctl+0x17c/0x1780
7352 [  681.755514] c0 7125 (syz-executor) [<ffffff90084c7ed4>] SyS_ioctl+0xac/0xc0

Wu found it's due to [1]. Before that, unevictable page goes to cull_mlocked
routine so that it couldn't reach the VM_BUG_ON_PAGE line.

To fix the issue, this patch filter out unevictable LRU pages
from the reclaim_clean_pages_from_list in CMA.

[1] ad6b67041a45, mm: remove SWAP_MLOCK in ttu

Cc: <stable@kernel.org>	[4.12+]
Reported-debugged-by: Wu Fangsuo <fangsuowu@asrmicro.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/vmscan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index d9c3e873eca6..7350afae5c3c 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1505,7 +1505,7 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 
 	list_for_each_entry_safe(page, next, page_list, lru) {
 		if (page_is_file_cache(page) && !PageDirty(page) &&
-		    !__PageMovable(page)) {
+		    !__PageMovable(page) && !PageUnevictable(page)) {
 			ClearPageActive(page);
 			list_move(&page->lru, &clean_pages);
 		}
-- 
2.22.0.rc2.383.gf4fbbf30c2-goog


