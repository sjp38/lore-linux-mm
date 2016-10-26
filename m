Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 247976B0275
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 18:45:22 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id i128so1741606wme.2
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 15:45:22 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l10si5054110wjk.232.2016.10.26.15.45.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 26 Oct 2016 15:45:20 -0700 (PDT)
Date: Thu, 27 Oct 2016 00:45:16 +0200
From: Borislav Petkov <bp@suse.de>
Subject: Re: CONFIG_VMAP_STACK, on-stack struct, and wake_up_bit
Message-ID: <20161026224516.4npimwrsxdui27k2@pd.tnic>
References: <CAHc6FU4e5sueLi7pfeXnSbuuvnc5PaU3xo5Hnn=SvzmQ+ZOEeg@mail.gmail.com>
 <CALCETrUt+4ojyscJT1AFN5Zt3mKY0rrxcXMBOUUJzzLMWXFXHg@mail.gmail.com>
 <CA+55aFzB2C0aktFZW3GquJF6dhM1904aDPrv4vdQ8=+mWO7jcg@mail.gmail.com>
 <CA+55aFww1iLuuhHw=iYF8xjfjGj8L+3oh33xxUHjnKKnsR-oHg@mail.gmail.com>
 <CA+55aFyRv0YttbLUYwDem=-L5ZAET026umh6LOUQ6hWaRur_VA@mail.gmail.com>
 <996124132.13035408.1477505043741.JavaMail.zimbra@redhat.com>
 <CA+55aFzVmppmua4U0pesp2moz7vVPbH1NP264EKeW3YqOzFc3A@mail.gmail.com>
 <1731570270.13088320.1477515684152.JavaMail.zimbra@redhat.com>
 <CA+55aFxfb-kY40P4HgYnhehx--TuwV7K7C4J4jdx9nan7u0s1A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CA+55aFxfb-kY40P4HgYnhehx--TuwV7K7C4J4jdx9nan7u0s1A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Bob Peterson <rpeterso@redhat.com>, Andy Lutomirski <luto@amacapital.net>, Andreas Gruenbacher <agruenba@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski <luto@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Steven Whitehouse <swhiteho@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, linux-mm <linux-mm@kvack.org>

On Wed, Oct 26, 2016 at 02:30:49PM -0700, Linus Torvalds wrote:
> Ok, similar issue, I think - passing a non-1:1 address to __phys_addr().
> 
> But the call trace has nothing to do with gfs2 or the bitlocks:
> 
> > [    2.504561] Call Trace:
> > [    2.507005]   save_microcode_in_initrd_amd+0x31/0x106
> > [    2.513778]   save_microcode_in_initrd+0x3c/0x45
> > [    2.526110]   do_one_initcall+0x50/0x180
> > [    2.531756]   ? set_debug_rodata+0x12/0x12
> > [    2.537573]   kernel_init_freeable+0x194/0x230
> > [    2.543740]   ? rest_init+0x80/0x80
> > [    2.548952]   kernel_init+0xe/0x100
> > [    2.554164]   ret_from_fork+0x25/0x30
> 
> I think this might be the
> 
>         cont    = __pa(container);
> 
> line in save_microcode_in_initrd_amd().
> 
> I see that Borislav is busy with some x86/microcode patches, I suspect
> he already hit this. Adding Borislav to the cc.

Hmm, I guess that fires because that container thing is a static pointer
so it is >= PAGE_OFFSET. But I might be wrong, it is too late here for
brain to work.

In any case, looking at his Code:

   0:   48 89 f8                mov    %rdi,%rax
   3:   72 28                   jb     0x2d
   5:   48 2b 05 7b a0 dc 00    sub    0xdca07b(%rip),%rax        # 0xdca087
   c:   48 05 00 00 00 80       add    $0xffffffff80000000,%rax
  12:   48 39 c7                cmp    %rax,%rdi
  				^^^^^^^^^^^^^^^^

it could be this comparison here:

RAX: fffff39132a822fc, RDI: ffff8800b2a822fc

  15:   72 14                   jb     0x2b

... which sends us to the UD2.

  17:   0f b6 0d 6a 75 ee 00    movzbl 0xee756a(%rip),%ecx        # 0xee7588

We might end up at 0x2b from here too - that's !phys_addr_valid(x) - but
ECX is 0 while it should be 36...

  1e:   48 89 c2                mov    %rax,%rdx
  21:   48 d3 ea                shr    %cl,%rdx
  24:   48 85 d2                test   %rdx,%rdx
  27:   75 02                   jne    0x2b
  29:   5d                      pop    %rbp
  2a:   c3                      retq   
  2b:*  0f 0b                   ud2             <-- trapping instruction
  2d:   48 03 05 7b 5b da 00    add    0xda5b7b(%rip),%rax        # 0xda5baf
  34:   48 81 ff ff ff ff 3f    cmp    $0x3fffffff,%rdi
  3b:   76 ec                   jbe    0x29
  3d:   0f 0b                   ud2    
  3f:   0f                      .byte 0xf

But again, I could be already sleeping and this could be me talking in
my sleep so don't take it too seriously.

In any case, this code was flaky and fragile for many reasons and it is
why this whole wankery is gone in the microcode loader now.

> Can you re-try without the AMD microcode driver for now?

Yeah, just boot with "dis_ucode_ldr".

-- 
Regards/Gruss,
    Boris.

SUSE Linux GmbH, GF: Felix ImendA?rffer, Jane Smithard, Graham Norton, HRB 21284 (AG NA 1/4 rnberg)
-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
