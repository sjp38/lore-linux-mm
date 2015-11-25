Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 6E34C6B0255
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 14:07:13 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so65448496pac.3
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 11:07:13 -0800 (PST)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id fe1si2760195pab.82.2015.11.25.11.07.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Nov 2015 11:07:12 -0800 (PST)
Received: by pacej9 with SMTP id ej9so65423153pac.2
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 11:07:12 -0800 (PST)
Subject: Re: [PATCH v3 0/4] Allow customizable random offset to mmap_base
 address.
References: <1447888808-31571-1-git-send-email-dcashman@android.com>
 <20151124163907.1a406b79458b1bb0d3519684@linux-foundation.org>
From: Daniel Cashman <dcashman@android.com>
Message-ID: <565606DD.2090502@android.com>
Date: Wed, 25 Nov 2015 11:07:09 -0800
MIME-Version: 1.0
In-Reply-To: <20151124163907.1a406b79458b1bb0d3519684@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux@arm.linux.org.uk, keescook@chromium.org, mingo@kernel.org, linux-arm-kernel@lists.infradead.org, corbet@lwn.net, dzickus@redhat.com, ebiederm@xmission.com, xypron.glpk@gmx.de, jpoimboe@redhat.com, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, mgorman@suse.de, tglx@linutronix.de, rientjes@google.com, linux-mm@kvack.org, linux-doc@vger.kernel.org, salyzyn@android.com, jeffv@google.com, nnk@google.com, catalin.marinas@arm.com, will.deacon@arm.com, hpa@zytor.com, x86@kernel.org, hecmargi@upv.es, bp@suse.de, dcashman@google.com, Ralf Baechle <ralf@linux-mips.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On 11/24/2015 04:39 PM, Andrew Morton wrote:

> mips, powerpc and s390 also implement arch_mmap_rnd().  Are there any
> special considerations here, or it just a matter of maintainers wiring
> it up and testing it?

I had not yet looked at those at all, as I had no way to do even a
rudimentary "does it boot" test and opted to post v3 first.  Upon first
glance, it should just be a matter of wiring it up:

Mips is divided into 12/16 bits for 32/64 bit (assume baseline 4k page)
w/COMPAT kconfig,  powerpc is 11/18 w/COMPAT, s390 is 11/11 w/COMPAT.
s390 is a bit strange as COMPAT is for a 31-bit address space, although
is_32bit_task() is used to determine which mask to use, and the mask
itself for 64-bit only introduces 11 bits of entropy, but while still
affecting larger chunks of the address space (mask is 0x3ff80, resulting
in an effective 0x7ff shift of PAGE_SIZE + 7 bits).

I could go ahead and add these to patchset v4 and as with the previous
architectures, rely on feedback from arch-specific maintainers to help
tune and test the values.

-Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
