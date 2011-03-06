Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id CD2DB8D0039
	for <linux-mm@kvack.org>; Sun,  6 Mar 2011 17:03:52 -0500 (EST)
Received: from hpaq13.eem.corp.google.com (hpaq13.eem.corp.google.com [172.25.149.13])
	by smtp-out.google.com with ESMTP id p26M3idf002169
	for <linux-mm@kvack.org>; Sun, 6 Mar 2011 14:03:44 -0800
Received: from pvg3 (pvg3.prod.google.com [10.241.210.131])
	by hpaq13.eem.corp.google.com with ESMTP id p26M3NdZ028429
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 6 Mar 2011 14:03:43 -0800
Received: by pvg3 with SMTP id 3so688005pvg.32
        for <linux-mm@kvack.org>; Sun, 06 Mar 2011 14:03:42 -0800 (PST)
Date: Sun, 6 Mar 2011 14:03:39 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: skip zombie in OOM-killer
In-Reply-To: <20110306193519.49DD.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1103061400170.23737@chino.kir.corp.google.com>
References: <1299286307-4386-1-git-send-email-avagin@openvz.org> <20110306193519.49DD.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrey Vagin <avagin@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, 6 Mar 2011, KOSAKI Motohiro wrote:

> > When we check that task has flag TIF_MEMDIE, we forgot check that
> > it has mm. A task may be zombie and a parent may wait a memor.
> > 
> > v2: Check that task doesn't have mm one time and skip it immediately
> > 
> > Signed-off-by: Andrey Vagin <avagin@openvz.org>
> 
> This seems incorrect. Do you have a reprodusable testcasae?
> Your patch only care thread group leader state, but current code
> care all thread in the process. Please look at oom_badness() and 
> find_lock_task_mm(). 
> 

That's all irrelevant, the test for TIF_MEMDIE specifically makes the oom 
killer a complete no-op when an eligible task is found to have been oom 
killed to prevent needlessly killing additional tasks.  oom_badness() and 
find_lock_task_mm() have nothing to do with that check to return 
ERR_PTR(-1UL) from select_bad_process().

Andrey is patching the case where an eligible TIF_MEMDIE process is found 
but it has already detached its ->mm.  In combination with the patch 
posted to linux-mm, oom: prevent unnecessary oom kills or kernel panics, 
which makes select_bad_process() iterate over all threads, it is an 
effective solution.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
