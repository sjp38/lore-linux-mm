Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 487C88D0040
	for <linux-mm@kvack.org>; Sat, 26 Mar 2011 13:59:01 -0400 (EDT)
Received: from mail-iy0-f169.google.com (mail-iy0-f169.google.com [209.85.210.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p2QHwwm6003120
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Sat, 26 Mar 2011 10:58:58 -0700
Received: by iyf13 with SMTP id 13so3058178iyf.14
        for <linux-mm@kvack.org>; Sat, 26 Mar 2011 10:58:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110326112725.GA28612@elte.hu>
References: <alpine.DEB.2.00.1103221635400.4521@tiger> <20110324142146.GA11682@elte.hu>
 <alpine.DEB.2.00.1103240940570.32226@router.home> <AANLkTikb8rtSX5hQG6MQF4quymFUuh5Tw97TcpB0YfwS@mail.gmail.com>
 <20110324172653.GA28507@elte.hu> <20110324185258.GA28370@elte.hu>
 <alpine.LFD.2.00.1103242005530.31464@localhost6.localdomain6>
 <20110324192247.GA5477@elte.hu> <AANLkTinBwM9egao496WnaNLAPUxhMyJmkusmxt+ARtnV@mail.gmail.com>
 <20110326112725.GA28612@elte.hu>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 26 Mar 2011 10:58:37 -0700
Message-ID: <AANLkTim+=nW820_QDBCabsY=UTxa1DAPnLqijDNicgB8@mail.gmail.com>
Subject: Re: [boot crash #2] Re: [GIT PULL] SLAB changes for v2.6.39-rc1
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Pekka Enberg <penberg@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Christoph Lameter <cl@linux.com>, akpm@linux-foundation.org, tj@kernel.org, npiggin@kernel.dk, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, Mar 26, 2011 at 4:27 AM, Ingo Molnar <mingo@elte.hu> wrote:
>
> ok, bad news - the bootcrash has come back - see the crashlog attached be=
low.
> Config attached as well.
>
> I reproduced this on upstream 16c29dafcc86 - i.e. all the latest Slab fix=
es
> applied.
>
> BUG: unable to handle kernel paging request at ffff87ffc1fdd020
> IP: [<ffffffff812b50c2>] this_cpu_cmpxchg16b_emu+0x2/0x1c
> ...
> Code: 47 08 48 89 47 10 48 89 47 18 48 89 47 20 48 89 47 28 48 89 47 30 4=
8 89 47 38 48 8d 7f 40 75 d9 90 c3 90 90 90 90 90 90 90 9c fa
> =A048 3b 06 75 14 65 48 3b 56 08 75 0d 65 48 89 1e 65 48 89 4e

Your "Code:" line is buggy, and is missing the first byte of the
faulting instruction (which should have that "<>" around it). But from
the offset, we know it's <65>, and it's the first read of %gs. In
which case it all decodes to the right thing, ie

   0:	9c                   	pushfq
   1:	fa                   	cli
   2:*	65 48 3b 06          	cmp    %gs     <-- trapping instruction:(%rsi)=
,%rax
   6:	75 14                	jne    0x1c
   8:	65 48 3b 56 08       	cmp    %gs:0x8(%rsi),%rdx
   d:	75 0d                	jne    0x1c
   f:	65 48 89 1e          	mov    %rbx,%gs:(%rsi)

(Heh, the "trapping instruction" points to the %gs override itself,
which looks odd but is technically not incorrect).

And quite frankly, I don't see how this can have anything to do with
the emulated code. It's doing exactly the same thing as the cmpxchg16b
instruction is, except for the fact that a real cmpxchg16b would have
(a) not done this with interrupts disabled and (b) would have done the
fault as a write-fault.

But neither of those should make any difference what-so-ever. If this
was rally about the vmalloc space, arch/x86/mm/fault.c should have
fixed it up. That code is entirely happy fixing up stuff with
interrupts disabled too, and is in fact designed to do so.

So I don't see how this could be about the cmpxchg16b instruction
emulation.  We should have gotten pretty much the exact same page
fault even for a real cmpxchg16b instruction.

I wonder if there is something wrong in the percpu allocation, and the
whole new slub thing just ends up causing us to do those allocations
earlier or in a different pattern. The percpu offset is fairly close
to the beginning of a page (offset 0x20).

Tejun, do you see anything suspicious/odd about the percpu allocations
that alloc_kmem_cache_cpus() does?  In particular, should the slab
init code use the reserved chunks so that we don't get some kind of
crazy "slab wants to do percpu alloc to initialize, which wants to use
slab to allocate the chunk"?

                                   Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
