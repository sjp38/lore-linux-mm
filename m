Date: Thu, 13 Apr 2006 17:46:11 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 2/5] Swapless V2: Add migration swap entries
In-Reply-To: <20060413174232.57d02343.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0604131743180.15965@schroedinger.engr.sgi.com>
References: <20060413235406.15398.42233.sendpatchset@schroedinger.engr.sgi.com>
 <20060413235416.15398.49978.sendpatchset@schroedinger.engr.sgi.com>
 <20060413171331.1752e21f.akpm@osdl.org> <Pine.LNX.4.64.0604131728150.15802@schroedinger.engr.sgi.com>
 <20060413174232.57d02343.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: hugh@veritas.com, linux-kernel@vger.kernel.org, lee.schermerhorn@hp.com, linux-mm@kvack.org, taka@valinux.co.jp, marcelo.tosatti@cyclades.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Thu, 13 Apr 2006, Andrew Morton wrote:

> Christoph Lameter <clameter@sgi.com> wrote:
> >
> > On Thu, 13 Apr 2006, Andrew Morton wrote:
> > 
> > > Christoph Lameter <clameter@sgi.com> wrote:
> > > >
> > > > +
> > > >  +	if (unlikely(is_migration_entry(entry))) {
> > > 
> > > Perhaps put the unlikely() in is_migration_entry()?
> > > 
> > > >  +		yield();
> > > 
> > > Please, no yielding.
> > > 
> > > _especially_ no unchangelogged, uncommented yielding.
> > 
> > Page migration is ongoing so its best to do something else first.
> 
> That doesn't help a lot.  What is "something else"?  What are the dynamics
> in there, and why do you feel that some sort of delay is needed?

Page migration is ongoing for the page that was faulted. This means 
the migration thread has torn down the ptes and replaced them with 
migration entries in order to prevent access to this page. The migration
thread is continuing the process of tearing down ptes, copying the page 
and then rebuilding the ptes.  When the ptes are back then the fault 
handler will no longer be invoked or it will fix up some of the bits in 
the ptes. This takes a short time, the more ptes point to a page the 
longer it will take to replace them.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
