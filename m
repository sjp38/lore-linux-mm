Subject: Re: [PATCH 2/5] Swapless V2: Add migration swap entries
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20060413222516.4cb5885c.akpm@osdl.org>
References: <20060413235406.15398.42233.sendpatchset@schroedinger.engr.sgi.com>
	 <20060413235416.15398.49978.sendpatchset@schroedinger.engr.sgi.com>
	 <20060413171331.1752e21f.akpm@osdl.org>
	 <Pine.LNX.4.64.0604131728150.15802@schroedinger.engr.sgi.com>
	 <20060413174232.57d02343.akpm@osdl.org>
	 <Pine.LNX.4.64.0604131743180.15965@schroedinger.engr.sgi.com>
	 <20060413180159.0c01beb7.akpm@osdl.org>
	 <20060413181716.152493b8.akpm@osdl.org>
	 <Pine.LNX.4.64.0604131831150.16220@schroedinger.engr.sgi.com>
	 <20060413222516.4cb5885c.akpm@osdl.org>
Content-Type: text/plain
Date: Fri, 14 Apr 2006 10:27:43 -0400
Message-Id: <1145024863.5211.14.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Christoph Lameter <clameter@sgi.com>, hugh@veritas.com, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, taka@valinux.co.jp, marcelo.tosatti@cyclades.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Thu, 2006-04-13 at 22:25 -0700, Andrew Morton wrote:
> Christoph Lameter <clameter@sgi.com> wrote:
> >
> > On Thu, 13 Apr 2006, Andrew Morton wrote:
> > 
> > > Andrew Morton <akpm@osdl.org> wrote:
> > > >
> > > > Perhaps it would be better to go to
> > > >  sleep on some global queue, poke that queue each time a page migration
> > > >  completes?
> > > 
> > > Or take mmap_sem for writing in do_migrate_pages()?  That takes the whole
> > > pagefault path out of the picture.
> > 
> > We would have to take that for each task mapping the page. Very expensive 
> > operation.
> 
> So...  why does do_migrate_pages() take mmap_sem at all?
> 
> And the code we're talking about here deals with anonymous pages, which are
> not shared betweem mm's.

I think that anon pages are shared, copy-on-write, between parent and
child after a fork().  If no exec() and no task writes the page, the
sharing can become quite extensive.  I encountered this testing the
migrate-on-fault patches.  With MPOL_MF_MOVE, these shared anon pages
don't get migrated at all [sometimes this is what you want, sometimes
not...], but with '_MOVE_ALL the shared anon pages DO get migrated, so
you can have races between a faulting task and the migrating task.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
