Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 3BF0B6B0033
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 17:07:03 -0400 (EDT)
Date: Wed, 14 Aug 2013 14:07:00 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v8] mm: make lru_add_drain_all() selective
Message-Id: <20130814140700.5fee193b193a529e72fa5a37@linux-foundation.org>
In-Reply-To: <20130814205029.GN28628@htj.dyndns.org>
References: <20130814200748.GI28628@htj.dyndns.org>
	<201308142029.r7EKTMRw023404@farm-0002.internal.tilera.com>
	<20130814134430.50cb8d609643620b00ab3705@linux-foundation.org>
	<20130814205029.GN28628@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Chris Metcalf <cmetcalf@tilera.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Frederic Weisbecker <fweisbec@gmail.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

On Wed, 14 Aug 2013 16:50:29 -0400 Tejun Heo <tj@kernel.org> wrote:

> On Wed, Aug 14, 2013 at 01:44:30PM -0700, Andrew Morton wrote:
> > > +static bool need_activate_page_drain(int cpu)
> > > +{
> > > +	return pagevec_count(&per_cpu(activate_page_pvecs, cpu)) != 0;
> > > +}
> > 
> > static int need_activate_page_drain(int cpu)
> > {
> > 	return pagevec_count(&per_cpu(activate_page_pvecs, cpu));
> > }
> > 
> > would be shorter and faster.  bool rather sucks that way.  It's a
> > performance-vs-niceness thing.  I guess one has to look at the call
> > frequency when deciding.
> 
> "!= 0" can be dropped but I'm fairly sure the compiler would be able
> to figure out that the type conversion can be skipped.  It's a trivial
> optimization.

The != 0 can surely be removed and that shouldn't make any difference
to generated code.

The compiler will always need to do the int-to-bool conversion and
that's overhead which is added by using bool.

It's possible that the compiler will optmise away the int-to-bool
conversion when inlining this function into a callsite.  I don't know
whether the compiler _does_ do this and it will be version dependent.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
