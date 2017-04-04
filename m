Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5E8A66B03A1
	for <linux-mm@kvack.org>; Tue,  4 Apr 2017 05:49:23 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id s205so49922169oif.20
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 02:49:23 -0700 (PDT)
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (mail-by2nam03on0067.outbound.protection.outlook.com. [104.47.42.67])
        by mx.google.com with ESMTPS id q40si7730286otb.236.2017.04.04.02.49.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 04 Apr 2017 02:49:22 -0700 (PDT)
Subject: Re: [PATCH 1/4] mm/vmalloc: allow to call vfree() in atomic context
References: <20170330102719.13119-1-aryabinin@virtuozzo.com>
 <2cfc601e-3093-143e-b93d-402f330a748a@vmware.com>
 <a28cc48d-3d6f-b4dd-10c2-a75d2e83ef14@virtuozzo.com>
 <20170404094148.GJ15132@dhcp22.suse.cz>
From: Thomas Hellstrom <thellstrom@vmware.com>
Message-ID: <2b95af00-e4e6-4df7-7cd5-30b4f6980b09@vmware.com>
Date: Tue, 4 Apr 2017 11:49:03 +0200
MIME-Version: 1.0
In-Reply-To: <20170404094148.GJ15132@dhcp22.suse.cz>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: akpm@linux-foundation.org, penguin-kernel@I-love.SAKURA.ne.jp, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hpa@zytor.com, chris@chris-wilson.co.uk, hch@lst.de, mingo@elte.hu, jszhang@marvell.com, joelaf@google.com, joaodias@google.com, willy@infradead.org, tglx@linutronix.de, stable@vger.kernel.org

On 04/04/2017 11:41 AM, Michal Hocko wrote:
> On Thu 30-03-17 17:48:39, Andrey Ryabinin wrote:
>> From: Andrey Ryabinin <aryabinin@virtuozzo.com>
>> Subject: mm/vmalloc: allow to call vfree() in atomic context fix
>>
>> Don't spawn worker if we already purging.
>>
>> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> I would rather put this into a separate patch. Ideally with some numners
> as this is an optimization...

Actually, this just mimics what the code was doing before, as it only
invoked
__purge_vmap_area_lazy() if the trylock succeeded.

/Thomas




>
>> ---
>>  mm/vmalloc.c | 3 ++-
>>  1 file changed, 2 insertions(+), 1 deletion(-)
>>
>> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
>> index ea1b4ab..88168b8 100644
>> --- a/mm/vmalloc.c
>> +++ b/mm/vmalloc.c
>> @@ -737,7 +737,8 @@ static void free_vmap_area_noflush(struct vmap_area *va)
>>  	/* After this point, we may free va at any time */
>>  	llist_add(&va->purge_list, &vmap_purge_list);
>>  
>> -	if (unlikely(nr_lazy > lazy_max_pages()))
>> +	if (unlikely(nr_lazy > lazy_max_pages()) &&
>> +	    !mutex_is_locked(&vmap_purge_lock))
>>  		schedule_work(&purge_vmap_work);
>>  }
>>  
>> -- 
>> 2.10.2
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
