Date: Tue, 3 Apr 2007 16:02:31 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: missing madvise functionality
Message-Id: <20070403160231.33aa862d.akpm@linux-foundation.org>
In-Reply-To: <20070403144948.fe8eede6.akpm@linux-foundation.org>
References: <46128051.9000609@redhat.com>
	<p73648dz5oa.fsf@bingen.suse.de>
	<46128CC2.9090809@redhat.com>
	<20070403172841.GB23689@one.firstfloor.org>
	<20070403125903.3e8577f4.akpm@linux-foundation.org>
	<4612B645.7030902@redhat.com>
	<20070403202937.GE355@devserv.devel.redhat.com>
	<20070403144948.fe8eede6.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jakub Jelinek <jakub@redhat.com>, Ulrich Drepper <drepper@redhat.com>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Tue, 3 Apr 2007 14:49:48 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> > int
> > main (void)
> > {
> >   pthread_t th[32];
> >   int i;
> >   for (i = 0; i < 32; i++)
> >     if (pthread_create (&th[i], NULL, tf, NULL))
> >       exit (4);
> >   for (i = 0; i < 32; i++)
> >     pthread_join (th[i], NULL);
> >   return 0;
> > }
> > 
> 
> whee.  135,000 context switches/sec on a slow 2-way.  mmap_sem, most
> likely.  That is ungood.
> 
> Did anyone monitor the context switch rate with the mysql test?
> 
> Interestingly, your test app (with s/100000/1000) runs to completion in 13
> seocnd on the slow 2-way.  On a fast 8-way, it took 52 seconds and
> sustained 40,000 context switches/sec.  That's a bit unexpected.
> 
> Both machines show ~8% idle time, too :(

All of which indicates that if we can remove the down_write(mmap_sem) from
this glibc operation, things should get a lot better - there will be no
additional context switches at all.

And we can surely do that if all we're doing is looking up pageframes,
putting pages into fake-swapcache and moving them around on the page LRUs.

Hugh?  Sanity check?

That difference between the 2-way and the 8-way sure is odd.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
