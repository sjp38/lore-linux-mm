Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id D4EF26B02A7
	for <linux-mm@kvack.org>; Thu, 12 Aug 2010 18:40:19 -0400 (EDT)
Received: from hpaq6.eem.corp.google.com (hpaq6.eem.corp.google.com [172.25.149.6])
	by smtp-out.google.com with ESMTP id o7CMeGMD002373
	for <linux-mm@kvack.org>; Thu, 12 Aug 2010 15:40:16 -0700
Received: from pzk28 (pzk28.prod.google.com [10.243.19.156])
	by hpaq6.eem.corp.google.com with ESMTP id o7CMeErx020616
	for <linux-mm@kvack.org>; Thu, 12 Aug 2010 15:40:15 -0700
Received: by pzk28 with SMTP id 28so844977pzk.37
        for <linux-mm@kvack.org>; Thu, 12 Aug 2010 15:40:13 -0700 (PDT)
Date: Thu, 12 Aug 2010 15:40:02 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] ipc/shm.c: add RSS and swap size information to
 /proc/sysvipc/shm
In-Reply-To: <4C6468A9.7090503@gmx.de>
Message-ID: <alpine.DEB.1.00.1008121522150.9966@tigran.mtv.corp.google.com>
References: <20100811201345.GA11304@p100.box> <20100812131005.e466a9fd.akpm@linux-foundation.org> <4C6468A9.7090503@gmx.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Helge Deller <deller@gmx.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Manfred Spraul <manfred@colorfullife.com>
List-ID: <linux-mm.kvack.org>

On Thu, 12 Aug 2010, Helge Deller wrote:
> On 08/12/2010 10:10 PM, Andrew Morton wrote:
> > On Wed, 11 Aug 2010 22:13:45 +0200
> > Helge Deller<deller@gmx.de>  wrote:
> > 
> > > The kernel currently provides no functionality to analyze the RSS
> > > and swap space usage of each individual sysvipc shared memory segment.
> > > 
> > > This patch add this info for each existing shm segment by extending
> > > the output of /proc/sysvipc/shm by two columns for RSS and swap.
> > > 
> > > Since shmctl(SHM_INFO) already provides a similiar calculation (it
> > > currently sums up all RSS/swap info for all segments), I did split
> > > out a static function which is now used by the /proc/sysvipc/shm
> > > output and shmctl(SHM_INFO).
> > > 
> > 
> > I suppose that could be useful, although it would be most interesting
> > to hear why _you_ consider it useful?
> 
> A reasonable question, and I really should have explained when I did send this
> patch.
> 
> In my job I do work for SAP in the SAP LinuxLab (http://www.sap.com/linux) and
> take care of the SAP ERP enterprise software on Linux.
> SAP products (esp. the SAP Netweaver ABAP Kernel) uses lots of big shared
> memory segments (we often have Linux systems with >= 16GB shm usage).
> Sometimes we get customer reports about "slow" system responses and while
> looking into their configurations we often find massive swapping activity on
> the system. With this patch it's now easy to see from the command line if and
> which shm segments gets swapped out (and how much) and can more easily give
> recommendations for system tuning.
> Without the patch it's currently not possible to do such shm analysis at all.
> 
> So, my patch actually does fix a real-world problem.

That's good justification, thanks.

> 
> By the way - I found another bug/issue in /proc/<pid>/smaps as well. The
> kernel currently does not adds swapped-out shm pages to the swap size value
> correctly. The swap size value always stays zero for shm pages. I'm currently
> preparing a small patch to fix that, which I will send to linux-mm for review
> soon.

I certainly wouldn't call smaps's present behaviour on it a bug: but given
your justification above, I can see that it would be more useful to you,
and probably to others, for it to be changed in the way that you suggest,
to reveal the underlying swap.

Hmm, I wonder what that patch is going to look like...

> 
> > But is it useful enough to risk breaking existing code which parses
> > that file?  The risk is not great, but it's there.
> 
> Sure. The only positive argument is maybe, that I added the new info to the
> end of the lines. IMHO existing applications which parse /proc files should
> always take into account, that more text could follow with newer Linux
> kernels...?

I hope so too.  And agree you're right to correct the 64-bit header
alignment, and to show the new fields in bytes rather than pages.
But one little thing in your patch upsets me greatly...

> 
> > > ---
> > > 
> > >   shm.c |   63
> > > ++++++++++++++++++++++++++++++++++++++++++---------------------
> > >   1 file changed, 42 insertions(+), 21 deletions(-)
> > > 
> > > 
> > > diff --git a/ipc/shm.c b/ipc/shm.c
> > > --- a/ipc/shm.c
> > > +++ b/ipc/shm.c
> > > @@ -108,7 +108,11 @@ void __init shm_init (void)
> > >   {
> > >   	shm_init_ns(&init_ipc_ns);
> > >   	ipc_init_proc_interface("sysvipc/shm",
> > > -				"       key      shmid perms       size  cpid
> > > lpid nattch   uid   gid  cuid  cgid      atime      dtime      ctime\n",
> > > +#if BITS_PER_LONG<= 32
> > > +				"       key      shmid perms       size  cpid
> > > lpid nattch   uid   gid  cuid  cgid      atime      dtime      ctime
> > > RSS       swap\n",
> > > +#else
> > > +				"       key      shmid perms
> > > size  cpid  lpid nattch   uid   gid  cuid  cgid      atime      dtime
> > > ctime                   RSS                  swap\n",

... why oh why do you write "RSS" in uppercase, when every other field
is named in lowercase?  Please change that to "rss" and then

Acked-by: Hugh Dickins <hughd@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
