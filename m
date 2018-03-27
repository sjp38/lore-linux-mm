Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8846B6B0008
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 09:36:19 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id z83so5542071wmc.2
        for <linux-mm@kvack.org>; Tue, 27 Mar 2018 06:36:19 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id o135si1088684wmg.78.2018.03.27.06.36.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 27 Mar 2018 06:36:17 -0700 (PDT)
Date: Tue, 27 Mar 2018 15:36:10 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 00/11] Use global pages with PTI
In-Reply-To: <be2e683c-bf0a-e9ce-2f02-4905f6bd56d3@linux.intel.com>
Message-ID: <alpine.DEB.2.21.1803271526260.1964@nanos.tec.linutronix.de>
References: <20180323174447.55F35636@viggo.jf.intel.com> <CA+55aFwEC1O+6qRc35XwpcuLSgJ+0GP6ciqw_1Oc-msX=efLvQ@mail.gmail.com> <be2e683c-bf0a-e9ce-2f02-4905f6bd56d3@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Lutomirski <luto@kernel.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, =?ISO-8859-15?Q?J=FCrgen_Gro=DF?= <jgross@suse.com>, the arch/x86 maintainers <x86@kernel.org>, namit@vmware.com

On Fri, 23 Mar 2018, Dave Hansen wrote:
> On 03/23/2018 11:26 AM, Linus Torvalds wrote:
> > On Fri, Mar 23, 2018 at 10:44 AM, Dave Hansen
> > <dave.hansen@linux.intel.com> wrote:
> >>
> >> This adds one major change from the last version of the patch set
> >> (present in the last patch).  It makes all kernel text global for non-
> >> PCID systems.  This keeps kernel data protected always, but means that
> >> it will be easier to find kernel gadgets via meltdown on old systems
> >> without PCIDs.  This heuristic is, I think, a reasonable one and it
> >> keeps us from having to create any new pti=foo options
> > 
> > Sounds sane.
> > 
> > The patches look reasonable, but I hate seeing a patch series like
> > this where the only ostensible reason is performance, and there are no
> > performance numbers anywhere..
> 
> Well, rats.  This somehow makes things slower with PCIDs on.  I thought
> I reversed the numbers, but I actually do a "grep -c GLB
> /sys/kernel/debug/page_tables/kernel" and record that in my logs right
> next to the output of time(1), so it's awfully hard to screw up.
> 
> This is time doing a modestly-sized kernel compile on a 4-core Skylake
> desktop.
> 
>                         User Time       Kernel Time     Clock Elapsed
> Baseline ( 0 GLB PTEs)  803.79          67.77           237.30
> w/series (28 GLB PTEs)  807.70 (+0.7%)  68.07 (+0.7%)   238.07 (+0.3%)
> 
> Without PCIDs, it behaves the way I would expect.

What's the performance benefit on !PCID systems? And I mean systems which
actually do not have PCID, not a PCID system with 'nopcid' on the command
line.

Thanks,

	tglx
