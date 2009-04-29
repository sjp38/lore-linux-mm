Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 059DA6B003D
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 23:02:47 -0400 (EDT)
Date: Tue, 28 Apr 2009 19:55:27 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 5/5] proc: export more page flags in /proc/kpageflags
Message-Id: <20090428195527.4638f58c.akpm@linux-foundation.org>
In-Reply-To: <20090429023842.GA10266@localhost>
References: <20090428010907.912554629@intel.com>
	<20090428014920.769723618@intel.com>
	<20090428143244.4e424d36.akpm@linux-foundation.org>
	<20090429023842.GA10266@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "andi@firstfloor.org" <andi@firstfloor.org>, "mpm@selenic.com" <mpm@selenic.com>, "adobriyan@gmail.com" <adobriyan@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Chandra Seetharaman <sekharan@us.ibm.com>, Nathan Lynch <ntl@pobox.com>, Olof Johansson <olof@lixom.net>, Helge Deller <deller@parisc-linux.org>
List-ID: <linux-mm.kvack.org>

On Wed, 29 Apr 2009 10:38:42 +0800 Wu Fengguang <fengguang.wu@intel.com> wrote:

> > > +#define kpf_copy_bit(uflags, kflags, visible, ubit, kbit)		\
> > > +	do {								\
> > > +		if (visible || genuine_linus())				\
> > > +			uflags |= ((kflags >> kbit) & 1) << ubit;	\
> > > +	} while (0);
> > 
> > Did this have to be implemented as a macro?
> > 
> > It's bad, because it might or might not reference its argument, so if
> > someone passes it an expression-with-side-effects, the end result is
> > unpredictable.  A C function is almost always preferable if possible.
> 
> Just tried inline function, the code size is increased slightly:
> 
>           text   data    bss     dec    hex   filename
> macro     1804    128      0    1932    78c   fs/proc/page.o
> inline    1828    128      0    1956    7a4   fs/proc/page.o
> 

hm, I wonder why.  Maybe it fixed a bug ;)

The code is effectively doing

	if (expr1)
		something();
	if (expr1)
		something_else();
	if (expr1)
		something_else2();

etc.  Obviously we _hope_ that the compiler turns that into

	if (expr1) {
		something();
		something_else();
		something_else2();
	}

for us, but it would be good to check...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
