Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id E40166B0279
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 00:45:40 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id f185so95364852pgc.10
        for <linux-mm@kvack.org>; Tue, 13 Jun 2017 21:45:40 -0700 (PDT)
Received: from mail-pg0-x230.google.com (mail-pg0-x230.google.com. [2607:f8b0:400e:c05::230])
        by mx.google.com with ESMTPS id n9si880312pgt.139.2017.06.13.21.45.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Jun 2017 21:45:40 -0700 (PDT)
Received: by mail-pg0-x230.google.com with SMTP id k71so69985377pgd.2
        for <linux-mm@kvack.org>; Tue, 13 Jun 2017 21:45:40 -0700 (PDT)
Date: Wed, 14 Jun 2017 13:45:30 +0900
From: Joonsoo Kim <js1304@gmail.com>
Subject: Re: [RFC][PATCH] slub: Introduce 'alternate' per cpu partial lists
Message-ID: <20170614044528.GA5924@js1304-desktop>
References: <1496965984-21962-1-git-send-email-labbott@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1496965984-21962-1-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kees Cook <keescook@chromium.org>

On Thu, Jun 08, 2017 at 04:53:04PM -0700, Laura Abbott wrote:
> SLUB debugging features (poisoning, red zoning etc.) skip the fast path
> completely. This ensures there is a single place to do all checks and
> take any locks that may be necessary for debugging. The overhead of some
> of the debugging features (e.g. poisoning) ends up being comparatively
> small vs the overhead of not using the fast path.
> 
> We don't want to impose any kind of overhead on the fast path so
> introduce the notion of an alternate fast path. This is essentially the
> same idea as the existing fast path (store partially used pages on the
> per-cpu list) but it happens after the real fast path. Debugging that
> doesn't require locks (poisoning/red zoning) can happen on this path to
> avoid the penalty of always needing to go for the slow path.
> 
> Signed-off-by: Laura Abbott <labbott@redhat.com>
> ---
> This is a follow up to my previous proposal to speed up slub_debug=P
> https://marc.info/?l=linux-mm&m=145920558822958&w=2 . The current approach
> is hopelessly slow and can't really be used outside of limited debugging.
> The goal is to make slub_debug=P more usable for general use.
> 
> Joonsoo Kim pointed out that my previous attempt still wouldn't scale
> as it still involved taking the list_lock for every allocation. He suggested
> adding per-cpu support, as did Christoph Lameter in a separate thread. This
> proposal adds a separate per-cpu list for use when poisoning is enabled.
> For this version, I'm mostly looking for general feedback about how reasonable
> this approach is before trying to clean it up more.
> 
> - Some of this code is redundant and can probably be combined.
> - The fast path is very sensitive and it was suggested I leave it alone. The
> approach I took means the fastpath cmpxchg always fails before trying the
> alternate cmpxchg. From some of my profiling, the cmpxchg seemed to be fairly
> expensive.

It looks better to modify the fastpath for non-debuging poisoning. If
we use the jump label, it doesn't cause any overhead to the fastpath
for the user who doesn't use this feature. It really makes thing
simpler. Only a few more lines will be needed in the fastpath.

Christoph, any opinion?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
