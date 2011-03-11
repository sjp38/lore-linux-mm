Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id B967C8D003A
	for <linux-mm@kvack.org>; Fri, 11 Mar 2011 14:46:06 -0500 (EST)
Received: from kpbe13.cbf.corp.google.com (kpbe13.cbf.corp.google.com [172.25.105.77])
	by smtp-out.google.com with ESMTP id p2BJk4IO011984
	for <linux-mm@kvack.org>; Fri, 11 Mar 2011 11:46:04 -0800
Received: from pxi2 (pxi2.prod.google.com [10.243.27.2])
	by kpbe13.cbf.corp.google.com with ESMTP id p2BJk39T017939
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 11 Mar 2011 11:46:03 -0800
Received: by pxi2 with SMTP id 2so754801pxi.24
        for <linux-mm@kvack.org>; Fri, 11 Mar 2011 11:46:03 -0800 (PST)
Date: Fri, 11 Mar 2011 11:45:58 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] oom: prevent unnecessary oom kills or kernel panics
In-Reply-To: <20110309151946.dea51cde.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1103111142260.30699@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1103011108400.28110@chino.kir.corp.google.com> <20110303100030.B936.A69D9226@jp.fujitsu.com> <20110308134233.GA26884@redhat.com> <alpine.DEB.2.00.1103081549530.27910@chino.kir.corp.google.com>
 <20110309151946.dea51cde.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Andrey Vagin <avagin@openvz.org>

On Wed, 9 Mar 2011, Andrew Morton wrote:

> If Oleg's test program cause a hang with
> oom-prevent-unnecessary-oom-kills-or-kernel-panics.patch and doesn't
> cause a hang without
> oom-prevent-unnecessary-oom-kills-or-kernel-panics.patch then that's a
> big problem for
> oom-prevent-unnecessary-oom-kills-or-kernel-panics.patch, no?
> 

It's a problem, but not because of 
oom-prevent-unnecessary-oom-kills-or-kernel-panics.patch.  If we don't 
have this patch, then we have a trivial panic when an oom kill occurs in a 
cpuset with no other eligible processes, the oom killed thread group 
leader exits but its other threads do not and they trigger oom kills 
themselves.  for_each_process() does not iterate over these threads and so 
it finds no eligible threads to kill and then panics (and we have many 
examples of that happening in production).  I'll look at Oleg's test case 
and see what can be done to fix that condition, but the answer isn't to 
ignore eligible threads that can be killed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
