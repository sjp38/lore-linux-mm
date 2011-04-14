Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 38701900086
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 06:25:34 -0400 (EDT)
Date: Thu, 14 Apr 2011 11:25:01 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: Regression from 2.6.36
Message-ID: <20110414102501.GE11871@csn.ul.ie>
References: <BANLkTinnTnjZvQ9S1AmudZcZBokMy8-93w@mail.gmail.com>
 <1302177428.3357.25.camel@edumazet-laptop>
 <1302178426.3357.34.camel@edumazet-laptop>
 <BANLkTikxWy-Pw1PrcAJMHs2R7JKksyQzMQ@mail.gmail.com>
 <1302190586.3357.45.camel@edumazet-laptop>
 <20110412154906.70829d60.akpm@linux-foundation.org>
 <BANLkTincoaxp5Soe6O-eb8LWpgra=k2NsQ@mail.gmail.com>
 <20110412183132.a854bffc.akpm@linux-foundation.org>
 <1302662256.2811.27.camel@edumazet-laptop>
 <20110413141600.28793661.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="17pEHd4RhPHOinZp"
Content-Disposition: inline
In-Reply-To: <20110413141600.28793661.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Changli Gao <xiaosuo@gmail.com>, Am?rico Wang <xiyou.wangcong@gmail.com>, Jiri Slaby <jslaby@suse.cz>, azurIt <azurit@pobox.sk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Jiri Slaby <jirislaby@gmail.com>


--17pEHd4RhPHOinZp
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline

On Wed, Apr 13, 2011 at 02:16:00PM -0700, Andrew Morton wrote:
> On Wed, 13 Apr 2011 04:37:36 +0200
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> > Le mardi 12 avril 2011 __ 18:31 -0700, Andrew Morton a __crit :
> > > On Wed, 13 Apr 2011 09:23:11 +0800 Changli Gao <xiaosuo@gmail.com> wrote:
> > > 
> > > > On Wed, Apr 13, 2011 at 6:49 AM, Andrew Morton
> > > > <akpm@linux-foundation.org> wrote:
> > > > >
> > > > > It's somewhat unclear (to me) what caused this regression.
> > > > >
> > > > > Is it because the kernel is now doing large kmalloc()s for the fdtable,
> > > > > and this makes the page allocator go nuts trying to satisfy high-order
> > > > > page allocation requests?
> > > > >
> > > > > Is it because the kernel now will usually free the fdtable
> > > > > synchronously within the rcu callback, rather than deferring this to a
> > > > > workqueue?
> > > > >
> > > > > The latter seems unlikely, so I'm thinking this was a case of
> > > > > high-order-allocations-considered-harmful?
> > > > >
> > > > 
> > > > Maybe, but I am not sure. Maybe my patch causes too many inner
> > > > fragments. For example, when asking for 5 pages, get 8 pages, and 3
> > > > pages are wasted, then memory thrash happens finally.
> > > 
> > > That theory sounds less likely, but could be tested by using
> > > alloc_pages_exact().
> > > 
> > 
> > Very unlikely, since fdtable sizes are powers of two, unless you hit
> > sysctl_nr_open and it was changed (default value being 2^20)
> > 
> 
> So am I correct in believing that this regression is due to the
> high-order allocations putting excess stress onto page reclaim?
> 

This is very plausible but it would be nice to get confirmation on
what the size of the fdtable was to be sure. If it's big enough for
high-order allocations and it's a fork-heavy workload with memory
mostly in use, the fork() latencies could be getting very high. In
addition, each fork is potentially kicking kswapd awake (to rebalance
the zone for higher orders). I do not see CONFIG_COMPACTION enabled
meaning that if I'm right in that kswapd is awake and fork() is
entering direct reclaim, then we are lumpy reclaiming as well which
can stall pretty severely.

> If so, then how large _are_ these allocations?  This perhaps can be
> determined from /proc/slabinfo.  They must be pretty huge, because slub
> likes to do excessively-large allocations and the system handles that
> reasonably well.
> 

I'd be interested in finding out the value of /proc/sys/fs/file-max and
the output of ulimit -n (max open files) for the main server is. This
should help us determine what the size of the fdtable is.

