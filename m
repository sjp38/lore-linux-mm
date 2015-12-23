Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id AC28E6B0295
	for <linux-mm@kvack.org>; Wed, 23 Dec 2015 07:58:58 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id l126so145472225wml.1
        for <linux-mm@kvack.org>; Wed, 23 Dec 2015 04:58:58 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id u128si50702930wme.112.2015.12.23.04.58.57
        for <linux-mm@kvack.org>;
        Wed, 23 Dec 2015 04:58:57 -0800 (PST)
Date: Wed, 23 Dec 2015 13:58:53 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCHV3 3/3] x86, ras: Add mcsafe_memcpy() function to recover
 from machine checks
Message-ID: <20151223125853.GF30213@pd.tnic>
References: <cover.1450283985.git.tony.luck@intel.com>
 <d560d03663b6fd7a5bbeae9842934f329a7dcbdf.1450283985.git.tony.luck@intel.com>
 <20151222111349.GB3728@pd.tnic>
 <CA+8MBbJ+T0Bkea48rivWEZRn8_iPiSvrPm5p22RfbS7V0_KyEA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CA+8MBbJ+T0Bkea48rivWEZRn8_iPiSvrPm5p22RfbS7V0_KyEA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@gmail.com>
Cc: Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Elliott@pd.tnic, Robert <elliott@hpe.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-nvdimm@ml01.01.org, X86-ML <x86@kernel.org>

On Tue, Dec 22, 2015 at 11:38:07AM -0800, Tony Luck wrote:
> I interpreted that comment as "stop playing with %rax in the fault
> handler ... just change the IP to point the the .fixup location" ...
> the target of the fixup being the "landing pad".
> 
> Right now this function has only one set of fault fixups (for machine
> checks). When I tackle copy_from_user() it will sprout a second
> set for page faults, and then will look a bit more like Andy's dual
> landing pad example.
> 
> I still need an indicator to the caller which type of fault happened
> since their actions will be different. So BIT(63) lives on ... but is
> now set in the .fixup section rather than in the machine check
> code.

You mean this previous example of yours:

int copy_from_user(void *to, void *from, unsigned long n)
{
        u64 ret = mcsafe_memcpy(to, from, n);

        if (COPY_HAD_MCHECK(r)) {
                if (memory_failure(COPY_MCHECK_PADDR(ret) >> PAGE_SIZE, ...))
                        force_sig(SIGBUS, current);
                return something;
        } else
                return ret;
}

?

So what's wrong with mcsafe_memcpy() returning a proper retval which
says what type of fault happened?

I know, memcpy returns the ptr to @dest like a parrot but your version
mcsafe_memcpy() will be different. It can even be called __mcsafe_memcpy
and have a wrapper around it which fiddles out the proper retvals and
returns @dest after all. It would still be cleaner this way IMHO.

> I'll move the function and #defines as you suggest - we don't need
> new files for these.  Also will fix the assembly code.
> [In my defense that load immediate 0x8000000000000000 and 'or'
> was what gcc -O2 generates from a simple bit of C code to set
> bit 63 ... perhaps it is faster, or perhaps gcc is on drugs. In this
> case code compactness wins over possible speed difference].

Well, upon a second thought, the reason why gcc would use that huge
immediate could be because by using BTS, it clobbers the carry flag
in rFLAGS. And I guess we don't want that. Although any Jcc or other
conditional instructions touching rFLAGS following will overwrite that
bit so it won't really matter.

I've asked a gcc person, we'll see what interesting explanation comes
back.

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
