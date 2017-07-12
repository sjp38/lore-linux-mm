Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id D6032440874
	for <linux-mm@kvack.org>; Wed, 12 Jul 2017 10:49:13 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id k3so19506378ita.4
        for <linux-mm@kvack.org>; Wed, 12 Jul 2017 07:49:13 -0700 (PDT)
Received: from resqmta-ch2-10v.sys.comcast.net (resqmta-ch2-10v.sys.comcast.net. [2001:558:fe21:29:69:252:207:42])
        by mx.google.com with ESMTPS id i140si3363149ioa.249.2017.07.12.07.49.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jul 2017 07:49:13 -0700 (PDT)
Date: Wed, 12 Jul 2017 09:49:11 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [RFC][PATCH] slub: Introduce 'alternate' per cpu partial lists
In-Reply-To: <20170614044528.GA5924@js1304-desktop>
Message-ID: <alpine.DEB.2.20.1707120946550.15771@nuc-kabylake>
References: <1496965984-21962-1-git-send-email-labbott@redhat.com> <20170614044528.GA5924@js1304-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Laura Abbott <labbott@redhat.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kees Cook <keescook@chromium.org>

On Wed, 14 Jun 2017, Joonsoo Kim wrote:

> > - Some of this code is redundant and can probably be combined.
> > - The fast path is very sensitive and it was suggested I leave it alone. The
> > approach I took means the fastpath cmpxchg always fails before trying the
> > alternate cmpxchg. From some of my profiling, the cmpxchg seemed to be fairly
> > expensive.
>
> It looks better to modify the fastpath for non-debuging poisoning. If
> we use the jump label, it doesn't cause any overhead to the fastpath
> for the user who doesn't use this feature. It really makes thing
> simpler. Only a few more lines will be needed in the fastpath.
>
> Christoph, any opinion?

Just looked through it. Sorry was on vacation in Europe for awhile.

The duplication in kmem_cache_cpu is not good performance wise. Maybe just
keep the single per cpu partial list and depending on a kmem_cache flag
change the locking semantics in order to allow for faster debugging?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
