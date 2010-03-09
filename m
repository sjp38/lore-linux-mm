Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 346EF6B00D4
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 15:35:15 -0500 (EST)
Date: Tue, 9 Mar 2010 15:33:26 -0500 (EST)
From: "Robert P. J. Day" <rpjday@crashcourse.ca>
Subject: Re: mm: Do not iterate over NR_CPUS in __zone_pcp_update()
In-Reply-To: <20100309122253.3f3d4a53.akpm@linux-foundation.org>
Message-ID: <alpine.LFD.2.00.1003091530230.11928@localhost>
References: <alpine.LFD.2.00.1003081018070.22855@localhost.localdomain> <20100309122253.3f3d4a53.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 9 Mar 2010, Andrew Morton wrote:

> On Mon, 8 Mar 2010 10:21:04 +0100 (CET)
> Thomas Gleixner <tglx@linutronix.de> wrote:
>
> > __zone_pcp_update() iterates over NR_CPUS instead of limiting the
> > access to the possible cpus. This might result in access to
> > uninitialized areas as the per cpu allocator only populates the per
> > cpu memory for possible cpus.
> >
> > Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
> > ---
> >  mm/page_alloc.c |    2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> >
> > Index: linux-2.6/mm/page_alloc.c
> > ===================================================================
> > --- linux-2.6.orig/mm/page_alloc.c
> > +++ linux-2.6/mm/page_alloc.c
> > @@ -3224,7 +3224,7 @@ static int __zone_pcp_update(void *data)
> >  	int cpu;
> >  	unsigned long batch = zone_batchsize(zone), flags;
> >
> > -	for (cpu = 0; cpu < NR_CPUS; cpu++) {
> > +	for_each_possible_cpu(cpu) {
> >  		struct per_cpu_pageset *pset;
> >  		struct per_cpu_pages *pcp;
>
> I'm having trouble working out whether we want to backport this into
> 2.6.33.x or earlier.  Help?

  given the above aesthetic mod, shouldn't that same change be applied
to *all* explicit loops of that form?  after all, checkpatch.pl warns
against it:

=====
# use of NR_CPUS is usually wrong
# ignore definitions of NR_CPUS and usage to define arrays as likely right
                if ($line =~ /\bNR_CPUS\b/ &&
                    $line !~ /^.\s*\s*#\s*if\b.*\bNR_CPUS\b/ &&
                    $line !~ /^.\s*\s*#\s*define\b.*\bNR_CPUS\b/ &&
                    $line !~ /^.\s*$Declare\s.*\[[^\]]*NR_CPUS[^\]]*\]/ &&
                    $line !~ /\[[^\]]*\.\.\.[^\]]*NR_CPUS[^\]]*\]/ &&
                    $line !~ /\[[^\]]*NR_CPUS[^\]]*\.\.\.[^\]]*\]/)
                {
                        WARN("usage of NR_CPUS is often wrong - consider using cpu_possible(), num_possible_cpus(), for_each_possible_cpu(), etc\n" . $herecurr);
                }
=====

rday
--

========================================================================
Robert P. J. Day                               Waterloo, Ontario, CANADA

            Linux Consulting, Training and Kernel Pedantry.

Web page:                                          http://crashcourse.ca
Twitter:                                       http://twitter.com/rpjday
========================================================================

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
