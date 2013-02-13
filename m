Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id B5D4B6B0005
	for <linux-mm@kvack.org>; Wed, 13 Feb 2013 05:47:59 -0500 (EST)
Date: Wed, 13 Feb 2013 10:47:55 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Improving lock pages
Message-ID: <20130213104755.GH4100@suse.de>
References: <20130115173814.GA13329@gulag1.americas.sgi.com>
 <20130206163129.GR21389@suse.de>
 <5115743D.3090903@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <5115743D.3090903@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nathan Zimmer <nzimmer@sgi.com>
Cc: holt@sgi.com, linux-mm@kvack.org

On Fri, Feb 08, 2013 at 03:55:09PM -0600, Nathan Zimmer wrote:
> >The main reason I never made an strong effort to push them upstream
> >because the problems are barely observable on any machine I had access to.
> >The unlock page optimisation requires a page flag and while it helps
> >profiles a little, the effects are barely observable on smaller machines
> >(at least since I last checked).  One machine it was reported to help
> >dramatically was a 768-way 128 node machine.
> >
> >Forthe 512-way machine you're testing with the figures are marginal. The
> >time to exit is shorter but the amount of time is tiny and very close to
> >noise. I forward ported the relevant patches but on a 48-way machine the
> >results for the same test were well within the noise and the standard
> >deviation was higher.
>
> One thing I had noticed the performance curve on this issue is worse
> then linear.
> This has made it tough to measure/capture data on smaller boxes.
> 

While this is true the figures you present are of marginal gain given the
complexity involved.  I know the patches also affected boot-times quite
significantly but this was not a common task for the machines involved.

> >I know you're tasked with improving this area more but what are you
> >using as your example workload? What's the minimum sized machine needed
> >for the optimisations to make a difference?
> >
>
> Right now I am just using the time_exit test I posted earlier.
> I know it is a bit artificial and am open to suggestion.
> 

I'm not currently aware of a workload that is dominated by lock_page
contention and I was expecting SGI was. There are plenty of times where we
stall on lock_page but it's usually IO related and not because processes
trying to acquire the lock went to sleep too quickly.

> One of the rough goals is to get under a second on a 4096 box.
> 
> Also here are some numbers from a larger box with 3.8-rc4...
> nzimmer@uv48-sys:~/tests/time_exit> for I in $(seq 1 5); {
> ./time_exit -p 3 2048; }
>       0.762282
>       0.810356
>       0.777785
>       0.840679
>       0.743509
> 
> nzimmer@uv48-sys:~/tests/time_exit> for I in $(seq 1 5); {
> ./time_exit -p 3 4096; }
>       2.550571
>       2.374378
>       2.669021
>       2.703232
>       2.679028
> 

I collapsed the patches, editted them a bit and pushed them to the
mm-lock-page-optimise-v1r1 branch in the git repository
git://git.kernel.org/pub/scm/linux/kernel/git/mel/linux.git 

The patches are rebased against 3.8-rc6 but I did not pay any special
attention to actually improving them. I did leave a few notes on what could
be done in the changelog. You could try them out as a starting point and
see if they can be reduced to the minimum you require. Unfortunately I
suspect that you'll need a more compelling test case than time_exit on a
4096-way machine to justify pushing them to mainline.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
