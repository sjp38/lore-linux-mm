Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id A94E36B0037
	for <linux-mm@kvack.org>; Tue, 16 Apr 2013 20:14:43 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 8D4313EE081
	for <linux-mm@kvack.org>; Wed, 17 Apr 2013 09:14:41 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6D2D345DEC5
	for <linux-mm@kvack.org>; Wed, 17 Apr 2013 09:14:41 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5109E45DEB6
	for <linux-mm@kvack.org>; Wed, 17 Apr 2013 09:14:41 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 44A8D1DB8041
	for <linux-mm@kvack.org>; Wed, 17 Apr 2013 09:14:41 +0900 (JST)
Received: from g01jpexchyt32.g01.fujitsu.local (g01jpexchyt32.g01.fujitsu.local [10.128.193.115])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E2E1AE08001
	for <linux-mm@kvack.org>; Wed, 17 Apr 2013 09:14:40 +0900 (JST)
Message-ID: <516DE958.1090200@jp.fujitsu.com>
Date: Wed, 17 Apr 2013 09:14:16 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [Bug fix PATCH v2] Reusing a resource structure allocated by
 bootmem
References: <516CA4F1.9060603@jp.fujitsu.com> <1366124458.3824.30.camel@misato.fc.hp.com>
In-Reply-To: <1366124458.3824.30.camel@misato.fc.hp.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rientjes@google.com, linuxram@us.ibm.com

2013/04/17 0:00, Toshi Kani wrote:
> On Tue, 2013-04-16 at 10:10 +0900, Yasuaki Ishimatsu wrote:
>> When hot removing memory presented at boot time, following messages are shown:
>
>   :
>
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
>>
>> Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>> ---
>> v2:
>> Based on following Toshi's works:
>>    Support memory hot-delete to boot memory
>>      https://lkml.org/lkml/2013/4/10/469
>>    resource: Update config option of release_mem_region_adjustable()
>>      https://lkml.org/lkml/2013/4/11/694
>> Added a NULL check into free_resource()
>> Remove __free_resource()
>
> Thanks for the update.  Looks good.  Can you also address Rui's comment?

Thank you for your review.
Of course I'll update Rui's comment.

Thanks,
Yasuaki Ishimatsu

>
> -Toshi
>
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
