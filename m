Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6CA426B0253
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 12:03:34 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 80so206954868pfy.2
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 09:03:34 -0800 (PST)
Received: from mail-pg0-x243.google.com (mail-pg0-x243.google.com. [2607:f8b0:400e:c05::243])
        by mx.google.com with ESMTPS id l4si16203215plk.234.2017.01.23.09.03.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jan 2017 09:03:33 -0800 (PST)
Received: by mail-pg0-x243.google.com with SMTP id t6so14173411pgt.1
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 09:03:33 -0800 (PST)
Date: Mon, 23 Jan 2017 12:03:29 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 3/4] mm, page_alloc: Drain per-cpu pages from workqueue
 context
Message-ID: <20170123170329.GA7820@htj.duckdns.org>
References: <20170117092954.15413-1-mgorman@techsingularity.net>
 <20170117092954.15413-4-mgorman@techsingularity.net>
 <06c39883-eff5-1412-a148-b063aa7bcc5f@suse.cz>
 <20170120152606.w3hb53m2w6thzsqq@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170120152606.w3hb53m2w6thzsqq@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Petr Mladek <pmladek@suse.cz>

Hello,

On Fri, Jan 20, 2017 at 03:26:06PM +0000, Mel Gorman wrote:
> > This translates to queue_work_on(), which has the comment of "We queue
> > the work to a specific CPU, the caller must ensure it can't go away.",
> > so is this safe? lru_add_drain_all() uses get_online_cpus() around this.
> > 
> 
> get_online_cpus() would be required.

This part of workqueue usage has always been a bit clunky and I should
imrpove it but you don't necessarily have to pin the cpus from
queueing to execution.  You can queue without checking whether the CPU
is online and instead synchronize the actual work item execution
against cpu offline callback so that if the work item gets executed
after offline callback is finished, it becomes a noop.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
