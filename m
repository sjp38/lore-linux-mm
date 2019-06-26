Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E96C9C48BD9
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 18:15:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 970BD21743
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 18:15:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="ZZUnoMA/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 970BD21743
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2D9D16B0003; Wed, 26 Jun 2019 14:15:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 28B828E0003; Wed, 26 Jun 2019 14:15:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 17C318E0002; Wed, 26 Jun 2019 14:15:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id EAC196B0003
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 14:15:53 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id 97so3813122qtb.16
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 11:15:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=owsUYixQqs2bCy4E9biTsLv5zZvUd0Q6DzJVujrTfmo=;
        b=TBvQvvZsXsAkiMHPgvC9jqis5HSVdG9o2yQUW6swnToGydyPVLVnI2KgK4OpJq42HN
         hpo+ZtOrPISq4LE4RxoeAtL+lkLzobxlkZDQOL/ECDuWVx6/eC5WQqVzNwYmtJX5BVFt
         nv68RJ/dxC4ZRjB6C2s/3g+tq4c240jxZRXm5QvOIXVwTOu1crPHoDhT90DjyRGtQN8U
         k4xI6JJqeylU7L6RR7MXi7VQvFTqP1sVmnFpMl0/z0NiloWIwMxgpKNxBMKcsiEhOcyf
         ZLeoH48tEgPFNYJM4CZDD6g3WUYxydKTxbxpXWvzS0YVqcBizLHGAXS/vOSVZnHg/btw
         QqJg==
X-Gm-Message-State: APjAAAVS+AEyHWz7d22Ds1hdT4U46MczUK0wFNGwL/WtMcybpIzUohwa
	UWfBmKfh7GZLVv6sBzrwOSyKjofMZBsVEhQkJAIyzgMw+HDYhLjeLHsahTkP/QrVb3z/4lE/XMW
	mV0rdmFNdgLzIGdu9yucN9ko7kUlKS869+d9mOCacmuKj/Nmnb8gDUZLdJGT11M6O+g==
X-Received: by 2002:a37:6442:: with SMTP id y63mr4956320qkb.377.1561572953664;
        Wed, 26 Jun 2019 11:15:53 -0700 (PDT)
X-Received: by 2002:a37:6442:: with SMTP id y63mr4956252qkb.377.1561572952774;
        Wed, 26 Jun 2019 11:15:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561572952; cv=none;
        d=google.com; s=arc-20160816;
        b=eVMfmRA6PvD7aJf53Rc4IvhcOSjBE6vXbsfFfkfkGa7ObW7yMbi9BOvEIMSNkE5u6F
         9ynt7cuQChb0+LJDkBw1UfHsXMKDTb6mtvNbo4XVboyYPUSRH3THUi2/053LmNevh2jX
         MQGcu0qbQEfcuy0bxwOYq0gg1pd471W3HaoYHC+cyZe+HWqb905stPcXLChKrRBXjSAX
         ZjW4QsOLG/Lt2a3ZzX7kEJrJslPJBdnqDKW5be/x/n8LWYqRig9H/5Aa8TlyMQ4y2Ivc
         Wbcv1lp6MTmiu1QeiYU8m8BF2h3WN/uMZKIGSbVl0OETvVVDdZadDL3x3ylX5csw8xTk
         I7vg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=owsUYixQqs2bCy4E9biTsLv5zZvUd0Q6DzJVujrTfmo=;
        b=fkq72bczE8hbEBLVJL+kR8XyE/zzceyVU/WaB5yQ7bXbTVZYpJzIv7/aOAcX8PGoK5
         bm6J9HYAGtrKt1azRxbzO8JkcmNCRCBpYcZJevkVSRwY6Z+s/TqJwovuVRSNkx+uFU71
         9TmDSydPZ4kz0DpKxVeaE480xL4Ogn/jvFsmTK3KkzC3Ve0BPEVyThzqcoaIEu32s9Eu
         7LM2caG2wIY0X59kmsZmhWFvGPzZm0x3NqvIhfNfcMsLl1NX1gw0x/GUMAPAaYS8nOgv
         IxKdH79q2NSrnlqmK8RyBnEylAHhEN7W377N4H9WtsTkMfgYUJ/p0FN7iPqGLeyosfHc
         v+Pw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b="ZZUnoMA/";
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j55sor170717qvc.39.2019.06.26.11.15.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 26 Jun 2019 11:15:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b="ZZUnoMA/";
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=owsUYixQqs2bCy4E9biTsLv5zZvUd0Q6DzJVujrTfmo=;
        b=ZZUnoMA/xDtbNjQ+fsacwZIh9VnJGWcfpIf5xbvFQvv4epAedFTnuFdNsj9UZhdBkb
         kkQqeK4eDdajfKwX5DqK0qwrbCkhkPqFXqjVRnjpV1vZ6cQeEFb6DBnn55PkSfoO6gHB
         SuZ23lupZFhr/0PceQKGbVJSsZz0UCtZbTBbQoH2AmD92E8mRQy8mmF24pwHa9OK/zuf
         ZztYlNXjM9/4fJf7hzC34KsTd9cmqwX3Mtfl6hr2DgEhyL2EWpjqVtAbYiaeAUdWW41E
         pVWX1xOPBp4slJVTRUJ9wRbjMRRqMfeqriH/gDZdVKrEhP3axZ2en7daCdzHCaegsgKj
         rMYw==
