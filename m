Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8E1FF8D003B
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 17:22:13 -0400 (EDT)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id p3JLM3PJ005581
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 14:22:04 -0700
Received: from pwj3 (pwj3.prod.google.com [10.241.219.67])
	by wpaz1.hot.corp.google.com with ESMTP id p3JLM1Ni003275
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 14:22:02 -0700
Received: by pwj3 with SMTP id 3so109469pwj.15
        for <linux-mm@kvack.org>; Tue, 19 Apr 2011 14:22:01 -0700 (PDT)
Date: Tue, 19 Apr 2011 14:21:59 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] break out page allocation warning code
In-Reply-To: <20110419094422.9375.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1104191419470.510@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1104181321480.31186@chino.kir.corp.google.com> <1303161774.9887.346.camel@nimitz> <20110419094422.9375.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Nazarewicz <mina86@mina86.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue, 19 Apr 2011, KOSAKI Motohiro wrote:

> The rule is,
> 
> 1) writing comm
> 	need task_lock
> 2) read _another_ thread's comm
> 	need task_lock
> 3) read own comm
> 	no need task_lock
> 

That was true a while ago, but you now need to protect every thread's 
->comm with get_task_comm() or ensuring task_lock() is held to protect 
against /proc/pid/comm which can change other thread's ->comm.  That was 
different before when prctl(PR_SET_NAME) would only operate on current, so 
no lock was needed when reading current->comm.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
