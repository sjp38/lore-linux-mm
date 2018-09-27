Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id DF4348E0001
	for <linux-mm@kvack.org>; Thu, 27 Sep 2018 11:51:18 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id p192-v6so2991898qke.13
        for <linux-mm@kvack.org>; Thu, 27 Sep 2018 08:51:18 -0700 (PDT)
Received: from a9-114.smtp-out.amazonses.com (a9-114.smtp-out.amazonses.com. [54.240.9.114])
        by mx.google.com with ESMTPS id s35-v6si1638472qvs.140.2018.09.27.08.51.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 27 Sep 2018 08:51:18 -0700 (PDT)
Date: Thu, 27 Sep 2018 15:51:17 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH] mm: don't warn about large allocations for slab
In-Reply-To: <20180927130707.151239-1-dvyukov@gmail.com>
Message-ID: <010001661bba2bbc-a5074e00-2009-414a-be8c-05c58545c7ec-000000@email.amazonses.com>
References: <20180927130707.151239-1-dvyukov@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@gmail.com>
Cc: penberg@kernel.org, akpm@linux-foundation.org, rientjes@google.com, iamjoonsoo.kim@lge.com, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 27 Sep 2018, Dmitry Vyukov wrote:

> From: Dmitry Vyukov <dvyukov@google.com>
>
> This warning does not seem to be useful. Most of the time it fires when
> allocation size depends on syscall arguments. We could add __GFP_NOWARN
> to these allocation sites, but having a warning only to suppress it
> does not make lots of sense. Moreover, this warnings never fires for
> constant-size allocations and never for slub, because there are
> additional checks and fallback to kmalloc_large() for large allocations
> and kmalloc_large() does not warn. So the warning only fires for
> non-constant allocations and only with slab, which is odd to begin with.
> The warning leads to episodic unuseful syzbot reports. Remote it.

/Remove/

If its only for slab then KMALLOC_MAX_CACHE_SIZE and KMALLOC_MAX_SIZE are
the same value.

> While we are here also fix the check. We should check against
> KMALLOC_MAX_CACHE_SIZE rather than KMALLOC_MAX_SIZE. It all kinda
> worked because for slab the constants are the same, and slub always
> checks the size against KMALLOC_MAX_CACHE_SIZE before kmalloc_slab().
> But if we get there with size > KMALLOC_MAX_CACHE_SIZE anyhow
> bad things will happen.

Then the WARN_ON is correct just change the constant used. Ensure that
SLAB does the same checks as SLUB.