X-Google-Smtp-Source: APXvYqzy6XGMDgLuXW150fDNJ+96wvxp08xFTcBmPLr51vxAnlq2rR5aKzFDUqv+aiM43XxogyUBsw==
X-Received: by 2002:a0c:d1d9:: with SMTP id k25mr4726582qvh.233.1561572952345;
        Wed, 26 Jun 2019 11:15:52 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id e125sm9726639qkd.120.2019.06.26.11.15.50
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jun 2019 11:15:51 -0700 (PDT)
Message-ID: <1561572949.5154.81.camel@lca.pw>
Subject: Re: [PATCH v8 1/2] mm: security: introduce init_on_alloc=1 and
 init_on_free=1 boot options
From: Qian Cai <cai@lca.pw>
To: Alexander Potapenko <glider@google.com>, Andrew Morton
	 <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Kees Cook
	 <keescook@chromium.org>
Cc: Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Hocko
 <mhocko@kernel.org>, James Morris <jmorris@namei.org>, "Serge E. Hallyn"
 <serge@hallyn.com>, Nick Desaulniers <ndesaulniers@google.com>, Kostya
 Serebryany <kcc@google.com>, Dmitry Vyukov <dvyukov@google.com>, Sandeep
 Patil <sspatil@android.com>,  Laura Abbott <labbott@redhat.com>, Randy
 Dunlap <rdunlap@infradead.org>, Jann Horn <jannh@google.com>,  Mark Rutland
 <mark.rutland@arm.com>, Marco Elver <elver@google.com>, linux-mm@kvack.org,
  linux-security-module@vger.kernel.org,
 kernel-hardening@lists.openwall.com,  clang-built-linux@googlegroups.com
Date: Wed, 26 Jun 2019 14:15:49 -0400
In-Reply-To: <20190626121943.131390-2-glider@google.com>
References: <20190626121943.131390-1-glider@google.com>
	 <20190626121943.131390-2-glider@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2019-06-26 at 14:19 +0200, Alexander Potapenko wrote:
> The new options are needed to prevent possible information leaks and
> make control-flow bugs that depend on uninitialized values more
> deterministic.
> 
> This is expected to be on-by-default on Android and Chrome OS. And it
> gives the opportunity for anyone else to use it under distros too via
> the boot args. (The init_on_free feature is regularly requested by
> folks where memory forensics is included in their threat models.)
> 
> init_on_alloc=1 makes the kernel initialize newly allocated pages and heap
> objects with zeroes. Initialization is done at allocation time at the
> places where checks for __GFP_ZERO are performed.
> 
> init_on_free=1 makes the kernel initialize freed pages and heap objects
> with zeroes upon their deletion. This helps to ensure sensitive data
> doesn't leak via use-after-free accesses.
> 
> Both init_on_alloc=1 and init_on_free=1 guarantee that the allocator
> returns zeroed memory. The two exceptions are slab caches with
> constructors and SLAB_TYPESAFE_BY_RCU flag. Those are never
> zero-initialized to preserve their semantics.
> 
> Both init_on_alloc and init_on_free default to zero, but those defaults
> can be overridden with CONFIG_INIT_ON_ALLOC_DEFAULT_ON and
> CONFIG_INIT_ON_FREE_DEFAULT_ON.
> 
> If either SLUB poisoning or page poisoning is enabled, we disable
> init_on_alloc and init_on_free so that initialization doesn't interfere
> with debugging.
> 
> Slowdown for the new features compared to init_on_free=0,
> init_on_alloc=0:
> 
> hackbench, init_on_free=1:  +7.62% sys time (st.err 0.74%)
> hackbench, init_on_alloc=1: +7.75% sys time (st.err 2.14%)
> 
> Linux build with -j12, init_on_free=1:  +8.38% wall time (st.err 0.39%)
> Linux build with -j12, init_on_free=1:  +24.42% sys time (st.err 0.52%)
> Linux build with -j12, init_on_alloc=1: -0.13% wall time (st.err 0.42%)
> Linux build with -j12, init_on_alloc=1: +0.57% sys time (st.err 0.40%)
> 
> The slowdown for init_on_free=0, init_on_alloc=0 compared to the
> baseline is within the standard error.
> 
> The new features are also going to pave the way for hardware memory
> tagging (e.g. arm64's MTE), which will require both on_alloc and on_free
> hooks to set the tags for heap objects. With MTE, tagging will have the
> same cost as memory initialization.
> 
> Although init_on_free is rather costly, there are paranoid use-cases where
> in-memory data lifetime is desired to be minimized. There are various
> arguments for/against the realism of the associated threat models, but
> given that we'll need the infrastructure for MTE anyway, and there are
> people who want wipe-on-free behavior no matter what the performance cost,
> it seems reasonable to include it in this series.
> 
> Signed-off-by: Alexander Potapenko <glider@google.com>
> Acked-by: Kees Cook <keescook@chromium.org>
> To: Andrew Morton <akpm@linux-foundation.org>
> To: Christoph Lameter <cl@linux.com>
> To: Kees Cook <keescook@chromium.org>
> Cc: Masahiro Yamada <yamada.masahiro@socionext.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: James Morris <jmorris@namei.org>
> Cc: "Serge E. Hallyn" <serge@hallyn.com>
> Cc: Nick Desaulniers <ndesaulniers@google.com>
> Cc: Kostya Serebryany <kcc@google.com>
> Cc: Dmitry Vyukov <dvyukov@google.com>
> Cc: Sandeep Patil <sspatil@android.com>
> Cc: Laura Abbott <labbott@redhat.com>
> Cc: Randy Dunlap <rdunlap@infradead.org>
> Cc: Jann Horn <jannh@google.com>
> Cc: Mark Rutland <mark.rutland@arm.com>
> Cc: Marco Elver <elver@google.com>
> Cc: Qian Cai <cai@lca.pw>
> Cc: linux-mm@kvack.org
> Cc: linux-security-module@vger.kernel.org
> Cc: kernel-hardening@lists.openwall.com
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
>  v2:
>   - unconditionally initialize pages in kernel_init_free_pages()
>   - comment from Randy Dunlap: drop 'default false' lines from
> Kconfig.hardening
>  v3:
>   - don't call kernel_init_free_pages() from memblock_free_pages()
>   - adopted some Kees' comments for the patch description
>  v4:
>   - use NULL instead of 0 in slab_alloc_node() (found by kbuild test robot)
>   - don't write to NULL object in slab_alloc_node() (found by Android
>     testing)
>  v5:
>   - adjusted documentation wording as suggested by Kees
>   - disable SLAB_POISON if auto-initialization is on
>   - don't wipe RCU cache allocations made without __GFP_ZERO
>   - dropped SLOB support
>  v7:
>   - rebase the patch, added the Acked-by: tag
>  v8:
>   - addressed comments by Michal Hocko: revert kernel/kexec_core.c and
>     apply initialization in dma_pool_free()
>   - disable init_on_alloc/init_on_free if slab poisoning or page
>     poisoning are enabled, as requested by Qian Cai
>   - skip the redzone when initializing a freed heap object, as requested
>     by Qian Cai and Kees Cook
>   - use s->offset to address the freeptr (suggested by Kees Cook)
>   - updated the patch description, added Signed-off-by: tag
> ---
>  .../admin-guide/kernel-parameters.txt         |  9 +++
>  drivers/infiniband/core/uverbs_ioctl.c        |  2 +-
>  include/linux/mm.h                            | 22 ++++++
>  mm/dmapool.c                                  |  4 +-
>  mm/page_alloc.c                               | 71 +++++++++++++++++--
>  mm/slab.c                                     | 16 ++++-
>  mm/slab.h                                     | 19 +++++
>  mm/slub.c                                     | 43 +++++++++--
>  net/core/sock.c                               |  2 +-
>  security/Kconfig.hardening                    | 29 ++++++++
>  10 files changed, 199 insertions(+), 18 deletions(-)
> 
> diff --git a/Documentation/admin-guide/kernel-parameters.txt
> b/Documentation/admin-guide/kernel-parameters.txt
> index 138f6664b2e2..84ee1121a2b9 100644
> --- a/Documentation/admin-guide/kernel-parameters.txt
> +++ b/Documentation/admin-guide/kernel-parameters.txt
> @@ -1673,6 +1673,15 @@
>  
>  	initrd=		[BOOT] Specify the location of the initial
> ramdisk
>  
> +	init_on_alloc=	[MM] Fill newly allocated pages and heap
> objects with
> +			zeroes.
> +			Format: 0 | 1
> +			Default set by CONFIG_INIT_ON_ALLOC_DEFAULT_ON.
> +
> +	init_on_free=	[MM] Fill freed pages and heap objects with
> zeroes.
> +			Format: 0 | 1
> +			Default set by CONFIG_INIT_ON_FREE_DEFAULT_ON.
> +
>  	init_pkru=	[x86] Specify the default memory protection keys
> rights
>  			register contents for all processes.  0x55555554 by
>  			default (disallow access to all but pkey 0).  Can
> diff --git a/drivers/infiniband/core/uverbs_ioctl.c
> b/drivers/infiniband/core/uverbs_ioctl.c
> index 829b0c6944d8..61758201d9b2 100644
> --- a/drivers/infiniband/core/uverbs_ioctl.c
> +++ b/drivers/infiniband/core/uverbs_ioctl.c
> @@ -127,7 +127,7 @@ __malloc void *_uverbs_alloc(struct uverbs_attr_bundle
> *bundle, size_t size,
>  	res = (void *)pbundle->internal_buffer + pbundle->internal_used;
>  	pbundle->internal_used =
>  		ALIGN(new_used, sizeof(*pbundle->internal_buffer));
> -	if (flags & __GFP_ZERO)
> +	if (want_init_on_alloc(flags))
>  		memset(res, 0, size);
>  	return res;
>  }
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index dd0b5f4e1e45..96be2604f313 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2696,6 +2696,28 @@ static inline void kernel_poison_pages(struct page
> *page, int numpages,
>  					int enable) { }
>  #endif
>  
> +#ifdef CONFIG_INIT_ON_ALLOC_DEFAULT_ON
> +DECLARE_STATIC_KEY_TRUE(init_on_alloc);
> +#else
> +DECLARE_STATIC_KEY_FALSE(init_on_alloc);
> +#endif
> +static inline bool want_init_on_alloc(gfp_t flags)
> +{
> +	if (static_branch_unlikely(&init_on_alloc))
> +		return true;
> +	return flags & __GFP_ZERO;
> +}
> +
> +#ifdef CONFIG_INIT_ON_FREE_DEFAULT_ON
> +DECLARE_STATIC_KEY_TRUE(init_on_free);
> +#else
> +DECLARE_STATIC_KEY_FALSE(init_on_free);
> +#endif
> +static inline bool want_init_on_free(void)
> +{
> +	return static_branch_unlikely(&init_on_free);
> +}
> +
>  extern bool _debug_pagealloc_enabled;
>  
>  static inline bool debug_pagealloc_enabled(void)

