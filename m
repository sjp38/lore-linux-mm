Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 415326B0265
	for <linux-mm@kvack.org>; Sun, 31 Jul 2016 18:24:28 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id 33so64483441lfw.1
        for <linux-mm@kvack.org>; Sun, 31 Jul 2016 15:24:28 -0700 (PDT)
Received: from outbound1.eu.mailhop.org (outbound1.eu.mailhop.org. [52.28.251.132])
        by mx.google.com with ESMTPS id g64si13214026wmd.109.2016.07.31.15.24.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 31 Jul 2016 15:24:26 -0700 (PDT)
Date: Sun, 31 Jul 2016 22:24:16 +0000
From: Jason Cooper <jason@lakedaemon.net>
Subject: Re: [kernel-hardening] Re: [PATCH] [RFC] Introduce mmap randomization
Message-ID: <20160731222416.GZ4541@io.lakedaemon.net>
References: <1469557346-5534-1-git-send-email-william.c.roberts@intel.com>
 <1469557346-5534-2-git-send-email-william.c.roberts@intel.com>
 <20160726200309.GJ4541@io.lakedaemon.net>
 <476DC76E7D1DF2438D32BFADF679FC560125F29C@ORSMSX103.amr.corp.intel.com>
 <20160726205944.GM4541@io.lakedaemon.net>
 <CAFJ0LnEZW7Y1zfN8v0_ckXQZn1n-UKEhf_tSmNOgHwrrnNnuMg@mail.gmail.com>
 <20160728210734.GU4541@io.lakedaemon.net>
 <1469787002.10626.34.camel@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1469787002.10626.34.camel@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel-hardening@lists.openwall.com
Cc: Nick Kralevich <nnk@google.com>, "Roberts, William C" <william.c.roberts@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "keescook@chromium.org" <keescook@chromium.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "jeffv@google.com" <jeffv@google.com>, "salyzyn@android.com" <salyzyn@android.com>, "dcashman@android.com" <dcashman@android.com>

Hi Daniel,

On Fri, Jul 29, 2016 at 06:10:02AM -0400, Daniel Micay wrote:
> > > In the Project Zero Stagefright post
> > > (http://googleprojectzero.blogspot.com/2015/09/stagefrightened.html)
> > > , we see that the linear allocation of memory combined with the
> > > low number of bits in the initial mmap offset resulted in a much
> > > more predictable layout which aided the attacker. The initial
> > > random mmap base range was increased by Daniel Cashman in
> > > d07e22597d1d355829b7b18ac19afa912cf758d1, but we've done nothing
> > > to address page relative attacks.
> > > 
> > > Inter-mmap randomization will decrease the predictability of later
> > > mmap() allocations, which should help make data structures harder
> > > to find in memory. In addition, this patch will also introduce
> > > unmapped gaps between pages, preventing linear overruns from one
> > > mapping to another another mapping. I am unable to quantify how
> > > much this will improve security, but it should be > 0.
> > 
> > One person calls "unmapped gaps between pages" a feature, others
> > call it a mess. ;-)
> 
> It's very hard to quantify the benefits of fine-grained randomization,

?  N = # of possible addresses.  The bigger N is, the more chances the
attacker will trip up before finding what they were looking for.

> but there are other useful guarantees you could provide. It would be
> quite helpful for the kernel to expose the option to force a PROT_NONE
> mapping after every allocation. The gaps should actually be enforced.
> 
> So perhaps 3 things, simply exposed as off-by-default sysctl options
> (no need for special treatment on 32-bit):

I'm certainly not an mm-developer, but this looks to me like we're
pushing the work of creating efficient, random mappings out to
userspace.  :-/

> a) configurable minimum gap size in pages (for protection against
> linear and small {under,over}flows) b) configurable minimum gap size
> based on a ratio to allocation size (for making the heap sparse to
> mitigate heap sprays, especially when mixed with fine-grained
> randomization - for example 2x would add a 2M gap after a 1M mapping)

mmm, this looks like an information leak.  Best to set a range of pages
and pick a random number within that range for each call.

> c) configurable maximum random gap size (the random gap would be in
> addition to the enforced minimums)
> 
> The randomization could just be considered an extra with minor
> benefits rather than the whole feature. A full fine-grained
> randomization implementation would need a higher-level form of
> randomization than gaps in the kernel along with cooperation from
> userspace allocators. This would make sense as one part of it though.

Ok, so here's an idea.  This idea could be used in conjunction with
random gaps, or on it's own.  It would be enhanced by userspace random
load order.

The benefit is that with 32bit address space, and no random gapping,
it's still not wasting much space.

Given a memory space, break it up into X bands such that there are 2*X
possible addresses.

  |A     B|C     D|E     F|G     H| ... |2*X-2  2*X-1|
  |--> <--|--> <--|--> <--|--> <--| ... |-->      <--|
min                                                  max

For each call to mmap, we randomly pick a value within [0 - 2*X).
Assuming A=0 in the diagram above, even values grow up, odd values grow
down.  Gradually consuming the single gap in the middle of each band.

How many bands to use would depend on:
  * 32/64bit
  * Average number of mmap calls
  * largest single mmap call usually seen
  * if using random gaps and range used

If the free gap in a chosen band is too small for the request, pick
again among the other bands.

Again, I'm not an mm dev, so I might be totally smoking crack on this
one...

thx,

Jason.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
