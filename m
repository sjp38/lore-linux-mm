Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f179.google.com (mail-ie0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id 332916B00CF
	for <linux-mm@kvack.org>; Tue, 25 Feb 2014 12:19:49 -0500 (EST)
Received: by mail-ie0-f179.google.com with SMTP id to1so591112ieb.38
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 09:19:49 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id x8si39054155igw.12.2014.02.25.09.19.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Feb 2014 09:19:47 -0800 (PST)
Date: Tue, 25 Feb 2014 18:19:40 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] ksm: Expose configuration via sysctl
Message-ID: <20140225171940.GS6835@laptop.programming.kicks-ass.net>
References: <1393284484-27637-1-git-send-email-agraf@suse.de>
 <20140225171528.GJ4407@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140225171528.GJ4407@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Alexander Graf <agraf@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Hugh Dickins <hughd@google.com>, Izik Eidus <izik.eidus@ravellosystems.com>, Andrea Arcangeli <aarcange@redhat.com>

On Tue, Feb 25, 2014 at 12:15:28PM -0500, Johannes Weiner wrote:
> On Tue, Feb 25, 2014 at 12:28:04AM +0100, Alexander Graf wrote:
> > Configuration of tunables and Linux virtual memory settings has traditionally
> > happened via sysctl. Thanks to that there are well established ways to make
> > sysctl configuration bits persistent (sysctl.conf).
> > 
> > KSM introduced a sysfs based configuration path which is not covered by user
> > space persistent configuration frameworks.
> > 
> > In order to make life easy for sysadmins, this patch adds all access to all
> > KSM tunables via sysctl as well. That way sysctl.conf works for KSM as well,
> > giving us a streamlined way to make KSM configuration persistent.
> > 
> > Reported-by: Sasche Peilicke <speilicke@suse.com>
> > Signed-off-by: Alexander Graf <agraf@suse.de>
> > ---
> >  kernel/sysctl.c |   10 +++++++
> >  mm/ksm.c        |   78 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
> >  2 files changed, 88 insertions(+), 0 deletions(-)
> > 
> > diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> > index 332cefc..2169a00 100644
> > --- a/kernel/sysctl.c
> > +++ b/kernel/sysctl.c
> > @@ -217,6 +217,9 @@ extern struct ctl_table random_table[];
> >  #ifdef CONFIG_EPOLL
> >  extern struct ctl_table epoll_table[];
> >  #endif
> > +#ifdef CONFIG_KSM
> > +extern struct ctl_table ksm_table[];
> > +#endif
> >  
> >  #ifdef HAVE_ARCH_PICK_MMAP_LAYOUT
> >  int sysctl_legacy_va_layout;
> > @@ -1279,6 +1282,13 @@ static struct ctl_table vm_table[] = {
> >  	},
> >  
> >  #endif /* CONFIG_COMPACTION */
> > +#ifdef CONFIG_KSM
> > +	{
> > +		.procname	= "ksm",
> > +		.mode		= 0555,
> > +		.child		= ksm_table,
> > +	},
> > +#endif
> 
> ksm can be a module, so this won't work.
> 
> Can we make those controls proper module parameters instead?

You can do dynamic sysctl registration and removal. Its its own little
filesystem of sorts.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
