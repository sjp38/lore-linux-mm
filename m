Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id EA07F6B0279
	for <linux-mm@kvack.org>; Tue, 30 May 2017 20:10:12 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id j28so2245827pfk.14
        for <linux-mm@kvack.org>; Tue, 30 May 2017 17:10:12 -0700 (PDT)
Received: from mail-pf0-x22a.google.com (mail-pf0-x22a.google.com. [2607:f8b0:400e:c00::22a])
        by mx.google.com with ESMTPS id m15si15173164pgs.246.2017.05.30.17.10.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 May 2017 17:10:12 -0700 (PDT)
Received: by mail-pf0-x22a.google.com with SMTP id m17so1323564pfg.3
        for <linux-mm@kvack.org>; Tue, 30 May 2017 17:10:12 -0700 (PDT)
Date: Tue, 30 May 2017 17:10:10 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] compiler, clang: suppress warning for unused static
 inline functions
In-Reply-To: <CAD=FV=XjC3M=EWC=rtcbTUR6e1F2cfuYvqL53F9H7tdMAOALNw@mail.gmail.com>
Message-ID: <alpine.DEB.2.10.1705301704370.10695@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1705241400510.49680@chino.kir.corp.google.com> <20170524212229.GR141096@google.com> <20170524143205.cae1a02ab2ad7348c1a59e0c@linux-foundation.org> <CAD=FV=XjC3M=EWC=rtcbTUR6e1F2cfuYvqL53F9H7tdMAOALNw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Doug Anderson <dianders@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthias Kaehlcke <mka@chromium.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Mark Brown <broonie@kernel.org>, Ingo Molnar <mingo@kernel.org>, David Miller <davem@davemloft.net>

On Wed, 24 May 2017, Doug Anderson wrote:

> * Matthias has been sending out individual patches that take each
> particular case into account to try to remove the warnings.  In some
> cases this removes totally dead code.  In other cases this adds
> __maybe_unused.  ...and as a last resort it uses #ifdef.  In each of
> these individual patches we wouldn't want a list of all other patches,
> I think.
> 

Again, I defer to maintainers like Andrew and Ingo who have to deal with 
an enormous amount of patches on how they would like to handle it; I don't 
think myself or anybody else who doesn't deal with a large number of 
patches should be mandating how it's handled.

For reference, the patchset that this patch originated from added 8 lines 
and removed 1, so I disagree that this cleans anything up; in reality, it 
obfuscates the code and makes the #ifdef nesting more complex.

> If you just want a list of things in response to this thread...
> 
> Clang's behavior has found some dead code, as shown by:
> 
> * https://patchwork.kernel.org/patch/9732161/
>   ring-buffer: Remove unused function __rb_data_page_index()
> * https://patchwork.kernel.org/patch/9735027/
>   r8152: Remove unused function usb_ocp_read()
> * https://patchwork.kernel.org/patch/9735053/
>   net1080: Remove unused function nc_dump_ttl()
> * https://patchwork.kernel.org/patch/9741513/
>   crypto: rng: Remove unused function __crypto_rng_cast()
> * https://patchwork.kernel.org/patch/9741539/
>   x86/ioapic: Remove unused function IO_APIC_irq_trigger()
> * https://patchwork.kernel.org/patch/9741549/
>   ASoC: Intel: sst: Remove unused function sst_restore_shim64()
> * https://patchwork.kernel.org/patch/9743225/
>   ASoC: cht_bsw_max98090_ti: Remove unused function cht_get_codec_dai()
> 
> ...plus more examples...
> 

Let us please not confuse the matter by suggesting that you cannot 
continue to do this work by simply removing the __attribute__((unused)) 
and emailing kernel-janitors to cleanup unused code (which should already 
be significantly small by the sheer fact that it is inlined).

> However, clang's behavior has also led to patches that add a
> "__maybe_unused" attribute (usually no increase in LOC unless it
> causes word wrap) and also added a handful of #ifdefs, as you've
> pointed out.  The example we already talked about was:
> 

The good work to remove truly dead code may easily continue while not 
adding more and more LOC to suppress these warnings for a compiler that is 
very heavily in the minority.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
