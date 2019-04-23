Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 768E4C10F14
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 07:36:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 150A320652
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 07:36:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=ffwll.ch header.i=@ffwll.ch header.b="YVSMCPmN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 150A320652
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ffwll.ch
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 987E26B0006; Tue, 23 Apr 2019 03:36:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 937AC6B0007; Tue, 23 Apr 2019 03:36:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7DA5A6B0008; Tue, 23 Apr 2019 03:36:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 28FA46B0006
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 03:36:31 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id h22so7532230edh.1
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 00:36:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:mail-followup-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=bKYaajiak7Zq/jXYNZsg7tprgawT9ZLW0GYZ4u8T1/U=;
        b=I8DIAmziEAlGECXbxKp0B2EK1o3a/HKI7O1klGiLRmHGe5mGBQxHgNHEafMGI4hOfe
         rMzP3R22ME4Bi4QzlkzNqlOtDOxg8yxhvgQHkzC8lcBd4ObXdR/5VjjhdH+MVjXU5g5G
         5JfDz3HHyJjiZH62OdQR83N6jZ1vv1kGteOz8G2LbnXIsoxscQPvfInNVaTwv9rCZ6Eb
         9JDjhOrNFj5hDiGJwtyGErD07zdXdDM7DmMASVkYZClYoyh1HuRA1avGi/mVVdv10FNc
         9GXJqQwgCeT4dfFJEXxCg5SIO5UXEGLQAMXtqJGGp1EN71IJ2uWPBn+zIJMl9rbVVNL7
         0hcg==
X-Gm-Message-State: APjAAAXqKUMqCeNEa2M2B5N4z5plCbBE/5BxrOZJNbx1OA6r/1UaLm8N
	z7OukUtsw5xefE+yJz3Fk2nxAqiMzu703H4O0jwT42tDHxA8TSteKxHatSUHKri5B54rl/+1s8k
	uHHF8UZP81KUDshluPI1k56ZnVDZOsb6YyjcZDkx4dJs0sFDRkWerMPQwLnDwY37uIA==
X-Received: by 2002:a50:a3c2:: with SMTP id t2mr14985220edb.46.1556004990587;
        Tue, 23 Apr 2019 00:36:30 -0700 (PDT)
X-Received: by 2002:a50:a3c2:: with SMTP id t2mr14985174edb.46.1556004989778;
        Tue, 23 Apr 2019 00:36:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556004989; cv=none;
        d=google.com; s=arc-20160816;
        b=x0lb7mkEIzFyy0Y+4bjEB95ODwLGVLhH0qI9FXF4RzT6cUgakGPt97Oguxm41VHqbM
         LSDTUMhFbE5O46dcqb25w2AeLz6Jfh37VNa5CKGHrQuZvpjSNxRwSOHjWS/+Ybfdrjx1
         c8bJnENt/g6Gu2UQ2tY/QvcRdKzKGXpETDyfA8czC+F7QmwsGJguAAIrlWs7+ia2MAEs
         vyGk0UKRzfQn0FdTdb3StvKM3vE+UPV+uILIL7FPIpqAqS3T5Hpj+npjwOeEVCMtpBV5
         K+FAZ6Y8Hl5C6NTLvFElLQXUPF38DBY/NcrQF391NnrIlA9WFENlQfpbuxoCCjSDSHgk
         tJJA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :mail-followup-to:message-id:subject:cc:to:from:date:sender
         :dkim-signature;
        bh=bKYaajiak7Zq/jXYNZsg7tprgawT9ZLW0GYZ4u8T1/U=;
        b=PZBkHbUZ//M/gpPW6YwUuIfQ9/WxoDB2ym/CRReazAqTje4fPE4WmFmKqhBEg4ZzSo
         hgHpaDTny9oIybW9jGqjfnKIqVXBw3ezb607b0Xs4OMgzfdjW6jOZA3AL3OTKQsS/LW1
         d1+iBKYNTOioKI5KIFwlp51veChOa/iyJ3+OxNF2UE8yPhNbDpMHPT9+/B64szsYoxaJ
         /sPR00bmu+3pXjKnAH58jy89/mtzUXjZxoLTPbLCQpTE3a99AyIPgA5bW3m1pzSn3ol/
         vWE7I9v8Zh9mOEMH/46O7ldekcWPgJnkLjCoz73LDr0x3ujoM7ba37+UjGdblXqYfF+S
         2Nng==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ffwll.ch header.s=google header.b=YVSMCPmN;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of daniel@ffwll.ch) smtp.mailfrom=daniel@ffwll.ch
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s26sor7474103edd.25.2019.04.23.00.36.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Apr 2019 00:36:29 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of daniel@ffwll.ch) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ffwll.ch header.s=google header.b=YVSMCPmN;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of daniel@ffwll.ch) smtp.mailfrom=daniel@ffwll.ch
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ffwll.ch; s=google;
        h=sender:date:from:to:cc:subject:message-id:mail-followup-to
         :references:mime-version:content-disposition:in-reply-to:user-agent;
        bh=bKYaajiak7Zq/jXYNZsg7tprgawT9ZLW0GYZ4u8T1/U=;
        b=YVSMCPmNBiDoDNpcTyNizSQpeFtdskx5nzotOQdI+PM4xCSjWZehbeKERXQ66dUsNf
         TXHm1tfsqbgr0menNDTyY6pXffkwQK1wj5A4gW69fvoOwQQDYM4lc/5v3tUnIgZJ5xdQ
         qbZCJtt8BK/ZddIoqnV348CMM9PeIofFwaJu4=
