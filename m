Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 134C66B0389
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 15:45:30 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id u188so150756537qkc.1
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 12:45:30 -0800 (PST)
Received: from mail-yw0-x243.google.com (mail-yw0-x243.google.com. [2607:f8b0:4002:c05::243])
        by mx.google.com with ESMTPS id e16si12770166qkj.0.2017.02.27.12.45.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Feb 2017 12:45:29 -0800 (PST)
Received: by mail-yw0-x243.google.com with SMTP id 203so7044929ywz.1
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 12:45:29 -0800 (PST)
Date: Mon, 27 Feb 2017 15:45:27 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2 3/3] percpu: improve allocation success rate for
 non-GFP_KERNEL callers
Message-ID: <20170227204527.GG8707@htj.duckdns.org>
References: <201702260805.zhem8KFI%fengguang.wu@intel.com>
 <20170226043829.14270-1-tahsin@google.com>
 <20170227095258.GG14029@dhcp22.suse.cz>
 <CAAeU0aMaGa63Nj=JvZKKy82FftAT9dF56=gZsufDvrkqDSGUrw@mail.gmail.com>
 <20170227195126.GC8707@htj.duckdns.org>
 <CAAeU0aORY=N0e0gMKu-CBAEF=HLuHUNV6KWy27th1rwuPMcTMg@mail.gmail.com>
 <20170227202906.GF8707@htj.duckdns.org>
 <CAAeU0aMnz-nsXGy44mwBfzwfFJtVWNRQiAE0UAonBQA3iDJBqg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAeU0aMnz-nsXGy44mwBfzwfFJtVWNRQiAE0UAonBQA3iDJBqg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tahsin Erdogan <tahsin@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Chris Wilson <chris@chris-wilson.co.uk>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Roman Pen <r.peniaev@gmail.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, zijun_hu <zijun_hu@htc.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello, Tahsin.

On Mon, Feb 27, 2017 at 12:37:59PM -0800, Tahsin Erdogan wrote:
> > Ah, absolutely, that's a stupid failure but we should be able to fix
> > that by making the blkg functions take gfp mask and allocate
> > accordingly, right?  It'll probably take preallocation tricks because
> > of locking but should be doable.
> 
> My initial goal was to allow calls to vmalloc(), but I now see the
> challenges in that
> approach.

I'd love to see that working too but this is a different issue.  Even
GFP_ATOMIC can fail under pressure and it's kinda wrong to depend on
that for userspace interactions.

> Doing preallocations would probably work but not sure if that can be
> done without
> complicating code too much. Could you describe what you have in mind?

So, blkg_create() already takes @new_blkg argument which is the
preallocated blkg and used during q init.  Wouldn't it work to make
blkg_lookup_create() take @new_blkg too and pass it down to
blkg_create() (and also free it if it doesn't get used)?  Then,
blkg_conf_prep() can always (or after a failure with -ENOMEM) allocate
a new blkg before calling into blkg_lookup_create().  I don't think
it'll complicate the code path that much.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