> I suppose that a suitable fix would be
> 
> 
> From: Andrew Morton <akpm@linux-foundation.org>
> 
> Azurit reports large increases in system time after 2.6.36 when running
> Apache.  It was bisected down to a892e2d7dcdfa6c76e6 ("vfs: use kmalloc()
> to allocate fdmem if possible").
> 
> That patch caused the vfs to use kmalloc() for very large allocations and
> this is causing excessive work (and presumably excessive reclaim) within
> the page allocator.
> 
> Fix it by falling back to vmalloc() earlier - when the allocation attempt
> would have been considered "costly" by reclaim.
> 
> Reported-by: azurIt <azurit@pobox.sk>
> Cc: Changli Gao <xiaosuo@gmail.com>
> Cc: Americo Wang <xiyou.wangcong@gmail.com>
> Cc: Jiri Slaby <jslaby@suse.cz>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  fs/file.c |   17 ++++++++++-------
>  1 file changed, 10 insertions(+), 7 deletions(-)
> 
> diff -puN fs/file.c~a fs/file.c
> --- a/fs/file.c~a
> +++ a/fs/file.c
> @@ -39,14 +39,17 @@ int sysctl_nr_open_max = 1024 * 1024; /*
>   */
>  static DEFINE_PER_CPU(struct fdtable_defer, fdtable_defer_list);
>  
> -static inline void *alloc_fdmem(unsigned int size)
> +static void *alloc_fdmem(unsigned int size)
>  {
> -	void *data;
> -
> -	data = kmalloc(size, GFP_KERNEL|__GFP_NOWARN);
> -	if (data != NULL)
> -		return data;
> -
> +	/*
> +	 * Very large allocations can stress page reclaim, so fall back to
> +	 * vmalloc() if the allocation size will be considered "large" by the VM.
> +	 */
> +	if (size <= (PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER) {

The reporter will need to retest this is really ok. The patch that was
reported to help avoided high-order allocations entirely. If fork-heavy
workloads are really entering direct reclaim and increasing fork latency
enough to ruin performance, then this patch will also suffer. How much
it helps depends on how big fdtable.

> +		void *data = kmalloc(size, GFP_KERNEL|__GFP_NOWARN);
> +		if (data != NULL)
> +			return data;
> +	}
>  	return vmalloc(size);
>  }
>  

I'm attaching a primitive perl script that reports high-order allocation
latencies. I'd be interesting to see what the output of it looks like,
particularly when the server is in trouble if the bug reporter as the
time.

-- 
Mel Gorman
SUSE Labs

--17pEHd4RhPHOinZp
Content-Type: application/x-perl
Content-Disposition: attachment; filename="watch-highorder-latency.pl"
Content-Transfer-Encoding: quoted-printable

#!/usr/bin/perl=0A# watch-highorder-latency - Print out allocation latencie=
s=0A# This is a very simple script that just dumps out how long an allocati=
on took.=0A# It's incompatible to run with any other tracing as assumptions=
 are being=0A# made about the output=0A=0Ause strict;=0Ause Time::HiRes qw(=
 usleep ualarm gettimeofday tv_interval );=0A=0Amy $ftrace_prefix=3D"/sys/k=
ernel/debug/tracing";=0Amy $exiting =3D 0;=0Amy $highorder_only =3D 1;=0A=
=0Asub write_value {=0A	my ($file, $value) =3D @_;=0A=0A	open (SYSFS, ">$fi=
le") or die("Failed to open $file for writing");=0A	print SYSFS $value;=0A	=
close SYSFS=0A}=0A=0Asub sigint_handler {=0A	$exiting =3D 1;=0A}=0A$SIG{INT=
} =3D "sigint_handler";=0A=0A# Configure ftrace to capture allocation laten=
cies=0Awrite_value("$ftrace_prefix/set_ftrace_filter", "__alloc_pages_nodem=
ask");=0Awrite_value("$ftrace_prefix/current_tracer", "function_graph");=0A=
write_value("$ftrace_prefix/events/kmem/mm_page_alloc/enable", "1");=0A=0Ao=
pen(FTRACE_PIPE, "$ftrace_prefix/trace_pipe") or die("Failed to open trace_=
pipe");=0Amy $line;=0Amy (@elements, $latency, $order);=0Amy ($sec, $msec);=
=0Amy $status;=0A=0A# Yes, this check means that a line of input from the p=
ipe is required before=0A# an update to exiting is noticed. In this case, i=
t's expected there will be=0A# a page allocation soon=0Awhile (!eof(FTRACE_=
PIPE) && !$exiting) {=0A	$line =3D <FTRACE_PIPE>;=0A	if ($line =3D~ /.*mm_p=
age_alloc:.*/) {=0A		@elements =3D split(/\s+/, $line);=0A=0A		if ($element=
s[6] eq "(null)") {=0A			$status =3D "failure";=0A			$order =3D $elements[8=
];=0A		} else {=0A			$status =3D "success";=0A			$order =3D $elements[7];=
=0A		}=0A		$order =3D substr $order, 6;=0A		if ($highorder_only && $order =
=3D=3D 0) {=0A			next;=0A		}=0A		=0A		$line =3D <FTRACE_PIPE>;=0A		while ($=
line !~ /\|  }$/) {=0A			$line =3D <FTRACE_PIPE>;=0A		}=0A		@elements =3D s=
plit(/\s+/, $line);=0A		$latency =3D $elements[2];=0A		if ( $latency !~ /^[=
0-9]/) {=0A			$latency =3D $elements[3];=0A		}=0A		if ( $latency !~ /^[0-9]=
/) {=0A			$latency =3D "BROKEN: $line";=0A		}=0A		($sec, $msec) =3D gettime=
ofday;=0A=0A		print "$sec.$msec $order $latency $status\n";=0A	}=0A}=0A=0Ac=
lose(FTRACE_PIPE);=0A
--17pEHd4RhPHOinZp--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