X-Google-Smtp-Source: APXvYqyfiVOQGBzi0xFFlvW7+u0SliHoY3BhrSH7C0jNdR2HDDmW0RiEkJeC4fVSS0YpOwtF9jGgvA==
X-Received: by 2002:a05:6402:6d9:: with SMTP id n25mr15163695edy.288.1556004989447;
        Tue, 23 Apr 2019 00:36:29 -0700 (PDT)
Received: from phenom.ffwll.local ([2a02:168:569e:0:3106:d637:d723:e855])
        by smtp.gmail.com with ESMTPSA id l18sm1712508edc.33.2019.04.23.00.36.27
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 23 Apr 2019 00:36:28 -0700 (PDT)
Date: Tue, 23 Apr 2019 09:36:25 +0200
From: Daniel Vetter <daniel@ffwll.ch>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>,
	Josh Poimboeuf <jpoimboe@redhat.com>, x86@kernel.org,
	Andy Lutomirski <luto@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Alexander Potapenko <glider@google.com>,
	intel-gfx@lists.freedesktop.org,
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
	Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
	dri-devel@lists.freedesktop.org, David Airlie <airlied@linux.ie>,
	Jani Nikula <jani.nikula@linux.intel.com>,
	Daniel Vetter <daniel@ffwll.ch>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org,
	David Rientjes <rientjes@google.com>,
	Christoph Lameter <cl@linux.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	kasan-dev@googlegroups.com, Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Akinobu Mita <akinobu.mita@gmail.com>,
	iommu@lists.linux-foundation.org,
	Robin Murphy <robin.murphy@arm.com>, Christoph Hellwig <hch@lst.de>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Johannes Thumshirn <jthumshirn@suse.de>,
	David Sterba <dsterba@suse.com>, Chris Mason <clm@fb.com>,
	Josef Bacik <josef@toxicpanda.com>, linux-btrfs@vger.kernel.org,
	dm-devel@redhat.com, Mike Snitzer <snitzer@redhat.com>,
	Alasdair Kergon <agk@redhat.com>, linux-arch@vger.kernel.org
