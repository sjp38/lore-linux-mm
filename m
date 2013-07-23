Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id D8C156B0032
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 13:32:23 -0400 (EDT)
Date: Tue, 23 Jul 2013 12:32:23 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm: zswap: add runtime enable/disable
Message-ID: <20130723173223.GB5820@medulla.variantweb.net>
References: <1374521642-25478-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <51EE49D7.4060501@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51EE49D7.4060501@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <bob.liu@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@sr71.net>, Bob Liu <lliubbo@gmail.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jul 23, 2013 at 05:16:07PM +0800, Bob Liu wrote:
> On 07/23/2013 03:34 AM, Seth Jennings wrote:
> > Right now, zswap can only be enabled at boot time.  This patch
> > modifies zswap so that it can be dynamically enabled or disabled
> > at runtime.
> > 
> > In order to allow this ability, zswap unconditionally registers as a
> > frontswap backend regardless of whether or not zswap.enabled=1 is passed
> > in the boot parameters or not.  This introduces a very small overhead
> > for systems that have zswap disabled as calls to frontswap_store() will
> > call zswap_frontswap_store(), but there is a fast path to immediately
> > return if zswap is disabled.
> 
> There is also overhead in frontswap_load() after all pages are faulted
> back into memory.

This is true.  However frontswap_load() (__frontswap_load() to be more
precise) will not call into the backend since the bit in the
frontswap_map will not be set.  But there is the overhead of checking
that bit, you're right.

> 
> > 
> > Disabling zswap does not unregister zswap from frontswap.  It simply
> > blocks all future stores.
> > 
> > Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
> > ---
> >  Documentation/vm/zswap.txt | 18 ++++++++++++++++--
> >  mm/zswap.c                 |  9 +++------
> >  2 files changed, 19 insertions(+), 8 deletions(-)
> > 
> > diff --git a/Documentation/vm/zswap.txt b/Documentation/vm/zswap.txt
> > index 7e492d8..d588477 100644
> > --- a/Documentation/vm/zswap.txt
> > +++ b/Documentation/vm/zswap.txt
> > @@ -26,8 +26,22 @@ Zswap evicts pages from compressed cache on an LRU basis to the backing swap
> >  device when the compressed pool reaches it size limit.  This requirement had
> >  been identified in prior community discussions.
> >  
> > -To enabled zswap, the "enabled" attribute must be set to 1 at boot time.  e.g.
> > -zswap.enabled=1
> > +Zswap is disabled by default but can be enabled at boot time by setting
> > +the "enabled" attribute to 1 at boot time. e.g. zswap.enabled=1.  Zswap
> > +can also be enabled and disabled at runtime using the sysfs interface.
> > +An exmaple command to enable zswap at runtime, assuming sysfs is mounted
> > +at /sys, is:
> > +
> > +echo 1 > /sys/modules/zswap/parameters/enabled
> > +
> > +When zswap is disabled at runtime, it will stop storing pages that are
> > +being swapped out.  However, it will _not_ immediately write out or
> > +fault back into memory all of the pages stored in the compressed pool.
> 
> I don't know what's you use case of adding this feature.

Dave expressed interest in having it, useful for testing, and I can see
people that just wanting to try it out enabling it manually at runtime.

> In my opinion I'd perfer to flush all the pages stored in zswap when
> disabled it, so that I can run testing without rebooting the machine.

Why would you have to reboot your machine?  If you want to force all
the pages out of the compressed pool, a swapoff should do it as now
noted in the Documentation file (below).

Seth 

> 
> > +The pages stored in zswap will continue to remain in the compressed pool
> > +until they are either invalidated or faulted back into memory.  In order
> > +to force all pages out of the compressed pool, a swapoff on the swap
> > +device(s) will fault all swapped out pages, included those in the
> > +compressed pool, back into memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
