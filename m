Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0D3696B025F
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 11:51:47 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id e26so13546115pfi.15
        for <linux-mm@kvack.org>; Mon, 04 Dec 2017 08:51:47 -0800 (PST)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0115.outbound.protection.outlook.com. [104.47.0.115])
        by mx.google.com with ESMTPS id 64si9973990ply.587.2017.12.04.08.51.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 04 Dec 2017 08:51:45 -0800 (PST)
Subject: Re: [PATCH v3 2/5] kasan/Makefile: Support LLVM style asan
 parameters.
References: <20171201213643.2506-1-paullawrence@google.com>
 <20171201213643.2506-3-paullawrence@google.com>
 <33f13b1a-494c-67d5-a470-294867c06f9a@virtuozzo.com>
 <CAL=UVf7LO5BDWVEeLXLkrLDBxwV0aO2sLv_htkpcL_Gp7sT07Q@mail.gmail.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <2da6480e-08ff-2444-7abf-2964de53e7ff@virtuozzo.com>
Date: Mon, 4 Dec 2017 19:55:15 +0300
MIME-Version: 1.0
In-Reply-To: <CAL=UVf7LO5BDWVEeLXLkrLDBxwV0aO2sLv_htkpcL_Gp7sT07Q@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Lawrence <paullawrence@google.com>
Cc: Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Masahiro Yamada <yamada.masahiro@socionext.com>, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kbuild@vger.kernel.org, Matthias Kaehlcke <mka@chromium.org>, Michael Davidson <md@google.com>, Greg Hackmann <ghackmann@google.com>

On 12/04/2017 07:20 PM, Paul Lawrence wrote:

> 
>     > +A  A # -fasan-shadow-offset fails without -fsanitize
>     > +A  A CFLAGS_KASAN_SHADOW := $(call cc-option, -fsanitize=kernel-address \
>     > +A  A  A  A  A  A  A  A  A  A  A -fasan-shadow-offset=$(KASAN_SHADOW_OFFSET), \
>     > +A  A  A  A  A  A  A  A  A  A  A $(call cc-option, -fsanitize=kernel-address \
>     > +A  A  A  A  A  A  A  A  A  A  A -mllvm -asan-mapping-offset=$(KASAN_SHADOW_OFFSET)))
>     > +
>     > +A  A ifeq ("$(CFLAGS_KASAN_SHADOW)"," ")
> 
>     This not how it was in my original patch. Why you changed this?
>     Condition is always false now, so it breaks kasan with 4.9.x gcc.
> 
> 
> a??I had the opposite problem - CFLAGS_KASAN_SHADOW is always at least a space, and the
> original condition would always be false, which is why I changed it.a?? On investigation, I foundA 
> that if the line was split it would always be a space - $(false,whatever,empty-string) would be
> truly empty, but if the line was split after the second comma it would be one space. Is this a
> difference in our make systems?

I dunno, but it could be.
Anyways, does the fixup bellow works for you?

---
 scripts/Makefile.kasan | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/scripts/Makefile.kasan b/scripts/Makefile.kasan
index 7c00be9216f4..d5a1a4b6d079 100644
--- a/scripts/Makefile.kasan
+++ b/scripts/Makefile.kasan
@@ -24,7 +24,7 @@ else
 			$(call cc-option, -fsanitize=kernel-address \
 			-mllvm -asan-mapping-offset=$(KASAN_SHADOW_OFFSET)))
 
-   ifeq ("$(CFLAGS_KASAN_SHADOW)"," ")
+   ifeq ($(strip $(CFLAGS_KASAN_SHADOW)),)
       CFLAGS_KASAN := $(CFLAGS_KASAN_MINIMAL)
    else
       # Now add all the compiler specific options that are valid standalone
-- 
2.13.6


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
