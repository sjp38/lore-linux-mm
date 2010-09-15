Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 374EB6B007D
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 13:24:43 -0400 (EDT)
Subject: Re: [PATCH v2] After swapout/swapin private dirty mappings are
 reported clean in smaps
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <alpine.LNX.2.00.1009151648390.28912@zhemvz.fhfr.qr>
References: <20100915134724.C9EE.A69D9226@jp.fujitsu.com>
	 <201009151034.22497.knikanth@suse.de>
	 <20100915141710.C9F7.A69D9226@jp.fujitsu.com>
	 <201009151201.11359.knikanth@suse.de>
	 <20100915140911.GC4383@balbir.in.ibm.com>
	 <alpine.LNX.2.00.1009151612450.28912@zhemvz.fhfr.qr>
	 <1284561982.21906.280.camel@calx>
	 <alpine.LNX.2.00.1009151648390.28912@zhemvz.fhfr.qr>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 15 Sep 2010 12:24:33 -0500
Message-ID: <1284571473.21906.428.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Richard Guenther <rguenther@suse.de>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Nikanth Karthikesan <knikanth@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michael Matz <matz@novell.com>, linux-kernel@vger.kernel.org, Hugh Dickins <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

[adding Hugh]

On Wed, 2010-09-15 at 16:53 +0200, Richard Guenther wrote:
> On Wed, 15 Sep 2010, Matt Mackall wrote:
> 
> > On Wed, 2010-09-15 at 16:14 +0200, Richard Guenther wrote:
> > > On Wed, 15 Sep 2010, Balbir Singh wrote:
> > > 
> > > > * Nikanth Karthikesan <knikanth@suse.de> [2010-09-15 12:01:11]:
> > > > 
> > > > > How? Current smaps information without this patch provides incorrect 
> > > > > information. Just because a private dirty page became part of swap cache, it 
> > > > > shown as clean and backed by a file. If it is shown as clean and backed by 
> > > > > swap then it is fine.
> > > > >
> > > > 
> > > > How is GDB using this information?  
> > > 
> > > GDB counts the number of dirty and swapped pages in a private mapping and
> > > based on that decides whether it needs to dump it to a core file or not.
> > > If there are no dirty or swapped pages gdb assumes it can reconstruct
> > > the mapping from the original backing file.  This way for example
> > > shared libraries do not end up in the core file.
> > 
> > This whole discussion is a little disturbing.
> >
> > The page is being reported clean as per the kernel's definition of
> > clean, full stop.
> > 
> > So either there's a latent bug/inconsistency in the kernel VM or
> > external tools are misinterpreting this data. But smaps is just
> > reporting what's there, the fault doesn't lie in smaps. So fixing smaps
> > just hides the problem, wherever it is.
> > 
> > Richard's report that the page is still clean after swapoff suggests the
> > inconsistency lies in the VM.
> 
> Well - the discussion is about the /proc/smaps interface and
> inconsistencies in what it reports.  In particular the interface
> does not have the capability of reporting all details the kernel
> has, so it might make sense to not "report a page clean as per
> the kernel's definition of clean", but only in a /proc/smaps
> context definition of clean that makes sense.
> 
> So, for
> 
> 7ffff81ff000-7ffff8201000 r--p 000a8000 08:01 16376 /bin/bash
> Size:                  8 kB
> Rss:                   8 kB
> Pss:                   8 kB
> Shared_Clean:          0 kB
> Shared_Dirty:          0 kB
> Private_Clean:         8 kB
> Private_Dirty:         0 kB
> Referenced:            4 kB
> Swap:                  0 kB
> 
> I expect both pages of that mapping to be file-backed by /bin/bash.
> But surprisingly one page is actually backed by anonymous memory
> (it was changed, then mapped readonly, swapped out and swapped in
> again).
> 
> Thus, the bug is the above inconsistency in /proc/smaps.

But that's my point: the consistency problem is NOT in smaps. The page
is NOT marked dirty, ergo smaps doesn't report it as dirty. Whether or
not there is MORE information smaps could be reporting is irrelevant,
the information it IS reporting is consistent with the underlying VM
data. If there's an inconsistency about what it means to be clean, it's
either in the VM or in your head.

And I frankly think it's in the VM.

In any case, I don't think Nikanth's fix is the right fix, as it
basically says "you can't trust any of this". Either swap should return
the pages to their pre-swap dirty state in the VM, or we should add
another field here:

Weird_Anon_Page_You_Should_Pretend_Is_Private_Dirty: 8 kB 

See?

-- 
Mathematics is the supreme nostalgia of our time.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
