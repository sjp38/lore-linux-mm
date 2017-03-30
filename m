Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 31AD82806DF
	for <linux-mm@kvack.org>; Thu, 30 Mar 2017 10:47:22 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id a72so47382639pge.10
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 07:47:22 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0137.outbound.protection.outlook.com. [104.47.0.137])
        by mx.google.com with ESMTPS id q9si2345870plk.300.2017.03.30.07.47.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 30 Mar 2017 07:47:21 -0700 (PDT)
Subject: Re: [PATCH 1/4] mm/vmalloc: allow to call vfree() in atomic context
References: <20170330102719.13119-1-aryabinin@virtuozzo.com>
 <2cfc601e-3093-143e-b93d-402f330a748a@vmware.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <a28cc48d-3d6f-b4dd-10c2-a75d2e83ef14@virtuozzo.com>
Date: Thu, 30 Mar 2017 17:48:39 +0300
MIME-Version: 1.0
In-Reply-To: <2cfc601e-3093-143e-b93d-402f330a748a@vmware.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Hellstrom <thellstrom@vmware.com>, akpm@linux-foundation.org
Cc: penguin-kernel@I-love.SAKURA.ne.jp, linux-kernel@vger.kernel.org, mhocko@kernel.org, linux-mm@kvack.org, hpa@zytor.com, chris@chris-wilson.co.uk, hch@lst.de, mingo@elte.hu, jszhang@marvell.com, joelaf@google.com, joaodias@google.com, willy@infradead.org, tglx@linutronix.de, stable@vger.kernel.org

On 03/30/2017 03:00 PM, Thomas Hellstrom wrote:

>>  
>>  	if (unlikely(nr_lazy > lazy_max_pages()))
>> -		try_purge_vmap_area_lazy();
> 
> Perhaps a slight optimization would be to schedule work iff
> !mutex_locked(&vmap_purge_lock) below?
> 

Makes sense, we don't need to spawn workers if we already purging.



From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: mm/vmalloc: allow to call vfree() in atomic context fix

Don't spawn worker if we already purging.

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
---
 mm/vmalloc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index ea1b4ab..88168b8 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -737,7 +737,8 @@ static void free_vmap_area_noflush(struct vmap_area *va)
 	/* After this point, we may free va at any time */
 	llist_add(&va->purge_list, &vmap_purge_list);
 
-	if (unlikely(nr_lazy > lazy_max_pages()))
+	if (unlikely(nr_lazy > lazy_max_pages()) &&
+	    !mutex_is_locked(&vmap_purge_lock))
 		schedule_work(&purge_vmap_work);
 }
 
-- 
2.10.2


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
