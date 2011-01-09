Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4EC046B0088
	for <linux-mm@kvack.org>; Sun,  9 Jan 2011 09:48:15 -0500 (EST)
Date: Sun, 9 Jan 2011 16:47:45 +0200
From: Pasi =?iso-8859-1?Q?K=E4rkk=E4inen?= <pasik@iki.fi>
Subject: Re: Panic caused by PTE corruption - 2.6.32 distro kernel
Message-ID: <20110109144745.GC2754@reaktio.net>
References: <20110109044848.GA20375@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110109044848.GA20375@sgi.com>
Sender: owner-linux-mm@kvack.org
To: Jack Steiner <steiner@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cl@linux.com
List-ID: <linux-mm.kvack.org>

On Sat, Jan 08, 2011 at 10:48:48PM -0600, Jack Steiner wrote:
> 
> A long shot but I'm hoping someone has seen corruption like this
> before.
> 
> System is running a 2.6.32 distro kernel on a large x86_64 Nehalem system.
>

Which exact kernel version/distro is this? 

-- Pasi

> During the last 4+ months we have seen 3 instances of panic's caused by a
> spurious bit 48 being set in a page table. So far, we are unable to
> reliably duplicate the problem but it has occured on multiple systems. We
> have not seen any other strange failures caused by memory corruption.  The
> bug only hits bit 48 in PTEs.
> 
> Has anyone seen anything like this before or have any ideas? Note
> that the system has several non-distro drivers. We have no
> reason to believe these drivers are related but can't rule it out.
> 
> Here is a detailed analysis of the first failure. The other failures are
> similar.
> 
> --------------------------------
> 
> Failure occurred because a user-mode page-table-walk found a page table
> entry with a reserved bit set.
> 
>         <1> engine_par: Corrupted page table at address 20705808
>         <4> PGD 7cf83c8b067 PUD 7ccd3170067 PMD 7e7f8c46067 PTE 800107e1d43f5067
>         <0> Bad pagetable: 000f [#1] SMP
>                               ^--- bit 3 ==> reserved bit is set in a PT entry
> 
>         PGD      7cf83c8b067
>         PUD      7ccd3170067
>         PMD      7e7f8c46067
>         PTE 800107e1d43f5067
>                ^------- ???
> 
> 
> Note bit 48 in the PTE. This bit should not be set. Failure left no trace
> that I could find.  Other observations:
> 
> Failing process is:
>         0xffff8fcff6942140   237757   237716  1 1010   R  0xffff8fcff69427d0 *engine_par
> 
> Appears to be a big MPI job (hybrid???)
> 
> 
> Other entries in the PT close to the corrupted entry look reasonable:
>         0xffff8fe7f8c46800 800007e1d43f0067 800007e1d43f1067
>         0xffff8fe7f8c46810 800007e1d43f2067 800007e1d43f3067
>         0xffff8fe7f8c46820 800007e1d43f4067 800107e1d43f5067 << has bad entry
>         0xffff8fe7f8c46830 800007e1d43f6067 800007e1d43f7067
>         0xffff8fe7f8c46840 800007e1ab590067 800007e1ab591067
>         0xffff8fe7f8c46850 800007e1ab592067 800007e1ab593067
>         0xffff8fe7f8c46860 800007e1ab594067 800007e1ab595067
>         0xffff8fe7f8c46870 800007e1ab596067 800007e1ab597067
> 
> 
> A second failure:
> 	0xffff8dbff5a34a70 800005bcdd382067 800005bcdd383067
> 	0xffff8dbff5a34a80 800005bcdd384067 800005bcdd385067
> 	0xffff8dbff5a34a90 800005bcdd386067 800005bcdd387067
> 	0xffff8dbff5a34aa0 800005bcdd388067 800105bcdd389067  << has bad entry
> 	0xffff8dbff5a34ab0 800005bcdd38a067 800005bcdd38b067
> 	0xffff8dbff5a34ac0 800005bcdd38c067 800005bcdd38d067
> 	0xffff8dbff5a34ad0 800005bcdd38e067 800005bcdd38f067
> 	0xffff8dbff5a34ae0 800005bcdd390067 800005bcdd391067
> 
> ---
> Jack Steiner (steiner@sgi.com)
> SGI - Silicon Graphics, Inc.
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
