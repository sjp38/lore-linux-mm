Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 881196B003D
	for <linux-mm@kvack.org>; Wed, 29 Apr 2009 01:09:44 -0400 (EDT)
Date: Wed, 29 Apr 2009 13:09:13 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 5/5] proc: export more page flags in /proc/kpageflags
Message-ID: <20090429050913.GA16683@localhost>
References: <20090428010907.912554629@intel.com> <20090428014920.769723618@intel.com> <20090428143244.4e424d36.akpm@linux-foundation.org> <20090429023842.GA10266@localhost> <20090428195527.4638f58c.akpm@linux-foundation.org> <20090429034829.GA10832@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090429034829.GA10832@localhost>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "andi@firstfloor.org" <andi@firstfloor.org>, "mpm@selenic.com" <mpm@selenic.com>, "adobriyan@gmail.com" <adobriyan@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Chandra Seetharaman <sekharan@us.ibm.com>, Nathan Lynch <ntl@pobox.com>, Olof Johansson <olof@lixom.net>, Helge Deller <deller@parisc-linux.org>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 29, 2009 at 11:48:29AM +0800, Wu Fengguang wrote:
> On Wed, Apr 29, 2009 at 10:55:27AM +0800, Andrew Morton wrote:
> > On Wed, 29 Apr 2009 10:38:42 +0800 Wu Fengguang <fengguang.wu@intel.com> wrote:
> > 
> > > > > +#define kpf_copy_bit(uflags, kflags, visible, ubit, kbit)		\
> > > > > +	do {								\
> > > > > +		if (visible || genuine_linus())				\
> > > > > +			uflags |= ((kflags >> kbit) & 1) << ubit;	\
> > > > > +	} while (0);
> > > > 
> > > > Did this have to be implemented as a macro?
> > > > 
> > > > It's bad, because it might or might not reference its argument, so if
> > > > someone passes it an expression-with-side-effects, the end result is
> > > > unpredictable.  A C function is almost always preferable if possible.
> > > 
> > > Just tried inline function, the code size is increased slightly:
> > > 
> > >           text   data    bss     dec    hex   filename
> > > macro     1804    128      0    1932    78c   fs/proc/page.o
> > > inline    1828    128      0    1956    7a4   fs/proc/page.o
> > > 
> > 
> > hm, I wonder why.  Maybe it fixed a bug ;)
> > 
> > The code is effectively doing
> > 
> > 	if (expr1)
> > 		something();
> > 	if (expr1)
> > 		something_else();
> > 	if (expr1)
> > 		something_else2();
> > 
> > etc.  Obviously we _hope_ that the compiler turns that into
> > 
> > 	if (expr1) {
> > 		something();
> > 		something_else();
> > 		something_else2();
> > 	}
> > 
> > for us, but it would be good to check...
> 
> By 'expr1', you mean (visible || genuine_linus())?
> 
> No, I can confirm the inefficiency does not lie here.
> 
> I simplified the kpf_copy_bit() to
> 
>         #define kpf_copy_bit(uflags, kflags, ubit, kbit)                     \
>                         uflags |= (((kflags) >> (kbit)) & 1) << (ubit);
> 
> or
> 
>         static inline u64 kpf_copy_bit(u64 kflags, int ubit, int kbit)
>         {       
>                 return (((kflags) >> (kbit)) & 1) << (ubit);
>         }
> 
> and double checked the differences: the gap grows unexpectedly!
> 
>               text               data                bss                dec            hex filename
> macro         1829                168                  0               1997            7cd fs/proc/page.o
> inline        1893                168                  0               2061            80d fs/proc/page.o
>               +3.5%
> 
> (note: the larger absolute text size is due to some experimental code elsewhere.)

Wow, after simplifications the text size goes down by -13.2%:

              text               data                bss                dec            hex filename
macro         1644                  8                  0               1652            674 fs/proc/page.o
inline        1644                  8                  0               1652            674 fs/proc/page.o

Amazingly we can now use inline function without performance penalty!

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
