Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 0D4466B002D
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 11:48:05 -0500 (EST)
Received: by qadc11 with SMTP id c11so376728qad.14
        for <linux-mm@kvack.org>; Mon, 21 Nov 2011 08:48:02 -0800 (PST)
Date: Mon, 21 Nov 2011 08:47:58 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3] PM/Memory-hotplug: Avoid task freezing failures
Message-ID: <20111121164758.GC15314@google.com>
References: <20111117083042.11419.19871.stgit@srivatsabhat.in.ibm.com>
 <201111192257.19763.rjw@sisk.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201111192257.19763.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, pavel@ucw.cz, lenb@kernel.org, ak@linux.intel.com, linux-kernel@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org

Hello, Rafael.

On Sat, Nov 19, 2011 at 10:57:19PM +0100, Rafael J. Wysocki wrote:
> > +	while (!mutex_trylock(&pm_mutex)) {
> > +		try_to_freeze();
> > +		msleep(10);
> 
> The number here seems to be somewhat arbitrary.  Is there any reason not to
> use 100 or any other number?

This is a bit moot at this point but, at least for me, yeah, it's a
number I pulled out of my ass.  That said, I think it's a good number
to pull out of ass for userland visible retry delays for the following
reasons.

* It's a good number - 10! which happens to match the number of
  fingers I have!  Isn't that just weird? @.@

* For modern hardware of most classes, repeating not-so-complex stuff
  every 10ms for a while isn't taxing (or even noticeable) at all.

* Sub 10ms delays usually aren't noticeable to human beings even when
  several of them are staggered.  This is very different when you get
  to 100ms range.

ie. going from 1ms to 10ms doesn't cost you too much in terms of human
noticeable latency (for this type of situations anyway) but going from
10ms to 100ms does.  In terms of computational cost, the reverse is
somewhat true too.  So, yeah, I think 10ms is a good out-of-ass number
for this type of delays.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
