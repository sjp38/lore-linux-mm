Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id AE9566B0002
	for <linux-mm@kvack.org>; Thu, 21 Mar 2013 08:35:07 -0400 (EDT)
Date: Thu, 21 Mar 2013 13:35:05 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch] mm: speedup in __early_pfn_to_nid
Message-ID: <20130321123505.GA6051@dhcp22.suse.cz>
References: <20130318155619.GA18828@sgi.com>
 <20130321105516.GC18484@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130321105516.GC18484@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Russ Anderson <rja@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com

On Thu 21-03-13 11:55:16, Ingo Molnar wrote:
> 
> * Russ Anderson <rja@sgi.com> wrote:
> 
> > When booting on a large memory system, the kernel spends
> > considerable time in memmap_init_zone() setting up memory zones.
> > Analysis shows significant time spent in __early_pfn_to_nid().
> > 
> > The routine memmap_init_zone() checks each PFN to verify the
> > nid is valid.  __early_pfn_to_nid() sequentially scans the list of
> > pfn ranges to find the right range and returns the nid.  This does
> > not scale well.  On a 4 TB (single rack) system there are 308
> > memory ranges to scan.  The higher the PFN the more time spent
> > sequentially spinning through memory ranges.
> > 
> > Since memmap_init_zone() increments pfn, it will almost always be
> > looking for the same range as the previous pfn, so check that
> > range first.  If it is in the same range, return that nid.
> > If not, scan the list as before.
> > 
> > A 4 TB (single rack) UV1 system takes 512 seconds to get through
> > the zone code.  This performance optimization reduces the time
> > by 189 seconds, a 36% improvement.
> > 
> > A 2 TB (single rack) UV2 system goes from 212.7 seconds to 99.8 seconds,
> > a 112.9 second (53%) reduction.
> 
> Nice speedup!
> 
> A minor nit, in addition to Andrew's suggestion about wrapping 
> __early_pfn_to_nid():
> 
> > Index: linux/mm/page_alloc.c
> > ===================================================================
> > --- linux.orig/mm/page_alloc.c	2013-03-18 10:52:11.510988843 -0500
> > +++ linux/mm/page_alloc.c	2013-03-18 10:52:14.214931348 -0500
> > @@ -4161,10 +4161,19 @@ int __meminit __early_pfn_to_nid(unsigne
> >  {
> >  	unsigned long start_pfn, end_pfn;
> >  	int i, nid;
> > +	static unsigned long last_start_pfn, last_end_pfn;
> > +	static int last_nid;
> 
> Please move these globals out of function local scope, to make it more 
> apparent that they are not on-stack. I only noticed it in the second pass.

Wouldn't this just add more confision with other _pfn variables? (e.g.
{min,max}_low_pfn and others)

IMO the local scope is more obvious as this is and should only be used
for caching purposes.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
