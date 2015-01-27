Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id D681B6B0032
	for <linux-mm@kvack.org>; Tue, 27 Jan 2015 11:17:11 -0500 (EST)
Received: by mail-wg0-f54.google.com with SMTP id b13so15592954wgh.13
        for <linux-mm@kvack.org>; Tue, 27 Jan 2015 08:17:11 -0800 (PST)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id jx3si3983163wid.0.2015.01.27.08.17.08
        for <linux-mm@kvack.org>;
        Tue, 27 Jan 2015 08:17:09 -0800 (PST)
Date: Tue, 27 Jan 2015 18:16:57 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: mmotm 2015-01-22-15-04: qemu failures due to 'mm: account pmd
 page tables to the process'
Message-ID: <20150127161657.GA7155@node.dhcp.inet.fi>
References: <54c1822d.RtdGfWPekQVAw8Ly%akpm@linux-foundation.org>
 <20150123050445.GA22751@roeck-us.net>
 <20150123111304.GA5975@node.dhcp.inet.fi>
 <54C263CC.1060904@roeck-us.net>
 <20150123135519.9f1061caf875f41f89298d59@linux-foundation.org>
 <20150124055207.GA8926@roeck-us.net>
 <20150126122944.GE25833@node.dhcp.inet.fi>
 <54C6494D.80802@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54C6494D.80802@roeck-us.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Guenter Roeck <linux@roeck-us.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Mon, Jan 26, 2015 at 06:03:57AM -0800, Guenter Roeck wrote:
> On 01/26/2015 04:29 AM, Kirill A. Shutemov wrote:
> >On Fri, Jan 23, 2015 at 09:52:07PM -0800, Guenter Roeck wrote:
> >>On Fri, Jan 23, 2015 at 01:55:19PM -0800, Andrew Morton wrote:
> >>>On Fri, 23 Jan 2015 07:07:56 -0800 Guenter Roeck <linux@roeck-us.net> wrote:
> >>>
> >>>>>>
> >>>>>>qemu:microblaze generates warnings to the console.
> >>>>>>
> >>>>>>WARNING: CPU: 0 PID: 32 at mm/mmap.c:2858 exit_mmap+0x184/0x1a4()
> >>>>>>
> >>>>>>with various call stacks. See
> >>>>>>http://server.roeck-us.net:8010/builders/qemu-microblaze-mmotm/builds/15/steps/qemubuildcommand/logs/stdio
> >>>>>>for details.
> >>>>>
> >>>>>Could you try patch below? Completely untested.
> >>>>>
> >>>>>>From b584bb8d493794f67484c0b57c161d61c02599bc Mon Sep 17 00:00:00 2001
> >>>>>From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> >>>>>Date: Fri, 23 Jan 2015 13:08:26 +0200
> >>>>>Subject: [PATCH] microblaze: define __PAGETABLE_PMD_FOLDED
> >>>>>
> >>>>>Microblaze uses custom implementation of PMD folding, but doesn't define
> >>>>>__PAGETABLE_PMD_FOLDED, which generic code expects to see. Let's fix it.
> >>>>>
> >>>>>Defining __PAGETABLE_PMD_FOLDED will drop out unused __pmd_alloc().
> >>>>>It also fixes problems with recently-introduced pmd accounting.
> >>>>>
> >>>>>Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> >>>>>Reported-by: Guenter Roeck <linux@roeck-us.net>
> >>>>
> >>>>Tested working.
> >>>>
> >>>>Tested-by: Guenter Roeck <linux@roeck-us.net>
> >>>>
> >>>>Any idea how to fix the sh problem ?
> >>>
> >>>Can you tell us more about it?  All I'm seeing is "qemu:sh fails to
> >>>shut down", which isn't very clear.
> >>
> >>Turns out that the include file defining __PAGETABLE_PMD_FOLDED
> >>was not always included where used, resulting in a messed up mm_struct.
> >
> >What means "messed up" here? It should only affect size of mm_struct.
> >
> Plus the offset of all variables after the #ifndef.

Okay, I guess the problem is that different parts of the kernel see
different mm_struct depending on include ordering.

Tried to look for options, but don't see anything better than patch below.
Andrew, is it okay to you?
