Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 5D3EF6B0253
	for <linux-mm@kvack.org>; Wed,  9 Mar 2016 01:43:40 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id td3so5086919pab.2
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 22:43:40 -0800 (PST)
Received: from smtprelay.synopsys.com (us01smtprelay-2.synopsys.com. [198.182.60.111])
        by mx.google.com with ESMTPS id qp8si10228074pac.244.2016.03.08.22.43.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Mar 2016 22:43:39 -0800 (PST)
Subject: Re: [PATCH] mm: slub: Ensure that slab_unlock() is atomic
References: <1457447457-25878-1-git-send-email-vgupta@synopsys.com>
 <alpine.DEB.2.20.1603080857360.4047@east.gentwo.org>
 <56DEF3D3.6080008@synopsys.com>
 <alpine.DEB.2.20.1603081438020.4268@east.gentwo.org>
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Message-ID: <56DFC604.6070407@synopsys.com>
Date: Wed, 9 Mar 2016 12:13:16 +0530
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1603081438020.4268@east.gentwo.org>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Noam Camus <noamc@ezchip.com>, stable@vger.kernel.org, linux-kernel@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-parisc@vger.kernel, Peter
 Zijlstra <peterz@infradead.org>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>

+CC linux-arch, parisc folks, PeterZ

On Wednesday 09 March 2016 02:10 AM, Christoph Lameter wrote:
> On Tue, 8 Mar 2016, Vineet Gupta wrote:
> 
>> # set the bit
>> 80543b8e:	ld_s       r2,[r13,0] <--- (A) Finds PG_locked is set
>> 80543b90:	or         r3,r2,1    <--- (B) other core unlocks right here
>> 80543b94:	st_s       r3,[r13,0] <--- (C) sets PG_locked (overwrites unlock)
> 
> Duh. Guess you  need to take the spinlock also in the arch specific
> implementation of __bit_spin_unlock(). This is certainly not the only case
> in which we use the __ op to unlock.

__bit_spin_lock() by definition is *not* required to be atomic, bit_spin_lock() is
- so I don't think we need a spinlock there.

There is clearly a problem in slub code that it is pairing a test_and_set_bit()
with a __clear_bit(). Latter can obviously clobber former if they are not a single
instruction each unlike x86 or they use llock/scond kind of instructions where the
interim store from other core is detected and causes a retry of whole llock/scond
sequence.

BTW ARC is not the only arch which suffers from this - other arches potentially
also are. AFAIK PARISC also doesn't have atomic r-m-w and also uses a set of
external hashed spinlocks to protect the r-m-w sequences.

https://lkml.org/lkml/2014/6/1/178

So there also we have the same race because the outer spin lock is not taken for
slab_unlock() -> __bit_spin_lock() -> __clear_bit.

Arguably I can fix the ARC !LLSC variant of test_and_set_bit() to not set the bit
unconditionally but only if it was clear (PARISC does the same). That would be a
slight micro-optimization as we won't need another snoop transaction to make line
writable and that would also elide this problem, but I think there is a
fundamental problem here in slub which is pairing atomic and non atomic ops - for
performance reasons. It doesn't work on all arches and/or configurations.

> You need a true atomic op or you need to take the "spinlock" in all
> cases where you modify the bit.

No we don't in __bit_spin_lock and we already do in bit_spin_lock.

> If you take the lock in __bit_spin_unlock
> then the race cannot happen.

Of course it won't but that means we penalize all non atomic callers of the API
with a superfluous spinlock which is not require din first place given the
definition of API.


>> Are you convinced now !
> 
> Yes, please fix your arch specific code.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
