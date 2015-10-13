Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 312FF6B0253
	for <linux-mm@kvack.org>; Tue, 13 Oct 2015 07:28:59 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so85136560wic.1
        for <linux-mm@kvack.org>; Tue, 13 Oct 2015 04:28:58 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.17.24])
        by mx.google.com with ESMTPS id bp5si3457158wjc.7.2015.10.13.04.28.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Oct 2015 04:28:57 -0700 (PDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC] arm: add __initbss section attribute
Date: Tue, 13 Oct 2015 13:28:18 +0200
Message-ID: <5171473.bOz59Zi81c@wuerfel>
In-Reply-To: <8004E8C3-F1EC-45C3-A995-88726B257563@gmail.com>
References: <1444622356-8263-1-git-send-email-yalin.wang2010@gmail.com> <5369261.8uuGVmeUFP@wuerfel> <8004E8C3-F1EC-45C3-A995-88726B257563@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yalin wang <yalin.wang2010@gmail.com>
Cc: Sam Ravnborg <sam@ravnborg.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Nicolas Pitre <nico@linaro.org>, Kees Cook <keescook@chromium.org>, Catalin Marinas <catalin.marinas@arm.com>, Victor Kamensky <victor.kamensky@linaro.org>, Mark Salter <msalter@redhat.com>, vladimir.murzin@arm.com, ggdavisiv@gmail.com, paul.gortmaker@windriver.com, mingo@kernel.org, rusty@rustcorp.com.au, mcgrof@suse.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, mhocko@suse.com, jack@suse.cz, iamjoonsoo.kim@lge.com, xiexiuqi@huawei.com, vbabka@suse.cz, Vineet.Gupta1@synopsys.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

On Tuesday 13 October 2015 17:51:32 yalin wang wrote:

> > 32	__earlycon_table_sentinel
> > 200	__earlycon_of_table_sentinel
> > 6	__irf_end
> > 
> > 
> > 26398 total
> i am curious about your scripts ,
> could you show me ?

I was using some ad-hoc command line tricks, including

objcopy  -j .init.data  build/multi_v7_defconfig/vmlinux   /tmp/initdata
nm initdata  | sort -n | { read start b sym ; while read a b c ; do objdump -Dr --start-address=0x$start --stop-address=0x$a initdata > initdata.d/$sym  ; start=$a ; sym=$c  ; done }
(some manual sorting to delete the files that have pre-initialized symbols)
sum=0 ; nm /tmp/initdata  | sort -n | { read start b sym ; while read a b c ; do test -e ../$sym  && { echo $[0x$a - 0x$start]\      $sym  ; sum=$[$sum + $[0x$a - 0x$start]] ; } ; start=$a ; sym=$c ; done ; echo $sum;}

I'm sure there are better ways to do this, and the manual step I used at
first was faulty.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
