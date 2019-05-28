Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2974AC072B1
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 15:14:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E357F206C1
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 15:14:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E357F206C1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 83B726B0276; Tue, 28 May 2019 11:14:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7EBF46B0279; Tue, 28 May 2019 11:14:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6DA8B6B027A; Tue, 28 May 2019 11:14:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1DABC6B0276
	for <linux-mm@kvack.org>; Tue, 28 May 2019 11:14:11 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id c26so33517536eda.15
        for <linux-mm@kvack.org>; Tue, 28 May 2019 08:14:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=3BnTUEEbed8NAU4EudqbipVdWhwTZhwgsRylJhd7Uok=;
        b=a6k/8QLrHtOcgn36kJBOkKH/v3ltAkCwB7jwUxtkz+RyduTQJqmOtGCbj5hTk2dZ5K
         vRAzFDfW9ngBcXr/vVTyTmsTOwCpHNuKBEYv5/ZJpTFyNLtXLDv0YMaCqpvaUwtYwCaf
         RKNA6JkXO+N8wfG6gGAbpEPOO56GCfCRkpIOcK299WzfhimrqEASikKt1wEh3XHzrxRL
         2Mx8kysrtDs1Y1y4KFOMYnLShLiXz96LtixAr8BCVYHHkVR1djaYXYONhkwgelFZ5uQQ
         7EuM5IGT/N/pPboq0hci9QmCVTNnQ7d4u4cFqjKN9QeTm3VPICJmbVDKK1OFLEVsr5hr
         serA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXGPRew6Q1E6gmtOLAwnwQXj/OconKwsbd9TeNLqY/U2prGyfbF
	x5lg796qFo7W1472Hsh5IsK9/xR+FXRWRPOrZhpYYNdFYG7Y99/3rj+BjGegE4dkxuMSnz0qceD
	sjc4iw7lbJpkxpoWc+FdRxcf/NeQoe7WXPHv5g0klIE2US0g6Ws+fFFsBYq0MOz0=
X-Received: by 2002:a50:9007:: with SMTP id b7mr129268836eda.194.1559056450648;
        Tue, 28 May 2019 08:14:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqze3ZbHr0PLWJT7LzpsX3E7zO7nbGsofr+rXh2/WCF+yXk8/1V4fOGVDKex7h3A7PGyOHgX
X-Received: by 2002:a50:9007:: with SMTP id b7mr129268704eda.194.1559056449578;
        Tue, 28 May 2019 08:14:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559056449; cv=none;
        d=google.com; s=arc-20160816;
        b=sF6Pp0XmpELXdVGRf4ctVmexPSAZ+QLpfKPtIb9eERnmVGnvUMYQoLTTfKD/e5Vqhr
         FxDMgZP3VfnnAPvpe2F0Ideb2RMGzsS9OsWbuxw5U+FWSJ5UNq8ZcRsgym2oVauIzt4j
         SVtaKBae48XgpxisCAmKV8QUcmriNEySWLprrD9HwkiiJIMgkhWIdeyDKNDmFDQiMiJ0
         ovLAlNfC8LEe+iYW7/lZhAG7cwDJG2rWsQre/zQ08rSw51DLed9FgMwAHBxROCiN1V5F
         hSdhqm0o3HoaXfrxb4y53uzPCBd7Kf9MnY4WALwi5/ojyC1mM+J1jNFEAvBVN5Mjvr66
         mcqA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=3BnTUEEbed8NAU4EudqbipVdWhwTZhwgsRylJhd7Uok=;
        b=ZafJsKtZEp8wd+2yijDqWFSaFHrb0I7xFwKODkLCO6J0aENUBZz9a03lU0s7VNCi0T
         44pEBEoMjSvlBVrr38lgKikun4bWkY/Dom4ZWmDPnoShuiQ16hiGK11AbnIdh0sx52qc
         TLJyn+FOS4b4a3eFdM3h9GDZjPo6ycGjE8uHdRISra5MB6UqQi29FJ5nuUNROWrpN6eQ
         Y/qIXlxagPHL0TWGLloZXdd1Rq7GH9LuQgPYWcfZy1UzoWQvaN0xP0DvSsof74Wp4k9n
         r3mVnX9ZUF+PiCMEHP1yZNO4m/DNrLD8dE68t5qLjz0YkNli/NfofDQ5ig6Tk7VAyNrn
         yCAQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id pg1si9385039ejb.285.2019.05.28.08.14.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 May 2019 08:14:09 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 0FE26ACE8;
	Tue, 28 May 2019 15:14:09 +0000 (UTC)
Date: Tue, 28 May 2019 17:14:07 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	stable@kernel.org, Wu Fangsuo <fangsuowu@asrmicro.com>,
	Pankaj Suryawanshi <pankaj.suryawanshi@einfochips.com>
