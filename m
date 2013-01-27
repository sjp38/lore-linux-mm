Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id B7C356B0007
	for <linux-mm@kvack.org>; Sun, 27 Jan 2013 18:35:20 -0500 (EST)
Received: by mail-da0-f49.google.com with SMTP id v40so955845dad.22
        for <linux-mm@kvack.org>; Sun, 27 Jan 2013 15:35:20 -0800 (PST)
Date: Sun, 27 Jan 2013 15:35:21 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 11/11] ksm: stop hotremove lockdep warning
In-Reply-To: <1359267810.6763.1.camel@kernel>
Message-ID: <alpine.LNX.2.00.1301271526040.17495@eggly.anvils>
References: <alpine.LNX.2.00.1301251747590.29196@eggly.anvils> <alpine.LNX.2.00.1301251808120.29196@eggly.anvils> <1359267810.6763.1.camel@kernel>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Petr Holasek <pholasek@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <izik.eidus@ravellosystems.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun, 27 Jan 2013, Simon Jeons wrote:
> On Fri, 2013-01-25 at 18:10 -0800, Hugh Dickins wrote:
> > @@ -2098,15 +2117,15 @@ static int ksm_memory_callback(struct no
> >  	switch (action) {
> >  	case MEM_GOING_OFFLINE:
> >  		/*
> > -		 * Keep it very simple for now: just lock out ksmd and
> > -		 * MADV_UNMERGEABLE while any memory is going offline.
> > -		 * mutex_lock_nested() is necessary because lockdep was alarmed
> > -		 * that here we take ksm_thread_mutex inside notifier chain
> > -		 * mutex, and later take notifier chain mutex inside
> > -		 * ksm_thread_mutex to unlock it.   But that's safe because both
> > -		 * are inside mem_hotplug_mutex.
> > +		 * Prevent ksm_do_scan(), unmerge_and_remove_all_rmap_items()
> > +		 * and remove_all_stable_nodes() while memory is going offline:
> > +		 * it is unsafe for them to touch the stable tree at this time.
> > +		 * But unmerge_ksm_pages(), rmap lookups and other entry points
> 
> Why unmerge_ksm_pages beneath us is safe for ksm memory hotremove?
> 
> > +		 * which do not need the ksm_thread_mutex are all safe.

It's just like userspace doing a write-fault on every KSM page in the vma.
If that were unsafe for memory hotremove, then it would not be KSM's
problem, memory hotremove would already be unsafe.  (But memory hotremove
is safe because it migrates away from all the pages to be removed before
it can reach MEM_OFFLINE.)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
