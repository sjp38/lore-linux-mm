Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4120C6B0279
	for <linux-mm@kvack.org>; Wed, 31 May 2017 18:31:29 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 139so5985673wmf.5
        for <linux-mm@kvack.org>; Wed, 31 May 2017 15:31:29 -0700 (PDT)
Received: from mail-wm0-x22d.google.com (mail-wm0-x22d.google.com. [2a00:1450:400c:c09::22d])
        by mx.google.com with ESMTPS id j24si132408wrd.187.2017.05.31.15.31.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 May 2017 15:31:28 -0700 (PDT)
Received: by mail-wm0-x22d.google.com with SMTP id 7so135712063wmo.1
        for <linux-mm@kvack.org>; Wed, 31 May 2017 15:31:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1705311436490.82977@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1705241400510.49680@chino.kir.corp.google.com>
 <20170524212229.GR141096@google.com> <20170524143205.cae1a02ab2ad7348c1a59e0c@linux-foundation.org>
 <CAD=FV=XjC3M=EWC=rtcbTUR6e1F2cfuYvqL53F9H7tdMAOALNw@mail.gmail.com>
 <alpine.DEB.2.10.1705301704370.10695@chino.kir.corp.google.com>
 <CAD=FV=Xi7NjDjsdwGP=GGS9p=uUpqZa7S=irNOFmhfD1F3kWZQ@mail.gmail.com> <alpine.DEB.2.10.1705311436490.82977@chino.kir.corp.google.com>
From: Doug Anderson <dianders@chromium.org>
Date: Wed, 31 May 2017 15:31:26 -0700
Message-ID: <CAD=FV=WUGP9zw3Tw3dBm3v88zccUUkw7Uj-PjEaBUG9mQ7-7iw@mail.gmail.com>
Subject: Re: [patch] compiler, clang: suppress warning for unused static
 inline functions
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthias Kaehlcke <mka@chromium.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Mark Brown <broonie@kernel.org>, Ingo Molnar <mingo@kernel.org>, David Miller <davem@davemloft.net>

Hi,

On Wed, May 31, 2017 at 2:45 PM, David Rientjes <rientjes@google.com> wrote:
> On Wed, 31 May 2017, Doug Anderson wrote:
>
>> > Again, I defer to maintainers like Andrew and Ingo who have to deal with
>> > an enormous amount of patches on how they would like to handle it; I don't
>> > think myself or anybody else who doesn't deal with a large number of
>> > patches should be mandating how it's handled.
>> >
>> > For reference, the patchset that this patch originated from added 8 lines
>> > and removed 1, so I disagree that this cleans anything up; in reality, it
>> > obfuscates the code and makes the #ifdef nesting more complex.
>>
>> As Matthias said, let's not argue about ifdeffs and instead talk about
>> adding "maybe unused".  100% of these cases _can_ be solved by adding
>> "maybe unused".  Then, if a maintainer thinks that an ifdef is cleaner
>> / better in a particular case, we can use an ifdef in that case.
>>
>> Do you believe that adding "maybe unused" tags significantly uglifies
>> the code?  I personally find them documenting.
>>
>
> But then you've eliminated the possibility of finding dead code again,
> which is the only point to the warning :)  So now we have patches going to
> swamped maintainers to add #ifdef's, more LOC, and now patches to sprinkle
> __maybe_unused throughout the code to not increase LOC in select areas but
> then we can't find dead code again.

True, once code is marked __maybe_unused once then it can no longer be
found later, even if it becomes completely dead.  ...but this is also
no different for __maybe_unused code that is _not_ marked as "static
inline".

Basically, my argument here is that "static inline" functions in ".c"
files should not be treated differently than "static" functions in
".c" files.  We have always agreed to add __maybe_unused for "static"
functions.

Also: allowing us to leave the warning turned on (and have no false
positives reported) mean that, as new code is added we'll be able to
find problems in the new code.  This is where it's most important.


> My suggestion is to match gcc behavior and if anybody is in the business
> of cleaning up truly dead code, send patches.  Tools exist to do this
> outside of relying on a minority compiler during compilation.  Otherwise,
> this is simply adding more burden to already swamped maintainers to
> annotate every single static inline function that clang complains about.
> I'd prefer to let them decide and this will be the extent of my
> participation in this thread.

Maybe Matthias can give actual stats here, but I think "every single"
overstates the issue a bit.  I get the impression we're talking
something like ~30-40 patches that don't actually delete dead code and
just add "maybe unused".  Given that nobody has ever looked for these
functions before, I'd expect that new code is unlikely to cause a new
deluge of patches.

Note also that Matthias started a bigger thread to discuss this
(subject: [RFC] clang: 'unused-function' warning on static inline
functions).  Maybe we should move the discussion there so it's not so
scattered?

-Doug

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
