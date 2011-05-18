Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id C82058D003B
	for <linux-mm@kvack.org>; Tue, 17 May 2011 20:28:49 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 6E8723EE0C3
	for <linux-mm@kvack.org>; Wed, 18 May 2011 09:28:46 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 52F1345DE94
	for <linux-mm@kvack.org>; Wed, 18 May 2011 09:28:46 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 345E745DE91
	for <linux-mm@kvack.org>; Wed, 18 May 2011 09:28:46 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 05B07E08001
	for <linux-mm@kvack.org>; Wed, 18 May 2011 09:28:46 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C426C1DB8037
	for <linux-mm@kvack.org>; Wed, 18 May 2011 09:28:45 +0900 (JST)
Message-ID: <4DD312B4.7060008@jp.fujitsu.com>
Date: Wed, 18 May 2011 09:28:36 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] comm: Introduce comm_lock seqlock to protect task->comm
 access
References: <1305580757-13175-1-git-send-email-john.stultz@linaro.org> <1305580757-13175-2-git-send-email-john.stultz@linaro.org>
In-Reply-To: <1305580757-13175-2-git-send-email-john.stultz@linaro.org>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: john.stultz@linaro.org
Cc: linux-kernel@vger.kernel.org, tytso@mit.edu, rientjes@google.com, dave@linux.vnet.ibm.com, akpm@linux-foundation.org, linux-mm@kvack.org

(2011/05/17 6:19), John Stultz wrote:
> The implicit rules for current->comm access being safe without locking
> are no longer true. Accessing current->comm without holding the task
> lock may result in null or incomplete strings (however, access won't
> run off the end of the string).
> 
> In order to properly fix this, I've introduced a comm_lock spinlock
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
> CC: Ted Ts'o<tytso@mit.edu>
> CC: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>
> CC: David Rientjes<rientjes@google.com>
> CC: Dave Hansen<dave@linux.vnet.ibm.com>
> CC: Andrew Morton<akpm@linux-foundation.org>
> CC: linux-mm@kvack.org
> Acked-by: David Rientjes<rientjes@google.com>
> Signed-off-by: John Stultz<john.stultz@linaro.org>

Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
