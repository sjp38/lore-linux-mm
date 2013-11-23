Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f177.google.com (mail-vc0-f177.google.com [209.85.220.177])
	by kanga.kvack.org (Postfix) with ESMTP id 46F4B6B0035
	for <linux-mm@kvack.org>; Sat, 23 Nov 2013 15:39:55 -0500 (EST)
Received: by mail-vc0-f177.google.com with SMTP id hv10so1744110vcb.22
        for <linux-mm@kvack.org>; Sat, 23 Nov 2013 12:39:55 -0800 (PST)
Received: from mail-vc0-x22c.google.com (mail-vc0-x22c.google.com [2607:f8b0:400c:c03::22c])
        by mx.google.com with ESMTPS id sl9si94682vdc.138.2013.11.23.12.39.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 23 Nov 2013 12:39:54 -0800 (PST)
Received: by mail-vc0-f172.google.com with SMTP id hz11so1771820vcb.3
        for <linux-mm@kvack.org>; Sat, 23 Nov 2013 12:39:54 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+55aFxQy8afgf6geqJOEHmsJ=ME-6CXrrPfj=aggH7u_jEEZA@mail.gmail.com>
References: <20131122184937.GX4138@linux.vnet.ibm.com>
	<CA+55aFyKKpf-i4pQ_dhy9gic74xtCbO+U8GXU6mCtQj1ZHy05A@mail.gmail.com>
	<20131122200620.GA4138@linux.vnet.ibm.com>
	<CA+55aFz0nP1_O8jO2UkX1DmDzcBm53-fFejvz=oY=x3cGNBJSQ@mail.gmail.com>
	<20131122203738.GC4138@linux.vnet.ibm.com>
	<CA+55aFwHUuaGzW_=xEWNcyVnHT-zW8-bs6Xi=M458xM3Y1qE0w@mail.gmail.com>
	<20131122215208.GD4138@linux.vnet.ibm.com>
	<CA+55aFzS2yd-VbJB5t14mP8NZG8smB1BQaYCw3Zo19FWQL92vA@mail.gmail.com>
	<20131123002542.GF4138@linux.vnet.ibm.com>
	<CA+55aFy8kx1qaWszc9nrbUaqFu7GfTtDkpzPBeE2g2U6RZjYkA@mail.gmail.com>
	<20131123013654.GG4138@linux.vnet.ibm.com>
	<CA+55aFxQy8afgf6geqJOEHmsJ=ME-6CXrrPfj=aggH7u_jEEZA@mail.gmail.com>
Date: Sat, 23 Nov 2013 12:39:53 -0800
Message-ID: <CA+55aFzr7=N=_t03Luzxg2Ln9_h+M9Ud5spLi7FH+5j7ynkPUg@mail.gmail.com>
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul McKenney <paulmck@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, Will Deacon <will.deacon@arm.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Sat, Nov 23, 2013 at 12:21 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> And as far as I can tell, the above gives you: A < B < C < D < E < F <
> A. Which doesn't look possible.

Hmm.. I guess technically all of those cases aren't "strictly
precedes" as much as "cannot have happened in the opposite order". So
the "<" might be "<=". Which I guess *is* possible: "it all happened
at the same time". And then the difference between your suggested
"lwsync" and "sync" in the unlock path on CPU0 basically approximating
the difference between "A <= B" and "A < B"..

Ho humm.

                 Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
