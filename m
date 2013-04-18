Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id A24996B003D
	for <linux-mm@kvack.org>; Thu, 18 Apr 2013 19:49:27 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id C31DC3EE0B6
	for <linux-mm@kvack.org>; Fri, 19 Apr 2013 08:49:25 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A81ED45DE55
	for <linux-mm@kvack.org>; Fri, 19 Apr 2013 08:49:25 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8DC8345DE50
	for <linux-mm@kvack.org>; Fri, 19 Apr 2013 08:49:25 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7DFEC1DB803E
	for <linux-mm@kvack.org>; Fri, 19 Apr 2013 08:49:25 +0900 (JST)
Received: from g01jpexchyt35.g01.fujitsu.local (g01jpexchyt35.g01.fujitsu.local [10.128.193.50])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 318F71DB8037
	for <linux-mm@kvack.org>; Fri, 19 Apr 2013 08:49:25 +0900 (JST)
Message-ID: <5170853B.2040807@jp.fujitsu.com>
Date: Fri, 19 Apr 2013 08:43:55 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [Bug fix PATCH v4] Reusing a resource structure allocated by
 bootmem
References: <516FB07C.9010603@jp.fujitsu.com>  <1366295000.3824.47.camel@misato.fc.hp.com>  <517082B9.7050708@jp.fujitsu.com> <1366327735.3824.50.camel@misato.fc.hp.com>
In-Reply-To: <1366327735.3824.50.camel@misato.fc.hp.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: akpm@linux-foundation.org, linuxram@us.ibm.com, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

2013/04/19 8:28, Toshi Kani wrote:
> On Fri, 2013-04-19 at 08:33 +0900, Yasuaki Ishimatsu wrote:
>   :
>>>
>>>> +static struct resource *get_resource(gfp_t flags)
>>>> +{
>>>> +	struct resource *res = NULL;
>>>> +
>>>> +	spin_lock(&bootmem_resource_lock);
>>>> +	if (bootmem_resource.sibling) {
>>>> +		res = bootmem_resource.sibling;
>>>> +		bootmem_resource.sibling = res->sibling;
>>>> +		memset(res, 0, sizeof(struct resource));
>>>> +	}
>>>> +	spin_unlock(&bootmem_resource_lock);
>>>
>>
>>> I prefer to keep memset() outside of the spin lock.
>>>
>>> spin_lock(&bootmem_resource_lock);
>>> if (..) {
>>> 	:
>>> 	spin_unlock(&bootmem_resource_lock);
>>> 	memset(res, 0, sizeof(struct resource));
>>> } else {
>>> 	spin_unlock(&bootmem_resource_lock);
>>> 	res = kzalloc(sizeof(struct resource), flags);
>>> }
>>
>> Hmm. It is a little ugly. How about it?
>>
>> spin_lock(&bootmem_resource_lock);
>> if (bootmem_resource.sibling) {
>> 	res = bootmem_resource.sibling;
>> 	bootmem_resource.sibling = res->sibling;
>> }
>> spin_unlock(&bootmem_resource_lock);
>>
>> if (res)
>> 	memset(res, 0, sizeof(struct resource));
>> else	
>> 	res = kzalloc(sizeof(struct resource), flags);
>

> Sounds good to me.

Great. I'll update it.

Thanks,
Yasuaki Ishimatsu

>
> Thanks,
> -Toshi
>
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
