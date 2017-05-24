Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 55AF16B0279
	for <linux-mm@kvack.org>; Wed, 24 May 2017 19:28:44 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id y106so17903530wrb.14
        for <linux-mm@kvack.org>; Wed, 24 May 2017 16:28:44 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 16sor53379wrw.13.2017.05.24.16.28.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 May 2017 16:28:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170524143205.cae1a02ab2ad7348c1a59e0c@linux-foundation.org>
References: <alpine.DEB.2.10.1705241400510.49680@chino.kir.corp.google.com>
 <20170524212229.GR141096@google.com> <20170524143205.cae1a02ab2ad7348c1a59e0c@linux-foundation.org>
From: Doug Anderson <dianders@chromium.org>
Date: Wed, 24 May 2017 16:28:41 -0700
Message-ID: <CAD=FV=XjC3M=EWC=rtcbTUR6e1F2cfuYvqL53F9H7tdMAOALNw@mail.gmail.com>
Subject: Re: [patch] compiler, clang: suppress warning for unused static
 inline functions
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthias Kaehlcke <mka@chromium.org>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Mark Brown <broonie@kernel.org>, Ingo Molnar <mingo@kernel.org>, David Miller <davem@davemloft.net>

Hi,

On Wed, May 24, 2017 at 2:32 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Wed, 24 May 2017 14:22:29 -0700 Matthias Kaehlcke <mka@chromium.org> wrote:
>
>> I'm not a kernel maintainer, so it's not my decision whether this
>> warning should be silenced, my personal opinion is that it's benfits
>> outweigh the inconveniences of dealing with half-false positives,
>> generally caused by the heavy use of #ifdef by the kernel itself.
>
> Please resend and include this info in the changelog.  Describe
> instances where this warning has resulted in actual runtime or
> developer-visible benefits.
>
> Where possible an appropriate I suggest it is better to move the
> offending function into a header file, rather than adding ifdefs.

Can you clarify what you're asking for here?

* Matthias has been sending out individual patches that take each
particular case into account to try to remove the warnings.  In some
cases this removes totally dead code.  In other cases this adds
__maybe_unused.  ...and as a last resort it uses #ifdef.  In each of
these individual patches we wouldn't want a list of all other patches,
I think.

* Matthias is arguing here _against_ David's patch.


The best I can understand is that you're asking David to add
Matthias's objections into his patch description, then say why we're
still disabling this warning?

---

If you just want a list of things in response to this thread...

Clang's behavior has found some dead code, as shown by:

* https://patchwork.kernel.org/patch/9732161/
  ring-buffer: Remove unused function __rb_data_page_index()
* https://patchwork.kernel.org/patch/9735027/
  r8152: Remove unused function usb_ocp_read()
* https://patchwork.kernel.org/patch/9735053/
  net1080: Remove unused function nc_dump_ttl()
* https://patchwork.kernel.org/patch/9741513/
  crypto: rng: Remove unused function __crypto_rng_cast()
* https://patchwork.kernel.org/patch/9741539/
  x86/ioapic: Remove unused function IO_APIC_irq_trigger()
* https://patchwork.kernel.org/patch/9741549/
  ASoC: Intel: sst: Remove unused function sst_restore_shim64()
* https://patchwork.kernel.org/patch/9743225/
  ASoC: cht_bsw_max98090_ti: Remove unused function cht_get_codec_dai()

...plus more examples...


However, clang's behavior has also led to patches that add a
"__maybe_unused" attribute (usually no increase in LOC unless it
causes word wrap) and also added a handful of #ifdefs, as you've
pointed out.  The example we already talked about was:

* https://patchwork.kernel.org/patch/9738139/
  mm/slub: Only define kmalloc_large_node_hook() for NUMA systems

We can, of course, discuss the best way to solve each individual
issue.  ...and if we can find a way around #ifdef in most places that
seems ideal.  If people really think the ability to spot dead code is
not important, though, then disabling the warning globally like
David's patch is the way to go.


Note that in addition to spotting some dead code, clang's warnings
also have the ability to identify "paste-o" bugs during development
that would be harder to find if these warnings were disabled.  It's
unlikely problems like this would last long in the kernel, but
certainly I've made paste-o mistakes like this and then spent quite a
while trying to figure out why things weren't working until my eyes
finally spotted my stupidity.  Like:

static inline void its_a_dog(void) {
  pr_info("It's a dog\n");
}

static inline void its_a_cat(void) {
  pr_info("It's a dog\n");
}

static void foo(void) {
  if (strcmp(animal, "cat") == 0) {
    /* It's a cat! */
    its_a_cat();
  } else {
    /* It's a dog! */
   its_a_cat();
  }
}

Clang would (nicely) tell me that its_a_dog() is unused.  This is a
stupid example but I've made this type of mistake in the past for
sure.


-Doug

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
