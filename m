Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 53EC86B0005
	for <linux-mm@kvack.org>; Wed,  4 May 2016 15:20:39 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id r12so59828845wme.0
        for <linux-mm@kvack.org>; Wed, 04 May 2016 12:20:39 -0700 (PDT)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id d12si6757526wjs.183.2016.05.04.12.20.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 04 May 2016 12:20:32 -0700 (PDT)
Date: Wed, 4 May 2016 20:17:55 +0100
From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: kmap_atomic and preemption
Message-ID: <20160504191755.GV19428@n2100.arm.linux.org.uk>
References: <5729D0F4.9090907@synopsys.com>
 <20160504134729.GP3430@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160504134729.GP3430@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Vineet Gupta <Vineet.Gupta1@synopsys.com>, Nicolas Pitre <nicolas.pitre@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, David Hildenbrand <dahi@linux.vnet.ibm.com>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>

On Wed, May 04, 2016 at 03:47:29PM +0200, Peter Zijlstra wrote:
> Traditionally kmap_atomic() disables preemption; and the reason is that
> the returned pointer must stay valid. This had a side effect in that it
> also disabled pagefaults.

A lowmem page should never change its page_address(), so that much is
safe.  I think the question is whether there is any driver code which
assumes that preemption is unconditionally disabled between a
kmap_atomic() has been called.

That wouldn't be an unreasonable assumption given the name of the
function, so I'd suggest caution with making kmap_atomic() have these
kinds of differing behaviours depending on whether we're asking to
kmap a high or lowmem page.

If we are going to allow this, I think it at least needs to be well
documented.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
