Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 651356B0032
	for <linux-mm@kvack.org>; Tue, 17 Sep 2013 01:39:35 -0400 (EDT)
Received: by mail-ea0-f174.google.com with SMTP id z15so2465451ead.33
        for <linux-mm@kvack.org>; Mon, 16 Sep 2013 22:39:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5237971b.4c19310a.2b36.7d41SMTPIN_ADDED_BROKEN@mx.google.com>
References: <1379202342-23140-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1379202342-23140-2-git-send-email-liwanp@linux.vnet.ibm.com>
 <523766E1.1020303@jp.fujitsu.com> <5237971b.4c19310a.2b36.7d41SMTPIN_ADDED_BROKEN@mx.google.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Tue, 17 Sep 2013 01:39:13 -0400
Message-ID: <CAHGf_=pNwf0CO_sTcLxTfTYUfqUrbr8mtcXDgLUC9_wa7wR_5Q@mail.gmail.com>
Subject: Re: [RESEND PATCH v5 2/4] mm/vmalloc: revert "mm/vmalloc.c: emit the
 failure message before return"
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, iamjoonsoo.kim@lge.com, David Rientjes <rientjes@google.com>, zhangyanfei@cn.fujitsu.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Sep 16, 2013 at 7:41 PM, Wanpeng Li <liwanp@linux.vnet.ibm.com> wrote:
> Hi KOSAKI,
> On Mon, Sep 16, 2013 at 04:15:29PM -0400, KOSAKI Motohiro wrote:
>>On 9/14/2013 7:45 PM, Wanpeng Li wrote:
>>> Changelog:
>>>  *v2 -> v3: revert commit 46c001a2 directly
>>>
>>> Don't warning twice in __vmalloc_area_node and __vmalloc_node_range if
>>> __vmalloc_area_node allocation failure. This patch revert commit 46c001a2
>>> (mm/vmalloc.c: emit the failure message before return).
>>>
>>> Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
>>> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>>> ---
>>>  mm/vmalloc.c | 2 +-
>>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>>
>>> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
>>> index d78d117..e3ec8b4 100644
>>> --- a/mm/vmalloc.c
>>> +++ b/mm/vmalloc.c
>>> @@ -1635,7 +1635,7 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
>>>
>>>      addr = __vmalloc_area_node(area, gfp_mask, prot, node, caller);
>>>      if (!addr)
>>> -            goto fail;
>>> +            return NULL;
>
> The goto fail is introduced by commit (mm/vmalloc.c: emit the failure message
> before return), and the commit author ignore there has already have warning in
> __vmalloc_area_node.
>
> http://marc.info/?l=linux-mm&m=137818671125209&w=2

But, module_alloc() directly calls __vmalloc_node_range(). Your fix
makes another regression.


>>This is not right fix. Now we have following call stack.
>>
>> __vmalloc_node
>>       __vmalloc_node_range
>>               __vmalloc_node
>>
>>Even if we remove a warning of __vmalloc_node_range, we still be able to see double warning
>>because we call __vmalloc_node recursively.
>
> Different size allocation failure in your example actually.

But, when we can not allocate small size memory, almost always we
can't allocate large size too.

You need some refactoring and make right fix.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
