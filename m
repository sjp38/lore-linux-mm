Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id D36126B0012
	for <linux-mm@kvack.org>; Tue, 17 May 2011 18:56:34 -0400 (EDT)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id p4HMuWZU020144
	for <linux-mm@kvack.org>; Tue, 17 May 2011 15:56:32 -0700
Received: from pwi5 (pwi5.prod.google.com [10.241.219.5])
	by wpaz21.hot.corp.google.com with ESMTP id p4HMuNgG022362
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 17 May 2011 15:56:31 -0700
Received: by pwi5 with SMTP id 5so550594pwi.3
        for <linux-mm@kvack.org>; Tue, 17 May 2011 15:56:26 -0700 (PDT)
Date: Tue, 17 May 2011 15:56:24 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/3] comm: Introduce comm_lock spinlock to protect
 task->comm access
In-Reply-To: <1305669256.2466.6286.camel@twins>
Message-ID: <alpine.DEB.2.00.1105171551450.10386@chino.kir.corp.google.com>
References: <1305665263-20933-1-git-send-email-john.stultz@linaro.org> <1305665263-20933-2-git-send-email-john.stultz@linaro.org> <20110517212734.GB28054@elte.hu> <1305669256.2466.6286.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Ingo Molnar <mingo@elte.hu>, John Stultz <john.stultz@linaro.org>, LKML <linux-kernel@vger.kernel.org>, Joe Perches <joe@perches.com>, Michal Nazarewicz <mina86@mina86.com>, Andy Whitcroft <apw@canonical.com>, Jiri Slaby <jirislaby@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Tue, 17 May 2011, Peter Zijlstra wrote:

> The changelog also fails to mention _WHY_ this is no longer true. Nor
> does it treat why making it true again isn't an option.
> 

It's been true since:

	4614a696bd1c3a9af3a08f0e5874830a85b889d4
	Author: john stultz <johnstul@us.ibm.com>
	Date:   Mon Dec 14 18:00:05 2009 -0800

	    procfs: allow threads to rename siblings via /proc/pid/tasks/tid/comm

Although at the time it appears that nobody was concerned about races so 
proper syncronization was never implemented.  We always had the 
prctl(PR_SET_NAME) so the majority of comm reads, those to current, 
required no locking, but this commit changed that.  The remainder of comm 
dereferences always required task_lock() and the helper get_task_comm() to 
read the string into a (usually stack-allocated) buffer.

> Who is changing another task's comm? That's just silly.
> 

I agree, and I suggested taking write privileges away from /proc/pid/comm, 
but others find that it is useful to be able to differentiate between 
threads in the same thread group without using the prctl() for debugging?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
