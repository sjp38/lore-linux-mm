Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 8BB6F6B0035
	for <linux-mm@kvack.org>; Tue, 15 Jul 2014 05:50:13 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id kx10so5616894pab.6
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 02:50:13 -0700 (PDT)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id os6si11298645pbb.212.2014.07.15.02.50.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Tue, 15 Jul 2014 02:50:12 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N8Q00EQ6YUSQK90@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 15 Jul 2014 10:40:04 +0100 (BST)
Message-id: <53C4F5A9.6030202@samsung.com>
Date: Tue, 15 Jul 2014 13:34:33 +0400
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [RFC/PATCH RESEND -next 20/21] fs: dcache: manually unpoison dname
 after allocation to shut up kasan's reports
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1404905415-9046-21-git-send-email-a.ryabinin@samsung.com>
 <20140715061219.GK11317@js1304-P5Q-DELUXE>
In-reply-to: <20140715061219.GK11317@js1304-P5Q-DELUXE>
Content-type: text/plain; charset=ISO-8859-1
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Alexey Preobrazhensky <preobr@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Michal Marek <mmarek@suse.cz>, Russell King <linux@arm.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kbuild@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-mm@kvack.org

On 07/15/14 10:12, Joonsoo Kim wrote:
> On Wed, Jul 09, 2014 at 03:30:14PM +0400, Andrey Ryabinin wrote:
>> We need to manually unpoison rounded up allocation size for dname
>> to avoid kasan's reports in __d_lookup_rcu.
>> __d_lookup_rcu may validly read a little beyound allocated size.
> 
> If it read a little beyond allocated size, IMHO, it is better to
> allocate correct size.
> 
> kmalloc(name->len + 1, GFP_KERNEL); -->
> kmalloc(roundup(name->len + 1, sizeof(unsigned long ), GFP_KERNEL);
> 
> Isn't it?
> 

It's not needed here because kmalloc always roundup allocation size.

This out of bound access happens in dentry_string_cmp() if CONFIG_DCACHE_WORD_ACCESS=y.
dentry_string_cmp() relays on fact that kmalloc always round up allocation size,
in other words it's by design.

That was discussed some time ago here - https://lkml.org/lkml/2013/10/3/493.
Since filesystem's maintainer don't want to add needless round up here, I'm not going to do it.

I think this patch needs only more detailed description why we not simply allocate more.
Also I think it would be better to rename unpoisoin_shadow to something like kasan_mark_allocated().


> Thanks.
> 
>>
>> Reported-by: Dmitry Vyukov <dvyukov@google.com>
>> Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
>> ---
>>  fs/dcache.c | 3 +++
>>  1 file changed, 3 insertions(+)
>>
>> diff --git a/fs/dcache.c b/fs/dcache.c
>> index b7e8b20..dff64f2 100644
>> --- a/fs/dcache.c
>> +++ b/fs/dcache.c
>> @@ -38,6 +38,7 @@
>>  #include <linux/prefetch.h>
>>  #include <linux/ratelimit.h>
>>  #include <linux/list_lru.h>
>> +#include <linux/kasan.h>
>>  #include "internal.h"
>>  #include "mount.h"
>>  
>> @@ -1412,6 +1413,8 @@ struct dentry *__d_alloc(struct super_block *sb, const struct qstr *name)
>>  			kmem_cache_free(dentry_cache, dentry); 
>>  			return NULL;
>>  		}
>> +		unpoison_shadow(dname,
>> +				roundup(name->len + 1, sizeof(unsigned long)));
>>  	} else  {
>>  		dname = dentry->d_iname;
>>  	}	
>> -- 
>> 1.8.5.5
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
