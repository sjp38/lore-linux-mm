Subject: Re: [PATCH] Recent VM fiasco - fixed
References: <Pine.LNX.4.10.10005091244270.1248-100000@penguin.transmeta.com>
From: Christoph Rohland <cr@sap.com>
Date: 10 May 2000 13:25:16 +0200
In-Reply-To: Linus Torvalds's message of "Tue, 9 May 2000 12:50:47 -0700 (PDT)"
Message-ID: <qwwn1lylk9v.fsf@sap.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Daniel Stone <tamriel@ductape.net>, riel@nl.linux.org, Zlatko Calusic <zlatko@iskon.hr>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Linus Torvalds <torvalds@transmeta.com> writes:

> On 9 May 2000, Christoph Rohland wrote:
> 
> > Linus Torvalds <torvalds@transmeta.com> writes:
> > 
> > > Try out the really recent one - pre7-8. So far it hassome good reviews,
> > > and I've tested it both on a 20MB machine and a 512MB one..

> > I append the mem and task info from sysrq. Mem info seems to not
> > change after lockup.
> 
> I suspect that if you do right-alt + scrolllock, you'll see it looping on
> a spinlock. Which is why the memory info isn't changing ;)
> 
> But I'll double-check the shm code (I didn't test anything that did any
> shared memory, for example).

Juan Quintela's patch fixes the lockup. shm paging locked up on the
page lock.

Now I can give more data about pre7-8. After a short run I can say the
following:

The machine seems to be stable, but VM is mainly unbalanced:

[root@ls3016 /root]# vmstat 5
   procs                      memory    swap          io     system         cpu
 r  b  w   swpd   free   buff  cache  si  so    bi    bo   in    cs  us  sy  id

[...]

 9  3  0      0 1460016   1588  11284   0   0     0     0  109 23524   4  96   0
 9  3  1   7552 557432   1004  19320   0 1607     0   402  186 42582   2  89   9
11  1  1  41972 111368    424  53740   0 6884     2  1721  277 25904   0  89  10
11  1  0  48084  11896    276  59404   0 1133     1   284  181  4439   0  95   5
13  2  2  48352 466952    180  52960   5 158     4    39  230  6381   2  98   0
10  3  1  53400 934204    248  59940 498 1442   128   363  272  3953   1  99   0
11  3  1  52624 878696    300  59820 248  50    81    13  148   971   0 100   0
11  1  0   4556 883852    316  16164 855   0   214     1  127 25188   3  97   0
12  0  0   3936 525620    316  15544   0   0     0     0  109 33969   4  96   0
12  0  0   3936 2029556    316  15544   0   0     0     0  123 19659   4  96   0
11  1  0   3936 686856    316  15544   0   0     0     0  117 14370   3  97   0
12  0  0   3936 388176    320  15544   0   0     0     0  121  7477   3  97   0
10  3  1  47660   5216     88  19992   0 9353     0  2341  757  1267   0  97   3
 VM: killing process ipctst
 6  6  1  36792 484880    152  26892  65 12307    21  3078 1619  2184   0  94   6
   procs                      memory    swap          io     system         cpu
 r  b  w   swpd   free   buff  cache  si  so    bi    bo   in    cs  us  sy  id
10  1  1  39620  66736    148  29364   8 494     2   125  327  1980   0 100   0
VM: killing process ipctst
 9  2  1  46536 627356    116  31072  87 8675    23  2169 1784  1412   0  96   4
10  0  1  46664 617368    116  31200   0  26     0     6  258   112   0 100   0
10  0  1  47300 607184    116  31832   0 126     0    32  291   110   0 100   0

So we are swapping out with lots of free memory and killing random
processes. The machine also becomes quite unresponsive compared to
pre4 on the same tests.

Greetings
		Christoph

-- 
Christoph Rohland               Tel:   +49 6227 748201
SAP AG                          Fax:   +49 6227 758201
LinuxLab                        Email: cr@sap.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
