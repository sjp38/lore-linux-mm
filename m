Date: Thu, 17 Jan 2008 12:23:16 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC] mmaped copy too slow?
In-Reply-To: <20080116110200.11B4.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <478CAB25.30300@grupopie.com> <20080116110200.11B4.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20080117121231.11D4.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paulo Marques <pmarques@grupopie.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi

> > One thing you could also try is to pass MAP_POPULATE to mmap so that the 
> > page tables are filled in at the time of the mmap, avoiding a lot of 
> > page faults later.
> > 
> 
> OK, I will test your idea and report about tomorrow.
> but I don't think page fault is major performance impact.

I got more interesting result :)
MAP_POPULATE is harmful result at large copy.


1G copy
                             elapse(sec)
--------------------------------------------
mmap                          71.54
mmap + madvice                69.63
mmap + populate              100.87
mmap + populate + madvice    101.16


more detail:
time command output of mmap copy
	0.50user 3.59system 1:11.54elapsed 5%CPU (0avgtext+0avgdata 0maxresident)k
	2101192inputs+2097160outputs (32776major+491573minor)pagefaults 0swaps

time command output of mmap+populate copy
	0.53user 5.13system 1:40.87elapsed 5%CPU (0avgtext+0avgdata 0maxresident)k
	4200808inputs+2097160outputs (49164major+737340minor)pagefaults 0swaps


input blocks increase about x2.
in fact, mmap(MAP_POPULATE) read disk to memory and drop it just after,
thus read again. 


of cource, when copy file size is enough small, MAP_POPULATE is effective.


100M copy
                             elapse(sec)
--------------------------------------------
mmap                          7.38
mmap + madvice                7.29
mmap + populate               7.13
mmap + populate + madvice     6.65


- kosaki


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