Subject: Re: [patch V2 16/29] drm: Simplify stacktrace handling
Message-ID: <20190423073625.GZ13337@phenom.ffwll.local>
Mail-Followup-To: Thomas Gleixner <tglx@linutronix.de>,
	LKML <linux-kernel@vger.kernel.org>,
	Josh Poimboeuf <jpoimboe@redhat.com>, x86@kernel.org,
	Andy Lutomirski <luto@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Alexander Potapenko <glider@google.com>,
	intel-gfx@lists.freedesktop.org,
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
	Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
	dri-devel@lists.freedesktop.org, David Airlie <airlied@linux.ie>,
	Jani Nikula <jani.nikula@linux.intel.com>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org,
	David Rientjes <rientjes@google.com>,
	Christoph Lameter <cl@linux.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	kasan-dev@googlegroups.com, Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Akinobu Mita <akinobu.mita@gmail.com>,
	iommu@lists.linux-foundation.org,
	Robin Murphy <robin.murphy@arm.com>, Christoph Hellwig <hch@lst.de>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Johannes Thumshirn <jthumshirn@suse.de>,
	David Sterba <dsterba@suse.com>, Chris Mason <clm@fb.com>,
	Josef Bacik <josef@toxicpanda.com>, linux-btrfs@vger.kernel.org,
	dm-devel@redhat.com, Mike Snitzer <snitzer@redhat.com>,
	Alasdair Kergon <agk@redhat.com>, linux-arch@vger.kernel.org
References: <20190418084119.056416939@linutronix.de>
 <20190418084254.549410214@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190418084254.549410214@linutronix.de>
X-Operating-System: Linux phenom 4.19.0-1-amd64 
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 18, 2019 at 10:41:35AM +0200, Thomas Gleixner wrote:
> Replace the indirection through struct stack_trace by using the storage
> array based interfaces.
> 
> The original code in all printing functions is really wrong. It allocates a
> storage array on stack which is unused because depot_fetch_stack() does not
> store anything in it. It overwrites the entries pointer in the stack_trace
> struct so it points to the depot storage.

Thanks for cleaning this up for us!

> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
> Cc: intel-gfx@lists.freedesktop.org
> Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
> Cc: Maarten Lankhorst <maarten.lankhorst@linux.intel.com>
> Cc: dri-devel@lists.freedesktop.org
> Cc: David Airlie <airlied@linux.ie>
> Cc: Jani Nikula <jani.nikula@linux.intel.com>
> Cc: Daniel Vetter <daniel@ffwll.ch>
> Cc: Rodrigo Vivi <rodrigo.vivi@intel.com>

Acked-by: Daniel Vetter <daniel.vetter@ffwll.ch>

for merging through whatever tree is convenient for you (or tell me I
should pick it up into drm-next when the prep work landed).

Cheers, Daniel

