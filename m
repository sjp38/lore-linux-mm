Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 0ECAF6B0031
	for <linux-mm@kvack.org>; Fri, 24 Jan 2014 02:01:20 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id rd3so2910006pab.30
        for <linux-mm@kvack.org>; Thu, 23 Jan 2014 23:01:20 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id tq3si4531597pab.241.2014.01.23.23.01.18
        for <linux-mm@kvack.org>;
        Thu, 23 Jan 2014 23:01:19 -0800 (PST)
Date: Thu, 23 Jan 2014 23:04:27 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Panic on 8-node system in memblock_virt_alloc_try_nid()
Message-Id: <20140123230427.e669f6b7.akpm@linux-foundation.org>
In-Reply-To: <CAE9FiQV+QETh62-RExJx_hmS0mUzEuUQkO7M-eKX6KAfj5Geog@mail.gmail.com>
References: <52E19C7D.7050603@intel.com>
	<CAE9FiQX9kTxnaqpWNgg3dUzr7+60YCrEx3q3xxO-G1n6z64xVQ@mail.gmail.com>
	<52E20A56.1000507@ti.com>
	<CAE9FiQV+QETh62-RExJx_hmS0mUzEuUQkO7M-eKX6KAfj5Geog@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: Santosh Shilimkar <santosh.shilimkar@ti.com>, Dave Hansen <dave.hansen@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@elte.hu>, Grygorii Strashko <grygorii.strashko@ti.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Tejun Heo <tj@kernel.org>

On Thu, 23 Jan 2014 22:57:08 -0800 Yinghai Lu <yinghai@kernel.org> wrote:

> On Thu, Jan 23, 2014 at 10:38 PM, Santosh Shilimkar
> <santosh.shilimkar@ti.com> wrote:
> > Yinghai,
> >
> > On Friday 24 January 2014 12:55 AM, Yinghai Lu wrote:
> >> On Thu, Jan 23, 2014 at 2:49 PM, Dave Hansen <dave.hansen@intel.com> wrote:
> >>> > Linus's current tree doesn't boot on an 8-node/1TB NUMA system that I
> >>> > have.  Its reboots are *LONG*, so I haven't fully bisected it, but it's
> >>> > down to a just a few commits, most of which are changes to the memblock
> >>> > code.  Since the panic is in the memblock code, it looks like a
> >>> > no-brainer.  It's almost certainly the code from Santosh or Grygorii
> >>> > that's triggering this.
> >>> >
> >>> > Config and good/bad dmesg with memblock=debug are here:
> >>> >
> >>> >         http://sr71.net/~dave/intel/3.13/
> >>> >
> >>> > Please let me know if you need it bisected further than this.
> >> Please check attached patch, and it should fix the problem.
> >>
> >
> > [...]
> >
> >>
> >> Subject: [PATCH] x86: Fix numa with reverting wrong memblock setting.
> >>
> >> Dave reported Numa on x86 is broken on system with 1T memory.
> >>
> >> It turns out
> >> | commit 5b6e529521d35e1bcaa0fe43456d1bbb335cae5d
> >> | Author: Santosh Shilimkar <santosh.shilimkar@ti.com>
> >> | Date:   Tue Jan 21 15:50:03 2014 -0800
> >> |
> >> |    x86: memblock: set current limit to max low memory address
> >>
> >> set limit to low wrongly.
> >>
> >> max_low_pfn_mapped is different from max_pfn_mapped.
> >> max_low_pfn_mapped is always under 4G.
> >>
> >> That will memblock_alloc_nid all go under 4G.
> >>
> >> Revert that offending patch.
> >>
> >> Reported-by: Dave Hansen <dave.hansen@intel.com>
> >> Signed-off-by: Yinghai Lu <yinghai@kernel.org>
> >>
> >>
> > This mostly will fix the $subject issue but the regression
> > reported by Andrew [1] will surface with the revert. Its clear
> > now that even though commit fixed the issue, it wasn't the fix.
> >
> > Would be great if you can have a look at the thread.
> 
> >> [1] http://lkml.indiana.edu/hypermail/linux/kernel/1312.1/03770.html
> 
> Andrew,
> 
> Did you bisect which patch in that 23 patchset cause your system have problem?
> 

Yes - it was caused by the patch which that email was replying to. 
"[PATCH v3 13/23] mm/lib/swiotlb: Use memblock apis for earlymemory
allocations".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
