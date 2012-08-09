Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 7062B6B002B
	for <linux-mm@kvack.org>; Thu,  9 Aug 2012 16:21:23 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <2e9ccb4f-1339-4c26-88dd-ea294b022127@default>
Date: Thu, 9 Aug 2012 13:20:55 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH 0/4] promote zcache from staging
References: <1343413117-1989-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <5021795A.5000509@linux.vnet.ibm.com> <5024067F.3010602@linux.vnet.ibm.com>
In-Reply-To: <5024067F.3010602@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org, Kurt Hackel <kurt.hackel@oracle.com>

> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> Subject: Re: [PATCH 0/4] promote zcache from staging
>=20
> On 08/07/2012 03:23 PM, Seth Jennings wrote:
> > On 07/27/2012 01:18 PM, Seth Jennings wrote:
> >> Some benchmarking numbers demonstrating the I/O saving that can be had
> >> with zcache:
> >>
> >> https://lkml.org/lkml/2012/3/22/383
> >
> > There was concern that kernel changes external to zcache since v3.3 may
> > have mitigated the benefit of zcache.  So I re-ran my kernel building
> > benchmark and confirmed that zcache is still providing I/O and runtime
> > savings.
>=20
> There was a request made to test with even greater memory pressure to
> demonstrate that, at some unknown point, zcache doesn't have real
> problems.  So I continued out to 32 threads:

Hi Seth --

Thanks for continuing with running the 24-32 thread benchmarks.

> Runtime (in seconds)
> N=09normal=09zcache=09%change
> 4=09126=09127=091%

> threads, even though the absolute runtime is suboptimal due to the
> extreme memory pressure.

I am not in a position right now to reproduce your results or
mine (due to a house move which is limiting my time and access
to my test machines, plus two presentations later this month at
Linuxcon NA and Plumbers) but I still don't think you've really
saturated the cache, which is when the extreme memory pressure
issues will show up in zcache.  I suspect that adding more threads
to a minimal kernel compile doesn't increase the memory pressure as
much as I was seeing, so you're not seeing what I was seeing:
the zcache number climb to as much as 150% WORSE than non-zcache.
In various experiments trying variations, I have seen four-fold
degradations and worse.

My test case is a kernel compile using a full OL kernel config
file, which is roughly equivalent to a RHEL6 config.  Compiling
this kernel, using similar hardware, I have never seen a runtime
less than ~800 seconds for any value of N.  I suspect that my
test case, having much more source to compile, causes the N threads
in a "make -jN" each have more work to do, in parallel.

Since your test harness is obviously all set up, would you be
willing to reproduce your/my non-zcache/zcache runs with a RHEL6
config file and publish the results (using a 3.5 zcache)?

IIRC, the really bad zcache results starting showing up at N=3D24.
I also wonder if you have anything else unusual in your
test setup, such as a fast swap disk (mine is a partition
on the same rotating disk as source and target of the kernel build,
the default install for a RHEL6 system)?  Or have you disabled
cleancache?  Or have you changed any sysfs parameters or
other kernel files?  Also, whether zcache or non-zcache,
I've noticed that the runtime of this workload when swapping
can vary by as much as 30-40%, so it would be wise to take at
least three samples to ensure a statistically valid comparison.
And are you using 512M of physical memory or relying on
kernel boot parameters to reduce visible memory... and
if the latter have you confirmed with /proc/meminfo?
Obviously, I'm baffled at the difference in our observations.

While I am always willing to admit that my numbers may be wrong,
I still can't imagine why you are in such a hurry to promote
zcache when these questions are looming.  Would you care to
explain why?  It seems reckless to me, and unlike the IBM
behavior I expect, so I really wonder about the motivation.

My goal is very simple: "First do no harm".  I don't think
zcache should be enabled for distros (and users) until we can
reasonably demonstrate that running a workload with zcache
is never substantially worse than running the same workload
without zcache.  If you can tell your customer: "Yes, always enable
zcache", great!  But if you have to tell your customer: "It
depends on the workload, enable it if it works for you, disable
it otherwise", then zcache will get a bad reputation, and
will/should never be enabled in a reputable non-hobbyist distro.
I fear the "demo" zcache will get a bad reputation
so prefer to delay promotion while there is serious doubt
about whether "harm" may occur.

Last, you've never explained what problems zcache solves
for you that zram does not.  With Minchan pushing for
the promotion of zram+zsmalloc, does zram solve your problem?
Another alternative might be to promote zcache as "demozcache"
(i.e. fork it for now).

It's hard to identify a reasonable compromise when you
are just saying "Gotta promote zcache NOW!" and not
explaining the problem you are trying to solve or motivations
behind it.

OK, Seth, I think all my cards are on the table.  Where's yours?
(And, hello, is anyone else following this anyway? :-)

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
