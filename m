Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5EF6A6B03A2
	for <linux-mm@kvack.org>; Wed, 21 Dec 2016 13:33:47 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id j128so328869617pfg.4
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 10:33:47 -0800 (PST)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id y21si27586479pgh.97.2016.12.21.10.33.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Dec 2016 10:33:46 -0800 (PST)
Received: by mail-pg0-x244.google.com with SMTP id g1so15373422pgn.0
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 10:33:46 -0800 (PST)
Date: Thu, 22 Dec 2016 04:33:31 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [RFC][PATCH] make global bitlock waitqueues per-node
Message-ID: <20161222043331.31aab9cc@roar.ozlabs.ibm.com>
In-Reply-To: <CA+55aFx-YmpZ4NBU0oSw_iJV8jEMaL8qX-HCH=DrutQ65UYR5A@mail.gmail.com>
References: <20161219225826.F8CB356F@viggo.jf.intel.com>
	<CA+55aFwK6JdSy9v_BkNYWNdfK82sYA1h3qCSAJQ0T45cOxeXmQ@mail.gmail.com>
	<156a5b34-ad3b-d0aa-83c9-109b366c1bdf@linux.intel.com>
	<CA+55aFxVzes5Jt-hC9BLVSb99x6K-_WkLO-_JTvCjhf5wuK_4w@mail.gmail.com>
	<CA+55aFwy6+ya_E8N3DFbrq2XjbDs8LWe=W_qW8awimbxw26bJw@mail.gmail.com>
	<20161221080931.GQ3124@twins.programming.kicks-ass.net>
	<20161221083247.GW3174@twins.programming.kicks-ass.net>
	<CA+55aFx-YmpZ4NBU0oSw_iJV8jEMaL8qX-HCH=DrutQ65UYR5A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Bob Peterson <rpeterso@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Steven Whitehouse <swhiteho@redhat.com>, Andrew Lutomirski <luto@kernel.org>, Andreas Gruenbacher <agruenba@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, linux-mm <linux-mm@kvack.org>

On Wed, 21 Dec 2016 10:02:27 -0800
Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Wed, Dec 21, 2016 at 12:32 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> >
> > FWIW, here's mine.. compiles and boots on a NUMA x86_64 machine.  
> 
> So I like how your patch is smaller, but your patch is also broken.
> 
> First off, the whole contention bit is *not* NUMA-specific. It should
> help non-NUMA too, by avoiding the stupid extra cache miss.
> 
> Secondly, CONFIG_NUMA is a broken thing to test anyway, since adding a
> bit for the NUMA case can overflow the page flags as far as I can tell
> (MIPS seems to support NUMA on 32-bit, for example, but I didn't
> really check the Kconfig details). Making it dependent on 64-bit might
> be ok (and would fix the issue above - I don't think we really need to
> care too much about 32-bit any more)
> 
> But making it conditional at all means that now you have those two
> different cases for this, which is a maintenance nightmare. So don't
> do it even if we could say "screw 32-bit".
> 
> Anyway, the conditional thing could be fixed by just taking Nick's
> patch 1/2, and your patch (with the conditional bits stripped out).
> 
> I do think your approach of just re-using the existing bit waiting
> with just a page-specific waiting function is nicer than Nick's "let's
> just roll new waiting functions" approach. It also avoids the extra
> initcall.
> 
> Nick, comments?

Well yes we should take my patch 1 and use the new bit for this
purpose regardless of what way we go with patch 2. I'll reply to
that in the other mail.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
