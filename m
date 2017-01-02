Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id B2E786B0069
	for <linux-mm@kvack.org>; Mon,  2 Jan 2017 03:54:10 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id dh1so43750436wjb.0
        for <linux-mm@kvack.org>; Mon, 02 Jan 2017 00:54:10 -0800 (PST)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.133])
        by mx.google.com with ESMTPS id m193si68667214wmb.157.2017.01.02.00.54.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jan 2017 00:54:09 -0800 (PST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC, PATCHv2 29/29] mm, x86: introduce RLIMIT_VADDR
Date: Mon, 02 Jan 2017 09:44:46 +0100
Message-ID: <2736959.3MfCab47fD@wuerfel>
In-Reply-To: <20161227015413.187403-30-kirill.shutemov@linux.intel.com>
References: <20161227015413.187403-1-kirill.shutemov@linux.intel.com> <20161227015413.187403-30-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>

On Tuesday, December 27, 2016 4:54:13 AM CET Kirill A. Shutemov wrote:
> This patch introduces new rlimit resource to manage maximum virtual
> address available to userspace to map.
>=20
> On x86, 5-level paging enables 56-bit userspace virtual address space.
> Not all user space is ready to handle wide addresses. It's known that
> at least some JIT compilers use high bit in pointers to encode their
> information. It collides with valid pointers with 5-level paging and
> leads to crashes.
>=20
> The patch aims to address this compatibility issue.
>=20
> MM would use min(RLIMIT_VADDR, TASK_SIZE) as upper limit of virtual
> address available to map by userspace.
>=20
> The default hard limit will be RLIM_INFINITY, which basically means that
> TASK_SIZE limits available address space.
>=20
> The soft limit will also be RLIM_INFINITY everywhere, but the machine
> with 5-level paging enabled. In this case, soft limit would be
> (1UL << 47) - PAGE_SIZE. It=E2=80=99s current x86-64 TASK_SIZE_MAX with 4=
=2Dlevel
> paging which known to be safe
>=20
> New rlimit resource would follow usual semantics with regards to
> inheritance: preserved on fork(2) and exec(2). This has potential to
> break application if limits set too wide or too narrow, but this is not
> uncommon for other resources (consider RLIMIT_DATA or RLIMIT_AS).
>=20
> As with other resources you can set the limit lower than current usage.
> It would affect only future virtual address space allocations.
>=20
> Use-cases for new rlimit:
>=20
>   - Bumping the soft limit to RLIM_INFINITY, allows current process all
>     its children to use addresses above 47-bits.
>=20
>   - Bumping the soft limit to RLIM_INFINITY after fork(2), but before
>     exec(2) allows the child to use addresses above 47-bits.
>=20
>   - Lowering the hard limit to 47-bits would prevent current process all
>     its children to use addresses above 47-bits, unless a process has
>     CAP_SYS_RESOURCES.
>=20
>   - It=E2=80=99s also can be handy to lower hard or soft limit to arbitra=
ry
>     address. User-mode emulation in QEMU may lower the limit to 32-bit
>     to emulate 32-bit machine on 64-bit host.
>=20
> TODO:
>   - port to non-x86;
>=20
> Not-yet-signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.co=
m>
> Cc: linux-api@vger.kernel.org

This seems to nicely address the same problem on arm64, which has
run into the same issue due to the various page table formats
that can currently be chosen at compile time.

I don't see how this interacts with the existing
PER_LINUX32/PER_LINUX32_3GB personality flags, but I assume you have
either already thought of that, or we can come up with a good way
to define what happens when conflicting settings are applied.

The two reasonable ways I can think of are to either use the
minimum of the two limits, or to make the personality syscall
set the soft rlimit and use whatever limit was last set.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
