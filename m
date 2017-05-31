Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 266D86B02B4
	for <linux-mm@kvack.org>; Wed, 31 May 2017 11:53:43 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id b84so3775186wmh.0
        for <linux-mm@kvack.org>; Wed, 31 May 2017 08:53:43 -0700 (PDT)
Received: from mail-wm0-x229.google.com (mail-wm0-x229.google.com. [2a00:1450:400c:c09::229])
        by mx.google.com with ESMTPS id r195si31367447wmd.56.2017.05.31.08.53.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 May 2017 08:53:41 -0700 (PDT)
Received: by mail-wm0-x229.google.com with SMTP id e127so26928008wmg.1
        for <linux-mm@kvack.org>; Wed, 31 May 2017 08:53:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1705301704370.10695@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1705241400510.49680@chino.kir.corp.google.com>
 <20170524212229.GR141096@google.com> <20170524143205.cae1a02ab2ad7348c1a59e0c@linux-foundation.org>
 <CAD=FV=XjC3M=EWC=rtcbTUR6e1F2cfuYvqL53F9H7tdMAOALNw@mail.gmail.com> <alpine.DEB.2.10.1705301704370.10695@chino.kir.corp.google.com>
From: Doug Anderson <dianders@chromium.org>
Date: Wed, 31 May 2017 08:53:40 -0700
Message-ID: <CAD=FV=Xi7NjDjsdwGP=GGS9p=uUpqZa7S=irNOFmhfD1F3kWZQ@mail.gmail.com>
Subject: Re: [patch] compiler, clang: suppress warning for unused static
 inline functions
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthias Kaehlcke <mka@chromium.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Mark Brown <broonie@kernel.org>, Ingo Molnar <mingo@kernel.org>, David Miller <davem@davemloft.net>

Hi,

On Tue, May 30, 2017 at 5:10 PM, David Rientjes <rientjes@google.com> wrote:
> On Wed, 24 May 2017, Doug Anderson wrote:
>
>> * Matthias has been sending out individual patches that take each
>> particular case into account to try to remove the warnings.  In some
>> cases this removes totally dead code.  In other cases this adds
>> __maybe_unused.  ...and as a last resort it uses #ifdef.  In each of
>> these individual patches we wouldn't want a list of all other patches,
>> I think.
>>
>
> Again, I defer to maintainers like Andrew and Ingo who have to deal with
> an enormous amount of patches on how they would like to handle it; I don't
> think myself or anybody else who doesn't deal with a large number of
> patches should be mandating how it's handled.
>
> For reference, the patchset that this patch originated from added 8 lines
> and removed 1, so I disagree that this cleans anything up; in reality, it
> obfuscates the code and makes the #ifdef nesting more complex.

As Matthias said, let's not argue about ifdeffs and instead talk about
adding "maybe unused".  100% of these cases _can_ be solved by adding
"maybe unused".  Then, if a maintainer thinks that an ifdef is cleaner
/ better in a particular case, we can use an ifdef in that case.

Do you believe that adding "maybe unused" tags significantly uglifies
the code?  I personally find them documenting.


>> If you just want a list of things in response to this thread...
>>
>> Clang's behavior has found some dead code, as shown by:
>>
>> * https://patchwork.kernel.org/patch/9732161/
>>   ring-buffer: Remove unused function __rb_data_page_index()
>> * https://patchwork.kernel.org/patch/9735027/
>>   r8152: Remove unused function usb_ocp_read()
>> * https://patchwork.kernel.org/patch/9735053/
>>   net1080: Remove unused function nc_dump_ttl()
>> * https://patchwork.kernel.org/patch/9741513/
>>   crypto: rng: Remove unused function __crypto_rng_cast()
>> * https://patchwork.kernel.org/patch/9741539/
>>   x86/ioapic: Remove unused function IO_APIC_irq_trigger()
>> * https://patchwork.kernel.org/patch/9741549/
>>   ASoC: Intel: sst: Remove unused function sst_restore_shim64()
>> * https://patchwork.kernel.org/patch/9743225/
>>   ASoC: cht_bsw_max98090_ti: Remove unused function cht_get_codec_dai()
>>
>> ...plus more examples...
>>
>
> Let us please not confuse the matter by suggesting that you cannot
> continue to do this work by simply removing the __attribute__((unused))
> and emailing kernel-janitors to cleanup unused code (which should already
> be significantly small by the sheer fact that it is inlined).

What you're suggesting here is that we don't land any "maybe unused"
tags and don't land any ifdeffs.  Instead, it would be the burden of
the person who is running this tool to ignore the false positives and
just provide patches which remove dead code.

It is certainly possible that something like this could be done (I
think Coverity works something like this), but I'm not sure there are
any volunteers.  Doing this would require a person to setup and
monitor a clang builder and then setup a list of false positives.  For
each new warning this person would need to analyze the warning and
either send a patch or add it to the list of false positives.

If, instead, we make it easy for everyone running with clang (yes, not
too many) to notice the errors then we spread the burden out.

Given that adding "maybe unused" (IMHO) doesn't uglify the code and
the total number of patches needed is small, it seems like that's a
good way to go.


-Doug

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
