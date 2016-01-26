Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f181.google.com (mail-io0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id 8C5D66B0005
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 02:03:05 -0500 (EST)
Received: by mail-io0-f181.google.com with SMTP id 1so176588611ion.1
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 23:03:05 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTPS id y3si2952727igl.73.2016.01.25.23.03.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 25 Jan 2016 23:03:04 -0800 (PST)
Date: Tue, 26 Jan 2016 16:03:20 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC][PATCH 0/3] Speed up SLUB poisoning + disable checks
Message-ID: <20160126070320.GB28254@js1304-P5Q-DELUXE>
References: <1453770913-32287-1-git-send-email-labbott@fedoraproject.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1453770913-32287-1-git-send-email-labbott@fedoraproject.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@fedoraproject.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Kees Cook <keescook@chromium.org>

On Mon, Jan 25, 2016 at 05:15:10PM -0800, Laura Abbott wrote:
> Hi,
> 
> Based on the discussion from the series to add slab sanitization
> (lkml.kernel.org/g/<1450755641-7856-1-git-send-email-laura@labbott.name>)
> the existing SLAB_POISON mechanism already covers similar behavior.
> The performance of SLAB_POISON isn't very good. With hackbench -g 20 -l 1000
> on QEMU with one cpu:

I doesn't follow up that discussion, but, I think that reusing
SLAB_POISON for slab sanitization needs more changes. I assume that
completeness and performance is matter for slab sanitization.

1) SLAB_POISON isn't applied to specific kmem_cache which has
constructor or SLAB_DESTROY_BY_RCU flag. For debug, it's not necessary
to be applied, but, for slab sanitization, it is better to apply it to
all caches.

2) SLAB_POISON makes object size bigger so natural alignment will be
broken. For example, kmalloc(256) cache's size is 256 in normal
case but it would be 264 when SLAB_POISON is enabled. This causes
memory waste.

In fact, I'd prefer not reusing SLAB_POISON. It would make thing
simpler. But, it's up to Christoph.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
