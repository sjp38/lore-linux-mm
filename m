Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 4CA9C6B006E
	for <linux-mm@kvack.org>; Wed, 22 May 2013 05:26:07 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v2 00/10] uaccess: better might_sleep/might_fault behavior
Date: Wed, 22 May 2013 11:25:36 +0200
References: <cover.1368702323.git.mst@redhat.com>
In-Reply-To: <cover.1368702323.git.mst@redhat.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201305221125.36284.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: linux-kernel@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, David Howells <dhowells@redhat.com>, Hirokazu Takata <takata@linux-m32r.org>, Michal Simek <monstr@monstr.eu>, Koichi Yasutake <yasutake.koichi@jp.panasonic.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Chris Metcalf <cmetcalf@tilera.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-arm-kernel@lists.infradead.org, linux-m32r@ml.linux-m32r.org, linux-m32r-ja@ml.linux-m32r.org, microblaze-uclinux@itee.uq.edu.au, linux-am33-list@redhat.com, linuxppc-dev@lists.ozlabs.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org

On Thursday 16 May 2013, Michael S. Tsirkin wrote:
> This improves the might_fault annotations used
> by uaccess routines:
> 
> 1. The only reason uaccess routines might sleep
>    is if they fault. Make this explicit for
>    all architectures.
> 2. Accesses (e.g through socket ops) to kernel memory
>    with KERNEL_DS like net/sunrpc does will never sleep.
>    Remove an unconditinal might_sleep in the inline
>    might_fault in kernel.h
>    (used when PROVE_LOCKING is not set).
> 3. Accesses with pagefault_disable return EFAULT
>    but won't cause caller to sleep.
>    Check for that and avoid might_sleep when
>    PROVE_LOCKING is set.
> 
> I'd like these changes to go in for the benefit of
> the vhost driver where we want to call socket ops
> under a spinlock, and fall back on slower thread handler
> on error.

Hi Michael,

I have recently stumbled over a related topic, which is the highly
inconsistent placement of might_fault() or might_sleep() in certain
classes of uaccess functions. Your patches seem completely reasonable,
but it would be good to also fix the other problem, at least on
the architectures we most care about.

Given the most commonly used functions and a couple of architectures
I'm familiar with, these are the ones that currently call might_fault()

			x86-32	x86-64	arm	arm64	powerpc	s390	generic
copy_to_user		-	x	-	-	-	x	x
copy_from_user		-	x	-	-	-	x	x
put_user		x	x	x	x	x	x	x
get_user		x	x	x	x	x	x	x
__copy_to_user		x	x	-	-	x	-	-
__copy_from_user	x	x	-	-	x	-	-
__put_user		-	-	x	-	x	-	-
__get_user		-	-	x	-	x	-	-

WTF?

Calling might_fault() for every __get_user/__put_user is rather expensive
because it turns what should be a single instruction (plus fixup) into an
external function call.

My feeling is that we should do might_fault() only in access_ok() to get
the right balance.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
