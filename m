Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id B3F256B0092
	for <linux-mm@kvack.org>; Thu, 23 Feb 2012 10:24:05 -0500 (EST)
Date: Thu, 23 Feb 2012 13:22:27 -0200
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH] oom: add sysctl to enable slab memory dump
Message-ID: <20120223152226.GA2014@x61.redhat.com>
References: <20120222115320.GA3107@x61.redhat.com>
 <alpine.DEB.2.00.1202221640420.14213@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1202221640420.14213@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, Randy Dunlap <rdunlap@xenotime.net>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, Josef Bacik <josef@redhat.com>, linux-kernel@vger.kernel.org

On Wed, Feb 22, 2012 at 04:44:58PM -0800, David Rientjes wrote:
> I don't like this because it duplicates what is given by /proc/slabinfo 
> that can easily be read at the time of oom and is unnecessary to dump to 
> the kernel log.  We display the meminfo (which includes the amount of 
> slab, just not broken down by cache) because it's absolutely necessary to 
> understand why the oom was triggered.  The tasklist dump is allowed 
> because it's difficult to attain all that information easily and to 
> determine which threads are eligible in the oom context (global, memcg, 
> cpuset, mempolicy) so they matter to the oom condition.  The per-cache 
> slabinfo fits neither of that criteria and just duplicates code in the 
> slab allocators that is attainable elsewhere.

Lets say the slab gets so bloated that for every user task spawned OOM-killer 
just kills it instantly, or the system falls under severe thrashing, leaving no
chance for you getting an interactive session to parse /proc/slabinfo, thus 
making the reset button as your only escape... How would you identify what was 
the set of caches responsible by the slab swelling?

IMHO, having such qualified info about slab usage at hand is very useful in
several occurrences of OOM. It not only helps out developers, but also sysadmins
on troubleshooting slab usage when OOM-killer is invoked, thus qualifying and 
showing such data surely does make sense for a lot of people. For those who do 
not mind/care about such reporting, in the end it just takes a sysctl knob 
adjustment to make it go quiet.

> 
> I think this also gives another usecase for a possible /dev/mem_notify in 
> the future: userspace could easily poll on an eventfd and wait for an oom 
> to occur and then cat /proc/slabinfo to attain all this.  In other words, 
> if we had this functionality (which I think we undoubtedly will in the 
> future), this patch would be obsoleted.

Great! So, why not letting the time tell us if this feature will be obsoleted
or not? I'd rather have this patch obsoleted by another one proven better, than
just stay still waiting for something that might, or might not, happen in the
future.



Thanks for your feedback!
-- 
Rafael Aquini <aquini@redhat.com>
Software Maintenance Engineer
Red Hat, Inc.
+55 51 4063.9436 / 8426138 (ext)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
