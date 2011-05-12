Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4696A90010B
	for <linux-mm@kvack.org>; Thu, 12 May 2011 18:00:58 -0400 (EDT)
Received: from kpbe15.cbf.corp.google.com (kpbe15.cbf.corp.google.com [172.25.105.79])
	by smtp-out.google.com with ESMTP id p4CM0m3S010777
	for <linux-mm@kvack.org>; Thu, 12 May 2011 15:00:50 -0700
Received: from pve37 (pve37.prod.google.com [10.241.210.37])
	by kpbe15.cbf.corp.google.com with ESMTP id p4CM0krW015349
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 12 May 2011 15:00:47 -0700
Received: by pve37 with SMTP id 37so1227400pve.21
        for <linux-mm@kvack.org>; Thu, 12 May 2011 15:00:46 -0700 (PDT)
Date: Thu, 12 May 2011 15:00:44 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/3] comm: Introduce comm_lock seqlock to protect task->comm
 access
In-Reply-To: <1305073386-4810-2-git-send-email-john.stultz@linaro.org>
Message-ID: <alpine.DEB.2.00.1105121458130.7530@chino.kir.corp.google.com>
References: <1305073386-4810-1-git-send-email-john.stultz@linaro.org> <1305073386-4810-2-git-send-email-john.stultz@linaro.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Ted Ts'o <tytso@mit.edu>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Tue, 10 May 2011, John Stultz wrote:

> The implicit rules for current->comm access being safe without locking
> are no longer true. Accessing current->comm without holding the task
> lock may result in null or incomplete strings (however, access won't
> run off the end of the string).
> 
> In order to properly fix this, I've introduced a comm_lock seqlock
> which will protect comm access and modified get_task_comm() and
> set_task_comm() to use it.
> 
> Since there are a number of cases where comm access is open-coded
> safely grabbing the task_lock(), we preserve the task locking in
> set_task_comm, so those users are also safe.
> 
> With this patch, users that access current->comm without a lock
> are still prone to null/incomplete comm strings, but it should
> be no worse then it is now.
> 
> The next step is to go through and convert all comm accesses to
> use get_task_comm(). This is substantial, but can be done bit by
> bit, reducing the race windows with each patch.
> 
> CC: Ted Ts'o <tytso@mit.edu>
> CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> CC: David Rientjes <rientjes@google.com>
> CC: Dave Hansen <dave@linux.vnet.ibm.com>
> CC: Andrew Morton <akpm@linux-foundation.org>
> CC: linux-mm@kvack.org
> Signed-off-by: John Stultz <john.stultz@linaro.org>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
