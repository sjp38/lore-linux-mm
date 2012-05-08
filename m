Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 292186B00FA
	for <linux-mm@kvack.org>; Tue,  8 May 2012 03:46:42 -0400 (EDT)
Message-ID: <4FA8CF5E.1070202@kernel.org>
Date: Tue, 08 May 2012 16:46:38 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCHv2 00/16] [FS, MM, block, MMC]: eMMC High Priority Interrupt
 Feature
References: <1336054995-22988-1-git-send-email-svenkatr@ti.com>
In-Reply-To: <1336054995-22988-1-git-send-email-svenkatr@ti.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Venkatraman S <svenkatr@ti.com>
Cc: linux-mmc@vger.kernel.org, cjb@laptop.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-omap@vger.kernel.org, linux-kernel@vger.kernel.org, arnd.bergmann@linaro.org, alex.lemberg@sandisk.com, ilan.smith@sandisk.com, lporzio@micron.com, rmk+kernel@arm.linux.org.uk

On 05/03/2012 11:22 PM, Venkatraman S wrote:

> Standard eMMC (Embedded MultiMedia Card) specification expects to execute
> one request at a time. If some requests are more important than others, they
> can't be aborted while the flash procedure is in progress.
> 
> New versions of the eMMC standard (4.41 and above) specfies a feature 
> called High Priority Interrupt (HPI). This enables an ongoing transaction
> to be aborted using a special command (HPI command) so that the card is ready
> to receive new commands immediately. Then the new request can be submitted
> to the card, and optionally the interrupted command can be resumed again.
> 
> Some restrictions exist on when and how the command can be used. For example,
> only write and write-like commands (ERASE) can be preempted, and the urgent
> request must be a read.
> 
> In order to support this in software,
> a) At the top level, some policy decisions have to be made on what is
> worth preempting for.
> 	This implementation uses the demand paging requests and swap
> read requests as potential reads worth preempting an ongoing long write.
> 	This is expected to provide improved responsiveness for smarphones
> with multitasking capabilities - example would be launch a email application
> while a video capture session (which causes long writes) is ongoing.


Do you have a number to prove it's really big effective?

What I have a concern is when we got low memory situation.
Then, writing speed for page reclaim is important for response.
If we allow read preempt write and write is delay, it means read path takes longer time to
get a empty buffer pages in reclaim. In such case, it couldn't be good.


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
