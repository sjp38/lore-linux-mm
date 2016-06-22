Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 084786B0005
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 11:40:44 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id a4so39421285lfa.1
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 08:40:43 -0700 (PDT)
Received: from mail-lf0-x242.google.com (mail-lf0-x242.google.com. [2a00:1450:4010:c07::242])
        by mx.google.com with ESMTPS id r77si535098lfd.223.2016.06.22.08.40.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jun 2016 08:40:42 -0700 (PDT)
Received: by mail-lf0-x242.google.com with SMTP id w130so14439139lfd.2
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 08:40:42 -0700 (PDT)
Date: Wed, 22 Jun 2016 18:40:39 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: JITs and 52-bit VA
Message-ID: <20160622154039.GA18723@node.shutemov.name>
References: <4A8E6E6D-6CF7-4964-A62E-467AE287D415@linaro.org>
 <576AA67E.50009@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <576AA67E.50009@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Covington <cov@codeaurora.org>
Cc: Maxim Kuvyrkov <maxim.kuvyrkov@linaro.org>, Linaro Dev Mailman List <linaro-dev@lists.linaro.org>, Arnd Bergmann <arnd.bergmann@linaro.org>, Mark Brown <broonie@linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dmitry Safonov <dsafonov@virtuozzo.com>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@gmail.com>

On Wed, Jun 22, 2016 at 10:53:50AM -0400, Christopher Covington wrote:
> +Andy, Cyrill, Dmitry who have been discussing variable TASK_SIZE on x86
> on linux-mm
> 
> http://marc.info/?l=linux-mm&m=146290118818484&w=2
> 
> >>> On 04/28/2016 09:00 AM, Maxim Kuvyrkov wrote:
> >>>> This is a summary of discussions we had on IRC between kernel and
> >>>> toolchain engineers regarding support for JITs and 52-bit virtual
> >>>> address space (mostly in the context of LuaJIT, but this concerns other
> >>>> JITs too).
> >>>> 
> >>>> The summary is that we need to consider ways of reducing the size of
> >>>> VA for a given process or container on a Linux system.
> >>>> 
> >>>> The high-level problem is that JITs tend to use upper bits of
> >>>> addresses to encode various pieces of data, and that the number of
> >>>> available bits is shrinking due to VA size increasing. With the usual
> >>>> 42-bit VA (which is what most JITs assume) they have 22 bits to encode
> >>>> various performance-critical data. With 48-bit VA (e.g., ThunderX world)
> >>>> things start to get complicated, and JITs need to be non-trivially
> >>>> patched at the source level to continue working with less bits available
> >>>> for their performance-critical storage. With upcoming 52-bit VA things
> >>>> might get dire enough for some JITs to declare such configurations
> >>>> unsupported.
> >>>> 
> >>>> On the other hand, most JITs are not expected to requires terabytes
> >>>> of RAM and huge VA for their applications. Most JIT applications will
> >>>> happily live in 42-bit world with mere 4 terabytes of RAM that it
> >>>> provides. Therefore, what JITs need in the modern world is a way to make
> >>>> mmap() return addresses below a certain threshold, and error out with
> >>>> ENOMEM when "lower" memory is exhausted. This is very similar to
> >>>> ADDR_LIMIT_32BIT personality, but extended to common VA sizes on 64-bit
> >>>> systems: 39-bit, 42-bit, 48-bit, 52-bit, etc.
> >>>> 
> >>>> Since we do not want to penalize the whole system (using an
> >>>> artificially low-size VA), it would be best to have a way to enable VA
> >>>> limit on per-process basis (similar to ADDR_LIMIT_32BIT personality). If
> >>>> that's not possible -- then on per-container / cgroup basis. If that's
> >>>> not possible -- then on system level (similar to vm.mmap_min_addr, but
> >>>> from the other end).
> >>>> 
> >>>> Dear kernel people, what can be done to address the JITs need to
> >>>> reduce effective VA size?

What about, by default, keep applications within known-to-be-safe VA size
and require explicit opt-in for larger one.

The opt-in can be provided in few forms: personality()/prctl() or ELF flag.

I think it's reasonable to set the large-VA ELF flag for newly compiled
binaries (unless specified otherwise). So they can benefit from larger VA
size, but existing binaries woundn't break.
I believe we had something similar for non-executable stack transition.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
