Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9D096800D8
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 04:05:43 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id u43so1835807pgn.12
        for <linux-mm@kvack.org>; Wed, 24 Jan 2018 01:05:43 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i90si2630249pfd.147.2018.01.24.01.05.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 24 Jan 2018 01:05:42 -0800 (PST)
Date: Wed, 24 Jan 2018 10:05:39 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: ppc elf_map breakage with MAP_FIXED_NOREPLACE
Message-ID: <20180124090539.GH1526@dhcp22.suse.cz>
References: <87tvvw80f2.fsf@concordia.ellerman.id.au>
 <96458c0a-e273-3fb9-a33b-f6f2d536f90b@linux.vnet.ibm.com>
 <20180109161355.GL1732@dhcp22.suse.cz>
 <a495f210-0015-efb2-a6a7-868f30ac4ace@linux.vnet.ibm.com>
 <20180117080731.GA2900@dhcp22.suse.cz>
 <082aa008-c56a-681d-0949-107245603a97@linux.vnet.ibm.com>
 <20180123124545.GL1526@dhcp22.suse.cz>
 <ef63c070-dcd7-3f26-f6ec-d95404007ae2@linux.vnet.ibm.com>
 <20180123160653.GU1526@dhcp22.suse.cz>
 <2a05eaf2-20fd-57a8-d4bd-5a1fbf57686c@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2a05eaf2-20fd-57a8-d4bd-5a1fbf57686c@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>, akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, broonie@kernel.org

On Wed 24-01-18 10:39:41, Anshuman Khandual wrote:
> On 01/23/2018 09:36 PM, Michal Hocko wrote:
> > On Tue 23-01-18 21:28:28, Anshuman Khandual wrote:
> >> On 01/23/2018 06:15 PM, Michal Hocko wrote:
> >>> On Tue 23-01-18 16:55:18, Anshuman Khandual wrote:
> >>>> On 01/17/2018 01:37 PM, Michal Hocko wrote:
> >>>>> On Thu 11-01-18 15:38:37, Anshuman Khandual wrote:
> >>>>>> On 01/09/2018 09:43 PM, Michal Hocko wrote:
> >>>>> [...]
> >>>>>>> Did you manage to catch _who_ is requesting that anonymous mapping? Do
> >>>>>>> you need a help with the debugging patch?
> >>>>>>
> >>>>>> Not yet, will get back on this.
> >>>>>
> >>>>> ping?
> >>>>
> >>>> Hey Michal,
> >>>>
> >>>> Missed this thread, my apologies. This problem is happening only with
> >>>> certain binaries like 'sed', 'tmux', 'hostname', 'pkg-config' etc. As
> >>>> you had mentioned before the map request collision is happening on
> >>>> [10030000, 10040000] and [10030000, 10040000] ranges only which is
> >>>> just a single PAGE_SIZE. You asked previously that who might have
> >>>> requested the anon mapping which is already present in there ? Would
> >>>> not that be the same process itself ? I am bit confused.
> >>>
> >>> We are early in the ELF loading. If we are mapping over an existing
> >>> mapping then we are effectivelly corrupting it. In other words exactly
> >>> what this patch tries to prevent. I fail to see what would be a relevant
> >>> anon mapping this early and why it would be colliding with elf
> >>> segements.
> >>>
> >>>> Would it be
> >>>> helpful to trap all the mmap() requests from any of the binaries
> >>>> and see where we might have created that anon mapping ?
> >>>
> >>> Yeah, that is exactly what I was suggesting. Sorry for not being clear
> >>> about that.
> >>>
> >>
> >> Tried to instrument just for the 'sed' binary and dont see any where
> >> it actually requests the anon VMA which got hit when loading the ELF
> >> section which is strange. All these requested flags here already has
> >> MAP_FIXED_NOREPLACE (0x100000). Wondering from where the anon VMA
> >> actually came from.
> > 
> > Could you try to dump backtrace?
> 
> This is when it fails inside elf_map() function due to collision with
> existing anon VMA mapping.

This is not the interesting one. This is the ELF loader. And we know it
fails. We are really interested in the one _who_ installs the original
VMA. Because nothing should be really there.

It would be also very helpful to translate the backtrace with faddr2line
to get line numbers.

> [c000201c9ad07880] [c000000000b0b4c0] dump_stack+0xb0/0xf0 (unreliable)
> [c000201c9ad078c0] [c0000000003c4550] elf_map+0x2d0/0x310
> [c000201c9ad07b60] [c0000000003c6258] load_elf_binary+0x6f8/0x158c
> [c000201c9ad07c80] [c000000000352900] search_binary_handler+0xd0/0x270
> [c000201c9ad07d10] [c000000000354838] do_execveat_common.isra.31+0x658/0x890
> [c000201c9ad07df0] [c000000000354e80] SyS_execve+0x40/0x50
> [c000201c9ad07e30] [c00000000000b220] system_call+0x58/0x6c

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
