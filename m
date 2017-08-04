Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 78FF5280393
	for <linux-mm@kvack.org>; Fri,  4 Aug 2017 14:55:10 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id o65so12240796qkl.12
        for <linux-mm@kvack.org>; Fri, 04 Aug 2017 11:55:10 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t62si2089720qkt.392.2017.08.04.11.55.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Aug 2017 11:55:09 -0700 (PDT)
Message-ID: <1501872906.79618.10.camel@redhat.com>
Subject: Re: [PATCH] mm: ratelimit PFNs busy info message
From: Doug Ledford <dledford@redhat.com>
Date: Fri, 04 Aug 2017 14:55:06 -0400
In-Reply-To: <20170802141720.228502368b534f517e3107ff@linux-foundation.org>
References: 
	<499c0f6cc10d6eb829a67f2a4d75b4228a9b356e.1501695897.git.jtoppins@redhat.com>
	 <20170802141720.228502368b534f517e3107ff@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Jonathan Toppins <jtoppins@redhat.com>
Cc: linux-mm@kvack.org, linux-rdma@vger.kernel.org, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Hillf Danton <hillf.zj@alibaba-inc.com>, open list <linux-kernel@vger.kernel.org>

On Wed, 2017-08-02 at 14:17 -0700, Andrew Morton wrote:
> On Wed,  2 Aug 2017 13:44:57 -0400 Jonathan Toppins <jtoppins@redhat.
> com> wrote:
> 
> > The RDMA subsystem can generate several thousand of these messages
> > per
> > second eventually leading to a kernel crash. Ratelimit these
> > messages
> > to prevent this crash.
> 
> Well...  why are all these EBUSY's occurring?  It sounds inefficient
> (at
> least) but if it is expected, normal and unavoidable then perhaps we
> should just remove that message altogether?

I don't have an answer to that question.  To be honest, I haven't
looked real hard.  We never had this at all, then it started out of the
blue, but only on our Dell 730xd machines (and it hits all of them),
but no other classes or brands of machines.  And we have our 730xd
machines loaded up with different brands and models of cards (for
instance one dedicated to mlx4 hardware, one for qib, one for mlx5, an
ocrdma/cxgb4 combo, etc), so the fact that it hit all of the machines
meant it wasn't tied to any particular brand/model of RDMA hardware. 
To me, it always smelled of a hardware oddity specific to maybe the
CPUs or mainboard chipsets in these machines, so given that I'm not an
mm expert anyway, I never chased it down.

A few other relevant details: it showed up somewhere around 4.8/4.9 or
thereabouts.  It never happened before, but the prinkt has been there
since the 3.18 days, so possibly the test to trigger this message was
changed, or something else in the allocator changed such that the
situation started happening on these machines?

And, like I said, it is specific to our 730xd machines (but they are
all identical, so that could mean it's something like their specific
ram configuration is causing the allocator to hit this on these machine
but not on other machines in the cluster, I don't want to say it's
necessarily the model of chipset or CPU, there are other bits of
identicalness between these machines).

-- 
Doug Ledford <dledford@redhat.com>
    GPG KeyID: B826A3330E572FDD
    Key fingerprint = AE6B 1BDA 122B 23B4 265B  1274 B826 A333 0E57 2FDD

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
