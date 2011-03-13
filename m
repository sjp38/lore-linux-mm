Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0A2AC8D003B
	for <linux-mm@kvack.org>; Sat, 12 Mar 2011 20:06:15 -0500 (EST)
Received: from kpbe16.cbf.corp.google.com (kpbe16.cbf.corp.google.com [172.25.105.80])
	by smtp-out.google.com with ESMTP id p2D16C9m014691
	for <linux-mm@kvack.org>; Sat, 12 Mar 2011 17:06:12 -0800
Received: from pxi7 (pxi7.prod.google.com [10.243.27.7])
	by kpbe16.cbf.corp.google.com with ESMTP id p2D166DU015219
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 12 Mar 2011 17:06:11 -0800
Received: by pxi7 with SMTP id 7so772292pxi.2
        for <linux-mm@kvack.org>; Sat, 12 Mar 2011 17:06:06 -0800 (PST)
Date: Sat, 12 Mar 2011 17:06:01 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] oom: prevent unnecessary oom kills or kernel panics
In-Reply-To: <20110310120519.GA18415@redhat.com>
Message-ID: <alpine.DEB.2.00.1103121704050.10317@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1103011108400.28110@chino.kir.corp.google.com> <20110303100030.B936.A69D9226@jp.fujitsu.com> <20110308134233.GA26884@redhat.com> <alpine.DEB.2.00.1103081549530.27910@chino.kir.corp.google.com> <20110309110606.GA16719@redhat.com>
 <alpine.DEB.2.00.1103091222420.13353@chino.kir.corp.google.com> <20110310120519.GA18415@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Andrey Vagin <avagin@openvz.org>

On Thu, 10 Mar 2011, Oleg Nesterov wrote:

> > That leader may exit and leave behind several other
> > threads
> 
> No, it can't.
> 
> More precisely, it can, and it can even exit _before_ this process starts
> to use a lot of memory, then later this process can be oom-killed.
> 
> But, until all threads disappear, the leader can't go away and
> for_each_process() must see it.
> 

for_each_process() sees the parent, but it is filtered because we no 
longer consider threads without an ->mm.  We only want to pass threads 
with valid ->mm pointers to oom_badness(), otherwise it ignores the thread 
anyway.  Please note that Andrey's patch to filter !p->mm is nothing new, 
it's more of a cleanup.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
