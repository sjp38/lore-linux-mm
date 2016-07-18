Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id C72316B0005
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 16:12:21 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id q2so318247224pap.1
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 13:12:21 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id m88si5113681pfi.190.2016.07.18.13.12.20
        for <linux-mm@kvack.org>;
        Mon, 18 Jul 2016 13:12:20 -0700 (PDT)
Subject: Re: [PATCH 6/9] x86, pkeys: add pkey set/get syscalls
References: <20160707124719.3F04C882@viggo.jf.intel.com>
 <20160707124728.C1116BB1@viggo.jf.intel.com>
 <20160707144508.GZ11498@techsingularity.net> <577E924C.6010406@sr71.net>
 <20160708071810.GA27457@gmail.com> <577FD587.6050101@sr71.net>
 <20160709083715.GA29939@gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <578D3821.4050705@intel.com>
Date: Mon, 18 Jul 2016 13:12:17 -0700
MIME-Version: 1.0
In-Reply-To: <20160709083715.GA29939@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, x86@kernel.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, dave.hansen@linux.intel.com, arnd@arndb.de, hughd@google.com, viro@zeniv.linux.org.uk, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On 07/09/2016 01:37 AM, Ingo Molnar wrote:
>  - There are 16 pkey indices on x86 currently. We already use index 15 for the 
>    true PROT_EXEC implementation. Let's set aside another pkey index for the 
>    kernel's potential future use (index 14), and clear it explicitly in the 
>    FPU context on every context switch if CONFIG_X86_DEBUG_FPU is enabled to make 
>    sure it remains unallocated.

After mulling over this for a week: I really don't think we want to
pre-reserve any keys.

The one bit of consistent feedback I've heard from the folks that are
going to use this is that they want more keys.  The current code does
not reserve any keys (except 0 of course).

Virtually every feature that we've talked about adding on top of this
_requires_ having this allocation mechanism and kernel knowledge of
which keys are in use.  Even having kernel-reserved keys requires
telling userspace about allocation, whether we use pkey_mprotect() for
it or not.

I'd like to resubmit this set with pkey_get/set() removed, but with
pkey_alloc/free() still in place.

Why are folks so sensitive to the number of keys?  There are a few modes
this will get used in when folks want more pkeys that hardware provides.
 Both of them are harmed in a meaningful way if we take some of their
keys away.  Here's how they will use pkeys:
1. As an accelerator for existing mprotect()-provided guarantees.
   Let's say you want 100 pieces of data, but you only get 15 pkeys in
   hardware.  The app picks the 15 most-frequently accessed pieces, and
   uses pkeys to control access to them, and uses mprotect() for the
   other 85.  Each pkey you remove means a smaller "working set"
   covered by pkeys, more mprotect()s and lower performance.
2. To provide stronger access guarantees.  Let's say you have 100
   pieces of data.  To access a given piece of data, you hash its key
   in to a pkey: hash(92)%NR_PKEYS.  Accessing a random bit of data,
   you have a 1/NR_PKEYS chance of a hash collision and access to data
   you should not have access to.  Fewer keys means more data
   corruption.  Losing 2/16 keys means a 15% greater chance of a
   collision on a given access.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
