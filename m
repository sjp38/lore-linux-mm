Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 373766B0083
	for <linux-mm@kvack.org>; Thu,  3 May 2012 10:38:21 -0400 (EDT)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [PATCH v2 06/16] block: treat DMPG and SWAPIN requests as special
References: <1336054995-22988-1-git-send-email-svenkatr@ti.com>
	<1336054995-22988-7-git-send-email-svenkatr@ti.com>
Date: Thu, 03 May 2012 10:38:10 -0400
In-Reply-To: <1336054995-22988-7-git-send-email-svenkatr@ti.com> (Venkatraman
	S.'s message of "Thu, 3 May 2012 19:53:05 +0530")
Message-ID: <x49fwbhl48d.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Venkatraman S <svenkatr@ti.com>
Cc: linux-mmc@vger.kernel.org, cjb@laptop.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-omap@vger.kernel.org, linux-kernel@vger.kernel.org, arnd.bergmann@linaro.org, alex.lemberg@sandisk.com, ilan.smith@sandisk.com, lporzio@micron.com, rmk+kernel@arm.linux.org.uk

Venkatraman S <svenkatr@ti.com> writes:

> From: Ilan Smith <ilan.smith@sandisk.com>
>
> When exp_swapin and exp_dmpg are set, treat read requests
> marked with DMPG and SWAPIN as high priority and move to
> the front of the queue.
>
[...]
> +	if (bio_swapin(bio) && blk_queue_exp_swapin(q)) {
> +		spin_lock_irq(q->queue_lock);
> +		where = ELEVATOR_INSERT_FLUSH;
> +		goto get_rq;
> +	}
> +
> +	if (bio_dmpg(bio) && blk_queue_exp_dmpg(q)) {
> +		spin_lock_irq(q->queue_lock);
> +		where = ELEVATOR_INSERT_FLUSH;
> +		goto get_rq;

Is ELEVATOR_INSERT_FRONT not good enough?  It seems wrong to use _FLUSH,
here.  If the semantics of ELEVATOR_INSERT_FLUSH are really what is
required, then perhaps we need to have another think about the naming of
these flags.

Cheers,
Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
