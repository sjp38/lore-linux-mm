Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9B4998E0001
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 23:14:44 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id p3so14521135plk.9
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 20:14:44 -0800 (PST)
Received: from mailgw01.mediatek.com ([210.61.82.183])
        by mx.google.com with ESMTPS id g12si13977781pgh.368.2019.01.21.20.14.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jan 2019 20:14:43 -0800 (PST)
Message-ID: <1548130475.7975.74.camel@mtkswgap22>
Subject: Re: [PATCH] mm/slub: use WARN_ON() for some slab errors
From: Miles Chen <miles.chen@mediatek.com>
Date: Tue, 22 Jan 2019 12:14:35 +0800
In-Reply-To: <01000168726fcf15-81d8feb3-26f0-44d6-bbd8-62aa149118b5-000000@email.amazonses.com>
References: <1548063490-545-1-git-send-email-miles.chen@mediatek.com>
	 <01000168726fcf15-81d8feb3-26f0-44d6-bbd8-62aa149118b5-000000@email.amazonses.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-mediatek@lists.infradead.org

On Mon, 2019-01-21 at 22:02 +0000, Christopher Lameter wrote:
> On Mon, 21 Jan 2019, miles.chen@mediatek.com wrote:
> 
> > From: Miles Chen <miles.chen@mediatek.com>
> >
> > When debugging with slub.c, sometimes we have to trigger a panic in
> > order to get the coredump file. To do that, we have to modify slub.c and
> > rebuild kernel. To make debugging easier, use WARN_ON() for these slab
> > errors so we can dump stack trace by default or set panic_on_warn to
> > trigger a panic.
> 
> These locations really should dump stack and not terminate. There is
> subsequent processing that should be done.

Understood. We should not terminate the process for normal case. The
change only terminate the process when panic_on_warn is set.

> Slub terminates by default. The messages you are modifying are only
> enabled if the user specified that special debugging should be one
> (typically via a kernel parameter slub_debug).

I'm a little bit confused about this: Do you mean that I should use the
following approach?

1. Add a special debugging flag (say SLAB_PANIC_ON_ERROR) and call
panic() by:

if (s->flags & SLAB_PANIC_ON_ERROR)
     panic("slab error");

2. The SLAB_PANIC_ON_ERROR should be set by slub_debug param.

> It does not make sense to terminate the process here.


Thanks for you comment. Sometimes it's useful to trigger a panic and get
its coredump file before any restore/reset processing because we can
exam the unmodified data in the coredump file with this approach. 

I added BUG() for the slab errors in internal branches for a few years
and it does help for both software issues and bit flipping issues. It's
a quite useful in developing stage.

cheers,
Miles
