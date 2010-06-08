Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id D8C7E6B01D7
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 19:54:37 -0400 (EDT)
Received: from hpaq13.eem.corp.google.com (hpaq13.eem.corp.google.com [172.25.149.13])
	by smtp-out.google.com with ESMTP id o58NsYAK008308
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 16:54:34 -0700
Received: from pwi5 (pwi5.prod.google.com [10.241.219.5])
	by hpaq13.eem.corp.google.com with ESMTP id o58NsXnP031221
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 16:54:33 -0700
Received: by pwi5 with SMTP id 5so400425pwi.12
        for <linux-mm@kvack.org>; Tue, 08 Jun 2010 16:54:32 -0700 (PDT)
Date: Tue, 8 Jun 2010 16:54:31 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 01/18] oom: filter tasks not sharing the same
 cpuset
In-Reply-To: <20100608162513.c633439e.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1006081654020.19582@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006010008410.29202@chino.kir.corp.google.com> <alpine.DEB.2.00.1006010013080.29202@chino.kir.corp.google.com> <20100607084024.873B.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1006081141330.18848@chino.kir.corp.google.com>
 <20100608162513.c633439e.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 8 Jun 2010, Andrew Morton wrote:

> And I wonder if David has observed some problem which the 2010 change
> fixes!
> 

Yes, as explained in my changelog.  I'll paste it:

Tasks that do not share the same set of allowed nodes with the task that
triggered the oom should not be considered as candidates for oom kill.

Tasks in other cpusets with a disjoint set of mems would be unfairly
penalized otherwise because of oom conditions elsewhere; an extreme
example could unfairly kill all other applications on the system if a
single task in a user's cpuset sets itself to OOM_DISABLE and then uses
more memory than allowed.

Killing tasks outside of current's cpuset rarely would free memory for
current anyway.  To use a sane heuristic, we must ensure that killing a
task would likely free memory for current and avoid needlessly killing
others at all costs just because their potential memory freeing is
unknown.  It is better to kill current than another task needlessly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
