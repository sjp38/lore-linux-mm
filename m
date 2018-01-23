Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0644A800D8
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 11:06:57 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id z83so642557wmc.5
        for <linux-mm@kvack.org>; Tue, 23 Jan 2018 08:06:56 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h48si482394wrf.393.2018.01.23.08.06.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 23 Jan 2018 08:06:55 -0800 (PST)
Date: Tue, 23 Jan 2018 17:06:53 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: ppc elf_map breakage with MAP_FIXED_NOREPLACE
Message-ID: <20180123160653.GU1526@dhcp22.suse.cz>
References: <87mv1phptq.fsf@concordia.ellerman.id.au>
 <7a44f42e-39d0-1c4b-19e0-7df1b0842c18@linux.vnet.ibm.com>
 <87tvvw80f2.fsf@concordia.ellerman.id.au>
 <96458c0a-e273-3fb9-a33b-f6f2d536f90b@linux.vnet.ibm.com>
 <20180109161355.GL1732@dhcp22.suse.cz>
 <a495f210-0015-efb2-a6a7-868f30ac4ace@linux.vnet.ibm.com>
 <20180117080731.GA2900@dhcp22.suse.cz>
 <082aa008-c56a-681d-0949-107245603a97@linux.vnet.ibm.com>
 <20180123124545.GL1526@dhcp22.suse.cz>
 <ef63c070-dcd7-3f26-f6ec-d95404007ae2@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ef63c070-dcd7-3f26-f6ec-d95404007ae2@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>, akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, broonie@kernel.org

On Tue 23-01-18 21:28:28, Anshuman Khandual wrote:
> On 01/23/2018 06:15 PM, Michal Hocko wrote:
> > On Tue 23-01-18 16:55:18, Anshuman Khandual wrote:
> >> On 01/17/2018 01:37 PM, Michal Hocko wrote:
> >>> On Thu 11-01-18 15:38:37, Anshuman Khandual wrote:
> >>>> On 01/09/2018 09:43 PM, Michal Hocko wrote:
> >>> [...]
> >>>>> Did you manage to catch _who_ is requesting that anonymous mapping? Do
> >>>>> you need a help with the debugging patch?
> >>>>
> >>>> Not yet, will get back on this.
> >>>
> >>> ping?
> >>
> >> Hey Michal,
> >>
> >> Missed this thread, my apologies. This problem is happening only with
> >> certain binaries like 'sed', 'tmux', 'hostname', 'pkg-config' etc. As
> >> you had mentioned before the map request collision is happening on
> >> [10030000, 10040000] and [10030000, 10040000] ranges only which is
> >> just a single PAGE_SIZE. You asked previously that who might have
> >> requested the anon mapping which is already present in there ? Would
> >> not that be the same process itself ? I am bit confused.
> > 
> > We are early in the ELF loading. If we are mapping over an existing
> > mapping then we are effectivelly corrupting it. In other words exactly
> > what this patch tries to prevent. I fail to see what would be a relevant
> > anon mapping this early and why it would be colliding with elf
> > segements.
> > 
> >> Would it be
> >> helpful to trap all the mmap() requests from any of the binaries
> >> and see where we might have created that anon mapping ?
> > 
> > Yeah, that is exactly what I was suggesting. Sorry for not being clear
> > about that.
> > 
> 
> Tried to instrument just for the 'sed' binary and dont see any where
> it actually requests the anon VMA which got hit when loading the ELF
> section which is strange. All these requested flags here already has
> MAP_FIXED_NOREPLACE (0x100000). Wondering from where the anon VMA
> actually came from.

Could you try to dump backtrace?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
