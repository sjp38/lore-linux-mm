Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8C3A39000BD
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 15:15:09 -0400 (EDT)
Received: by eye13 with SMTP id 13so6451111eye.14
        for <linux-mm@kvack.org>; Tue, 27 Sep 2011 12:15:06 -0700 (PDT)
Date: Tue, 27 Sep 2011 23:14:13 +0400
From: Vasiliy Kulikov <segoon@openwall.com>
Subject: Re: [PATCH 2/2] mm: restrict access to /proc/meminfo
Message-ID: <20110927191413.GA4820@albatros>
References: <20110927175453.GA3393@albatros>
 <20110927175642.GA3432@albatros>
 <alpine.DEB.2.00.1109271122480.17876@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1109271122480.17876@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: kernel-hardening@lists.openwall.com, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Kees Cook <kees@ubuntu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Valdis.Kletnieks@vt.edu, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@linux.intel.com>, linux-kernel@vger.kernel.org

On Tue, Sep 27, 2011 at 11:27 -0700, David Rientjes wrote:
> On Tue, 27 Sep 2011, Vasiliy Kulikov wrote:
> 
> > /proc/meminfo stores information related to memory pages usage, which
> > may be used to monitor the number of objects in specific caches (and/or
> > the changes of these numbers).  This might reveal private information
> > similar to /proc/slabinfo infoleaks.  To remove the infoleak, just
> > restrict meminfo to root.  If it is used by unprivileged daemons,
> > meminfo permissions can be altered the same way as slabinfo:
> > 
> >     groupadd meminfo
> >     usermod -a -G meminfo $MONITOR_USER
> >     chmod g+r /proc/meminfo
> >     chgrp meminfo /proc/meminfo
> > 
> 
> I guess the side-effect of this is that users without root will no longer 
> report VM issues where "there's tons of freeable memory but my task got 
> killed", "there's swap available but is unutilized in lowmem situations", 
> etc. :)

Uhh, lost of "free" is rather significant.

> Seriously, though, can't we just change the granularity of /proc/meminfo 
> to be MB instead of KB or at least provide a separate file that is 
> readable that does that?  I can understand not exporting information on a 
> page-level granularity but not giving users a way to determine the amount 
> of free memory is a little extreme.

Probably it is the way to go.  Users still may identify *some*
information about the slab objects in question (ecryptfs, etc.), but it
is more limited with MB granularity.  Though, it is probably the only
acceptable tradeoff in sense of backward compatibility.

Thank you,

-- 
Vasiliy Kulikov
http://www.openwall.com - bringing security into open computing environments

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
