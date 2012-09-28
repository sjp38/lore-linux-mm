Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 03CF26B005D
	for <linux-mm@kvack.org>; Thu, 27 Sep 2012 23:44:08 -0400 (EDT)
Message-ID: <50651CF5.5030903@oracle.com>
Date: Fri, 28 Sep 2012 11:43:49 +0800
From: Zhenzhong Duan <zhenzhong.duan@oracle.com>
Reply-To: zhenzhong.duan@oracle.com
MIME-Version: 1.0
Subject: Re: [PATCH -v2] mm: frontswap: fix a wrong if condition in frontswap_shrink
References: <505C27FE.5080205@oracle.com> <1348745730.1512.19.camel@x61.thuisdomein>
In-Reply-To: <1348745730.1512.19.camel@x61.thuisdomein>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Bolle <pebolle@tiscali.nl>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, levinsasha928@gmail.com, Feng Jin <joe.jin@oracle.com>, dan.carpenter@oracle.com



On 2012-09-27 19:35, Paul Bolle wrote:
> On Fri, 2012-09-21 at 16:40 +0800, Zhenzhong Duan wrote:
>>
>> @@ -275,7 +280,7 @@ static int __frontswap_shrink(unsigned long target_pages,
>>   	if (total_pages<= target_pages) {
>>   		/* Nothing to do */
>>   		*pages_to_unuse = 0;
>
> I think setting pages_to_unuse to zero here is not needed. It is
> initiated to zero in frontswap_shrink() and hasn't been touched since.
> See my patch at https://lkml.org/lkml/2012/9/27/250.
Yes, it's unneeded. But I didn't see warning as you said in above link 
when run 'make V=1 mm/frontswap.o'.
>> -		return 0;
>> +		return 1;
>>   	}
>>   	total_pages_to_unuse = total_pages - target_pages;
>>   	return __frontswap_unuse_pages(total_pages_to_unuse, pages_to_unuse, type);
>> @@ -302,7 +307,7 @@ void frontswap_shrink(unsigned long target_pages)
>>   	spin_lock(&swap_lock);
>>   	ret = __frontswap_shrink(target_pages,&pages_to_unuse,&type);
>>   	spin_unlock(&swap_lock);
>> -	if (ret == 0&&  pages_to_unuse)
>> +	if (ret == 0)
>>   		try_to_unuse(type, true, pages_to_unuse);
>>   	return;
>>   }
>
> Are you sure pages_to_unuse won't be zero here? I've stared quite a bit
> at __frontswap_unuse_pages() and it's not obvious pages_to_unuse (there
> also called unused) will never be zero when that function returns zero.
pages_to_unuse==0 means all pages need to be unused.

zduan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
