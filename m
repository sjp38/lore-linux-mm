Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7F86B6B0033
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 15:04:15 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id c7so28618713wjb.7
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 12:04:15 -0800 (PST)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id x5si15445551wmg.133.2017.01.23.12.04.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 23 Jan 2017 12:04:14 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id 9CB0698B9A
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 20:04:13 +0000 (UTC)
Date: Mon, 23 Jan 2017 20:04:12 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 3/4] mm, page_alloc: Drain per-cpu pages from workqueue
 context
Message-ID: <20170123200412.mkesardc4mckk6df@techsingularity.net>
References: <20170117092954.15413-1-mgorman@techsingularity.net>
 <20170117092954.15413-4-mgorman@techsingularity.net>
 <06c39883-eff5-1412-a148-b063aa7bcc5f@suse.cz>
 <20170120152606.w3hb53m2w6thzsqq@techsingularity.net>
 <20170123170329.GA7820@htj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170123170329.GA7820@htj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Petr Mladek <pmladek@suse.cz>

On Mon, Jan 23, 2017 at 12:03:29PM -0500, Tejun Heo wrote:
> Hello,
> 
> On Fri, Jan 20, 2017 at 03:26:06PM +0000, Mel Gorman wrote:
> > > This translates to queue_work_on(), which has the comment of "We queue
> > > the work to a specific CPU, the caller must ensure it can't go away.",
> > > so is this safe? lru_add_drain_all() uses get_online_cpus() around this.
> > > 
> > 
> > get_online_cpus() would be required.
> 
> This part of workqueue usage has always been a bit clunky and I should
> imrpove it but you don't necessarily have to pin the cpus from
> queueing to execution.  You can queue without checking whether the CPU
> is online and instead synchronize the actual work item execution
> against cpu offline callback so that if the work item gets executed
> after offline callback is finished, it becomes a noop.
> 

What is the actual mechanism that does that? It's not something that
schedule_on_each_cpu does and one would expect that the core workqueue
implementation would get this sort of detail correct. Or is this a proposal
on how it should be done?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
