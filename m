From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCHV5 3/3] x86, ras: Add __mcsafe_copy() function to recover
 from machine checks
Date: Sat, 26 Dec 2015 11:32:52 +0100
Message-ID: <20151226103252.GA21988@pd.tnic>
References: <20151224214632.GF4128@pd.tnic>
 <ce84932301823b991b9b439a4715be93f1912c05.1451002295.git.tony.luck@intel.com>
 <20151225114937.GA862@pd.tnic>
 <5FBC1CF1-095B-466D-85D6-832FBFA98364@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5FBC1CF1-095B-466D-85D6-832FBFA98364@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, "Williams, Dan J" <dan.j.williams@intel.com>, "elliott@hpe.com" <elliott@hpe.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-nvdimm@ml01.01.org" <linux-nvdimm@ml01.01.org>, "x86@kernel.org" <x86@kernel.org>
List-Id: linux-mm.kvack.org

On Fri, Dec 25, 2015 at 08:05:39PM +0000, Luck, Tony wrote:
> mce_in_kernel_recov() should check whether we have a fix up entry for
> the specific IP that hit the machine check before rating the severity
> as kernel recoverable.

Yeah, it is not precise right now. But this is easy - I'll change it to
a simpler version of fixup_mcexception() to iterate over the exception
table.

> If we add more functions (for different cache behaviour, or to
> optimize for specific processor model) we can make sure to put them
> all together inside begin/end labels.

Yeah, I think we can do even better than that as all the info is in the
ELF file already. For example, ENDPROC(__mcsafe_copy) generates

.type __mcsafe_copy, @function ; .size __mcsafe_copy, .-__mcsafe_copy

and there's the size of the function, I guess we can macroize something
like that or even parse the ELF file:

$ readelf --syms vmlinux | grep mcsafe
   706: ffffffff819df73e    14 OBJECT  LOCAL  DEFAULT   11 __kstrtab___mcsafe_copy
   707: ffffffff819d0e18     8 OBJECT  LOCAL  DEFAULT    9 __kcrctab___mcsafe_copy
 56107: ffffffff819b3bb0    16 OBJECT  GLOBAL DEFAULT    7 __ksymtab___mcsafe_copy
 58581: ffffffff812e6d70   179 FUNC    GLOBAL DEFAULT    1 __mcsafe_copy
 62233: 000000003313f9d4     0 NOTYPE  GLOBAL DEFAULT  ABS __crc___mcsafe_copy
 68818: ffffffff812e6e23     0 NOTYPE  GLOBAL DEFAULT    1 __mcsafe_copy_end

__mcsafe_copy is of size 179 bytes:

0xffffffff812e6d70 + 179 = 0xffffffff812e6e23 which is __mcsafe_copy_end
so those labels should not really be necessary as they're global and
polluting the binary unnecessarily.

> We would run into trouble if we want to have some in-line macros for
> use from arbitrary C-code like we have for the page fault case.

Example?

> I might make the arbitrary %rax value be #PF and #MC to reflect the
> h/w fault that got us here rather than -EINVAL/-EFAULT. But that's
> just bike shedding.

Yeah, I picked those arbitrarily to show the intention.

> But now we are back to having the fault handler poke %rax again, which
> made Andy twitch before.

Andy, why is that? It makes the exception handling much simpler this way...

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
