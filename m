Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A1DE56B016A
	for <linux-mm@kvack.org>; Mon,  8 Aug 2011 19:32:59 -0400 (EDT)
Date: Tue, 9 Aug 2011 07:32:55 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 4/5] writeback: per task dirty rate limit
Message-ID: <20110808233254.GA15932@localhost>
References: <20110806084447.388624428@intel.com>
 <20110806094527.002914580@intel.com>
 <1312811234.10488.34.camel@twins>
 <20110808142123.GB22080@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110808142123.GB22080@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

> --- linux-next.orig/kernel/fork.c	2011-08-08 22:11:59.000000000 +0800
> +++ linux-next/kernel/fork.c	2011-08-08 22:18:05.000000000 +0800
> @@ -1301,6 +1301,9 @@ static struct task_struct *copy_process(
>  	p->pdeath_signal = 0;
>  	p->exit_state = 0;
>  
> +	p->nr_dirtied = 0;
> +	p->nr_dirtied_pause = 8;

Hmm, it looks better to allow a new task to dirty 128KB without being
throttled, if the system is not in dirty exceeded state. So changed
the last line to this:

+	p->nr_dirtied_pause = 128 >> (PAGE_SHIFT - 10);

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
