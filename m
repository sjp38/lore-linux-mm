Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 79E036B0038
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 06:05:52 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id i5so463716otf.2
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 03:05:52 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id w12si3094972otg.27.2017.12.20.03.05.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 20 Dec 2017 03:05:51 -0800 (PST)
Subject: Re: [PATCH v2] mm/zsmalloc: simplify shrinker init/destroy
References: <20171219102213.GA435@jagdpanzerIV>
 <1513680552-9798-1-git-send-email-akaraliou.dev@gmail.com>
 <20171219151341.GC15210@dhcp22.suse.cz>
 <20171219152536.GA591@tigerII.localdomain>
 <20171219155815.GC2787@dhcp22.suse.cz> <20171220071500.GA11774@jagdpanzerIV>
 <04faff62-0944-3c7d-15b0-9dc60054a830@gmail.com>
 <20171220083403.GC11774@jagdpanzerIV> <20171220090828.GB4831@dhcp22.suse.cz>
 <20171220091653.GE11774@jagdpanzerIV> <20171220092513.GF4831@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <ad885766-69b8-940a-c69a-4c23779eb228@I-love.SAKURA.ne.jp>
Date: Wed, 20 Dec 2017 20:05:35 +0900
MIME-Version: 1.0
In-Reply-To: <20171220092513.GF4831@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: A K <akaraliou.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, minchan@kernel.org, ngupta@vflare.org, linux-mm@kvack.org

On 2017/12/20 18:25, Michal Hocko wrote:
> On Wed 20-12-17 18:16:53, Sergey Senozhatsky wrote:
>> On (12/20/17 10:08), Michal Hocko wrote:
>> [..]
>>>> let's keep void zs_register_shrinker() and just suppress the
>>>> register_shrinker() must_check warning.
>>>
>>> I would just hope we simply drop the must_check nonsense.
>>
>> agreed. given that unregister_shrinker() does not oops anymore,
>> enforcing that check does not make that much sense.
> 
> Well, the registration failure is a failure like any others. Ignoring
> the failure can have bad influence on the overal system behavior but
> that is no different from thousands of other functions. must_check is an
> overreaction here IMHO.
> 

I don't think that must_check is an overreaction.
As of linux-next-20171218, no patch is available for 10 locations.

drivers/staging/android/ion/ion_heap.c:306:     register_shrinker(&heap->shrinker);
drivers/staging/android/ashmem.c:857:   register_shrinker(&ashmem_shrinker);
drivers/gpu/drm/ttm/ttm_page_alloc_dma.c:1185:  register_shrinker(&manager->mm_shrink);
drivers/gpu/drm/ttm/ttm_page_alloc.c:484:       register_shrinker(&manager->mm_shrink);
drivers/gpu/drm/i915/i915_gem_shrinker.c:508:   WARN_ON(register_shrinker(&i915->mm.shrinker));
drivers/gpu/drm/msm/msm_gem_shrinker.c:154:     WARN_ON(register_shrinker(&priv->shrinker));
drivers/md/dm-bufio.c:1756:     register_shrinker(&c->shrinker);
drivers/android/binder_alloc.c:1012:    register_shrinker(&binder_shrinker);
arch/x86/kvm/mmu.c:5485:        register_shrinker(&mmu_shrinker);
fs/xfs/xfs_qm.c:698:    register_shrinker(&qinf->qi_shrinker);

We have out of tree modules. And as a troubleshooting staff at
a support center, I want to be able to identify the careless module.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
