Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 739B36B0038
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 15:27:10 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id 68so40349433itg.0
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 12:27:10 -0800 (PST)
Received: from mail-it0-x22d.google.com (mail-it0-x22d.google.com. [2607:f8b0:4001:c0b::22d])
        by mx.google.com with ESMTPS id l69si7202319iod.80.2017.02.27.12.27.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Feb 2017 12:27:09 -0800 (PST)
Received: by mail-it0-x22d.google.com with SMTP id h10so65543342ith.1
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 12:27:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170227195126.GC8707@htj.duckdns.org>
References: <201702260805.zhem8KFI%fengguang.wu@intel.com> <20170226043829.14270-1-tahsin@google.com>
 <20170227095258.GG14029@dhcp22.suse.cz> <CAAeU0aMaGa63Nj=JvZKKy82FftAT9dF56=gZsufDvrkqDSGUrw@mail.gmail.com>
 <20170227195126.GC8707@htj.duckdns.org>
From: Tahsin Erdogan <tahsin@google.com>
Date: Mon, 27 Feb 2017 12:27:08 -0800
Message-ID: <CAAeU0aORY=N0e0gMKu-CBAEF=HLuHUNV6KWy27th1rwuPMcTMg@mail.gmail.com>
Subject: Re: [PATCH v2 3/3] percpu: improve allocation success rate for
 non-GFP_KERNEL callers
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Michal Hocko <mhocko@kernel.org>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Chris Wilson <chris@chris-wilson.co.uk>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Roman Pen <r.peniaev@gmail.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, zijun_hu <zijun_hu@htc.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Tejun,

On Mon, Feb 27, 2017 at 11:51 AM, Tejun Heo <tj@kernel.org> wrote:
>> __vmalloc+0x45/0x50
>> pcpu_mem_zalloc+0x50/0x80
>> pcpu_populate_chunk+0x3b/0x380
>> pcpu_alloc+0x588/0x6e0
>> __alloc_percpu_gfp+0xd/0x10
>> __percpu_counter_init+0x55/0xc0
>> blkg_alloc+0x76/0x230
>> blkg_create+0x489/0x670
>> blkg_lookup_create+0x9a/0x230
>> generic_make_request_checks+0x7dd/0x890
>> generic_make_request+0x1f/0x180
>> submit_bio+0x61/0x120
>
> As indicated by GFP_NOWAIT | __GFP_NOWARN, it's okay to fail there.
> It's not okay to fail consistently for a long time but it's not a big
> issue to fail occassionally even if somewhat bunched up.  The only bad
> side effect of that is temporary misaccounting of some IOs, which
> shouldn't be noticeable outside of pathological cases.  If you're
> actually seeing adverse effects of this, I'd love to learn about it.

A better example is the call path below:

pcpu_alloc+0x68f/0x710
__alloc_percpu_gfp+0xd/0x10
__percpu_counter_init+0x55/0xc0
cfq_pd_alloc+0x3b2/0x4e0
blkg_alloc+0x187/0x230
blkg_create+0x489/0x670
blkg_lookup_create+0x9a/0x230
blkg_conf_prep+0x1fb/0x240
__cfqg_set_weight_device.isra.105+0x5c/0x180
cfq_set_weight_on_dfl+0x69/0xc0
cgroup_file_write+0x39/0x1c0
kernfs_fop_write+0x13f/0x1d0
__vfs_write+0x23/0x120
vfs_write+0xc2/0x1f0
SyS_write+0x44/0xb0
entry_SYSCALL_64_fastpath+0x18/0xad

A failure in this call path gives grief to tools which are trying to
configure io
weights. We see occasional failures happen here shortly after reboots even
when system is not under any memory pressure. Machines with a lot of cpus
are obviously more vulnerable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
