Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 7440F6B005A
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 08:53:58 -0500 (EST)
Date: Mon, 30 Jan 2012 14:53:41 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [RFCv1 0/6] PASR: Partial Array Self-Refresh Framework
Message-ID: <20120130135341.GA3720@elte.hu>
References: <1327930436-10263-1-git-send-email-maxime.coquelin@stericsson.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1327930436-10263-1-git-send-email-maxime.coquelin@stericsson.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Maxime Coquelin <maxime.coquelin@stericsson.com>
Cc: linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Mel Gorman <mel@csn.ul.ie>, Ankita Garg <ankita@in.ibm.com>, linux-kernel@vger.kernel.org, linus.walleij@stericsson.com, andrea.gallo@stericsson.com, vincent.guittot@stericsson.com, philippe.langlais@stericsson.com, loic.pallardy@stericsson.com, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>


* Maxime Coquelin <maxime.coquelin@stericsson.com> wrote:

> The role of this framework is to stop the refresh of unused 
> memory to enhance DDR power consumption.

I'm wondering in what scenarios this is useful, and how 
consistently it is useful.

The primary concern I can see is that on most Linux systems with 
an uptime more than a couple of minutes RAM gets used up by the 
Linux page-cache:

 $ uptime
  14:46:39 up 11 days,  2:04, 19 users,  load average: 0.11, 0.29, 0.80
 $ free
              total       used       free     shared    buffers     cached
 Mem:      12255096   12030152     224944          0     651560    6000452
 -/+ buffers/cache:    5378140    6876956

Even mobile phones easily have days of uptime - quite often 
weeks of uptime. I'd expect the page-cache to fill up RAM on 
such systems.

So how will this actually end up saving power consistently? Does 
it have to be combined with a VM policy that more aggressively 
flushes cached pages from the page-cache?

A secondary concern is fragmentation: right now we fragment 
memory rather significantly. For the Ux500 PASR driver you've 
implemented the section size is 64 MB. Do I interpret the code 
correctly in that a continuous, 64MB physical block of RAM has 
to be 100% free for us to be able to turn off refresh and power 
for this block of RAM?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
