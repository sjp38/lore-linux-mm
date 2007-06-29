Date: Fri, 29 Jun 2007 16:12:54 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH 01 of 16] remove nr_scan_inactive/active
Message-ID: <20070629141254.GA23310@v2.random>
References: <8e38f7656968417dfee0.1181332979@v2.random> <466C36AE.3000101@redhat.com> <20070610181700.GC7443@v2.random> <46814829.8090808@redhat.com> <20070626105541.cd82c940.akpm@linux-foundation.org> <468439E8.4040606@redhat.com> <1183124309.5037.31.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1183124309.5037.31.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Nick Dokos <nicholas.dokos@hp.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jun 29, 2007 at 09:38:29AM -0400, Lee Schermerhorn wrote:
> On Thu, 2007-06-28 at 18:44 -0400, Rik van Riel wrote:
> > Andrew Morton wrote:
> > 
> > > Where's the system time being spent?
> > 
> > OK, it turns out that there is quite a bit of variability
> > in where the system spends its time.  I did a number of
> > reaim runs and averaged the time the system spent in the
> > top functions.
> > 
> > This is with the Fedora rawhide kernel config, which has
> > quite a few debugging options enabled.
> > 
> > _raw_spin_lock		32.0%
> > page_check_address	12.7%
> > __delay			10.8%
> > mwait_idle		10.4%
> > anon_vma_unlink		5.7%
> > __anon_vma_link		5.3%
> > lockdep_reset_lock	3.5%
> > __kmalloc_node_track_caller 2.8%
> > security_port_sid	1.8%
> > kfree			1.6%
> > anon_vma_link		1.2%
> > page_referenced_one	1.1%

BTW, hope the above numbers are measured before the trashing stage
when the number of jobs per second is lower than 10. It'd be nice not
to spend all that time in system time but after that point the system
will shortly reach oom. It's more important to be fast and save cpu in
"useful" conditions (like with <4000 tasks).

> Here's a fairly recent version of the patch if you want to try it on
> your workload.  We've seen mixed results on somewhat larger systems,
> with and without your split LRU patch.  I've started writing up those
> results.  I'll try to get back to finishing up the writeup after OLS and
> vacation.

This looks a very good idea indeed.

Overall the O(log(N)) change I doubt would help, being able to give an
efficient answer to "give me only the vmas that maps this anon page"
won't be helpful here since the answer will be the same as the current
question "give me any vma that may be mapping this anon page". Only
for the filebacked mappings it matters.

Also I'm stunned this is being compared to a java workload, java is a
threaded beast (unless you're capable of understanding async-io in
which case it's still threaded but with tons less threads, but anyway
you code it won't create any anonymous related overhead). What we deal
with isn't really an issue with anon-vma but just with the fact the
system is trying to unmap pages that are mapped in 4000-5000 pte, so
no matter how you code it, there will be still 4000-5000 ptes to check
for each page that we want to know if it's referenced and it will take
system time, this is an hardware issue not a software one. And the
other suspect thing is to do all that pte-mangling work without doing
any I/O at all.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
