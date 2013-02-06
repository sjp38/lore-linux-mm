Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id D3B176B0005
	for <linux-mm@kvack.org>; Wed,  6 Feb 2013 11:31:33 -0500 (EST)
Date: Wed, 6 Feb 2013 16:31:29 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Improving lock pages
Message-ID: <20130206163129.GR21389@suse.de>
References: <20130115173814.GA13329@gulag1.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130115173814.GA13329@gulag1.americas.sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nathan Zimmer <nzimmer@sgi.com>
Cc: holt@sgi.com, linux-mm@kvack.org

On Tue, Jan 15, 2013 at 11:38:14AM -0600, Nathan Zimmer wrote:
> 
> Hello Mel,

Hi Nathan,

>     You helped some time ago with contention in lock_pages on very large boxes. 

It was Nick Piggin and Jack Steiner that helped the situation within SLES
and before my time. I inherited the relevant patches but made relatively
few contributions to the effort.

> You worked with Jack Steiner on this.  Currently I am tasked with improving this 
> area even more.  So I am fishing for any more ideas that would be productive or 
> worth trying. 
> 
> I have some numbers from a 512 machine.
> 
> Linux uvpsw1 3.0.51-0.7.9-default #1 SMP Thu Nov 29 22:12:17 UTC 2012 (f3be9d0) x86_64 x86_64 x86_64 GNU/Linux
>       0.166850
>       0.082339
>       0.248428
>       0.081197
>       0.127635

Ok, this looks like a SLES 11 SP2 kernel and so includes some unlock/lock
page optimisations.

> Linux uvpsw1 3.8.0-rc1-medusa_ntz_clean-dirty #32 SMP Tue Jan 8 16:01:04 CST 2013 x86_64 x86_64 x86_64 GNU/Linux
>       0.151778
>       0.118343
>       0.135750
>       0.437019
>       0.120536
> 

And this is a mainline-ish kernel which doesn't.

The main reason I never made an strong effort to push them upstream
because the problems are barely observable on any machine I had access to.
The unlock page optimisation requires a page flag and while it helps
profiles a little, the effects are barely observable on smaller machines
(at least since I last checked).  One machine it was reported to help
dramatically was a 768-way 128 node machine.

Forthe 512-way machine you're testing with the figures are marginal. The
time to exit is shorter but the amount of time is tiny and very close to
noise. I forward ported the relevant patches but on a 48-way machine the
results for the same test were well within the noise and the standard
deviation was higher.

I know you're tasked with improving this area more but what are you
using as your example workload? What's the minimum sized machine needed
for the optimisations to make a difference?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
