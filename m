Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7A64A6B0253
	for <linux-mm@kvack.org>; Sat, 15 Oct 2016 12:55:30 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 128so144710031pfz.1
        for <linux-mm@kvack.org>; Sat, 15 Oct 2016 09:55:30 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id v27si12405469pfj.204.2016.10.15.09.55.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Oct 2016 09:55:29 -0700 (PDT)
Date: Sat, 15 Oct 2016 09:55:21 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH vmalloc] reduce purge_lock range and hold time of
Message-ID: <20161015165521.GB31568@infradead.org>
References: <1476540769-31893-1-git-send-email-zhouxianrong@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1476540769-31893-1-git-send-email-zhouxianrong@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhouxianrong@huawei.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, rientjes@google.com, hannes@cmpxchg.org, chris@chris-wilson.co.uk, vdavydov.dev@gmail.com, mgorman@techsingularity.net, joe@perches.com, shawn.lin@rock-chips.com, iamjoonsoo.kim@lge.com, kuleshovmail@gmail.com, zhouxiyu@huawei.com, zhangshiming5@huawei.com, won.ho.park@huawei.com, tuxiaobing@huawei.com

On Sat, Oct 15, 2016 at 10:12:48PM +0800, zhouxianrong@huawei.com wrote:
> From: z00281421 <z00281421@notesmail.huawei.com>
> 
> i think no need to place __free_vmap_area loop in purge_lock;
> _free_vmap_area could be non-atomic operations with flushing tlb
> but must be done after flush tlb. and the whole__free_vmap_area loops
> also could be non-atomic operations. if so we could improve realtime
> because the loop times sometimes is larg and spend a few time.

Right, see the previous patch in reply to Joel that drops purge_lock
entirely.

Instead of your open coded batch counter you probably want to add
a cond_resched_lock after the call to __free_vmap_area.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
