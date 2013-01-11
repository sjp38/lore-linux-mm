Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 402C16B0068
	for <linux-mm@kvack.org>; Fri, 11 Jan 2013 15:31:51 -0500 (EST)
Date: Fri, 11 Jan 2013 12:31:49 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC] Reproducible OOM with partial workaround
Message-Id: <20130111123149.c3232a96.akpm@linux-foundation.org>
In-Reply-To: <201301111151.r0BBpZt1023276@como.maths.usyd.edu.au>
References: <20130111000119.8e9bdf5d.akpm@linux-foundation.org>
	<201301111151.r0BBpZt1023276@como.maths.usyd.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paul.szabo@sydney.edu.au
Cc: 695182@bugs.debian.org, dave@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 11 Jan 2013 22:51:35 +1100
paul.szabo@sydney.edu.au wrote:

> Dear Andrew,
> 
> > Check /proc/slabinfo, see if all your lowmem got eaten up by buffer_heads.
> 
> Please see below: I do not know what any of that means. This machine has
> been running just fine, with all my users logging in here via XDMCP from
> X-terminals, dozens logged in simultaneously. (But, I think I could make
> it go OOM with more processes or logins.)

I'm counting 107MB in slab there.  Was this dump taken when the system
was at or near oom?

Please send a copy of the oom-killer kernel message dump, if you still
have one.

> > If so, you *may* be able to work around this by setting
> > /proc/sys/vm/dirty_ratio really low, so the system keeps a minimum
> > amount of dirty pagecache around.  Then, with luck, if we haven't
> > broken the buffer_heads_over_limit logic it in the past decade (we
> > probably have), the VM should be able to reclaim those buffer_heads.
> 
> I tried setting dirty_ratio to "funny" values, that did not seem to
> help.

Did you try setting it as low as possible?

> Did you notice my patch about bdi_position_ratio(), how it was
> plain wrong half the time (for negative x)? 

Nope, please resend.

> Anyway that did not help.
> 
> > Alternatively, use a filesystem which doesn't attach buffer_heads to
> > dirty pages.  xfs or btrfs, perhaps.
> 
> Seems there is also a problem not related to filesystem... or rather,
> the essence does not seem to be filesystem or caches. The filesystem
> thing now seems OK with my patch doing drop_caches.

hm, if doing a regular drop_caches fixes things then that implies the
problem is not with dirty pagecache.  Odd.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
