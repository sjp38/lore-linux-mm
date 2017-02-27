Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 86EAC6B0038
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 12:01:11 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id i1so28505950ota.0
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 09:01:11 -0800 (PST)
Received: from mail-it0-x230.google.com (mail-it0-x230.google.com. [2607:f8b0:4001:c0b::230])
        by mx.google.com with ESMTPS id j75si10544396ita.10.2017.02.27.09.01.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Feb 2017 09:01:10 -0800 (PST)
Received: by mail-it0-x230.google.com with SMTP id y135so71978993itc.1
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 09:01:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170227152516.GJ26504@dhcp22.suse.cz>
References: <201702260805.zhem8KFI%fengguang.wu@intel.com> <20170226043829.14270-1-tahsin@google.com>
 <20170227095258.GG14029@dhcp22.suse.cz> <CAAeU0aMaGa63Nj=JvZKKy82FftAT9dF56=gZsufDvrkqDSGUrw@mail.gmail.com>
 <20170227152516.GJ26504@dhcp22.suse.cz>
From: Tahsin Erdogan <tahsin@google.com>
Date: Mon, 27 Feb 2017 09:01:09 -0800
Message-ID: <CAAeU0aOCGrwmYGPWgA_7Y=2O2RXG_Ux14h4FrogpKPAKvVNaXg@mail.gmail.com>
Subject: Re: [PATCH v2 3/3] percpu: improve allocation success rate for
 non-GFP_KERNEL callers
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Chris Wilson <chris@chris-wilson.co.uk>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Roman Pen <r.peniaev@gmail.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, zijun_hu <zijun_hu@htc.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Feb 27, 2017 at 7:25 AM, Michal Hocko <mhocko@kernel.org> wrote:
>         /*
>          * No space left.  Create a new chunk.  We don't want multiple
>          * tasks to create chunks simultaneously.  Serialize and create iff
>          * there's still no empty chunk after grabbing the mutex.
>          */
>         if (is_atomic)
>                 goto fail;
>
> right before pcpu_populate_chunk so is this actually a problem?

Yes, this prevents adding more pcpu chunks and so cause "atomic" allocations
to fail more easily.

>> By the way, I now noticed the might_sleep() in alloc_vmap_area() which makes
>> it unsafe to call vmalloc* in GFP_ATOMIC contexts. It was added recently:
>
> Do we call alloc_vmap_area from true atomic contexts (aka from under
> spinlocks etc)? I thought this was a nogo and GFP_NOWAIT resp.
> GFP_ATOMIC was more about optimistic request resp. access to memory
> reserves rather than true atomicity requirements.

In the call path that I am trying to fix, the caller uses GFP_NOWAIT mask.
The caller is holding a spinlock (request_queue->queue_lock) so we can't afford
to sleep.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
