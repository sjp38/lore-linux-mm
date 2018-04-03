Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id DCD556B0005
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 08:16:18 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id s23-v6so9606155plr.15
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 05:16:18 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y11si1806527pgo.735.2018.04.03.05.16.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 03 Apr 2018 05:16:18 -0700 (PDT)
Date: Tue, 3 Apr 2018 14:16:14 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v1] kernel/trace:check the val against the available mem
Message-ID: <20180403121614.GV5501@dhcp22.suse.cz>
References: <1522320104-6573-1-git-send-email-zhaoyang.huang@spreadtrum.com>
 <20180330102038.2378925b@gandalf.local.home>
 <20180403110612.GM5501@dhcp22.suse.cz>
 <20180403075158.0c0a2795@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180403075158.0c0a2795@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Zhaoyang Huang <huangzhaoyang@gmail.com>, Ingo Molnar <mingo@kernel.org>, linux-kernel@vger.kernel.org, kernel-patch-test@lists.linaro.org, Andrew Morton <akpm@linux-foundation.org>, Joel Fernandes <joelaf@google.com>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>

On Tue 03-04-18 07:51:58, Steven Rostedt wrote:
> On Tue, 3 Apr 2018 13:06:12 +0200
> Michal Hocko <mhocko@kernel.org> wrote:
> 
> > > I wonder if I should have the ring buffer allocate groups of pages, to
> > > avoid this. Or try to allocate with NORETRY, one page at a time, and
> > > when that fails, allocate groups of pages with RETRY_MAYFAIL, and that
> > > may keep it from causing an OOM?  
> > 
> > I wonder why it really matters. The interface is root only and we expect
> > some sanity from an admin, right? So allocating such a large ring buffer
> > that it sends the system to the OOM is a sign that the admin should be
> > more careful. Balancing on the OOM edge is always a risk and the result
> > will highly depend on the workload running in parallel.
> 
> This came up because there's scripts or programs that set the size of
> the ring buffer. The complaint was that the application would just set
> the size to something bigger than what was available and cause an OOM
> killing other applications. The final solution is to simply check the
> available memory before allocating the ring buffer:
> 
> 	/* Check if the available memory is there first */
> 	i = si_mem_available();
> 	if (i < nr_pages)
> 		return -ENOMEM;
> 
> And it works well.

Except that it doesn't work. si_mem_available is not really suitable for
any allocation estimations. Its only purpose is to provide a very rough
estimation for userspace. Any other use is basically abuse. The
situation can change really quickly. Really it is really hard to be
clever here with the volatility the memory allocations can cause.
-- 
Michal Hocko
SUSE Labs
