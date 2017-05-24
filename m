Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 797876B0279
	for <linux-mm@kvack.org>; Wed, 24 May 2017 17:22:31 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 62so205270857pft.3
        for <linux-mm@kvack.org>; Wed, 24 May 2017 14:22:31 -0700 (PDT)
Received: from mail-pf0-x232.google.com (mail-pf0-x232.google.com. [2607:f8b0:400e:c00::232])
        by mx.google.com with ESMTPS id 61si25367824plc.226.2017.05.24.14.22.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 May 2017 14:22:30 -0700 (PDT)
Received: by mail-pf0-x232.google.com with SMTP id 9so146980204pfj.1
        for <linux-mm@kvack.org>; Wed, 24 May 2017 14:22:30 -0700 (PDT)
Date: Wed, 24 May 2017 14:22:29 -0700
From: Matthias Kaehlcke <mka@chromium.org>
Subject: Re: [patch] compiler, clang: suppress warning for unused static
 inline functions
Message-ID: <20170524212229.GR141096@google.com>
References: <alpine.DEB.2.10.1705241400510.49680@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1705241400510.49680@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Douglas Anderson <dianders@chromium.org>, Mark Brown <broonie@kernel.org>, Ingo Molnar <mingo@kernel.org>, David Miller <davem@davemloft.net>

El Wed, May 24, 2017 at 02:01:15PM -0700 David Rientjes ha dit:

> GCC explicitly does not warn for unused static inline functions for
> -Wunused-function.  The manual states:
> 
> 	Warn whenever a static function is declared but not defined or
> 	a non-inline static function is unused.
> 
> Clang does warn for static inline functions that are unused.
> 
> It turns out that suppressing the warnings avoids potentially complex
> #ifdef directives, which also reduces LOC.
> 
> Supress the warning for clang.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---

As expressed earlier in other threads, I don't think gcc's behavior is
preferable in this case. The warning on static inline functions (only
in .c files) allows to detect truly unused code. About 50% of the
warnings I have looked into so far fall into this category.

In my opinion it is more valuable to detect dead code than not having
a few more __maybe_unused attributes (there aren't really that many
instances, at least with x86 and arm64 defconfig). In most cases it is
not necessary to use #ifdef, it is an option which is preferred by
some maintainers. The reduced LOC is arguable, since dectecting dead
code allows to remove it.

I'm not a kernel maintainer, so it's not my decision whether this
warning should be silenced, my personal opinion is that it's benfits
outweigh the inconveniences of dealing with half-false positives,
generally caused by the heavy use of #ifdef by the kernel itself.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
