Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id B376B8D0039
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 15:35:41 -0500 (EST)
Received: from kpbe11.cbf.corp.google.com (kpbe11.cbf.corp.google.com [172.25.105.75])
	by smtp-out.google.com with ESMTP id p29KYk3k002167
	for <linux-mm@kvack.org>; Wed, 9 Mar 2011 12:35:25 -0800
Received: from gwb11 (gwb11.prod.google.com [10.200.2.11])
	by kpbe11.cbf.corp.google.com with ESMTP id p29KWoda024538
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 9 Mar 2011 12:32:51 -0800
Received: by gwb11 with SMTP id 11so208123gwb.20
        for <linux-mm@kvack.org>; Wed, 09 Mar 2011 12:32:50 -0800 (PST)
Date: Wed, 9 Mar 2011 12:32:42 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] oom: prevent unnecessary oom kills or kernel panics
In-Reply-To: <20110309110606.GA16719@redhat.com>
Message-ID: <alpine.DEB.2.00.1103091222420.13353@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1103011108400.28110@chino.kir.corp.google.com> <20110303100030.B936.A69D9226@jp.fujitsu.com> <20110308134233.GA26884@redhat.com> <alpine.DEB.2.00.1103081549530.27910@chino.kir.corp.google.com>
 <20110309110606.GA16719@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Andrey Vagin <avagin@openvz.org>

On Wed, 9 Mar 2011, Oleg Nesterov wrote:

> > Using for_each_process() does not consider threads that have failed to
> > exit after the oom killed parent and, thus, we select another innocent
> > task to kill when we're really just waiting for those threads to exit
> 
> How so? select_bad_process() checks TIF_MEMDIE and returns ERR_PTR()
> if it is set.
> 

TIF_MEMDIE is quite obviously a per-thread flag that only gets set for the 
oom killed task.  That leader may exit and leave behind several other 
threads that cannot be detected in a subsequent oom killer call using 
for_each_process().  We instead want to identify those threads and target 
them as well so that they may die and free memory.

> And, exactly because we use for_each_process() we do not need to check
> other threads. The main thread can't disappear until they all exit.
> 

That's obviously false, otherwise we wouldn't have lots of panics because 
there are no other eligible processes found using for_each_process() yet 
there are eligible threads using do_each_thread().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
