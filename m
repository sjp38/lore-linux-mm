Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f181.google.com (mail-qc0-f181.google.com [209.85.216.181])
	by kanga.kvack.org (Postfix) with ESMTP id 84CE16B0037
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 10:17:39 -0500 (EST)
Received: by mail-qc0-f181.google.com with SMTP id e9so4912349qcy.26
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 07:17:39 -0800 (PST)
Received: from a9-62.smtp-out.amazonses.com (a9-62.smtp-out.amazonses.com. [54.240.9.62])
        by mx.google.com with ESMTP id kc8si14756236qeb.65.2013.12.17.07.17.37
        for <linux-mm@kvack.org>;
        Tue, 17 Dec 2013 07:17:38 -0800 (PST)
Date: Tue, 17 Dec 2013 15:17:37 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC][PATCH 0/7] re-shrink 'struct page' when SLUB is on.
In-Reply-To: <52AF9EB9.7080606@sr71.net>
Message-ID: <0000014301223b3e-a73f3d59-8234-48f1-9888-9af32709a879-000000@email.amazonses.com>
References: <20131213235903.8236C539@viggo.jf.intel.com> <20131216160128.aa1f1eb8039f5eee578cf560@linux-foundation.org> <52AF9EB9.7080606@sr71.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pravin B Shelar <pshelar@nicira.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Pekka Enberg <penberg@kernel.org>

On Mon, 16 Dec 2013, Dave Hansen wrote:

> I'll do some testing and see if I can coax out any delta from the
> optimization myself.  Christoph went to a lot of trouble to put this
> together, so I assumed that he had a really good reason, although the
> changelogs don't really mention any.

The cmpxchg on the struct page avoids disabling interrupts etc and
therefore simplifies the code significantly.

> I honestly can't imagine that a cmpxchg16 is going to be *THAT* much
> cheaper than a per-page spinlock.  The contended case of the cmpxchg is
> way more expensive than spinlock contention for sure.

Make sure slub does not set __CMPXCHG_DOUBLE in the kmem_cache flags
and it will fall back to spinlocks if you want to do a comparison. Most
non x86 arches will use that fallback code.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
