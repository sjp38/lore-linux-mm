Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 996AA6B13F0
	for <linux-mm@kvack.org>; Fri,  3 Feb 2012 08:32:36 -0500 (EST)
Received: from 178-85-86-190.dynamic.upc.nl ([178.85.86.190] helo=dyad.programming.kicks-ass.net)
	by casper.infradead.org with esmtpsa (Exim 4.76 #1 (Red Hat Linux))
	id 1RtJFh-0000dV-QM
	for linux-mm@kvack.org; Fri, 03 Feb 2012 13:32:34 +0000
Subject: Re: [PATCH 2/2] mm: make do_writepages() use plugging
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <1328275626-5322-1-git-send-email-amit.sahrawat83@gmail.com>
References: <1328275626-5322-1-git-send-email-amit.sahrawat83@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 03 Feb 2012 14:32:28 +0100
Message-ID: <1328275948.2662.15.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Amit Sahrawat <amit.sahrawat83@gmail.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, Amit Sahrawat <a.sahrawat@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 2012-02-03 at 18:57 +0530, Amit Sahrawat wrote:
> This will cover all the invocations for writepages to be called with
> plugging support.

This changelog fails to explain why this is a good thing... I thought
the idea of the new plugging stuff was that we now don't need to
sprinkle plugs all over the kernel..

> Signed-off-by: Amit Sahrawat <a.sahrawat@samsung.com>
> ---
>  mm/page-writeback.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index 363ba70..2bea32c 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -1866,14 +1866,18 @@ EXPORT_SYMBOL(generic_writepages);
>  
>  int do_writepages(struct address_space *mapping, struct writeback_control *wbc)
>  {
> +	struct blk_plug plug;
>  	int ret;
>  
>  	if (wbc->nr_to_write <= 0)
>  		return 0;
> +
> +	blk_start_plug(&plug);
>  	if (mapping->a_ops->writepages)
>  		ret = mapping->a_ops->writepages(mapping, wbc);
>  	else
>  		ret = generic_writepages(mapping, wbc);
> +	blk_finish_plug(&plug);
>  	return ret;
>  }
>  



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
