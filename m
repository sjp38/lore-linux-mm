Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id E0A216B0005
	for <linux-mm@kvack.org>; Thu, 24 Mar 2016 18:36:40 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id td3so32419337pab.2
        for <linux-mm@kvack.org>; Thu, 24 Mar 2016 15:36:40 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id r72si1388310pfb.235.2016.03.24.15.36.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Mar 2016 15:36:40 -0700 (PDT)
Date: Thu, 24 Mar 2016 15:36:39 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] include/linux: apply __malloc attribute
Message-Id: <20160324153639.bb996d7bf5a585dfb46740b7@linux-foundation.org>
In-Reply-To: <1458776553-9033-2-git-send-email-linux@rasmusvillemoes.dk>
References: <1458776553-9033-1-git-send-email-linux@rasmusvillemoes.dk>
	<1458776553-9033-2-git-send-email-linux@rasmusvillemoes.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andi Kleen <ak@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 24 Mar 2016 00:42:32 +0100 Rasmus Villemoes <linux@rasmusvillemoes.dk> wrote:

> Attach the malloc attribute to a few allocation functions. This helps
> gcc generate better code by telling it that the return value doesn't
> alias any existing pointers (which is even more valuable given the
> pessimizations implied by -fno-strict-aliasing).
> 
> A simple example of what this allows gcc to do can be seen by looking
> at the last part of drm_atomic_helper_plane_reset:
> 
> 	plane->state = kzalloc(sizeof(*plane->state), GFP_KERNEL);
> 
> 	if (plane->state) {
> 		plane->state->plane = plane;
> 		plane->state->rotation = BIT(DRM_ROTATE_0);
> 	}
> 
> which compiles to
> 
>     e8 99 bf d6 ff          callq  ffffffff8116d540 <kmem_cache_alloc_trace>
>     48 85 c0                test   %rax,%rax
>     48 89 83 40 02 00 00    mov    %rax,0x240(%rbx)
>     74 11                   je     ffffffff814015c4 <drm_atomic_helper_plane_reset+0x64>
>     48 89 18                mov    %rbx,(%rax)
>     48 8b 83 40 02 00 00    mov    0x240(%rbx),%rax [*]
>     c7 40 40 01 00 00 00    movl   $0x1,0x40(%rax)
> 
> With this patch applied, the instruction at [*] is elided, since the
> store to plane->state->plane is known to not alter the value of
> plane->state.

Shaves 6 bytes off my 1MB i386 defconfig vmlinux.  Winner!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
