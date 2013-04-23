Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 69E5B6B0002
	for <linux-mm@kvack.org>; Tue, 23 Apr 2013 19:47:54 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 629413EE0C0
	for <linux-mm@kvack.org>; Wed, 24 Apr 2013 08:47:52 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4CDFD45DEBE
	for <linux-mm@kvack.org>; Wed, 24 Apr 2013 08:47:52 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 236B445DEBA
	for <linux-mm@kvack.org>; Wed, 24 Apr 2013 08:47:52 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 113031DB8044
	for <linux-mm@kvack.org>; Wed, 24 Apr 2013 08:47:52 +0900 (JST)
Received: from g01jpexchkw36.g01.fujitsu.local (g01jpexchkw36.g01.fujitsu.local [10.0.193.54])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id AAAC71DB803C
	for <linux-mm@kvack.org>; Wed, 24 Apr 2013 08:47:51 +0900 (JST)
Message-ID: <51771D8B.9000005@jp.fujitsu.com>
Date: Wed, 24 Apr 2013 08:47:23 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [Bug fix PATCH v5] Reusing a resource structure allocated by
 bootmem
References: <5175E5E8.3010003@jp.fujitsu.com> <1366751135.6660.3.camel@misato.fc.hp.com>
In-Reply-To: <1366751135.6660.3.camel@misato.fc.hp.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: hannes@cmpxchg.org, akpm@linux-foundation.org, linuxram@us.ibm.com, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

2013/04/24 6:05, Toshi Kani wrote:
> On Tue, 2013-04-23 at 10:37 +0900, Yasuaki Ishimatsu wrote:
>   :
>> The reason why the messages are shown is to release a resource structure,
>> allocated by bootmem, by kfree(). So when we release a resource structure,
>> we should check whether it is allocated by bootmem or not.
>>
>> But even if we know a resource structure is allocated by bootmem, we cannot
>> release it since SLxB cannot treat it. So for reusing a resource structure,
>> this patch remembers it by using bootmem_resource as follows:
>>
>> When releasing a resource structure by free_resource(), free_resource() checks
>> whether the resource structure is allocated by bootmem or not. If it is
>> allocated by bootmem, free_resource() adds it to bootmem_resource. If it is
>> not allocated by bootmem, free_resource() release it by kfree().
>>
>> And when getting a new resource structure by get_resource(), get_resource()
>> checks whether bootmem_resource has released resource structures or not. If
>> there is a released resource structure, get_resource() returns it. If there is
>> not a releaed resource structure, get_resource() returns new resource structure
>> allocated by kzalloc().
>> ---
>> v5:
>> Define bootmem_resource_free as static and poiner for saving memory
>> Fix slab check in free_resource()
>> Move memset outside of spin lock in get_resource()
>
> Please add your "Signed-off-by".  Otherwise the changes look good.
>
> Reviewed-by: Toshi Kani <toshi.kani@hp.com>

Thank you for your review.
I'll resend a patch with my "Signed-off-by" and your "Reviewed-by".

Thanks,
Yasuaki Ishimatsu

>
> Thanks,
> -Toshi
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
