Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7B1558D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 22:09:44 -0400 (EDT)
Date: Tue, 29 Mar 2011 19:10:07 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH]mmap: add alignment for some variables
Message-Id: <20110329191007.04e8376a.akpm@linux-foundation.org>
In-Reply-To: <1301450041.3981.55.camel@sli10-conroe>
References: <1301277536.3981.27.camel@sli10-conroe>
	<m2oc4v18x8.fsf@firstfloor.org>
	<1301360054.3981.31.camel@sli10-conroe>
	<20110329152434.d662706f.akpm@linux-foundation.org>
	<1301446882.3981.33.camel@sli10-conroe>
	<20110329180611.a71fe829.akpm@linux-foundation.org>
	<1301447843.3981.48.camel@sli10-conroe>
	<20110329182544.6ad4eccb.akpm@linux-foundation.org>
	<1301449000.3981.52.camel@sli10-conroe>
	<20110329184110.0086924e.akpm@linux-foundation.org>
	<1301450041.3981.55.camel@sli10-conroe>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

On Wed, 30 Mar 2011 09:54:01 +0800 Shaohua Li <shaohua.li@intel.com> wrote:

> On Wed, 2011-03-30 at 09:41 +0800, Andrew Morton wrote:
> > On Wed, 30 Mar 2011 09:36:40 +0800 Shaohua Li <shaohua.li@intel.com> wrote:
> > 
> > > > how is it that this improves things?
> > > Hmm, it actually is:
> > > struct percpu_counter {
> > >  	spinlock_t lock;
> > >  	s64 count;
> > >  #ifdef CONFIG_HOTPLUG_CPU
> > >  	struct list_head list;	/* All percpu_counters are on a list */
> > >  #endif
> > >  	s32 __percpu *counters;
> > >  } __attribute__((__aligned__(1 << (INTERNODE_CACHE_SHIFT))))
> > > so lock and count are in one cache line.
> > 
> > ____cacheline_aligned_in_smp would achieve that?
> ____cacheline_aligned_in_smp can't guarantee the cache alignment for
> multiple nodes, because the variable can be updated by multiple
> nodes/cpus.

Confused.  If an object is aligned at a mulitple-of-128 address on one
node, it is aligned at a multiple-of-128 address when viewed from other
nodes, surely?

Even if the cache alignment to which you're referring is the internode
cache, can a 34-byte, L1-cache-aligned structure ever span multiple
internode cachelines?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
