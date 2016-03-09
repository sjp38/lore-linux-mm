Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 341406B0255
	for <linux-mm@kvack.org>; Wed,  9 Mar 2016 06:13:08 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id td3so10475557pab.2
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 03:13:08 -0800 (PST)
Received: from smtprelay.synopsys.com (smtprelay4.synopsys.com. [198.182.47.9])
        by mx.google.com with ESMTPS id 83si11886331pfl.78.2016.03.09.03.13.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Mar 2016 03:13:07 -0800 (PST)
Subject: Re: [PATCH] mm: slub: Ensure that slab_unlock() is atomic
References: <1457447457-25878-1-git-send-email-vgupta@synopsys.com>
 <alpine.DEB.2.20.1603080857360.4047@east.gentwo.org>
 <56DEF3D3.6080008@synopsys.com>
 <alpine.DEB.2.20.1603081438020.4268@east.gentwo.org>
 <56DFC604.6070407@synopsys.com>
 <20160309101349.GJ6344@twins.programming.kicks-ass.net>
 <20160309103143.GF25010@twins.programming.kicks-ass.net>
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Message-ID: <56E0052B.3080304@synopsys.com>
Date: Wed, 9 Mar 2016 16:42:43 +0530
MIME-Version: 1.0
In-Reply-To: <20160309103143.GF25010@twins.programming.kicks-ass.net>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Noam
 Camus <noamc@ezchip.com>, stable@vger.kernel.org, linux-kernel@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-parisc@vger.kernel, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>

On Wednesday 09 March 2016 04:01 PM, Peter Zijlstra wrote:
> On Wed, Mar 09, 2016 at 11:13:49AM +0100, Peter Zijlstra wrote:
>> ---
>> Subject: bitops: Do not default to __clear_bit() for __clear_bit_unlock()
>>
>> __clear_bit_unlock() is a special little snowflake. While it carries the
>> non-atomic '__' prefix, it is specifically documented to pair with
>> test_and_set_bit() and therefore should be 'somewhat' atomic.
>>
>> Therefore the generic implementation of __clear_bit_unlock() cannot use
>> the fully non-atomic __clear_bit() as a default.
>>
>> If an arch is able to do better; is must provide an implementation of
>> __clear_bit_unlock() itself.
>>
> 
> FWIW, we could probably undo this if we unified all the spinlock based
> atomic ops implementations (there's a whole bunch doing essentially the
> same), and special cased __clear_bit_unlock() for that.
> 
> Collapsing them is probably a good idea anyway, just a fair bit of
> non-trivial work to figure out all the differences and if they matter
> etc..

Indeed I thought about this when we first did the SMP port. The only issue was
somewhat more generated code with the hashed spinlocks (vs. my dumb 2 spin locks -
which as I see now will also cause false sharing - likely ending up in the same
cache line), but I was more of a micro-optimization freak then than I'm now :-)

So yeah I agree !




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
