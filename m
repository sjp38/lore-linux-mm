Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 977E56B0038
	for <linux-mm@kvack.org>; Thu, 26 Nov 2015 10:11:37 -0500 (EST)
Received: by wmvv187 with SMTP id v187so35584875wmv.1
        for <linux-mm@kvack.org>; Thu, 26 Nov 2015 07:11:37 -0800 (PST)
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com. [195.75.94.109])
        by mx.google.com with ESMTPS id v79si4049057wmv.95.2015.11.26.07.11.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 26 Nov 2015 07:11:36 -0800 (PST)
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Thu, 26 Nov 2015 15:11:35 -0000
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 1D9961B08074
	for <linux-mm@kvack.org>; Thu, 26 Nov 2015 15:11:57 +0000 (GMT)
Received: from d06av10.portsmouth.uk.ibm.com (d06av10.portsmouth.uk.ibm.com [9.149.37.251])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id tAQFBXok50528318
	for <linux-mm@kvack.org>; Thu, 26 Nov 2015 15:11:33 GMT
Received: from d06av10.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av10.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id tAQEBWxq014840
	for <linux-mm@kvack.org>; Thu, 26 Nov 2015 07:11:34 -0700
Date: Thu, 26 Nov 2015 16:11:29 +0100
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH v3 0/4] Allow customizable random offset to mmap_base
 address.
Message-ID: <20151126161129.59024450@mschwide>
In-Reply-To: <565606DD.2090502@android.com>
References: <1447888808-31571-1-git-send-email-dcashman@android.com>
	<20151124163907.1a406b79458b1bb0d3519684@linux-foundation.org>
	<565606DD.2090502@android.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Cashman <dcashman@android.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux@arm.linux.org.uk, keescook@chromium.org, mingo@kernel.org, linux-arm-kernel@lists.infradead.org, corbet@lwn.net, dzickus@redhat.com, ebiederm@xmission.com, xypron.glpk@gmx.de, jpoimboe@redhat.com, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, mgorman@suse.de, tglx@linutronix.de, rientjes@google.com, linux-mm@kvack.org, linux-doc@vger.kernel.org, salyzyn@android.com, jeffv@google.com, nnk@google.com, catalin.marinas@arm.com, will.deacon@arm.com, hpa@zytor.com, x86@kernel.org, hecmargi@upv.es, bp@suse.de, dcashman@google.com, Ralf Baechle <ralf@linux-mips.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Heiko Carstens <heiko.carstens@de.ibm.com>

On Wed, 25 Nov 2015 11:07:09 -0800
Daniel Cashman <dcashman@android.com> wrote:

> On 11/24/2015 04:39 PM, Andrew Morton wrote:
> 
> > mips, powerpc and s390 also implement arch_mmap_rnd().  Are there any
> > special considerations here, or it just a matter of maintainers wiring
> > it up and testing it?
> 
> I had not yet looked at those at all, as I had no way to do even a
> rudimentary "does it boot" test and opted to post v3 first.  Upon first
> glance, it should just be a matter of wiring it up:
> 
> Mips is divided into 12/16 bits for 32/64 bit (assume baseline 4k page)
> w/COMPAT kconfig,  powerpc is 11/18 w/COMPAT, s390 is 11/11 w/COMPAT.
> s390 is a bit strange as COMPAT is for a 31-bit address space, although
> is_32bit_task() is used to determine which mask to use, and the mask
> itself for 64-bit only introduces 11 bits of entropy, but while still
> affecting larger chunks of the address space (mask is 0x3ff80, resulting
> in an effective 0x7ff shift of PAGE_SIZE + 7 bits).

s390 uses a mmap randomization of 11 bits but applies it to different
bits dependent if the task is a compat task or not. From the machine
perspective we would like to always use the randomization bits for
normal, non-compat tasks. But as the 2GB address space for compat tasks
is really limited the randomization is applied in bits 2^12..2^22 for
compat tasks vs 2^19..2^29 for normal tasks at the cost of performance.
This has to do with the cache aliasing on z13.

By the way we will replace is_32bit_task with() is_compat_task(), I have
a patch from Heiko pending for that.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
