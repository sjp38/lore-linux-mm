Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id C9CFE828E1
	for <linux-mm@kvack.org>; Tue, 21 Jun 2016 17:52:39 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id g127so69233011ith.3
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 14:52:39 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id k9si7645341pag.188.2016.06.21.14.52.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jun 2016 14:52:39 -0700 (PDT)
Date: Tue, 21 Jun 2016 14:52:37 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: slab.h: use ilog2() in kmalloc_index()
Message-Id: <20160621145237.dae264ea5fe6b3b7f2d2d4e6@linux-foundation.org>
In-Reply-To: <1466465586-22096-1-git-send-email-yury.norov@gmail.com>
References: <1466465586-22096-1-git-send-email-yury.norov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yury Norov <yury.norov@gmail.com>
Cc: masmart@yandex.ru, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cl@linux.com, enberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux@rasmusvillemoes.dk, Alexey Klimov <klimov.linux@gmail.com>

On Tue, 21 Jun 2016 02:33:06 +0300 Yury Norov <yury.norov@gmail.com> wrote:

> kmalloc_index() uses simple straightforward way to calculate
> bit position of nearest or equal upper power of 2.
> This effectively results in generation of 24 episodes of
> compare-branch instructions in assembler.
> 
> There is shorter way to calculate this: fls(size - 1).
> 
> The patch removes hard-coded calculation of kmalloc slab and
> uses ilog2() instead that works on top of fls(). ilog2 is used
> with intention that compiler also might optimize constant case
> during compile time if it detects that.
> 
> BUG() is moved to the beginning of function. We left it here to
> provide identical behaviour to previous version. It may be removed
> if there's no requirement in it anymore.
> 
> While we're at this, fix comment that describes return value.

kmalloc_index() is always called with a constant-valued `size' (see
__builtin_constant_p() tests) so the compiler will evaluate the switch
statement at compile-time.  This will be more efficient than calling
fls() at runtime.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
