Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0C00F6B02A5
	for <linux-mm@kvack.org>; Thu, 12 Aug 2010 17:44:40 -0400 (EDT)
Date: Thu, 12 Aug 2010 14:44:30 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] ipc/shm.c: add RSS and swap size information to
 /proc/sysvipc/shm
Message-Id: <20100812144430.23eb8149.akpm@linux-foundation.org>
In-Reply-To: <4C6468A9.7090503@gmx.de>
References: <20100811201345.GA11304@p100.box>
	<20100812131005.e466a9fd.akpm@linux-foundation.org>
	<4C6468A9.7090503@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Helge Deller <deller@gmx.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Manfred Spraul <manfred@colorfullife.com>
List-ID: <linux-mm.kvack.org>

On Thu, 12 Aug 2010 23:33:29 +0200
Helge Deller <deller@gmx.de> wrote:

> On 08/12/2010 10:10 PM, Andrew Morton wrote:
> > On Wed, 11 Aug 2010 22:13:45 +0200
> > Helge Deller<deller@gmx.de>  wrote:
> >
> >> The kernel currently provides no functionality to analyze the RSS
> >> and swap space usage of each individual sysvipc shared memory segment.
> >>
> >> This patch add this info for each existing shm segment by extending
> >> the output of /proc/sysvipc/shm by two columns for RSS and swap.
> >>
> >> Since shmctl(SHM_INFO) already provides a similiar calculation (it
> >> currently sums up all RSS/swap info for all segments), I did split
> >> out a static function which is now used by the /proc/sysvipc/shm
> >> output and shmctl(SHM_INFO).
> >>
> >
> > I suppose that could be useful, although it would be most interesting
> > to hear why _you_ consider it useful?
> 
> A reasonable question, and I really should have explained when I did 
> send this patch.
> 
> In my job I do work for SAP in the SAP LinuxLab 
> (http://www.sap.com/linux) and take care of the SAP ERP enterprise 
> software on Linux.
> SAP products (esp. the SAP Netweaver ABAP Kernel) uses lots of big 
> shared memory segments (we often have Linux systems with >= 16GB shm 
> usage). Sometimes we get customer reports about "slow" system responses 
> and while looking into their configurations we often find massive 
> swapping activity on the system. With this patch it's now easy to see 
> from the command line if and which shm segments gets swapped out (and 
> how much) and can more easily give recommendations for system tuning.
> Without the patch it's currently not possible to do such shm analysis at 
> all.

OK, thanks.  copied-n-pasted into changelog ;)

> So, my patch actually does fix a real-world problem.
> 
> By the way - I found another bug/issue in /proc/<pid>/smaps as well. The 
> kernel currently does not adds swapped-out shm pages to the swap size 
> value correctly. The swap size value always stays zero for shm pages. 
> I'm currently preparing a small patch to fix that, which I will send to 
> linux-mm for review soon.
> 
> > But is it useful enough to risk breaking existing code which parses
> > that file?  The risk is not great, but it's there.
> 
> Sure. The only positive argument is maybe, that I added the new info to 
> the end of the lines. IMHO existing applications which parse /proc files 
> should always take into account, that more text could follow with newer 
> Linux kernels...?

Yeah, they'd be pretty dumb if they failed because new columns appear
in later kernels.

But there's some pretty dumb code out there.

> > This adds 11 new spaces between "perms" and "size", only on 64-bit
> > machines.  That was unchangelogged and adds another (smaller) risk of
> > breaking things.  Please explain.
> 
> Yes, I did added some spaces in front of the "size" field for 64bit 
> kernels to get the columns correct if you cat the contents of the file.
> In sysvipc_shm_proc_show() the kernel prints the size value in 
> "SPEC_SIZE" format, which is defined like this:
> 
> #if BITS_PER_LONG <= 32
> #define SIZE_SPEC "%10lu"
> #else
> #define SIZE_SPEC "%21lu"
> #endif
> 
> So, if the header is not adjusted, the columns are not correctly 
> aligned. I actually tested this on 32- and 64-bit and it seems correct now.

<copy, paste>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
