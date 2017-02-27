Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6EA8F6B0387
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 10:25:24 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id t18so39352370wmt.7
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 07:25:24 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p13si13848062wmi.13.2017.02.27.07.25.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 27 Feb 2017 07:25:22 -0800 (PST)
Date: Mon, 27 Feb 2017 16:25:17 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 3/3] percpu: improve allocation success rate for
 non-GFP_KERNEL callers
Message-ID: <20170227152516.GJ26504@dhcp22.suse.cz>
References: <201702260805.zhem8KFI%fengguang.wu@intel.com>
 <20170226043829.14270-1-tahsin@google.com>
 <20170227095258.GG14029@dhcp22.suse.cz>
 <CAAeU0aMaGa63Nj=JvZKKy82FftAT9dF56=gZsufDvrkqDSGUrw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAeU0aMaGa63Nj=JvZKKy82FftAT9dF56=gZsufDvrkqDSGUrw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tahsin Erdogan <tahsin@google.com>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Chris Wilson <chris@chris-wilson.co.uk>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Roman Pen <r.peniaev@gmail.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, zijun_hu <zijun_hu@htc.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 27-02-17 05:00:31, Tahsin Erdogan wrote:
> On Mon, Feb 27, 2017 at 1:52 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > On Sat 25-02-17 20:38:29, Tahsin Erdogan wrote:
> >> When pcpu_alloc() is called with gfp != GFP_KERNEL, the likelihood of
> >> a failure is higher than GFP_KERNEL case. This is mainly because
> >> pcpu_alloc() relies on previously allocated reserves and does not make
> >> an effort to add memory to its pools for non-GFP_KERNEL case.
> >
> > Who is going to use a different mask?
> 
> blkg_create() makes a call with a non-GFP_KERNEL mask:
>    new_blkg = blkg_alloc(blkcg, q, GFP_NOWAIT | __GFP_NOWARN);
> 
> which turns into a call stack like below:
> 
> __vmalloc+0x45/0x50
> pcpu_mem_zalloc+0x50/0x80
> pcpu_populate_chunk+0x3b/0x380
> pcpu_alloc+0x588/0x6e0
> __alloc_percpu_gfp+0xd/0x10
> __percpu_counter_init+0x55/0xc0
> blkg_alloc+0x76/0x230
> blkg_create+0x489/0x670
> blkg_lookup_create+0x9a/0x230
> generic_make_request_checks+0x7dd/0x890
> generic_make_request+0x1f/0x180
> submit_bio+0x61/0x120

OK, I see. Thanks for the clarification. I am not familiar with the pcp
allocator much, but we have
	/*
	 * No space left.  Create a new chunk.  We don't want multiple
	 * tasks to create chunks simultaneously.  Serialize and create iff
	 * there's still no empty chunk after grabbing the mutex.
	 */
	if (is_atomic)
		goto fail;

right before pcpu_populate_chunk so is this actually a problem?

> > We already have __vmalloc_gfp, why this cannot be used? Also note that
> > vmalloc dosn't really support arbitrary gfp flags. One have to be really
> > careful because there are some internal allocations which are hardcoded
> > GFP_KERNEL. Also this patch doesn't really add any new callers so it is
> > hard to tell whether what you do actually makes sense and is correct.
> 
> Did you mean to say __vmalloc? If so, yes, I should use that.

yeah

> By the way, I now noticed the might_sleep() in alloc_vmap_area() which makes
> it unsafe to call vmalloc* in GFP_ATOMIC contexts. It was added recently:

Do we call alloc_vmap_area from true atomic contexts (aka from under
spinlocks etc)? I thought this was a nogo and GFP_NOWAIT resp.
GFP_ATOMIC was more about optimistic request resp. access to memory
reserves rather than true atomicity requirements.

> commit 5803ed292e63 ("mm: mark all calls into the vmalloc subsystem as
> potentially sleeping")
> 
> Any suggestions on how to deal with that? For instance, would it be
> safe to replace it with:
> 
> might_sleep_if(gfpflags_allow_blocking(gfp_mask));
> 
> and then skip purge_vmap_area_lazy() if blocking is not allowed?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
