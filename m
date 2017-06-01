Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id EEF6C6B02B4
	for <linux-mm@kvack.org>; Wed, 31 May 2017 20:01:16 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id y65so32963723pff.13
        for <linux-mm@kvack.org>; Wed, 31 May 2017 17:01:16 -0700 (PDT)
Received: from mail-pf0-x22e.google.com (mail-pf0-x22e.google.com. [2607:f8b0:400e:c00::22e])
        by mx.google.com with ESMTPS id v3si47525621plk.127.2017.05.31.17.01.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 May 2017 17:01:07 -0700 (PDT)
Received: by mail-pf0-x22e.google.com with SMTP id n23so21026426pfb.2
        for <linux-mm@kvack.org>; Wed, 31 May 2017 17:01:07 -0700 (PDT)
Date: Wed, 31 May 2017 17:01:05 -0700
From: Matthias Kaehlcke <mka@chromium.org>
Subject: Re: [patch] compiler, clang: suppress warning for unused static
 inline functions
Message-ID: <20170601000105.GY141096@google.com>
References: <alpine.DEB.2.10.1705241400510.49680@chino.kir.corp.google.com>
 <20170524212229.GR141096@google.com>
 <20170524143205.cae1a02ab2ad7348c1a59e0c@linux-foundation.org>
 <CAD=FV=XjC3M=EWC=rtcbTUR6e1F2cfuYvqL53F9H7tdMAOALNw@mail.gmail.com>
 <alpine.DEB.2.10.1705301704370.10695@chino.kir.corp.google.com>
 <CAD=FV=Xi7NjDjsdwGP=GGS9p=uUpqZa7S=irNOFmhfD1F3kWZQ@mail.gmail.com>
 <alpine.DEB.2.10.1705311436490.82977@chino.kir.corp.google.com>
 <CAD=FV=WUGP9zw3Tw3dBm3v88zccUUkw7Uj-PjEaBUG9mQ7-7iw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CAD=FV=WUGP9zw3Tw3dBm3v88zccUUkw7Uj-PjEaBUG9mQ7-7iw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Doug Anderson <dianders@chromium.org>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Mark Brown <broonie@kernel.org>, Ingo Molnar <mingo@kernel.org>, David Miller <davem@davemloft.net>

El Wed, May 31, 2017 at 03:31:26PM -0700 Doug Anderson ha dit:

> Hi,
> 
> On Wed, May 31, 2017 at 2:45 PM, David Rientjes <rientjes@google.com> wrote:
> > On Wed, 31 May 2017, Doug Anderson wrote:
> >
> >> > Again, I defer to maintainers like Andrew and Ingo who have to deal with
> >> > an enormous amount of patches on how they would like to handle it; I don't
> >> > think myself or anybody else who doesn't deal with a large number of
> >> > patches should be mandating how it's handled.
> >> >
> >> > For reference, the patchset that this patch originated from added 8 lines
> >> > and removed 1, so I disagree that this cleans anything up; in reality, it
> >> > obfuscates the code and makes the #ifdef nesting more complex.
> >>
> >> As Matthias said, let's not argue about ifdeffs and instead talk about
> >> adding "maybe unused".  100% of these cases _can_ be solved by adding
> >> "maybe unused".  Then, if a maintainer thinks that an ifdef is cleaner
> >> / better in a particular case, we can use an ifdef in that case.
> >>
> >> Do you believe that adding "maybe unused" tags significantly uglifies
> >> the code?  I personally find them documenting.
> >>
> >
> > But then you've eliminated the possibility of finding dead code again,
> > which is the only point to the warning :)  So now we have patches going to
> > swamped maintainers to add #ifdef's, more LOC, and now patches to sprinkle
> > __maybe_unused throughout the code to not increase LOC in select areas but
> > then we can't find dead code again.
> 
> True, once code is marked __maybe_unused once then it can no longer be
> found later, even if it becomes completely dead.  ...but this is also
> no different for __maybe_unused code that is _not_ marked as "static
> inline".
> 
> Basically, my argument here is that "static inline" functions in ".c"
> files should not be treated differently than "static" functions in
> ".c" files.  We have always agreed to add __maybe_unused for "static"
> functions.
> 
> Also: allowing us to leave the warning turned on (and have no false
> positives reported) mean that, as new code is added we'll be able to
> find problems in the new code.  This is where it's most important.
> 
> 
> > My suggestion is to match gcc behavior and if anybody is in the business
> > of cleaning up truly dead code, send patches.  Tools exist to do this
> > outside of relying on a minority compiler during compilation.  Otherwise,
> > this is simply adding more burden to already swamped maintainers to
> > annotate every single static inline function that clang complains about.
> > I'd prefer to let them decide and this will be the extent of my
> > participation in this thread.
> 
> Maybe Matthias can give actual stats here, but I think "every single"
> overstates the issue a bit.  I get the impression we're talking
> something like ~30-40 patches that don't actually delete dead code and
> just add "maybe unused".  Given that nobody has ever looked for these
> functions before, I'd expect that new code is unlikely to cause a new
> deluge of patches.
> 
> Note also that Matthias started a bigger thread to discuss this
> (subject: [RFC] clang: 'unused-function' warning on static inline
> functions).  Maybe we should move the discussion there so it's not so
> scattered?

I sent a list of instances from x86 and arm64 defconfig to the RFC
thread. For these configs its 25 instances distributed over different
subsystems, the number of patches would likely be around 20, since in
some cases multiple warnings can be addressed in a single patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
