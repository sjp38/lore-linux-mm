Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 154C4C282CE
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 12:28:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C73FF23E30
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 12:28:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C73FF23E30
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6CE3E6B0010; Tue,  4 Jun 2019 08:28:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 67F086B026C; Tue,  4 Jun 2019 08:28:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 594E36B026E; Tue,  4 Jun 2019 08:28:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0B4A56B0010
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 08:28:10 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b33so196385edc.17
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 05:28:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=lepDYsUvaXnDt0f0nz6PlpvAApyLcKLeXdJQcJ2aQ24=;
        b=NoULra05e9+uXOKD3k345eJ84pNU3+zZKg+DIG0z7OS2vGOzJGvWaiKHzB7NC0EZOR
         szGt1aEUFxp191VOE/rqcyFpDeO+QesAELJX10vKuXvwkahQndde/ecEqcGCJpzKdrXG
         zx9uW4aojK3rx+uUCG7Vlt7qwYbUK+MLJL2aNr8RgXsh6XK1Xv8BUx7dzvZAqk00N+WS
         nt3hRSQ22oYxv33/LuN6yItXWM3YvmLB3rTg3zeX+ZJkS+NFGP73NnGk0YWeGZeYHmzU
         hyOVoQVGsEiN8ZiMMlaVk6efMiLRTxpXDlr29Lk36+IrjQb2WURwi2jvtpbPkpGYHiXr
         s83Q==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVBoA4Lr7oZOIU4YJ7QdVLtlLvZhuyToB6sRb/9P3d9vd6808/5
	J0ERezRwsO7uzb46lM6Obs1VL/RSqdfjm836VaUnW95YeFjvbHD5eEhE5ckQkj0aYwarr9M+1eD
	oCKgGfAs4yvsxCMcB8kMLAg4CTgf+epVRpV0+YfqcgA6aJUBYjuETdTLFNN9wM9M=
X-Received: by 2002:a50:b104:: with SMTP id k4mr10349428edd.75.1559651289601;
        Tue, 04 Jun 2019 05:28:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyB2EfnWh8kF+oYlK2Ln+40gkVjpF0d5ahnamWrpAKHoyzd84NCFIPpkdRrJ2WsP+h2YT5+
X-Received: by 2002:a50:b104:: with SMTP id k4mr10349343edd.75.1559651288545;
        Tue, 04 Jun 2019 05:28:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559651288; cv=none;
        d=google.com; s=arc-20160816;
        b=GRgCieGTVYOnzIoq2pNpVJAkPNnGLEEwbphKBRzyfVwDMBBP1iJvNXdhPI+5ZJ1bat
         4Ov9ZF3AVojjMnGsuUz6PvfAOQbVTHxZk46gxdABD107MB/7Iy8TOoe1mHotyVKaN6+g
         1oRGJTIekcpiOkulenb/Dj4497eYR/Jo5a654Ozbvafs+JHVJPIY2FNhL+Udf1gZpZe/
         1PhrblYTdng/UY3+DfiUaKAZusLIEOnd77wcP3qj8NO4vZY16fVNGP7NyUYgkbXxj1fL
         gG+nfMoHCOlV+uw1DI1srfXoSOo/QV91g7wCMpSD+sXxz8Z/SHR4sKoeYpDEKhViQSLe
         SeWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=lepDYsUvaXnDt0f0nz6PlpvAApyLcKLeXdJQcJ2aQ24=;
        b=qhv9W67UR96Qt9x1dlygoZEBbOayUYuaeX8VegeLzZD6M9npYBPejVT704VsTyUEXO
         w5zh9A2Ebpq93LEQyb1FzUYqlApWfmRRAoKy0vSVLxN+XZdxJXLAvfFh12zzFf7yAfaS
         tjHIgX632pYOsQrpX3WNtxFE9kdlcgpl8/msb3yNrCP2gx+sFiBWeV9rcPDOKQ4uZg4H
         Fl7fVhjh6E8hqnjIfRWeaxcV0vMiTZM5a+8bib+OTj+e4DgbQe3S96LRua6zvYUk9TBr
         HwnYmYEwpXNk5foWZNekjfdJz/3tPh6e2yvP2NY/R7KQ5XafX+R7GLoVZxewy/7lfiTI
         yNvg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m16si6623891ejd.347.2019.06.04.05.28.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jun 2019 05:28:08 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 042C8AFBE;
	Tue,  4 Jun 2019 12:28:07 +0000 (UTC)
Date: Tue, 4 Jun 2019 14:28:06 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	stable@kernel.org, Wu Fangsuo <fangsuowu@asrmicro.com>,
	Pankaj Suryawanshi <pankaj.suryawanshi@einfochips.com>
Subject: Re: [PATCH] mm: fix trying to reclaim unevicable LRU page
Message-ID: <20190604122806.GH4669@dhcp22.suse.cz>
References: <20190524071114.74202-1-minchan@kernel.org>
 <20190528151407.GE1658@dhcp22.suse.cz>
 <20190530024229.GF229459@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190530024229.GF229459@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 30-05-19 11:42:29, Minchan Kim wrote:
> On Tue, May 28, 2019 at 05:14:07PM +0200, Michal Hocko wrote:
> > [Cc Pankaj Suryawanshi who has reported a similar problem
> > http://lkml.kernel.org/r/SG2PR02MB309806967AE91179CAFEC34BE84B0@SG2PR02MB3098.apcprd02.prod.outlook.com]
> > 
> > On Fri 24-05-19 16:11:14, Minchan Kim wrote:
> > > There was below bugreport from Wu Fangsuo.
> > > 
> > > 7200 [  680.491097] c4 7125 (syz-executor) page:ffffffbf02f33b40 count:86 mapcount:84 mapping:ffffffc08fa7a810 index:0x24
> > > 7201 [  680.531186] c4 7125 (syz-executor) flags: 0x19040c(referenced|uptodate|arch_1|mappedtodisk|unevictable|mlocked)
> > > 7202 [  680.544987] c0 7125 (syz-executor) raw: 000000000019040c ffffffc08fa7a810 0000000000000024 0000005600000053
> > > 7203 [  680.556162] c0 7125 (syz-executor) raw: ffffffc009b05b20 ffffffc009b05b20 0000000000000000 ffffffc09bf3ee80
> > > 7204 [  680.566860] c0 7125 (syz-executor) page dumped because: VM_BUG_ON_PAGE(PageLRU(page) || PageUnevictable(page))
> > > 7205 [  680.578038] c0 7125 (syz-executor) page->mem_cgroup:ffffffc09bf3ee80
> > > 7206 [  680.585467] c0 7125 (syz-executor) ------------[ cut here ]------------
> > > 7207 [  680.592466] c0 7125 (syz-executor) kernel BUG at /home/build/farmland/adroid9.0/kernel/linux/mm/vmscan.c:1350!
> > > 7223 [  680.603663] c0 7125 (syz-executor) Internal error: Oops - BUG: 0 [#1] PREEMPT SMP
> > > 7224 [  680.611436] c0 7125 (syz-executor) Modules linked in:
> > > 7225 [  680.616769] c0 7125 (syz-executor) CPU: 0 PID: 7125 Comm: syz-executor Tainted: G S              4.14.81 #3
> > > 7226 [  680.626826] c0 7125 (syz-executor) Hardware name: ASR AQUILAC EVB (DT)
> > > 7227 [  680.633623] c0 7125 (syz-executor) task: ffffffc00a54cd00 task.stack: ffffffc009b00000
> > > 7228 [  680.641917] c0 7125 (syz-executor) PC is at shrink_page_list+0x1998/0x3240
> > > 7229 [  680.649144] c0 7125 (syz-executor) LR is at shrink_page_list+0x1998/0x3240
> > > 7230 [  680.656303] c0 7125 (syz-executor) pc : [<ffffff90083a2158>] lr : [<ffffff90083a2158>] pstate: 60400045
> > > 7231 [  680.666086] c0 7125 (syz-executor) sp : ffffffc009b05940
> > > ..
> > > 7342 [  681.671308] c0 7125 (syz-executor) [<ffffff90083a2158>] shrink_page_list+0x1998/0x3240
> > > 7343 [  681.679567] c0 7125 (syz-executor) [<ffffff90083a3dc0>] reclaim_clean_pages_from_list+0x3c0/0x4f0
> > > 7344 [  681.688793] c0 7125 (syz-executor) [<ffffff900837ed64>] alloc_contig_range+0x3bc/0x650
> > > 7347 [  681.717421] c0 7125 (syz-executor) [<ffffff90084925cc>] cma_alloc+0x214/0x668
> > > 7348 [  681.724892] c0 7125 (syz-executor) [<ffffff90091e4d78>] ion_cma_allocate+0x98/0x1d8
> > > 7349 [  681.732872] c0 7125 (syz-executor) [<ffffff90091e0b20>] ion_alloc+0x200/0x7e0
> > > 7350 [  681.740302] c0 7125 (syz-executor) [<ffffff90091e154c>] ion_ioctl+0x18c/0x378
> > > 7351 [  681.747738] c0 7125 (syz-executor) [<ffffff90084c6824>] do_vfs_ioctl+0x17c/0x1780
> > > 7352 [  681.755514] c0 7125 (syz-executor) [<ffffff90084c7ed4>] SyS_ioctl+0xac/0xc0
> > > 
> > > Wu found it's due to [1]. Before that, unevictable page goes to cull_mlocked
> > > routine so that it couldn't reach the VM_BUG_ON_PAGE line.
> > > 
> > > To fix the issue, this patch filter out unevictable LRU pages
> > > from the reclaim_clean_pages_from_list in CMA.
> > 
> > The changelog is rather modest on details and I have to confess I have
> > little bit hard time to understand it. E.g. why do not we need to handle
> > the regular reclaim path?
> 
> No need to pass unevictable pages into regular reclaim patch if we are
> able to know in advance.

I am sorry to be dense here. So what is the difference in the CMA path?
Am I right that the pfn walk (CMA) rather than LRU isolation (reclaim)
is the key differentiator?

-- 
Michal Hocko
SUSE Labs

