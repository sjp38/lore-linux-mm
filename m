Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 34A76C282DD
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 10:39:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E568E206BB
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 10:39:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E568E206BB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 771CA6B0269; Mon, 10 Jun 2019 06:39:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 720E16B026B; Mon, 10 Jun 2019 06:39:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6114A6B026C; Mon, 10 Jun 2019 06:39:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 110296B0269
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 06:39:49 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id s5so14781989eda.10
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 03:39:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=MSVHT84Q0DKfM83aJPcXfzzM+N3D+dAr//0lgcEAk4M=;
        b=qb0TWPxJw79XngvJkdO8fw/g2KMIWF4poyYYxrbeB+nRJID1Du+n4ayzFn/mT20LQX
         DKZCh3loF83XGvAkWdBSwebVT9+axs7K/ZnDmevkMub8mpLLrlI5H5b8m2HRrNdZ3L5G
         B8vHacshPPqNsiLANy4zuE10KuE+yO1YtCLI1IAstIVWPjor6otRSD/NSs4rR1rFRgBL
         vMkJMZW1vnyMEQOh5hNV0jZp3OiQgqOWbuvtO8xfoe1T6ZZCttoiczoVWE6thGHb28yi
         KnsvFhDgEt6aUPS/1Xf12RjuCKfG5r5QFJhCQt3/eGCIlMjayXLour3HINnp5D7X2rPd
         bFrw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAV62LXPvcCkhWQ5eNcnkKgtxcpgavVlqugSUMpeUdaDTGlfdXGb
	nSMEgHjx1cD7jXJH7OconFPqeAHBt9Fda2OVgve5NQOa2EVzdAlrbd5ulG0nXd+hvl0+SWjT0W7
	U2Cf3jCr5Jl6Nw61ASnoVqCOYaTD1X+8qgqj4uINAooG9ZBMea1FqsTUIQrhqrp0=
X-Received: by 2002:a50:9646:: with SMTP id y64mr1267127eda.111.1560163188550;
        Mon, 10 Jun 2019 03:39:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxDfnUB6cugYuOwqcCS484lWXK04K0c5lldy/RkIuD9NkkaEhNUgMXw3KiF5GV6P/oYZaRm
X-Received: by 2002:a50:9646:: with SMTP id y64mr1267058eda.111.1560163187581;
        Mon, 10 Jun 2019 03:39:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560163187; cv=none;
        d=google.com; s=arc-20160816;
        b=0ACFwBpSn/sC8PSvmEylVPj0tgkOxgy/8F2D/uUg0NG4b4dFR1bijNZQHW7Z1C9tfv
         Slzch8y4jsDnjRLtO5PzyHmXnWCqWshU2gwJZS0UDzL03DxZGhE5c6j94gEPEvfI1pWX
         vHuY3Yrl8M+RaIDbHzJuPLKRTaMa6dDoZD8ciOtgJm3o3t3nipv1YMFEDoFgJbSd+3pX
         PCxs1T/tF0Le7HVyYXbVUC0eb7AmM/NyHxop7RPY2xeIUra40sv1GV7tIyPD2GCxUW9j
         IPwEhd1jrBkGOaGToiKVtGRnix7qw5V9iGen30HkZeJxdBcOhiWaXF5svWuUepMK5yVH
         w3uA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=MSVHT84Q0DKfM83aJPcXfzzM+N3D+dAr//0lgcEAk4M=;
        b=VPYbdljQjRqIMLN5Tw7YEPDQ4P2xh5c1VoUEo8Pe9lDvMT0auz3JEWNlrbyoswId0N
         lWvuAKE/f40WBa7nk11AyGLjWK1YnJj21aXwxUm/KnDcs29JV6d3KJVBVayJVe3fg5oM
         RUtT5IexzKE3wFf5QnRrQfADlaebds4X490TBiKc69nZqYZROSsj0lN6iMhpb3AvA42+
         Xqlrtwy5j5/u+0kBhfPHT+q/gbtEdozJ6/uzsc5wlp27LDv+wfy8dzOeElFKY8KQdgbk
         2D8YEu6HiSyBiF7Vb4j6H/wNQAt75dwW2xw8ng29APZmJb74VSpnr7gD5ba7lSOP2QhM
         OTXA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k58si5303776ede.417.2019.06.10.03.39.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 03:39:47 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id DA37DAFAB;
	Mon, 10 Jun 2019 10:39:46 +0000 (UTC)
Date: Mon, 10 Jun 2019 12:39:46 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	stable@kernel.org, Wu Fangsuo <fangsuowu@asrmicro.com>,
	Pankaj Suryawanshi <pankaj.suryawanshi@einfochips.com>
Subject: Re: [PATCH] mm: fix trying to reclaim unevicable LRU page
Message-ID: <20190610103946.GE30967@dhcp22.suse.cz>
References: <20190524071114.74202-1-minchan@kernel.org>
 <20190528151407.GE1658@dhcp22.suse.cz>
 <20190530024229.GF229459@google.com>
 <20190604122806.GH4669@dhcp22.suse.cz>
 <20190610094222.GA55602@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190610094222.GA55602@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 10-06-19 18:42:22, Minchan Kim wrote:
