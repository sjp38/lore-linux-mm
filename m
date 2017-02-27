Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id D19856B0389
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 08:00:36 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id 203so87778497ith.3
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 05:00:36 -0800 (PST)
Received: from mail-io0-x235.google.com (mail-io0-x235.google.com. [2607:f8b0:4001:c06::235])
        by mx.google.com with ESMTPS id m40si2699666ioi.53.2017.02.27.05.00.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Feb 2017 05:00:32 -0800 (PST)
Received: by mail-io0-x235.google.com with SMTP id l7so17541181ioe.3
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 05:00:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170227095258.GG14029@dhcp22.suse.cz>
References: <201702260805.zhem8KFI%fengguang.wu@intel.com> <20170226043829.14270-1-tahsin@google.com>
 <20170227095258.GG14029@dhcp22.suse.cz>
From: Tahsin Erdogan <tahsin@google.com>
Date: Mon, 27 Feb 2017 05:00:31 -0800
Message-ID: <CAAeU0aMaGa63Nj=JvZKKy82FftAT9dF56=gZsufDvrkqDSGUrw@mail.gmail.com>
Subject: Re: [PATCH v2 3/3] percpu: improve allocation success rate for
 non-GFP_KERNEL callers
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Chris Wilson <chris@chris-wilson.co.uk>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Roman Pen <r.peniaev@gmail.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, zijun_hu <zijun_hu@htc.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Feb 27, 2017 at 1:52 AM, Michal Hocko <mhocko@kernel.org> wrote:
> On Sat 25-02-17 20:38:29, Tahsin Erdogan wrote:
>> When pcpu_alloc() is called with gfp != GFP_KERNEL, the likelihood of
>> a failure is higher than GFP_KERNEL case. This is mainly because
>> pcpu_alloc() relies on previously allocated reserves and does not make
>> an effort to add memory to its pools for non-GFP_KERNEL case.
>
> Who is going to use a different mask?

blkg_create() makes a call with a non-GFP_KERNEL mask:
   new_blkg = blkg_alloc(blkcg, q, GFP_NOWAIT | __GFP_NOWARN);

which turns into a call stack like below:

__vmalloc+0x45/0x50
pcpu_mem_zalloc+0x50/0x80
pcpu_populate_chunk+0x3b/0x380
pcpu_alloc+0x588/0x6e0
__alloc_percpu_gfp+0xd/0x10
__percpu_counter_init+0x55/0xc0
blkg_alloc+0x76/0x230
blkg_create+0x489/0x670
blkg_lookup_create+0x9a/0x230
generic_make_request_checks+0x7dd/0x890
generic_make_request+0x1f/0x180
submit_bio+0x61/0x120


> We already have __vmalloc_gfp, why this cannot be used? Also note that
> vmalloc dosn't really support arbitrary gfp flags. One have to be really
> careful because there are some internal allocations which are hardcoded
> GFP_KERNEL. Also this patch doesn't really add any new callers so it is
> hard to tell whether what you do actually makes sense and is correct.

Did you mean to say __vmalloc? If so, yes, I should use that.

By the way, I now noticed the might_sleep() in alloc_vmap_area() which makes
it unsafe to call vmalloc* in GFP_ATOMIC contexts. It was added recently:

commit 5803ed292e63 ("mm: mark all calls into the vmalloc subsystem as
potentially sleeping")

Any suggestions on how to deal with that? For instance, would it be
safe to replace it with:

might_sleep_if(gfpflags_allow_blocking(gfp_mask));

and then skip purge_vmap_area_lazy() if blocking is not allowed?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
