Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6B4CA6B0388
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 14:32:52 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id r141so95575631ita.6
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 11:32:52 -0800 (PST)
Received: from mail-it0-x22b.google.com (mail-it0-x22b.google.com. [2607:f8b0:4001:c0b::22b])
        by mx.google.com with ESMTPS id x67si10969395itg.20.2017.02.27.11.32.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Feb 2017 11:32:51 -0800 (PST)
Received: by mail-it0-x22b.google.com with SMTP id d9so21314357itc.0
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 11:32:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170227171404.GP26504@dhcp22.suse.cz>
References: <201702260805.zhem8KFI%fengguang.wu@intel.com> <20170226043829.14270-1-tahsin@google.com>
 <20170227095258.GG14029@dhcp22.suse.cz> <CAAeU0aMaGa63Nj=JvZKKy82FftAT9dF56=gZsufDvrkqDSGUrw@mail.gmail.com>
 <20170227152516.GJ26504@dhcp22.suse.cz> <CAAeU0aOCGrwmYGPWgA_7Y=2O2RXG_Ux14h4FrogpKPAKvVNaXg@mail.gmail.com>
 <20170227170753.GO26504@dhcp22.suse.cz> <20170227171404.GP26504@dhcp22.suse.cz>
From: Tahsin Erdogan <tahsin@google.com>
Date: Mon, 27 Feb 2017 11:32:50 -0800
Message-ID: <CAAeU0aNVMf6KD7oHNOjzZNqHwBDBpkpx1mtT1O4HipUv1CeLDQ@mail.gmail.com>
Subject: Re: [PATCH v2 3/3] percpu: improve allocation success rate for
 non-GFP_KERNEL callers
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Chris Wilson <chris@chris-wilson.co.uk>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Roman Pen <r.peniaev@gmail.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, zijun_hu <zijun_hu@htc.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

>> >
>> > Yes, this prevents adding more pcpu chunks and so cause "atomic" allocations
>> > to fail more easily.
>>
>> Then I fail to see what is the problem you are trying to fix.
>
> To be more specific. Could you describe what more can we do in the
> vmalloc layer for GFP_NOWAIT allocations? They certainly cannot sleep
> and cannot perform the reclaim so you have to rely on the background
> work.

The main problem that I am trying to fix is in percpu.c code. It
currently doesn't
even attempt to call vmalloc() for GFP_NOWAIT case. It solely relies on the
background allocator to replenish the reserves. I would like percpu.c to call
__vmalloc(GFP_NOWAIT) inline and see whether that succeeds. If that fails, it is
fair to fail the call.

For this to work, __vmalloc() should be ready to serve a caller that
is holding a
spinlock. The might_sleep() in alloc_vmap_area() basically prevents us calling
vmalloc in this context.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
