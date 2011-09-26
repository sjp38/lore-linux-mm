Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 403B69000BD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 02:47:13 -0400 (EDT)
Received: by yia25 with SMTP id 25so5434652yia.14
        for <linux-mm@kvack.org>; Sun, 25 Sep 2011 23:47:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1317001924.29510.160.camel@sli10-conroe>
References: <1316940890-24138-1-git-send-email-gilad@benyossef.com>
	<1316940890-24138-5-git-send-email-gilad@benyossef.com>
	<1317001924.29510.160.camel@sli10-conroe>
Date: Mon, 26 Sep 2011 09:47:10 +0300
Message-ID: <CAOtvUMddUAATZcU_5jLgY10ocsHNnOO2GC2c4ecYO9KGt-U7VQ@mail.gmail.com>
Subject: Re: [PATCH 4/5] mm: Only IPI CPUs to drain local pages if they exist
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, Chris Metcalf <cmetcalf@tilera.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>

Hi Li,

Thank you for the feedback!

On Mon, Sep 26, 2011 at 4:52 AM, Shaohua Li <shaohua.li@intel.com> wrote:
> On Sun, 2011-09-25 at 16:54 +0800, Gilad Ben-Yossef wrote:
>> Use a cpumask to track CPUs with per-cpu pages in any zone
>> and only send an IPI requesting CPUs to drain these pages
>> to the buddy allocator if they actually have pages.
> Did you have evaluation why the fine-grained ipi is required? I suppose
> every CPU has local pages here.


I have given it a lot of though and I believe It's a question of work
load - in a "classic" symmetric work load on a small SMP system I
would indeed expect each CPU to have a per cpu pages cache in some
zone.  However, we are seeing more and more push towards massively
multi core systems and we add support for using them (e.g. cpusets,
Frederic's dynamic tick task patch set etc.). For these work loads,
things can be different:

In a system where you have many core (or hardware threads) and you
dedicate processors to run a singe CPU bound task that performs
virtually no system calls (quite typical for some high performance
computing set ups), you can very well have situations where the per
cpu released page is empty on many processors, since the working set
per cpu rarely changes, so there was now release since the last drain.

Or just consider a multicore machine where a lot of processors are
simply idle with no activity (and we now have cores with 8 cores / 128
hw threads in a single package) - again, no per CPU local page cache
since there was 0 activity since the last drain, but the IPI will be
yanking cores out of low power states to do the check.

I do not know if these scenarios warrant the additional overhead,
certainly not in all situations. Maybe the right thing is to make it a
config option dependent. As I stated in the patch description, that is
one of the thing I'm interested in feedback on.

Thanks,
Gilad

-- 
Gilad Ben-Yossef
Chief Coffee Drinker
gilad@benyossef.com
Israel Cell: +972-52-8260388
US Cell: +1-973-8260388
http://benyossef.com

"I've seen things you people wouldn't believe. Goto statements used to
implement co-routines. I watched C structures being stored in
registers. All those moments will be lost in time... like tears in
rain... Time to die. "

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
