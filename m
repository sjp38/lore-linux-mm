Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8BDF190014F
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 00:10:19 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id p7B4A5mY018750
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 21:10:06 -0700
Received: from pzk32 (pzk32.prod.google.com [10.243.19.160])
	by wpaz29.hot.corp.google.com with ESMTP id p7B49xJf010088
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 21:10:04 -0700
Received: by pzk32 with SMTP id 32so3469199pzk.5
        for <linux-mm@kvack.org>; Wed, 10 Aug 2011 21:10:02 -0700 (PDT)
Date: Wed, 10 Aug 2011 21:09:59 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: running of out memory => kernel crash
In-Reply-To: <1312964098.7449.YahooMailNeo@web111712.mail.gq1.yahoo.com>
Message-ID: <alpine.DEB.2.00.1108102106410.14230@chino.kir.corp.google.com>
References: <1312872786.70934.YahooMailNeo@web111712.mail.gq1.yahoo.com> <1db776d865939be598cdb80054cf5d93.squirrel@xenotime.net> <1312874259.89770.YahooMailNeo@web111704.mail.gq1.yahoo.com> <alpine.DEB.2.00.1108090900170.30199@chino.kir.corp.google.com>
 <1312964098.7449.YahooMailNeo@web111712.mail.gq1.yahoo.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="397155492-2005623161-1313035801=:14230"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mahmood Naderan <nt_mahmood@yahoo.com>
Cc: Randy Dunlap <rdunlap@xenotime.net>, "\"linux-kernel@vger.kernel.org\"" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--397155492-2005623161-1313035801=:14230
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Wed, 10 Aug 2011, Mahmood Naderan wrote:

> >If you're using cpusets or mempolicies, you must ensure that all tasks 
> >attached to either of them are not set to OOM_DISABLE.  It seems unlikely 
> >that you're using those, so it seems like a system-wide oom condition.
>  
> I didn't do that manually. What is the default behaviour? Does oom
> working or not?
> 

The default behavior is to kill all eligible and unkillable threads until 
there are none left to sacrifice (i.e. all kthreads and OOM_DISABLE).

> For a user process:
> 
> root@srv:~# cat /proc/18564/oom_score
> 9198
> root@srv:~# cat /proc/18564/oom_adj
> 0
> 

Ok, so you don't have a /proc/pid/oom_score_adj, so you're using a kernel 
that predates 2.6.36.

> And for "init" process:
> 
> root@srv:~# cat /proc/1/oom_score
> 17509
> root@srv:~# cat /proc/1/oom_adj
> 0
> 
> Based on my understandings, in an out of memory condition (oom),
> the init process is more eligible to be killed!!!!!!! Is that right?
> 

init is exempt from oom killing, it's oom_score is meaningless.

> Again I didn't get my answer yet:
> What is the default behavior of linux in an oom condition? If the default is,
> crash (kernel panic), then how can I change that in such a way to kill
> the hungry process?
> 

You either have /proc/sys/vm/panic_on_oom set or it's killing a thread 
that is taking down the entire machine.  If it's the latter, then please 
capture the kernel log and post it as Randy suggested.
--397155492-2005623161-1313035801=:14230--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