Do those really necessary need to be static keys?

Adding either init_on_free=0 or init_on_alloc=0 to the kernel cmdline will
generate a warning with kernels built with clang.

[    0.000000] static_key_disable(): static key 'init_on_free+0x0/0x4' used
before call to jump_label_init()
[    0.000000] WARNING: CPU: 0 PID: 0 at ./include/linux/jump_label.h:317
early_init_on_free+0x1c0/0x200
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 5.2.0-rc6-next-20190626+
#9
[    0.000000] pstate: 60000089 (nZCv daIf -PAN -UAO)
[    0.000000] pc : early_init_on_free+0x1c0/0x200
[    0.000000] lr : early_init_on_free+0x1c0/0x200
[    0.000000] sp : ffff100012c07df0
[    0.000000] x29: ffff100012c07e20 x28: ffff1000110a01ec 
[    0.000000] x27: 000000000000005f x26: ffff100011716cd0 
[    0.000000] x25: ffff100010d36166 x24: ffff100010d3615d 
[    0.000000] x23: ffff100010d364b5 x22: ffff1000117164a0 
[    0.000000] x21: 0000000000000000 x20: 0000000000000000 
[    0.000000] x19: 0000000000000000 x18: 000000000000002e 
[    0.000000] x17: 000000000000000f x16: 0000000000000040 
[    0.000000] x15: 0000000000000000 x14: 6c61632065726f66 
[    0.000000] x13: 6562206465737520 x12: 273478302f307830 
[    0.000000] x11: 0000000000000000 x10: 0000000000000000 
[    0.000000] x9 : 0000000000000000 x8 : 0000000000000000 
[    0.000000] x7 : 6d756a206f74206c x6 : ffff100014426625 
[    0.000000] x5 : ffff100012c07b28 x4 : 0000000000000007 
[    0.000000] x3 : ffff1000101aadf4 x2 : 0000000000000001 
[    0.000000] x1 : 0000000000000001 x0 : 000000000000005d 
[    0.000000] Call trace:
[    0.000000]  early_init_on_free+0x1c0/0x200
[    0.000000]  do_early_param+0xd0/0x104
[    0.000000]  parse_args+0x1f0/0x524
[    0.000000]  parse_early_param+0x70/0x8c
[    0.000000]  setup_arch+0xa8/0x268
[    0.000000]  start_kernel+0x80/0x560

