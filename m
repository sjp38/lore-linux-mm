Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id EC6036B0031
	for <linux-mm@kvack.org>; Mon, 16 Sep 2013 19:41:10 -0400 (EDT)
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 17 Sep 2013 09:41:08 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id EDEE63578052
	for <linux-mm@kvack.org>; Tue, 17 Sep 2013 09:41:05 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8GNORLi5767502
	for <linux-mm@kvack.org>; Tue, 17 Sep 2013 09:24:27 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r8GNf5WV002445
	for <linux-mm@kvack.org>; Tue, 17 Sep 2013 09:41:05 +1000
Date: Tue, 17 Sep 2013 07:41:04 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [RESEND PATCH v5 2/4] mm/vmalloc: revert "mm/vmalloc.c: emit the
 failure message before return"
Message-ID: <20130916234104.GD3241@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1379202342-23140-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1379202342-23140-2-git-send-email-liwanp@linux.vnet.ibm.com>
 <523766E1.1020303@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <523766E1.1020303@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: akpm@linux-foundation.org, iamjoonsoo.kim@lge.com, rientjes@google.com, zhangyanfei@cn.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi KOSAKI,
On Mon, Sep 16, 2013 at 04:15:29PM -0400, KOSAKI Motohiro wrote:
>On 9/14/2013 7:45 PM, Wanpeng Li wrote:
>> Changelog:
>>  *v2 -> v3: revert commit 46c001a2 directly
>> 
>> Don't warning twice in __vmalloc_area_node and __vmalloc_node_range if
>> __vmalloc_area_node allocation failure. This patch revert commit 46c001a2
>> (mm/vmalloc.c: emit the failure message before return).
>> 
>> Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
>> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>> ---
>>  mm/vmalloc.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>> 
>> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
>> index d78d117..e3ec8b4 100644
>> --- a/mm/vmalloc.c
>> +++ b/mm/vmalloc.c
>> @@ -1635,7 +1635,7 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
>>  
>>  	addr = __vmalloc_area_node(area, gfp_mask, prot, node, caller);
>>  	if (!addr)
>> -		goto fail;
>> +		return NULL;

The goto fail is introduced by commit (mm/vmalloc.c: emit the failure message 
before return), and the commit author ignore there has already have warning in
__vmalloc_area_node. 

http://marc.info/?l=linux-mm&m=137818671125209&w=2

>
>This is not right fix. Now we have following call stack.
>
> __vmalloc_node
>	__vmalloc_node_range
>		__vmalloc_node
>
>Even if we remove a warning of __vmalloc_node_range, we still be able to see double warning
>because we call __vmalloc_node recursively.

Different size allocation failure in your example actually.

>
>I haven't catch your point why twice warning is unacceptable though.
>
>

I think I have already answer your question. 

Regards,
Wanpeng Li 

>
>
>
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