> On Tue, Jun 04, 2019 at 02:28:06PM +0200, Michal Hocko wrote:
> > On Thu 30-05-19 11:42:29, Minchan Kim wrote:
> > > On Tue, May 28, 2019 at 05:14:07PM +0200, Michal Hocko wrote:
> > > > [Cc Pankaj Suryawanshi who has reported a similar problem
> > > > http://lkml.kernel.org/r/SG2PR02MB309806967AE91179CAFEC34BE84B0@SG2PR02MB3098.apcprd02.prod.outlook.com]
> > > > 
> > > > On Fri 24-05-19 16:11:14, Minchan Kim wrote:
> > > > > There was below bugreport from Wu Fangsuo.
> > > > > 
> > > > > 7200 [  680.491097] c4 7125 (syz-executor) page:ffffffbf02f33b40 count:86 mapcount:84 mapping:ffffffc08fa7a810 index:0x24
> > > > > 7201 [  680.531186] c4 7125 (syz-executor) flags: 0x19040c(referenced|uptodate|arch_1|mappedtodisk|unevictable|mlocked)
> > > > > 7202 [  680.544987] c0 7125 (syz-executor) raw: 000000000019040c ffffffc08fa7a810 0000000000000024 0000005600000053
> > > > > 7203 [  680.556162] c0 7125 (syz-executor) raw: ffffffc009b05b20 ffffffc009b05b20 0000000000000000 ffffffc09bf3ee80
> > > > > 7204 [  680.566860] c0 7125 (syz-executor) page dumped because: VM_BUG_ON_PAGE(PageLRU(page) || PageUnevictable(page))
> > > > > 7205 [  680.578038] c0 7125 (syz-executor) page->mem_cgroup:ffffffc09bf3ee80
> > > > > 7206 [  680.585467] c0 7125 (syz-executor) ------------[ cut here ]------------
> > > > > 7207 [  680.592466] c0 7125 (syz-executor) kernel BUG at /home/build/farmland/adroid9.0/kernel/linux/mm/vmscan.c:1350!
> > > > > 7223 [  680.603663] c0 7125 (syz-executor) Internal error: Oops - BUG: 0 [#1] PREEMPT SMP
> > > > > 7224 [  680.611436] c0 7125 (syz-executor) Modules linked in:
> > > > > 7225 [  680.616769] c0 7125 (syz-executor) CPU: 0 PID: 7125 Comm: syz-executor Tainted: G S              4.14.81 #3
> > > > > 7226 [  680.626826] c0 7125 (syz-executor) Hardware name: ASR AQUILAC EVB (DT)
> > > > > 7227 [  680.633623] c0 7125 (syz-executor) task: ffffffc00a54cd00 task.stack: ffffffc009b00000
> > > > > 7228 [  680.641917] c0 7125 (syz-executor) PC is at shrink_page_list+0x1998/0x3240
> > > > > 7229 [  680.649144] c0 7125 (syz-executor) LR is at shrink_page_list+0x1998/0x3240
> > > > > 7230 [  680.656303] c0 7125 (syz-executor) pc : [<ffffff90083a2158>] lr : [<ffffff90083a2158>] pstate: 60400045
> > > > > 7231 [  680.666086] c0 7125 (syz-executor) sp : ffffffc009b05940
> > > > > ..
> > > > > 7342 [  681.671308] c0 7125 (syz-executor) [<ffffff90083a2158>] shrink_page_list+0x1998/0x3240
> > > > > 7343 [  681.679567] c0 7125 (syz-executor) [<ffffff90083a3dc0>] reclaim_clean_pages_from_list+0x3c0/0x4f0
> > > > > 7344 [  681.688793] c0 7125 (syz-executor) [<ffffff900837ed64>] alloc_contig_range+0x3bc/0x650
> > > > > 7347 [  681.717421] c0 7125 (syz-executor) [<ffffff90084925cc>] cma_alloc+0x214/0x668
> > > > > 7348 [  681.724892] c0 7125 (syz-executor) [<ffffff90091e4d78>] ion_cma_allocate+0x98/0x1d8
> > > > > 7349 [  681.732872] c0 7125 (syz-executor) [<ffffff90091e0b20>] ion_alloc+0x200/0x7e0
> > > > > 7350 [  681.740302] c0 7125 (syz-executor) [<ffffff90091e154c>] ion_ioctl+0x18c/0x378
> > > > > 7351 [  681.747738] c0 7125 (syz-executor) [<ffffff90084c6824>] do_vfs_ioctl+0x17c/0x1780
> > > > > 7352 [  681.755514] c0 7125 (syz-executor) [<ffffff90084c7ed4>] SyS_ioctl+0xac/0xc0
> > > > > 
> > > > > Wu found it's due to [1]. Before that, unevictable page goes to cull_mlocked
> > > > > routine so that it couldn't reach the VM_BUG_ON_PAGE line.
> > > > > 
> > > > > To fix the issue, this patch filter out unevictable LRU pages
> > > > > from the reclaim_clean_pages_from_list in CMA.
> > > > 
> > > > The changelog is rather modest on details and I have to confess I have
> > > > little bit hard time to understand it. E.g. why do not we need to handle
> > > > the regular reclaim path?
> > > 
> > > No need to pass unevictable pages into regular reclaim patch if we are
> > > able to know in advance.
> > 
> > I am sorry to be dense here. So what is the difference in the CMA path?
> > Am I right that the pfn walk (CMA) rather than LRU isolation (reclaim)
> > is the key differentiator?
> 
> Yes.
> We could isolate unevictable LRU pages from the pfn waker to migrate and
> could discard clean file-backed pages to reduce migration latency in CMA
> path.

Please be explicit about that in the changelog. The fact that this is
not possible from the regular reclaim path is really important and not
obvious from the first glance.

Thanks!

-- 
Michal Hocko
SUSE Labs

