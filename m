Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id ECE356B0038
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 14:51:28 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id s186so147707286qkb.5
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 11:51:28 -0800 (PST)
Received: from mail-yw0-x244.google.com (mail-yw0-x244.google.com. [2607:f8b0:4002:c05::244])
        by mx.google.com with ESMTPS id u26si3379274qte.73.2017.02.27.11.51.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Feb 2017 11:51:28 -0800 (PST)
Received: by mail-yw0-x244.google.com with SMTP id l138so2902869ywc.0
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 11:51:28 -0800 (PST)
Date: Mon, 27 Feb 2017 14:51:26 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2 3/3] percpu: improve allocation success rate for
 non-GFP_KERNEL callers
Message-ID: <20170227195126.GC8707@htj.duckdns.org>
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
Cc: Michal Hocko <mhocko@kernel.org>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Chris Wilson <chris@chris-wilson.co.uk>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Roman Pen <r.peniaev@gmail.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, zijun_hu <zijun_hu@htc.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello,

On Mon, Feb 27, 2017 at 05:00:31AM -0800, Tahsin Erdogan wrote:
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

As indicated by GFP_NOWAIT | __GFP_NOWARN, it's okay to fail there.
It's not okay to fail consistently for a long time but it's not a big
issue to fail occassionally even if somewhat bunched up.  The only bad
side effect of that is temporary misaccounting of some IOs, which
shouldn't be noticeable outside of pathological cases.  If you're
actually seeing adverse effects of this, I'd love to learn about it.

> > We already have __vmalloc_gfp, why this cannot be used? Also note that
> > vmalloc dosn't really support arbitrary gfp flags. One have to be really
> > careful because there are some internal allocations which are hardcoded
> > GFP_KERNEL. Also this patch doesn't really add any new callers so it is
> > hard to tell whether what you do actually makes sense and is correct.
>
> Did you mean to say __vmalloc? If so, yes, I should use that.

So, the last time I looked at it the thorny ones in that path are the
page table (pgd, pud...) allocation functions.  There are several
layers of indirection there but they end up in arch-specific
implemntations which hard code GFP_KERNEL.  Without fixing them up, we
can't guarantee mapping the allocated pages making things kinda moot.

The only reason percpu allocator has the background allocator stuff is
vmalloc path can't do non-blocking allocations.  If we can properly
fix that up, we can get rid of all those code from percpu allocator
and simply path the gfp flag to vmap functions.  Please take a look at
__pcpu_map_pages() in mm/percpu-vm.c.  map_kernel_range_noflush() is
the function which has implicit GFP_KERNEL allocation in it and what's
requiring the reserve.

If you can get rid of that, awesome, but given that your patch doesn't
touch that at all, I can't see how it's supposed to work.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
