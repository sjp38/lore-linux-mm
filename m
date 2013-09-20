Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id F21546B0034
	for <linux-mm@kvack.org>; Fri, 20 Sep 2013 19:03:03 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id hz10so1262960pad.30
        for <linux-mm@kvack.org>; Fri, 20 Sep 2013 16:03:03 -0700 (PDT)
Received: by mail-qa0-f47.google.com with SMTP id k4so121264qaq.6
        for <linux-mm@kvack.org>; Fri, 20 Sep 2013 16:03:01 -0700 (PDT)
Date: Fri, 20 Sep 2013 18:02:56 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] writeback: fix delayed sync(2)
Message-ID: <20130920230256.GB8763@mtj.dyndns.org>
References: <20130920125029.17356.66782.stgit@dhcp-10-30-17-2.sw.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130920125029.17356.66782.stgit@dhcp-10-30-17-2.sw.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Maxim Patlasov <MPatlasov@parallels.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, fengguang.wu@intel.com, jack@suse.cz, linux-kernel@vger.kernel.org

Hello,

On Fri, Sep 20, 2013 at 04:52:26PM +0400, Maxim Patlasov wrote:
> @@ -294,7 +294,7 @@ void bdi_wakeup_thread_delayed(struct backing_dev_info *bdi)
>  	unsigned long timeout;
>  
>  	timeout = msecs_to_jiffies(dirty_writeback_interval * 10);
> -	mod_delayed_work(bdi_wq, &bdi->wb.dwork, timeout);
> +	queue_delayed_work(bdi_wq, &bdi->wb.dwork, timeout);

Hmmm... this at least requires comment explaining why
mod_delayed_work() doesn't work here.  Also, I wonder whether what we
need is a function which either queues if !pending and shortens timer
if pending.  This is a relatively common pattern and the suggested fix
is subtle and fragile.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
