Subject: Re: [PATCH] Recent VM fiasco - fixed
References: <Pine.LNX.4.10.10005091244270.1248-100000@penguin.transmeta.com> <qwwn1lylk9v.fsf@sap.com>
Reply-To: zlatko@iskon.hr
From: Zlatko Calusic <zlatko@iskon.hr>
Date: 10 May 2000 13:50:47 +0200
In-Reply-To: Christoph Rohland's message of "10 May 2000 13:25:16 +0200"
Message-ID: <dnitwmfwtk.fsf@magla.iskon.hr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Rohland <cr@sap.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, Daniel Stone <tamriel@ductape.net>, riel@nl.linux.org, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Christoph Rohland <cr@sap.com> writes:

> Linus Torvalds <torvalds@transmeta.com> writes:
> 
> > On 9 May 2000, Christoph Rohland wrote:
> > 
> > > Linus Torvalds <torvalds@transmeta.com> writes:
> > > 
> > > > Try out the really recent one - pre7-8. So far it hassome good reviews,
> > > > and I've tested it both on a 20MB machine and a 512MB one..
> 
> > > I append the mem and task info from sysrq. Mem info seems to not
> > > change after lockup.
> > 
> > I suspect that if you do right-alt + scrolllock, you'll see it looping on
> > a spinlock. Which is why the memory info isn't changing ;)
> > 
> > But I'll double-check the shm code (I didn't test anything that did any
> > shared memory, for example).
> 
> Juan Quintela's patch fixes the lockup. shm paging locked up on the
> page lock.
> 
> Now I can give more data about pre7-8. After a short run I can say the
> following:
> 
> The machine seems to be stable, but VM is mainly unbalanced:
> 
> [root@ls3016 /root]# vmstat 5
>    procs                      memory    swap          io     system         cpu
>  r  b  w   swpd   free   buff  cache  si  so    bi    bo   in    cs  us  sy  id
> 
> [...]
> 
>  9  3  0      0 1460016   1588  11284   0   0     0     0  109 23524   4  96   0
>  9  3  1   7552 557432   1004  19320   0 1607     0   402  186 42582   2  89   9
> 11  1  1  41972 111368    424  53740   0 6884     2  1721  277 25904   0  89  10
[ too many lines error, truncating... ]
>  9  2  1  46536 627356    116  31072  87 8675    23  2169 1784  1412   0  96   4
> 10  0  1  46664 617368    116  31200   0  26     0     6  258   112   0 100   0
> 10  0  1  47300 607184    116  31832   0 126     0    32  291   110   0 100   0
> 
> So we are swapping out with lots of free memory and killing random
> processes. The machine also becomes quite unresponsive compared to
> pre4 on the same tests.
> 

I'll second this!

I checked pre7-8 briefly, but I/O & MM interaction is bad. Lots of
swapping, lots of wasted CPU cycles and lots of dead writer processes
(write(2): out of memory, while there is 100MB in the page cache).

Back to my patch and working on the solution for the 20-24 MB & 1GB
machines. Anybody with spare 1GB RAM to help development? :)

-- 
Zlatko
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
