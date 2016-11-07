Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id EECEE6B0038
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 18:57:52 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 144so36358298pfv.5
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 15:57:52 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id 127si8391014pgi.128.2016.11.07.15.57.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Nov 2016 15:57:52 -0800 (PST)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCHv3 0/8] powerpc/mm: refactor vDSO mapping code
In-Reply-To: <CAJwJo6b16mt0N_xJeeQ0EikyPhoo-UvAx-FaXO9hGzwW=o+s5Q@mail.gmail.com>
References: <20161027170948.8279-1-dsafonov@virtuozzo.com> <CAJwJo6b16mt0N_xJeeQ0EikyPhoo-UvAx-FaXO9hGzwW=o+s5Q@mail.gmail.com>
Date: Tue, 08 Nov 2016 10:57:49 +1100
Message-ID: <87pom6lu6a.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <0x7f454c46@gmail.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>
Cc: Dmitry Safonov <dsafonov@virtuozzo.com>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, open list <linux-kernel@vger.kernel.org>

Dmitry Safonov <0x7f454c46@gmail.com> writes:

> 2016-10-27 20:09 GMT+03:00 Dmitry Safonov <dsafonov@virtuozzo.com>:
>
> ping?

There's another series doing some similar changes:

http://www.spinics.net/lists/linux-mm/msg115860.html


And I don't like all the macro games in 3/8, eg:

+#ifndef BITS
+#define BITS 32
+#endif
+
+#undef Elf_Ehdr
+#undef Elf_Sym
+#undef Elf_Shdr
+
+#define _CONCAT3(a, b, c)	a ## b ## c
+#define CONCAT3(a, b, c)	_CONCAT3(a, b, c)
+#define Elf_Ehdr	CONCAT3(Elf,  BITS, _Ehdr)
+#define Elf_Sym		CONCAT3(Elf,  BITS, _Sym)
+#define Elf_Shdr	CONCAT3(Elf,  BITS, _Shdr)
+#define VDSO_LBASE	CONCAT3(VDSO, BITS, _LBASE)
+#define vdso_kbase	CONCAT3(vdso, BITS, _kbase)
+#define vdso_pages	CONCAT3(vdso, BITS, _pages)
+
+#undef pr_fmt
+#define pr_fmt(fmt)	"vDSO" __stringify(BITS) ": " fmt
+
+#define lib_elfinfo CONCAT3(lib, BITS, _elfinfo)
+
+#define find_section CONCAT3(find_section, BITS,)
+static void * __init find_section(Elf_Ehdr *ehdr, const char *secname,
+		unsigned long *size)


I'd rather we kept the duplication of code than the obfuscation those
macros add.

If we can come up with a way to share more of the code without having to
do all those tricks then I'd be interested.

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
