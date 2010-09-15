Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A5FA86B007B
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 15:53:30 -0400 (EDT)
Date: Wed, 15 Sep 2010 21:53:26 +0200 (CEST)
From: Richard Guenther <rguenther@suse.de>
Subject: Re: [PATCH v2] After swapout/swapin private dirty mappings are
 reported clean in smaps
In-Reply-To: <1284579969.21906.451.camel@calx>
Message-ID: <alpine.LNX.2.00.1009152147550.28912@zhemvz.fhfr.qr>
References: <20100915134724.C9EE.A69D9226@jp.fujitsu.com>  <201009151034.22497.knikanth@suse.de>  <20100915141710.C9F7.A69D9226@jp.fujitsu.com>  <201009151201.11359.knikanth@suse.de>  <20100915140911.GC4383@balbir.in.ibm.com>  <alpine.LNX.2.00.1009151612450.28912@zhemvz.fhfr.qr>
  <1284561982.21906.280.camel@calx>  <alpine.LNX.2.00.1009151648390.28912@zhemvz.fhfr.qr>  <1284571473.21906.428.camel@calx>  <AANLkTimYQgm6nKZ4TantPiL4kmUP9FtMQwzqeetVnGrr@mail.gmail.com> <1284579969.21906.451.camel@calx>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Matt Mackall <mpm@selenic.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Balbir Singh <balbir@linux.vnet.ibm.com>, Nikanth Karthikesan <knikanth@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michael Matz <matz@novell.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 15 Sep 2010, Matt Mackall wrote:

> On Wed, 2010-09-15 at 12:18 -0700, Hugh Dickins wrote:
> > On Wed, Sep 15, 2010 at 10:24 AM, Matt Mackall <mpm@selenic.com> wrote:
> > 
> > > But that's my point: the consistency problem is NOT in smaps. The page
> > > is NOT marked dirty, ergo smaps doesn't report it as dirty. Whether or
> > > not there is MORE information smaps could be reporting is irrelevant,
> > > the information it IS reporting is consistent with the underlying VM
> > > data. If there's an inconsistency about what it means to be clean, it's
> > > either in the VM or in your head.
> > >
> > > And I frankly think it's in the VM.
> > 
> > I don't believe there's any problem in the VM here, we'd be having
> > SIGSEGVs all over if there were.
> 
> Of course it works. It's just not as orthogonal (aka consistent) as it
> could be in this case: it's not actually reflecting any of the usual
> meanings of dirtiness here.
> 
> > The problem is that /proc/pid/smaps exports a simplified view of the
> > VM, and Richard and Nikanth were hoping that it gave them some info
> > which it has never pretended to give them,
> > 
> > It happens to use a pte_dirty(ptent) test: you could argue that that
> > should be pte_dirty(ptent) || PageDirty(page) (which would then "fix
> > the issue" which Richard sees with swapoff/swapon),
> 
> That might be interesting. Are there any other notable cases where
> pte_dirty() differs from PageDirty()?
> 
> >  or you could argue
> > that it should be pte_dirty(ptent) || PageDirty(page) ||
> > PageSwapCache(page) (which would then note clean copies of swap cache
> > as dirty in the sense which Richard and Nikanth are interested in).
> > 
> > But after these years, we should probably assume that most users of
> > /proc/pid/smaps are used to the existing pte_dirty(ptent) test, and
> > would be troubled by a departure from it.
> 
> Dunno, my smem tool[1] is probably also expecting too much here and I
> should know better!

The question is also what smaps is supposed to deliver (I guess the
only documentation as of that respect is the kernel source ...).

The appearantly incomplete information isn't too useful at the
moment (apart from displaying the numbers in some form).  So
changing the semantics of the numbers in a slight way shouldn't
cause regressions in tools that formerly worked correct in all
cases.

Unfortunately gdb needs some reliable way of checking whether
the mappings content in memory is still equal to that of
the backing file (best without actually carrying out that
comparison ...).  /proc/pid/smaps looked like the most precise
interface for that - now unfortunately it's not usable for this.
Is there any other way?

Richard.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
