Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 84CAC6B0253
	for <linux-mm@kvack.org>; Mon, 14 Mar 2016 04:05:45 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id td3so124567749pab.2
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 01:05:45 -0700 (PDT)
Received: from smtprelay.synopsys.com (us01smtprelay-2.synopsys.com. [198.182.60.111])
        by mx.google.com with ESMTPS id kn6si1665527pab.36.2016.03.14.01.05.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Mar 2016 01:05:44 -0700 (PDT)
Subject: Re: [PATCH] mm: slub: Ensure that slab_unlock() is atomic
References: <1457447457-25878-1-git-send-email-vgupta@synopsys.com>
 <alpine.DEB.2.20.1603080857360.4047@east.gentwo.org>
 <56DEF3D3.6080008@synopsys.com>
 <alpine.DEB.2.20.1603081438020.4268@east.gentwo.org>
 <56DFC604.6070407@synopsys.com>
 <20160309101349.GJ6344@twins.programming.kicks-ass.net>
 <56E0024F.4070401@synopsys.com>
 <20160309114054.GJ6356@twins.programming.kicks-ass.net>
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Message-ID: <56E670C0.7080901@synopsys.com>
Date: Mon, 14 Mar 2016 13:35:20 +0530
MIME-Version: 1.0
In-Reply-To: <20160309114054.GJ6356@twins.programming.kicks-ass.net>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-parisc@vger.kernel, Helge Deller <deller@gmx.de>, linux-kernel@vger.kernel.org, stable@vger.kernel.org, "James E.J.
 Bottomley" <jejb@parisc-linux.org>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, Noam Camus <noamc@ezchip.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-snps-arc@lists.infradead.org, Christoph Lameter <cl@linux.com>

On Wednesday 09 March 2016 05:10 PM, Peter Zijlstra wrote:

> ---
> Subject: bitops: Do not default to __clear_bit() for __clear_bit_unlock()
> 
> __clear_bit_unlock() is a special little snowflake. While it carries the
> non-atomic '__' prefix, it is specifically documented to pair with
> test_and_set_bit() and therefore should be 'somewhat' atomic.
> 
> Therefore the generic implementation of __clear_bit_unlock() cannot use
> the fully non-atomic __clear_bit() as a default.
> 
> If an arch is able to do better; is must provide an implementation of
> __clear_bit_unlock() itself.
> 
> Specifically, this came up as a result of hackbench livelock'ing in
> slab_lock() on ARC with SMP + SLUB + !LLSC.
> 
> The issue was incorrect pairing of atomic ops.
> 
> slab_lock() -> bit_spin_lock() -> test_and_set_bit()
> slab_unlock() -> __bit_spin_unlock() -> __clear_bit()
> 
> The non serializing __clear_bit() was getting "lost"
> 
> 80543b8e:	ld_s       r2,[r13,0] <--- (A) Finds PG_locked is set
> 80543b90:	or         r3,r2,1    <--- (B) other core unlocks right here
> 80543b94:	st_s       r3,[r13,0] <--- (C) sets PG_locked (overwrites unlock)
> 
> Fixes ARC STAR 9000817404 (and probably more).
> 
> Cc: stable@vger.kernel.org
> Reported-by: Vineet Gupta <Vineet.Gupta1@synopsys.com>
> Tested-by: Vineet Gupta <Vineet.Gupta1@synopsys.com>
> Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>

Peter, I don't see this in linux-next yet. I'm hoping you will send it Linus' way
for 4.6-rc1.

Thx,
-Vineet


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