> ---
>  drivers/gpu/drm/drm_mm.c                |   22 +++++++---------------
>  drivers/gpu/drm/i915/i915_vma.c         |   11 ++++-------
>  drivers/gpu/drm/i915/intel_runtime_pm.c |   21 +++++++--------------
>  3 files changed, 18 insertions(+), 36 deletions(-)
> 
> --- a/drivers/gpu/drm/drm_mm.c
> +++ b/drivers/gpu/drm/drm_mm.c
> @@ -106,22 +106,19 @@
>  static noinline void save_stack(struct drm_mm_node *node)
>  {
>  	unsigned long entries[STACKDEPTH];
> -	struct stack_trace trace = {
> -		.entries = entries,
> -		.max_entries = STACKDEPTH,
> -		.skip = 1
> -	};
> +	unsigned int n;
>  
> -	save_stack_trace(&trace);
> +	n = stack_trace_save(entries, ARRAY_SIZE(entries), 1);
>  
>  	/* May be called under spinlock, so avoid sleeping */
> -	node->stack = depot_save_stack(&trace, GFP_NOWAIT);
> +	node->stack = stack_depot_save(entries, n, GFP_NOWAIT);
>  }
>  
>  static void show_leaks(struct drm_mm *mm)
>  {
>  	struct drm_mm_node *node;
> -	unsigned long entries[STACKDEPTH];
> +	unsigned long *entries;
> +	unsigned int nr_entries;
>  	char *buf;
>  
>  	buf = kmalloc(BUFSZ, GFP_KERNEL);
> @@ -129,19 +126,14 @@ static void show_leaks(struct drm_mm *mm
>  		return;
>  
>  	list_for_each_entry(node, drm_mm_nodes(mm), node_list) {
> -		struct stack_trace trace = {
> -			.entries = entries,
> -			.max_entries = STACKDEPTH
> -		};
> -
>  		if (!node->stack) {
>  			DRM_ERROR("node [%08llx + %08llx]: unknown owner\n",
>  				  node->start, node->size);
>  			continue;
>  		}
>  
> -		depot_fetch_stack(node->stack, &trace);
> -		snprint_stack_trace(buf, BUFSZ, &trace, 0);
> +		nr_entries = stack_depot_fetch(node->stack, &entries);
> +		stack_trace_snprint(buf, BUFSZ, entries, nr_entries, 0);
>  		DRM_ERROR("node [%08llx + %08llx]: inserted at\n%s",
>  			  node->start, node->size, buf);
>  	}
> --- a/drivers/gpu/drm/i915/i915_vma.c
> +++ b/drivers/gpu/drm/i915/i915_vma.c
> @@ -36,11 +36,8 @@
>  
>  static void vma_print_allocator(struct i915_vma *vma, const char *reason)
>  {
> -	unsigned long entries[12];
> -	struct stack_trace trace = {
> -		.entries = entries,
> -		.max_entries = ARRAY_SIZE(entries),
> -	};
> +	unsigned long *entries;
> +	unsigned int nr_entries;
>  	char buf[512];
>  
>  	if (!vma->node.stack) {
> @@ -49,8 +46,8 @@ static void vma_print_allocator(struct i
>  		return;
>  	}
>  
> -	depot_fetch_stack(vma->node.stack, &trace);
> -	snprint_stack_trace(buf, sizeof(buf), &trace, 0);
> +	nr_entries = stack_depot_fetch(vma->node.stack, &entries);
> +	stack_trace_snprint(buf, sizeof(buf), entries, nr_entries, 0);
>  	DRM_DEBUG_DRIVER("vma.node [%08llx + %08llx] %s: inserted at %s\n",
>  			 vma->node.start, vma->node.size, reason, buf);
>  }
> --- a/drivers/gpu/drm/i915/intel_runtime_pm.c
> +++ b/drivers/gpu/drm/i915/intel_runtime_pm.c
> @@ -60,27 +60,20 @@
>  static noinline depot_stack_handle_t __save_depot_stack(void)
>  {
>  	unsigned long entries[STACKDEPTH];
> -	struct stack_trace trace = {
> -		.entries = entries,
> -		.max_entries = ARRAY_SIZE(entries),
> -		.skip = 1,
> -	};
> +	unsigned int n;
>  
> -	save_stack_trace(&trace);
> -	return depot_save_stack(&trace, GFP_NOWAIT | __GFP_NOWARN);
> +	n = stack_trace_save(entries, ARRAY_SIZE(entries), 1);
> +	return stack_depot_save(entries, n, GFP_NOWAIT | __GFP_NOWARN);
>  }
>  
>  static void __print_depot_stack(depot_stack_handle_t stack,
>  				char *buf, int sz, int indent)
>  {
> -	unsigned long entries[STACKDEPTH];
> -	struct stack_trace trace = {
> -		.entries = entries,
> -		.max_entries = ARRAY_SIZE(entries),
> -	};
> +	unsigned long *entries;
> +	unsigned int nr_entries;
>  
> -	depot_fetch_stack(stack, &trace);
> -	snprint_stack_trace(buf, sz, &trace, indent);
> +	nr_entries = stack_depot_fetch(stack, &entries);
> +	stack_trace_snprint(buf, sz, entries, nr_entries, indent);
>  }
>  
>  static void init_intel_runtime_pm_wakeref(struct drm_i915_private *i915)
> 
> 

-- 
Daniel Vetter
Software Engineer, Intel Corporation
http://blog.ffwll.ch

