Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id D56436B025F
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 02:58:22 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 185so12267234wmk.12
        for <linux-mm@kvack.org>; Sun, 06 Aug 2017 23:58:22 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 191si7079533wmv.152.2017.08.06.23.58.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 06 Aug 2017 23:58:21 -0700 (PDT)
Date: Mon, 7 Aug 2017 08:58:19 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: ratelimit PFNs busy info message
Message-ID: <20170807065819.GB32434@dhcp22.suse.cz>
References: <499c0f6cc10d6eb829a67f2a4d75b4228a9b356e.1501695897.git.jtoppins@redhat.com>
 <20170802141720.228502368b534f517e3107ff@linux-foundation.org>
 <1501872906.79618.10.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1501872906.79618.10.camel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Doug Ledford <dledford@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jonathan Toppins <jtoppins@redhat.com>, linux-mm@kvack.org, linux-rdma@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Hillf Danton <hillf.zj@alibaba-inc.com>, open list <linux-kernel@vger.kernel.org>

On Fri 04-08-17 14:55:06, Doug Ledford wrote:
> On Wed, 2017-08-02 at 14:17 -0700, Andrew Morton wrote:
> > On Wed,  2 Aug 2017 13:44:57 -0400 Jonathan Toppins <jtoppins@redhat.
> > com> wrote:
> > 
> > > The RDMA subsystem can generate several thousand of these messages
> > > per
> > > second eventually leading to a kernel crash. Ratelimit these
> > > messages
> > > to prevent this crash.
> > 
> > Well...  why are all these EBUSY's occurring?  It sounds inefficient
> > (at
> > least) but if it is expected, normal and unavoidable then perhaps we
> > should just remove that message altogether?
> 
> I don't have an answer to that question.  To be honest, I haven't
> looked real hard.  We never had this at all, then it started out of the
> blue, but only on our Dell 730xd machines (and it hits all of them),
> but no other classes or brands of machines.  And we have our 730xd
> machines loaded up with different brands and models of cards (for
> instance one dedicated to mlx4 hardware, one for qib, one for mlx5, an
> ocrdma/cxgb4 combo, etc), so the fact that it hit all of the machines
> meant it wasn't tied to any particular brand/model of RDMA hardware. 
> To me, it always smelled of a hardware oddity specific to maybe the
> CPUs or mainboard chipsets in these machines, so given that I'm not an
> mm expert anyway, I never chased it down.

It would certainly be good to chase this down. I do not object to
ratelimiting, it is much better than having a non-bootable system but
this doesn't solve the underlying problem.
 
> A few other relevant details: it showed up somewhere around 4.8/4.9 or
> thereabouts.  It never happened before, but the prinkt has been there
> since the 3.18 days, so possibly the test to trigger this message was
> changed, or something else in the allocator changed such that the
> situation started happening on these machines?

Is this still the case with the current Linus tree? We have had a fix
424f6c4818bb ("mm: alloc_contig: re-allow CMA to compact FS pages")
which made it into 4.10
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
