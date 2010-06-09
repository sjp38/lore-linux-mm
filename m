Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 97BAF6B01D5
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:52:51 -0400 (EDT)
Received: from kpbe16.cbf.corp.google.com (kpbe16.cbf.corp.google.com [172.25.105.80])
	by smtp-out.google.com with ESMTP id o590qkrk005955
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 17:52:46 -0700
Received: from pzk13 (pzk13.prod.google.com [10.243.19.141])
	by kpbe16.cbf.corp.google.com with ESMTP id o590q71Z010371
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 17:52:45 -0700
Received: by pzk13 with SMTP id 13so914288pzk.13
        for <linux-mm@kvack.org>; Tue, 08 Jun 2010 17:52:44 -0700 (PDT)
Date: Tue, 8 Jun 2010 17:52:42 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 10/18] oom: enable oom tasklist dump by default
In-Reply-To: <20100608141342.114156ac.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1006081748410.19582@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com> <alpine.DEB.2.00.1006061525150.32225@chino.kir.corp.google.com> <20100608141342.114156ac.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 8 Jun 2010, Andrew Morton wrote:

> > The oom killer tasklist dump, enabled with the oom_dump_tasks sysctl, is
> > very helpful information in diagnosing why a user's task has been killed.
> > It emits useful information such as each eligible thread's memory usage
> > that can determine why the system is oom, so it should be enabled by
> > default.
> 
> Unclear.  On a large system the poor thing will now spend half an hour
> squirting junk out the diagnostic port.  Probably interspersed with the
> occasional whine from the softlockup detector.  And for many
> applications, spending a long time stuck in the kernel printing
> diagnostics is equivalent to an outage.
> 
> I guess people can turn it off again if this happens, but they'll get
> justifiably grumpy at us.  I wonder if this change is too
> developer-friendly and insufficiently operator-friendly.
> 

This is one of the main reasons why I wanted to unify both 
oom_kill_allocating_task and oom_dump_tasks into a single sysctl: 
oom_kill_quick, but that was nacked.  Both of the former sysctls have the 
same audience: those that want to avoid lengthy tasklist scans, namely 
companies like SGI, by enabling the first and disabling the second.  If we 
were to extend the oom killer in the future and need to add special 
handling for these customers, it would have been easy with the unified 
sysctl, but I'm not going to wage that war again.

I think this is more helpful than harmful, however, solely because it 
gives users a better indication of what caused their system to be oom in 
the first place and can be disabled at runtime.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
