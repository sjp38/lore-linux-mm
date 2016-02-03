Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f180.google.com (mail-io0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id AAACC82963
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 18:02:23 -0500 (EST)
Received: by mail-io0-f180.google.com with SMTP id d63so73804686ioj.2
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 15:02:23 -0800 (PST)
Received: from resqmta-ch2-11v.sys.comcast.net (resqmta-ch2-11v.sys.comcast.net. [2001:558:fe21:29:69:252:207:43])
        by mx.google.com with ESMTPS id v13si15443908igr.35.2016.02.03.15.02.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 03 Feb 2016 15:02:22 -0800 (PST)
Date: Wed, 3 Feb 2016 17:02:21 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC][PATCH 0/3] Speed up SLUB poisoning + disable checks
In-Reply-To: <56B272B8.2050808@redhat.com>
Message-ID: <alpine.DEB.2.20.1602031658060.6707@east.gentwo.org>
References: <1453770913-32287-1-git-send-email-labbott@fedoraproject.org> <20160126070320.GB28254@js1304-P5Q-DELUXE> <56B24B01.30306@redhat.com> <CAGXu5jJK1UhNX7h2YmxxTrCABr8oS=Y2OBLMr4KTxk7LctRaiQ@mail.gmail.com> <56B272B8.2050808@redhat.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Kees Cook <keescook@chromium.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Laura Abbott <labbott@fedoraproject.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

> The fast path uses the per cpu caches. No locks are taken and there
> is no IRQ disabling. For concurrency protection this comment
> explains it best:
>
> /*
>  * The cmpxchg will only match if there was no additional
>  * operation and if we are on the right processor.
>  *
>  * The cmpxchg does the following atomically (without lock
>  * semantics!)
>  * 1. Relocate first pointer to the current per cpu area.
>  * 2. Verify that tid and freelist have not been changed
>  * 3. If they were not changed replace tid and freelist
>  *
>  * Since this is without lock semantics the protection is only
>  * against code executing on this cpu *not* from access by
>  * other cpus.
>  */
>
> in the slow path, IRQs and locks have to be taken at the minimum.
> The debug options disable ever loading the per CPU caches so it
> always falls back to the slow path.

You could add the use of per cpu lists to the slow paths as well in
order
to increase performance. Then weave in the debugging options.

But the performance of the fast path is critical to the overall
performance of the kernel as a whole since this is a heavily used code
path for many subsystems.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
