Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 630EE6B0038
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 00:00:13 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id l29so90422736pfg.7
        for <linux-mm@kvack.org>; Sun, 16 Oct 2016 21:00:13 -0700 (PDT)
Received: from mail-pa0-x243.google.com (mail-pa0-x243.google.com. [2607:f8b0:400e:c03::243])
        by mx.google.com with ESMTPS id ro4si24056390pab.36.2016.10.16.21.00.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 16 Oct 2016 21:00:12 -0700 (PDT)
Received: by mail-pa0-x243.google.com with SMTP id os4so4655552pac.3
        for <linux-mm@kvack.org>; Sun, 16 Oct 2016 21:00:12 -0700 (PDT)
Date: Mon, 17 Oct 2016 15:00:05 +1100
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [PATCH v2] mm: vmalloc: Replace purge_lock spinlock with atomic
 refcount
Message-ID: <20161017150005.4c8f890d@roar.ozlabs.ibm.com>
In-Reply-To: <1476528162-21981-1-git-send-email-joelaf@google.com>
References: <1476528162-21981-1-git-send-email-joelaf@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joel Fernandes <joelaf@google.com>
Cc: linux-kernel@vger.kernel.org, linux-rt-users@vger.kernel.org, Chris Wilson <chris@chris-wilson.co.uk>, Jisheng Zhang <jszhang@marvell.com>, John Dias <joaodias@google.com>, Andrew Morton <akpm@linux-foundation.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

On Sat, 15 Oct 2016 03:42:42 -0700
Joel Fernandes <joelaf@google.com> wrote:

> The purge_lock spinlock causes high latencies with non RT kernel. This has been
> reported multiple times on lkml [1] [2] and affects applications like audio.
> 
> In this patch, I replace the spinlock with an atomic refcount so that
> preemption is kept turned on during purge. This Ok to do since [3] builds the
> lazy free list in advance and atomically retrieves the list so any instance of
> purge will have its own list it is purging. Since the individual vmap area
> frees are themselves protected by a lock, this is Ok.

This is a good idea, and good results, but that's not what the spinlock was
for -- it was for enforcing the sync semantics.

Going this route, you'll have to audit callers to expect changed behavior
and change documentation of sync parameter.

I suspect a better approach would be to instead use a mutex for this, and
require that all sync=1 callers be able to sleep. I would say that most
probably already can.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
