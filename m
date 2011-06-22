Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 09C6D900194
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 18:59:45 -0400 (EDT)
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id p5MMxhVl025146
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 15:59:43 -0700
Received: from pwi5 (pwi5.prod.google.com [10.241.219.5])
	by kpbe14.cbf.corp.google.com with ESMTP id p5MMxfYt028270
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 15:59:42 -0700
Received: by pwi5 with SMTP id 5so747725pwi.32
        for <linux-mm@kvack.org>; Wed, 22 Jun 2011 15:59:41 -0700 (PDT)
Date: Wed, 22 Jun 2011 15:59:40 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/6] oom: improve dump_tasks() show items
In-Reply-To: <4E01C82A.7070702@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1106221558160.11759@chino.kir.corp.google.com>
References: <4E01C7D5.3060603@jp.fujitsu.com> <4E01C82A.7070702@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, caiqian@redhat.com, hughd@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan.kim@gmail.com, oleg@redhat.com

On Wed, 22 Jun 2011, KOSAKI Motohiro wrote:

> Recently, oom internal logic was dramatically changed. Thus
> dump_tasks() doesn't show enough information for bug report
> analysis. it has some meaningless items and don't have some
> oom socre related items.
> 
> This patch adapt displaying fields to new oom logic.
> 
> details
> --------
> removed: pid (we always kill process. don't need thread id),
>          signal->oom_adj (we no longer uses it internally)
> 	 cpu (we no longer uses it)
> added:  ppid (we often kill sacrifice child process)
>         swap (it's accounted)
> modify: RSS (account mm->nr_ptes too)
> 
> <old>
> [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
> [ 3886]     0  3886     2893      441   1       0             0 bash
> [ 3905]     0  3905    29361    25833   0       0             0 memtoy
> 
> <new>
> [   pid]   ppid   uid euid total_vm      rss     swap score_adj name
> [   417]      1     0    0     3298       12      184     -1000 udevd
> [   830]      1     0    0     1776       11       16         0 system-setup-ke
> [   973]      1     0    0    61179       35      116         0 rsyslogd
> [  1733]   1732     0    0  1052337   958582        0         0 memtoy
> 

I like this very much!  I'm always supportive of providing additional 
information that will allow users to investigate oom conditions more 
thoroughly.

I'm not sure that we should be exporting the euid, however, since I 
disagreed with using it in the badness heuristic of the first patch.  
Let's talk about it there and then perhaps it can be removed from the 
tasklist dump if we don't actually end up using it?

Otherwise, it looks good!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
