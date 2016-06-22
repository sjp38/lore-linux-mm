Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1DC0E6B0005
	for <linux-mm@kvack.org>; Tue, 21 Jun 2016 20:56:05 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id 13so88158072itl.0
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 17:56:05 -0700 (PDT)
Received: from na01-by2-obe.outbound.protection.outlook.com (mail-by2on0080.outbound.protection.outlook.com. [207.46.100.80])
        by mx.google.com with ESMTPS id q83si1177336oia.161.2016.06.21.17.56.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 21 Jun 2016 17:56:04 -0700 (PDT)
Date: Wed, 22 Jun 2016 03:51:35 +0300
From: Yury Norov <ynorov@caviumnetworks.com>
Subject: Re: [PATCH] mm: slab.h: use ilog2() in kmalloc_index()
Message-ID: <20160622005135.GA342@yury-N73SV>
References: <1466465586-22096-1-git-send-email-yury.norov@gmail.com>
 <20160621145237.dae264ea5fe6b3b7f2d2d4e6@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20160621145237.dae264ea5fe6b3b7f2d2d4e6@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Yury Norov <yury.norov@gmail.com>, masmart@yandex.ru, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cl@linux.com, enberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux@rasmusvillemoes.dk, Alexey Klimov <klimov.linux@gmail.com>

On Tue, Jun 21, 2016 at 02:52:37PM -0700, Andrew Morton wrote:
> On Tue, 21 Jun 2016 02:33:06 +0300 Yury Norov <yury.norov@gmail.com> wrote:
> 
> > kmalloc_index() uses simple straightforward way to calculate
> > bit position of nearest or equal upper power of 2.
> > This effectively results in generation of 24 episodes of
> > compare-branch instructions in assembler.
> > 
> > There is shorter way to calculate this: fls(size - 1).
> > 
> > The patch removes hard-coded calculation of kmalloc slab and
> > uses ilog2() instead that works on top of fls(). ilog2 is used
> > with intention that compiler also might optimize constant case
> > during compile time if it detects that.
> > 
> > BUG() is moved to the beginning of function. We left it here to
> > provide identical behaviour to previous version. It may be removed
> > if there's no requirement in it anymore.
> > 
> > While we're at this, fix comment that describes return value.
> 
> kmalloc_index() is always called with a constant-valued `size' (see
> __builtin_constant_p() tests)

It might change one day. This function is public to any slab user.
If you really want to allow call kmalloc_index() for constants only,
you'd place __builtin_constant_p() tests inside kmalloc_index().

> so the compiler will evaluate the switch
> statement at compile-time.  This will be more efficient than calling
> fls() at runtime.

There will be no fls() for constant at runtime because ilog2() calculates 
constant values at compile-time as well. From this point of view,
this patch removes code duplication, as we already have compile-time
log() calculation in kernel, and should re-use it whenever possible.\

Yury.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
