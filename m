Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 442536B0105
	for <linux-mm@kvack.org>; Wed,  9 May 2012 04:35:01 -0400 (EDT)
Message-ID: <3f7a217a08fd2c508576cbac8d26b017.squirrel@www.codeaurora.org>
In-Reply-To: <1336054995-22988-15-git-send-email-svenkatr@ti.com>
References: <1336054995-22988-1-git-send-email-svenkatr@ti.com>
    <1336054995-22988-15-git-send-email-svenkatr@ti.com>
Date: Wed, 9 May 2012 01:35:00 -0700 (PDT)
Subject: Re: [PATCH v2 14/16] mmc: block: Implement HPI invocation and
     handling logic.
From: kdorfman@codeaurora.org
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Venkatraman S <svenkatr@ti.com>
Cc: linux-mmc@vger.kernel.org, cjb@laptop.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-omap@vger.kernel.org, linux-kernel@vger.kernel.org, arnd.bergmann@linaro.org, alex.lemberg@sandisk.com, ilan.smith@sandisk.com, lporzio@micron.com, rmk+kernel@arm.linux.org.uk


> +static bool mmc_can_do_foreground_hpi(struct mmc_queue *mq,
> +			struct request *req, unsigned int thpi)
> +{
> +
> +	/*
> +	 * If some time has elapsed since the issuing of previous write
> +	 * command, or if the size of the request was too small, there's
> +	 * no point in preempting it. Check if it's worthwhile to preempt
> +	 */
> +	int time_elapsed = jiffies_to_msecs(jiffies -
> +			mq->mqrq_cur->mmc_active.mrq->cmd->started_time);
> +
> +	if (time_elapsed <= thpi)
> +			return true;
Some host controllers (or DMA) has possibility to get the byte count of
current transaction. It may be implemented as host api (similar to abort
ops). Then you have more accurate estimation of worthiness.

> +
> +	return false;
> +}

Thanks, Kostya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
