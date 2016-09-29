Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 76B9E280251
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 03:15:00 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id fu14so126407994pad.0
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 00:15:00 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id y5si2438520pfk.271.2016.09.29.00.14.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Sep 2016 00:14:59 -0700 (PDT)
Date: Thu, 29 Sep 2016 09:14:51 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: page_waitqueue() considered harmful
Message-ID: <20160929071451.GI3318@worktop.controleur.wifipass.org>
References: <CA+55aFwVSXZPONk2OEyxcP-aAQU7-aJsF3OFXVi8Z5vA11v_-Q@mail.gmail.com>
 <20160927083104.GC2838@techsingularity.net>
 <20160928005318.2f474a70@roar.ozlabs.ibm.com>
 <20160927165221.GP5016@twins.programming.kicks-ass.net>
 <20160928030621.579ece3a@roar.ozlabs.ibm.com>
 <20160928070546.GT2794@worktop>
 <20160929113132.5a85b887@roar.ozlabs.ibm.com>
 <20160929062132.GG3318@worktop.controleur.wifipass.org>
 <20160929164231.166d2910@roar.ozlabs.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160929164231.166d2910@roar.ozlabs.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Will Deacon <will.deacon@arm.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Alan Stern <stern@rowland.harvard.edu>

On Thu, Sep 29, 2016 at 04:42:31PM +1000, Nicholas Piggin wrote:
> Take Alpha instead. It's using 32-bit ops.

Hmm, my Alpha docs are on the other machine, but I suppose the problem
is 64bit immediates (which would be a common problem I suppose, those
don't really work well on x86 either).

Yes, that does make it all more tricky than desired.

OTOH maybe this is a good excuse to (finally) sanitize the bitmap API to
use a fixed width. It using 'unsigned long' has been something of a pain
at times.

With that it would be 'obvious' bits need to be part of the same 32bit
word and we can use the normal smp_mb__{before,after}_atomic() again.

Given our bitops really are only about single bits, I can't see the
change making a real performance difference.

OTOH, the non atomic things like weight and ff[sz] do benefit from using
the longer words. Bother..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
