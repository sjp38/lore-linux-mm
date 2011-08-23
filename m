Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0F4866B0173
	for <linux-mm@kvack.org>; Tue, 23 Aug 2011 16:18:19 -0400 (EDT)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id p7NKIICZ013193
	for <linux-mm@kvack.org>; Tue, 23 Aug 2011 13:18:18 -0700
Received: from pzk6 (pzk6.prod.google.com [10.243.19.134])
	by wpaz33.hot.corp.google.com with ESMTP id p7NKHwnM024712
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 23 Aug 2011 13:18:17 -0700
Received: by pzk6 with SMTP id 6so91010pzk.8
        for <linux-mm@kvack.org>; Tue, 23 Aug 2011 13:18:16 -0700 (PDT)
Date: Tue, 23 Aug 2011 13:18:14 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] oom: skip frozen tasks
In-Reply-To: <20110823073101.6426.77745.stgit@zurg>
Message-ID: <alpine.DEB.2.00.1108231313520.21637@chino.kir.corp.google.com>
References: <20110823073101.6426.77745.stgit@zurg>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Tue, 23 Aug 2011, Konstantin Khlebnikov wrote:

> All frozen tasks are unkillable, and if one of them has TIF_MEMDIE
> we must kill something else to avoid deadlock. After this patch
> select_bad_process() will skip frozen task before checking TIF_MEMDIE.
> 

The caveat is that if the task in the refrigerator is not OOM_DISABLE and 
there are no other eligible tasks (system wide, in the cpuset, or in the 
memcg) to kill, then the machine will panic as a result of this when, in 
the past, we would simply issue the SIGKILL and keep looping in the page 
allocator until it is thawed.

So you may actually be trading a stall waiting for this thread to thaw for 
what would now be a panic, and that's not clearly better to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
