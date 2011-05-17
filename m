Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0E72F6B0027
	for <linux-mm@kvack.org>; Tue, 17 May 2011 18:27:19 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e37.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p4HMOLfd010137
	for <linux-mm@kvack.org>; Tue, 17 May 2011 16:24:21 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id p4HMRC1e128618
	for <linux-mm@kvack.org>; Tue, 17 May 2011 16:27:12 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4HGQhva013335
	for <linux-mm@kvack.org>; Tue, 17 May 2011 10:26:44 -0600
Subject: Re: [PATCH 1/3] comm: Introduce comm_lock spinlock to protect
 task->comm access
From: John Stultz <john.stultz@linaro.org>
In-Reply-To: <20110517212734.GB28054@elte.hu>
References: <1305665263-20933-1-git-send-email-john.stultz@linaro.org>
	 <1305665263-20933-2-git-send-email-john.stultz@linaro.org>
	 <20110517212734.GB28054@elte.hu>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 17 May 2011 15:27:05 -0700
Message-ID: <1305671225.2915.133.camel@work-vm>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: LKML <linux-kernel@vger.kernel.org>, Joe Perches <joe@perches.com>, Michal Nazarewicz <mina86@mina86.com>, Andy Whitcroft <apw@canonical.com>, Jiri Slaby <jirislaby@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Tue, 2011-05-17 at 23:27 +0200, Ingo Molnar wrote:
> * John Stultz <john.stultz@linaro.org> wrote:
> 
> > The implicit rules for current->comm access being safe without locking are no 
> > longer true. Accessing current->comm without holding the task lock may result 
> > in null or incomplete strings (however, access won't run off the end of the 
> > string).
> 
> This is rather unfortunate - task->comm is used in a number of performance 
> critical codepaths such as tracing.
> 
> Why does this matter so much? A NULL string is not a big deal.

I'll defer to KOSAKI Motohiro and David on this bit. :)

> Note, since task->comm is 16 bytes there's the CMPXCHG16B instruction on x86 
> which could be used to update it atomically, should atomicity really be 
> desired.

Could we use this where cmpxchg16b is available and fall back to locking
if not? Or does that put too much of a penalty on arches that don't have
cmpxchg16b support?

Alternatively, we can have locked accessors that are safe in the
majority of slow-path warning printks, and provide unlocked accessors
for cases where the performance is critical and the code can properly
handle possibly incomplete comms.

thanks
-john



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
