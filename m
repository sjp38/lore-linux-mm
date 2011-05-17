Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id E06666B0027
	for <linux-mm@kvack.org>; Tue, 17 May 2011 17:27:50 -0400 (EDT)
Date: Tue, 17 May 2011 23:27:34 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 1/3] comm: Introduce comm_lock spinlock to protect
 task->comm access
Message-ID: <20110517212734.GB28054@elte.hu>
References: <1305665263-20933-1-git-send-email-john.stultz@linaro.org>
 <1305665263-20933-2-git-send-email-john.stultz@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1305665263-20933-2-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Joe Perches <joe@perches.com>, Michal Nazarewicz <mina86@mina86.com>, Andy Whitcroft <apw@canonical.com>, Jiri Slaby <jirislaby@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>


* John Stultz <john.stultz@linaro.org> wrote:

> The implicit rules for current->comm access being safe without locking are no 
> longer true. Accessing current->comm without holding the task lock may result 
> in null or incomplete strings (however, access won't run off the end of the 
> string).

This is rather unfortunate - task->comm is used in a number of performance 
critical codepaths such as tracing.

Why does this matter so much? A NULL string is not a big deal.

Note, since task->comm is 16 bytes there's the CMPXCHG16B instruction on x86 
which could be used to update it atomically, should atomicity really be 
desired.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
