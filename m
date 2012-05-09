Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 2E66E6B00F9
	for <linux-mm@kvack.org>; Wed,  9 May 2012 10:01:15 -0400 (EDT)
From: Arnd Bergmann <arnd.bergmann@linaro.org>
Subject: Re: [PATCH v2 14/16] mmc: block: Implement HPI invocation and handling logic.
Date: Wed, 9 May 2012 14:01:11 +0000
References: <1336054995-22988-1-git-send-email-svenkatr@ti.com> <1336054995-22988-15-git-send-email-svenkatr@ti.com> <3f7a217a08fd2c508576cbac8d26b017.squirrel@www.codeaurora.org>
In-Reply-To: <3f7a217a08fd2c508576cbac8d26b017.squirrel@www.codeaurora.org>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201205091401.11894.arnd.bergmann@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kdorfman@codeaurora.org
Cc: Venkatraman S <svenkatr@ti.com>, linux-mmc@vger.kernel.org, cjb@laptop.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-omap@vger.kernel.org, linux-kernel@vger.kernel.org, alex.lemberg@sandisk.com, ilan.smith@sandisk.com, lporzio@micron.com, rmk+kernel@arm.linux.org.uk

On Wednesday 09 May 2012, kdorfman@codeaurora.org wrote:
> > +static bool mmc_can_do_foreground_hpi(struct mmc_queue *mq,
> > +                     struct request *req, unsigned int thpi)
> > +{
> > +
> > +     /*
> > +      * If some time has elapsed since the issuing of previous write
> > +      * command, or if the size of the request was too small, there's
> > +      * no point in preempting it. Check if it's worthwhile to preempt
> > +      */
> > +     int time_elapsed = jiffies_to_msecs(jiffies -
> > +                     mq->mqrq_cur->mmc_active.mrq->cmd->started_time);
> > +
> > +     if (time_elapsed <= thpi)
> > +                     return true;
> Some host controllers (or DMA) has possibility to get the byte count of
> current transaction. It may be implemented as host api (similar to abort
> ops). Then you have more accurate estimation of worthiness.

I'm rather sure that the byte count is not relevant here: it's not
the actual write that is taking so long, it's the garbage collection
that the device does internally before the write actually gets done.
The data transfer is much faster than the time we are waiting for here.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
