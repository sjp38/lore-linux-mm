Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id D40CB6B038A
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 10:26:38 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id v66so45587995wrc.4
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 07:26:38 -0700 (PDT)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id z46si836204wrz.204.2017.03.13.07.26.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 13 Mar 2017 07:26:37 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id 3E6FE98D7C
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 14:26:37 +0000 (UTC)
Date: Mon, 13 Mar 2017 14:26:36 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm, page_alloc: fix the duplicate save/ressave irq
Message-ID: <20170313142636.ghschfm2sff7j7oh@techsingularity.net>
References: <1489392174-11794-1-git-send-email-zhongjiang@huawei.com>
 <20170313111947.rdydbpblymc6a73x@techsingularity.net>
 <58C6A5C5.9070301@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <58C6A5C5.9070301@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, linux-mm@kvack.org

On Mon, Mar 13, 2017 at 09:59:33PM +0800, zhong jiang wrote:
> On 2017/3/13 19:19, Mel Gorman wrote:
> > On Mon, Mar 13, 2017 at 04:02:54PM +0800, zhongjiang wrote:
> >> From: zhong jiang <zhongjiang@huawei.com>
> >>
> >> when commit 374ad05ab64d ("mm, page_alloc: only use per-cpu allocator for irq-safe requests")
> >> introduced to the mainline, free_pcppages_bulk irq_save/resave to protect
> >> the IRQ context. but drain_pages_zone fails to clear away the irq. because
> >> preempt_disable have take effect. so it safely remove the code.
> >>
> >> Fixes: 374ad05ab64d ("mm, page_alloc: only use per-cpu allocator for irq-safe requests")
> >> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
> > It's not really a fix but is this even measurable?
> >
> > The reason the IRQ saving was preserved was for callers that are removing
> > the CPU where it's not 100% clear if the CPU is protected from IPIs at
> > the time the pcpu drain takes place. It may be ok but the changelog
> > should include an indication that it has been considered and is known to
> > be fine versus CPU hotplug.
> >
> you mean the removing cpu maybe  handle the IRQ, it will result in the incorrect pcpu->count ?
> 

Yes, if it hasn't had interrupts disabled yet at the time of the drain.
I didn't check, it probably is called from a context that disables
interrupts but the fact you're not sure makes me automatically wary of
the patch particularly given how little difference it makes for the common
case where direct reclaim failed triggering a drain.

> but I don't sure that dying cpu remain handle the IRQ.
> 

You'd need to be certain to justify the patch.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
