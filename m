Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f46.google.com (mail-yh0-f46.google.com [209.85.213.46])
	by kanga.kvack.org (Postfix) with ESMTP id E921B6B0032
	for <linux-mm@kvack.org>; Tue, 13 Jan 2015 18:48:52 -0500 (EST)
Received: by mail-yh0-f46.google.com with SMTP id t59so2996514yho.5
        for <linux-mm@kvack.org>; Tue, 13 Jan 2015 15:48:52 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id o82si11431339yko.30.2015.01.13.15.48.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Jan 2015 15:48:51 -0800 (PST)
Date: Tue, 13 Jan 2015 15:48:49 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/5] kstrdup optimization
Message-Id: <20150113154849.5bb3fdd0ff9d73a89e639f19@linux-foundation.org>
In-Reply-To: <CAMuHMdV74n3v81xaLRDN_Mn_QGg14yUkXNn6JYaGH4MGgLRM2A@mail.gmail.com>
References: <1421054323-14430-1-git-send-email-a.hajda@samsung.com>
	<CAMuHMdV74n3v81xaLRDN_Mn_QGg14yUkXNn6JYaGH4MGgLRM2A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Andrzej Hajda <a.hajda@samsung.com>, Linux MM <linux-mm@kvack.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>, Andreas Mohr <andi@lisas.de>, Mike Turquette <mturquette@linaro.org>, Alexander Viro <viro@zeniv.linux.org.uk>

On Mon, 12 Jan 2015 21:45:58 +0100 Geert Uytterhoeven <geert@linux-m68k.org> wrote:

> On Mon, Jan 12, 2015 at 10:18 AM, Andrzej Hajda <a.hajda@samsung.com> wrote:
> > kstrdup if often used to duplicate strings where neither source neither
> > destination will be ever modified. In such case we can just reuse the source
> > instead of duplicating it. The problem is that we must be sure that
> > the source is non-modifiable and its life-time is long enough.
> >
> > I suspect the good candidates for such strings are strings located in kernel
> > .rodata section, they cannot be modifed because the section is read-only and
> > their life-time is equal to kernel life-time.
> >
> > This small patchset proposes alternative version of kstrdup - kstrdup_const,
> > which returns source string if it is located in .rodata otherwise it fallbacks
> > to kstrdup.
> 
> It also introduces kfree_const(const void *x).
> 
> As kfree_const() has the exact same signature as kfree(), the risk of
> accidentally passing pointers returned from kstrdup_const() to kfree() seems
> high, which may lead to memory corruption if the pointer doesn't point to
> allocated memory.

Yes, it's an ugly little patchset.  But 100-200k of memory is hard to
argue with, and I'm not seeing a practical way of getting those savings
with a cleaner approach.

Hopefully a kfree(rodata-address) will promptly oops, but I haven't
tested that and it presumably depends on which flavour of
slab/sleb/slib/slob/slub you're using.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