Subject: Re: [PATCH] mm: fix trying to reclaim unevicable LRU page
Message-ID: <20190528151407.GE1658@dhcp22.suse.cz>
References: <20190524071114.74202-1-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190524071114.74202-1-minchan@kernel.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[Cc Pankaj Suryawanshi who has reported a similar problem
http://lkml.kernel.org/r/SG2PR02MB309806967AE91179CAFEC34BE84B0@SG2PR02MB3098.apcprd02.prod.outlook.com]

On Fri 24-05-19 16:11:14, Minchan Kim wrote:
> There was below bugreport from Wu Fangsuo.
> 
> 7200 [  680.491097] c4 7125 (syz-executor) page:ffffffbf02f33b40 count:86 mapcount:84 mapping:ffffffc08fa7a810 index:0x24
> 7201 [  680.531186] c4 7125 (syz-executor) flags: 0x19040c(referenced|uptodate|arch_1|mappedtodisk|unevictable|mlocked)
> 7202 [  680.544987] c0 7125 (syz-executor) raw: 000000000019040c ffffffc08fa7a810 0000000000000024 0000005600000053
> 7203 [  680.556162] c0 7125 (syz-executor) raw: ffffffc009b05b20 ffffffc009b05b20 0000000000000000 ffffffc09bf3ee80
> 7204 [  680.566860] c0 7125 (syz-executor) page dumped because: VM_BUG_ON_PAGE(PageLRU(page) || PageUnevictable(page))
> 7205 [  680.578038] c0 7125 (syz-executor) page->mem_cgroup:ffffffc09bf3ee80
> 7206 [  680.585467] c0 7125 (syz-executor) ------------[ cut here ]------------
> 7207 [  680.592466] c0 7125 (syz-executor) kernel BUG at /home/build/farmland/adroid9.0/kernel/linux/mm/vmscan.c:1350!
> 7223 [  680.603663] c0 7125 (syz-executor) Internal error: Oops - BUG: 0 [#1] PREEMPT SMP
> 7224 [  680.611436] c0 7125 (syz-executor) Modules linked in:
> 7225 [  680.616769] c0 7125 (syz-executor) CPU: 0 PID: 7125 Comm: syz-executor Tainted: G S              4.14.81 #3
> 7226 [  680.626826] c0 7125 (syz-executor) Hardware name: ASR AQUILAC EVB (DT)
> 7227 [  680.633623] c0 7125 (syz-executor) task: ffffffc00a54cd00 task.stack: ffffffc009b00000
> 7228 [  680.641917] c0 7125 (syz-executor) PC is at shrink_page_list+0x1998/0x3240
> 7229 [  680.649144] c0 7125 (syz-executor) LR is at shrink_page_list+0x1998/0x3240
> 7230 [  680.656303] c0 7125 (syz-executor) pc : [<ffffff90083a2158>] lr : [<ffffff90083a2158>] pstate: 60400045
> 7231 [  680.666086] c0 7125 (syz-executor) sp : ffffffc009b05940
> ..
> 7342 [  681.671308] c0 7125 (syz-executor) [<ffffff90083a2158>] shrink_page_list+0x1998/0x3240
> 7343 [  681.679567] c0 7125 (syz-executor) [<ffffff90083a3dc0>] reclaim_clean_pages_from_list+0x3c0/0x4f0
> 7344 [  681.688793] c0 7125 (syz-executor) [<ffffff900837ed64>] alloc_contig_range+0x3bc/0x650
> 7347 [  681.717421] c0 7125 (syz-executor) [<ffffff90084925cc>] cma_alloc+0x214/0x668
> 7348 [  681.724892] c0 7125 (syz-executor) [<ffffff90091e4d78>] ion_cma_allocate+0x98/0x1d8
> 7349 [  681.732872] c0 7125 (syz-executor) [<ffffff90091e0b20>] ion_alloc+0x200/0x7e0
> 7350 [  681.740302] c0 7125 (syz-executor) [<ffffff90091e154c>] ion_ioctl+0x18c/0x378
> 7351 [  681.747738] c0 7125 (syz-executor) [<ffffff90084c6824>] do_vfs_ioctl+0x17c/0x1780
> 7352 [  681.755514] c0 7125 (syz-executor) [<ffffff90084c7ed4>] SyS_ioctl+0xac/0xc0
> 
> Wu found it's due to [1]. Before that, unevictable page goes to cull_mlocked
> routine so that it couldn't reach the VM_BUG_ON_PAGE line.
> 
> To fix the issue, this patch filter out unevictable LRU pages
> from the reclaim_clean_pages_from_list in CMA.

The changelog is rather modest on details and I have to confess I have
little bit hard time to understand it. E.g. why do not we need to handle
the regular reclaim path?

> [1] ad6b67041a45, mm: remove SWAP_MLOCK in ttu
> 
> Cc: <stable@kernel.org>	[4.12+]
> Reported-debugged-by: Wu Fangsuo <fangsuowu@asrmicro.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  mm/vmscan.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index d9c3e873eca6..7350afae5c3c 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1505,7 +1505,7 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
>  
>  	list_for_each_entry_safe(page, next, page_list, lru) {
>  		if (page_is_file_cache(page) && !PageDirty(page) &&
> -		    !__PageMovable(page)) {
> +		    !__PageMovable(page) && !PageUnevictable(page)) {
>  			ClearPageActive(page);
>  			list_move(&page->lru, &clean_pages);
>  		}
> -- 
> 2.22.0.rc1.257.g3120a18244-goog
> 

-- 
Michal Hocko
SUSE Labs

