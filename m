Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id C12C56B0005
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 04:42:09 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id b4so7336691pgs.5
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 01:42:09 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z3si1327791pgr.12.2018.01.30.01.42.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 30 Jan 2018 01:42:08 -0800 (PST)
Date: Tue, 30 Jan 2018 10:42:05 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: ppc elf_map breakage with MAP_FIXED_NOREPLACE
Message-ID: <20180130094205.GS21609@dhcp22.suse.cz>
References: <ef63c070-dcd7-3f26-f6ec-d95404007ae2@linux.vnet.ibm.com>
 <20180123160653.GU1526@dhcp22.suse.cz>
 <2a05eaf2-20fd-57a8-d4bd-5a1fbf57686c@linux.vnet.ibm.com>
 <20180124090539.GH1526@dhcp22.suse.cz>
 <5acba3c2-754d-e449-24ff-a72a0ad0d895@linux.vnet.ibm.com>
 <20180126140415.GD5027@dhcp22.suse.cz>
 <15da8c87-e6db-13aa-01c8-a913656bfdb6@linux.vnet.ibm.com>
 <6db9b33d-fd46-c529-b357-3397926f0733@linux.vnet.ibm.com>
 <20180129132235.GE21609@dhcp22.suse.cz>
 <87k1w081e7.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87k1w081e7.fsf@concordia.ellerman.id.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, broonie@kernel.org

On Tue 30-01-18 14:35:12, Michael Ellerman wrote:
> Michal Hocko <mhocko@kernel.org> writes:
> 
> > On Mon 29-01-18 11:02:09, Anshuman Khandual wrote:
> >> On 01/29/2018 08:17 AM, Anshuman Khandual wrote:
> >> > On 01/26/2018 07:34 PM, Michal Hocko wrote:
> >> >> On Fri 26-01-18 18:04:27, Anshuman Khandual wrote:
> >> >> [...]
> >> >>> I tried to instrument mmap_region() for a single instance of 'sed'
> >> >>> binary and traced all it's VMA creation. But there is no trace when
> >> >>> that 'anon' VMA got created which suddenly shows up during subsequent
> >> >>> elf_map() call eventually failing it. Please note that the following
> >> >>> VMA was never created through call into map_region() in the process
> >> >>> which is strange.
> ...
> >> 
> >> Okay, this colliding VMA seems to be getting loaded from load_elf_binary()
> >> function as well.
> >> 
> >> [    9.422410] vma c000001fceedbc40 start 0000000010030000 end 0000000010040000
> >> next c000001fceedbe80 prev c000001fceedb700 mm c000001fceea8200
> >> prot 8000000000000104 anon_vma           (null) vm_ops           (null)
> >> pgoff 1003 file           (null) private_data           (null)
> >> flags: 0x100073(read|write|mayread|maywrite|mayexec|account)
> >> [    9.422576] CPU: 46 PID: 7457 Comm: sed Not tainted 4.14.0-dirty #158
> >> [    9.422610] Call Trace:
> >> [    9.422623] [c000001fdc4f79b0] [c000000000b17ac0] dump_stack+0xb0/0xf0 (unreliable)
> >> [    9.422670] [c000001fdc4f79f0] [c0000000002dafb8] do_brk_flags+0x2d8/0x440
> >> [    9.422708] [c000001fdc4f7ac0] [c0000000002db3d0] vm_brk_flags+0x80/0x130
> >> [    9.422747] [c000001fdc4f7b20] [c0000000003d23a4] set_brk+0x80/0xdc
> >> [    9.422785] [c000001fdc4f7b60] [c0000000003d1f24] load_elf_binary+0x1304/0x158c
> >> [    9.422830] [c000001fdc4f7c80] [c00000000035d3e0] search_binary_handler+0xd0/0x270
> >> [    9.422881] [c000001fdc4f7d10] [c00000000035f338] do_execveat_common.isra.31+0x658/0x890
> >> [    9.422926] [c000001fdc4f7df0] [c00000000035f980] SyS_execve+0x40/0x50
> >> [    9.423588] [c000001fdc4f7e30] [c00000000000b220] system_call+0x58/0x6c
> >> 
> >> which is getting hit after adding some more debug.
> >
> > Voila! So your binary simply overrides brk by elf segments. That sounds
> > like the exactly the thing that the patch is supposed to protect from.
> > Why this is the case I dunno. It is just clear that either brk or
> > elf base are not put to the proper place. Something to get fixed. You
> > are probably just lucky that brk allocations do not spil over to elf
> > mappings.
> 
> It is something to get fixed, but we can't retrospectively fix the
> existing binaries sitting on peoples' systems.

Yeah. Can we identify those somehow? Are they something people can
easily come across?

> Possibly powerpc arch code is doing something with the mmap layout or
> something else that is confusing the ELF loader, in which case we should
> fix that.

Yes this definitely should be fixed. How can elf loader completely
overlap brk mapping?

> But if not then the only solution is for the ELF loader to be more
> tolerant of this situation.
> 
> So for 4.16 this patch either needs to be dropped, or reworked such that
> powerpc can opt out of it.

Yeah, let's hold on merging this until we understand what the heck is
going on here. If this turnes to be unfixable I will think of a way for
ppc to opt out.

Anshuman, could you try to run
sed 's@^@@' /proc/self/smaps
on a system with MAP_FIXED_NOREPLACE reverted?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
