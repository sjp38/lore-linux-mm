Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 825146B0005
	for <linux-mm@kvack.org>; Thu,  5 May 2016 05:37:11 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 4so158185761pfw.0
        for <linux-mm@kvack.org>; Thu, 05 May 2016 02:37:11 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id s9si10408005paa.115.2016.05.05.02.37.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 May 2016 02:37:10 -0700 (PDT)
Date: Thu, 5 May 2016 11:37:07 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: kmap_atomic and preemption
Message-ID: <20160505093707.GL3448@twins.programming.kicks-ass.net>
References: <5729D0F4.9090907@synopsys.com>
 <20160504134729.GP3430@twins.programming.kicks-ass.net>
 <20160504191755.GV19428@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160504191755.GV19428@n2100.arm.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Cc: Vineet Gupta <Vineet.Gupta1@synopsys.com>, Nicolas Pitre <nicolas.pitre@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, David Hildenbrand <dahi@linux.vnet.ibm.com>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>

On Wed, May 04, 2016 at 08:17:55PM +0100, Russell King - ARM Linux wrote:
> On Wed, May 04, 2016 at 03:47:29PM +0200, Peter Zijlstra wrote:
> > Traditionally kmap_atomic() disables preemption; and the reason is that
> > the returned pointer must stay valid. This had a side effect in that it
> > also disabled pagefaults.
> 
> A lowmem page should never change its page_address(), so that much is
> safe. 

Agreed..

> I think the question is whether there is any driver code which
> assumes that preemption is unconditionally disabled between a
> kmap_atomic() has been called.

right, this and consistency. Having the function disable preemption
sometimes is just plain weird.

> That wouldn't be an unreasonable assumption given the name of the
> function, so I'd suggest caution with making kmap_atomic() have these
> kinds of differing behaviours depending on whether we're asking to
> kmap a high or lowmem page.

So for -rt I did a preemptible kmap_atomic() for x86 (and maybe someone
did other archs too, I cannot remember), now -rt is funny wrt locking
anyway, but I cannot remember anything breaking because of this, so
there is some hope it will actually work.

> If we are going to allow this, I think it at least needs to be well
> documented.

Indeed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
