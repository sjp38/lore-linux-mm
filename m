Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id AFEB98D0039
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 19:33:06 -0400 (EDT)
Received: from hpaq5.eem.corp.google.com (hpaq5.eem.corp.google.com [172.25.149.5])
	by smtp-out.google.com with ESMTP id p2FNX4Qc003504
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 16:33:04 -0700
Received: from pwi3 (pwi3.prod.google.com [10.241.219.3])
	by hpaq5.eem.corp.google.com with ESMTP id p2FNX1sq022667
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 16:33:02 -0700
Received: by pwi3 with SMTP id 3so245380pwi.23
        for <linux-mm@kvack.org>; Tue, 15 Mar 2011 16:33:01 -0700 (PDT)
Date: Tue, 15 Mar 2011 16:32:58 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: unnecessary oom killer panics in 2.6.38 (was Re: Linux 2.6.38)
In-Reply-To: <20110315210855.GI21640@redhat.com>
Message-ID: <alpine.DEB.2.00.1103151618150.5985@chino.kir.corp.google.com>
References: <AANLkTi=_cZRNPU29+MJkt9u6zDSLo153CKqLqg1+t7O6@mail.gmail.com> <alpine.DEB.2.00.1103142011550.16032@chino.kir.corp.google.com> <20110314213331.24229139.akpm@linux-foundation.org> <alpine.DEB.2.00.1103142137020.13734@chino.kir.corp.google.com>
 <20110315210855.GI21640@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Tue, 15 Mar 2011, Oleg Nesterov wrote:

> What I can't understand is what exactly the first patch tries to fix.
> When I ask you, you tell me that for_each_process() can miss the group
> leader because it can exit before sub-threads. This must not happen,
> or we have some serious bug triggered by your workload.
> 
> So, once again. Could you please explain the original problem and how
> this patch helps?
> 

[trimming cc list with a less worrysome subject line]

A process in a cpuset by itself (or with other processes that are 
OOM_DISABLE) runs out of memory while handling page faults.  It is 
selected as the last possible target by the oom killer and gets killed.  
All of its children are reparented to init (yet they have the same 
cpuset restrictions as the parent and are oom as well) and call do_exit().  
do_exit() happens to require memory while handling proc_exit_connector() 
and trigger an oom itself.  There are no eligible threads left to be found 
in the for_each_process() loop which results in a panic.  The remaining 
children of the oom killed process spin in the page allocator because they 
cannot acquire the zone locks necessary for calling the oom killer 
themselves -- this isn't really important since they would panic the 
machine as well if they do call out_of_memory().

Instead, we want do_each_thread() to identify these threads that are 
eligible for oom kill because they have the same intersecting set of 
allowed nodes (regardless of whether they are reparented to init or not) 
and give them access to memory reserves so that they may finish allocating 
slab for proc_exit_connector() and exit.  Anything else will unnecessary 
panic the machine and that's why 
oom-prevent-unnecessary-oom-kills-or-kernel-panics.patch fixes the issue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
