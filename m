Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D760B6B0012
	for <linux-mm@kvack.org>; Wed, 25 May 2011 19:50:33 -0400 (EDT)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id p4PNoWqn009686
	for <linux-mm@kvack.org>; Wed, 25 May 2011 16:50:32 -0700
Received: from pwi6 (pwi6.prod.google.com [10.241.219.6])
	by wpaz24.hot.corp.google.com with ESMTP id p4PNoHvv015346
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 25 May 2011 16:50:25 -0700
Received: by pwi6 with SMTP id 6so112172pwi.4
        for <linux-mm@kvack.org>; Wed, 25 May 2011 16:50:17 -0700 (PDT)
Date: Wed, 25 May 2011 16:50:15 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 4/5] oom: don't kill random process
In-Reply-To: <4DDB11F4.2070903@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1105251645270.29729@chino.kir.corp.google.com>
References: <4DD61F80.1020505@jp.fujitsu.com> <4DD6207E.1070300@jp.fujitsu.com> <alpine.DEB.2.00.1105231529340.17840@chino.kir.corp.google.com> <4DDB0B45.2080507@jp.fujitsu.com> <alpine.DEB.2.00.1105231838420.17729@chino.kir.corp.google.com>
 <4DDB1028.7000600@jp.fujitsu.com> <alpine.DEB.2.00.1105231856210.18353@chino.kir.corp.google.com> <4DDB11F4.2070903@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, caiqian@redhat.com, hughd@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan.kim@gmail.com, oleg@redhat.com

On Tue, 24 May 2011, KOSAKI Motohiro wrote:

> > I don't care if it happens in the usual case or extremely rare case.  It
> > significantly increases the amount of time that tasklist_lock is held
> > which causes writelock starvation on other cpus and causes issues,
> > especially if the cpu being starved is updating the timer because it has
> > irqs disabled, i.e. write_lock_irq(&tasklist_lock) usually in the clone or
> > exit path.  We can do better than that, and that's why I proposed my patch
> > to CAI that increases the resolution of the scoring and makes the root
> > process bonus proportional to the amount of used memory.
> 
> Do I need to say the same word? Please read the code at first.
> 

I'm afraid that a second time through the tasklist in select_bad_process() 
is simply a non-starter for _any_ case; it significantly increases the 
amount of time that tasklist_lock is held and causes problems elsewhere on 
large systems -- such as some of ours -- since irqs are disabled while 
waiting for the writeside of the lock.  I think it would be better to use 
a proportional privilege for root processes based on the amount of memory 
they are using (discounting 1% of memory per 10% of memory used, as 
proposed earlier, seems sane) so we can always protect root when necessary 
and never iterate through the list again.

Please look into the earlier review comments on the other patches, refresh 
the series, and post it again.  Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
