Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id E81F190010B
	for <linux-mm@kvack.org>; Mon, 16 May 2011 16:35:37 -0400 (EDT)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p4GKN04f015438
	for <linux-mm@kvack.org>; Mon, 16 May 2011 14:23:00 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4GKaIeS077294
	for <linux-mm@kvack.org>; Mon, 16 May 2011 14:36:20 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4GEYVT9020200
	for <linux-mm@kvack.org>; Mon, 16 May 2011 08:34:33 -0600
Subject: Re: [PATCH 1/3] comm: Introduce comm_lock seqlock to protect
 task->comm access
From: John Stultz <john.stultz@linaro.org>
In-Reply-To: <BANLkTin_MitzRUkWToj055AuAPdMC9msXQ@mail.gmail.com>
References: <1305241371-25276-1-git-send-email-john.stultz@linaro.org>
	 <1305241371-25276-2-git-send-email-john.stultz@linaro.org>
	 <4DCD1256.4070808@jp.fujitsu.com> <1305311276.2680.34.camel@work-vm>
	 <BANLkTin_MitzRUkWToj055AuAPdMC9msXQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 16 May 2011 13:34:54 -0700
Message-ID: <1305578094.2915.53.camel@work-vm>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Ted Ts'o <tytso@mit.edu>, David Rientjes <rientjes@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Sat, 2011-05-14 at 20:12 +0900, KOSAKI Motohiro wrote:
> >> Can you please explain why we should use seqlock? That said,
> >> we didn't use seqlock for /proc items. because, plenty seqlock
> >> write may makes readers busy wait. Then, if we don't have another
> >> protection, we give the local DoS attack way to attackers.
> >
> > So you're saying that heavy write contention can cause reader
> > starvation?
> 
> Yes.
> 
> >> task->comm is used for very fundamentally. then, I doubt we can
> >> assume write is enough rare. Why can't we use normal spinlock?
> >
> > I think writes are likely to be fairly rare. Tasks can only name
> > themselves or sibling threads, so I'm not sure I see the risk here.
> 
> reader starvation may cause another task's starvation if reader have
> an another lock.

So the risk is a thread rewriting its own comm over and over could
starve some other critical task trying to read the comm.

Ok. It makes it a little more costly, but fair enough.

thanks
-john




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
