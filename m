Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 267276B0389
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 15:38:01 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id w10so101598775iod.7
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 12:38:01 -0800 (PST)
Received: from mail-io0-x233.google.com (mail-io0-x233.google.com. [2607:f8b0:4001:c06::233])
        by mx.google.com with ESMTPS id b62si11162317ith.93.2017.02.27.12.38.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Feb 2017 12:38:00 -0800 (PST)
Received: by mail-io0-x233.google.com with SMTP id g18so39751151ioe.0
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 12:38:00 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170227202906.GF8707@htj.duckdns.org>
References: <201702260805.zhem8KFI%fengguang.wu@intel.com> <20170226043829.14270-1-tahsin@google.com>
 <20170227095258.GG14029@dhcp22.suse.cz> <CAAeU0aMaGa63Nj=JvZKKy82FftAT9dF56=gZsufDvrkqDSGUrw@mail.gmail.com>
 <20170227195126.GC8707@htj.duckdns.org> <CAAeU0aORY=N0e0gMKu-CBAEF=HLuHUNV6KWy27th1rwuPMcTMg@mail.gmail.com>
 <20170227202906.GF8707@htj.duckdns.org>
From: Tahsin Erdogan <tahsin@google.com>
Date: Mon, 27 Feb 2017 12:37:59 -0800
Message-ID: <CAAeU0aMnz-nsXGy44mwBfzwfFJtVWNRQiAE0UAonBQA3iDJBqg@mail.gmail.com>
Subject: Re: [PATCH v2 3/3] percpu: improve allocation success rate for
 non-GFP_KERNEL callers
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Michal Hocko <mhocko@kernel.org>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Chris Wilson <chris@chris-wilson.co.uk>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Roman Pen <r.peniaev@gmail.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, zijun_hu <zijun_hu@htc.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Feb 27, 2017 at 12:29 PM, Tejun Heo <tj@kernel.org> wrote:
> Hello,
>
> On Mon, Feb 27, 2017 at 12:27:08PM -0800, Tahsin Erdogan wrote:
>> A better example is the call path below:
>>
>> pcpu_alloc+0x68f/0x710
>> __alloc_percpu_gfp+0xd/0x10
>> __percpu_counter_init+0x55/0xc0
>> cfq_pd_alloc+0x3b2/0x4e0
>> blkg_alloc+0x187/0x230
>> blkg_create+0x489/0x670
>> blkg_lookup_create+0x9a/0x230
>> blkg_conf_prep+0x1fb/0x240
>> __cfqg_set_weight_device.isra.105+0x5c/0x180
>> cfq_set_weight_on_dfl+0x69/0xc0
>> cgroup_file_write+0x39/0x1c0
>> kernfs_fop_write+0x13f/0x1d0
>> __vfs_write+0x23/0x120
>> vfs_write+0xc2/0x1f0
>> SyS_write+0x44/0xb0
>> entry_SYSCALL_64_fastpath+0x18/0xad
>>
>> A failure in this call path gives grief to tools which are trying to
>> configure io
>> weights. We see occasional failures happen here shortly after reboots even
>> when system is not under any memory pressure. Machines with a lot of cpus
>> are obviously more vulnerable.
>
> Ah, absolutely, that's a stupid failure but we should be able to fix
> that by making the blkg functions take gfp mask and allocate
> accordingly, right?  It'll probably take preallocation tricks because
> of locking but should be doable.

My initial goal was to allow calls to vmalloc(), but I now see the
challenges in that
approach.

Doing preallocations would probably work but not sure if that can be
done without
complicating code too much. Could you describe what you have in mind?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
