From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [RESEND PATCH v5 2/4] mm/vmalloc: revert "mm/vmalloc.c: emit the
 failure message before return"
Date: Tue, 17 Sep 2013 14:28:25 +0800
Message-ID: <27339.1746254221$1379399324@news.gmane.org>
References: <1379202342-23140-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1379202342-23140-2-git-send-email-liwanp@linux.vnet.ibm.com>
 <523766E1.1020303@jp.fujitsu.com>
 <5237971b.4c19310a.2b36.7d41SMTPIN_ADDED_BROKEN@mx.google.com>
 <CAHGf_=pNwf0CO_sTcLxTfTYUfqUrbr8mtcXDgLUC9_wa7wR_5Q@mail.gmail.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1VLom4-0003PX-I9
	for glkm-linux-mm-2@m.gmane.org; Tue, 17 Sep 2013 08:28:36 +0200
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 7EE996B0032
	for <linux-mm@kvack.org>; Tue, 17 Sep 2013 02:28:34 -0400 (EDT)
Received: from /spool/local
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 17 Sep 2013 16:28:31 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id C218B2CE8059
	for <linux-mm@kvack.org>; Tue, 17 Sep 2013 16:28:28 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8H6Bw1Y5832982
	for <linux-mm@kvack.org>; Tue, 17 Sep 2013 16:11:58 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r8H6SRkw002283
	for <linux-mm@kvack.org>; Tue, 17 Sep 2013 16:28:28 +1000
Content-Disposition: inline
In-Reply-To: <CAHGf_=pNwf0CO_sTcLxTfTYUfqUrbr8mtcXDgLUC9_wa7wR_5Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, iamjoonsoo.kim@lge.com, David Rientjes <rientjes@google.com>, zhangyanfei@cn.fujitsu.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hi KOSAKI,
On Tue, Sep 17, 2013 at 01:39:13AM -0400, KOSAKI Motohiro wrote:
>On Mon, Sep 16, 2013 at 7:41 PM, Wanpeng Li <liwanp@linux.vnet.ibm.com> wrote:
>> Hi KOSAKI,
>> On Mon, Sep 16, 2013 at 04:15:29PM -0400, KOSAKI Motohiro wrote:
>>>On 9/14/2013 7:45 PM, Wanpeng Li wrote:
>>>> Changelog:
>>>>  *v2 -> v3: revert commit 46c001a2 directly
>>>>
>>>> Don't warning twice in __vmalloc_area_node and __vmalloc_node_range if
>>>> __vmalloc_area_node allocation failure. This patch revert commit 46c001a2
>>>> (mm/vmalloc.c: emit the failure message before return).
>>>>
>>>> Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
>>>> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>>>> ---
>>>>  mm/vmalloc.c | 2 +-
>>>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>>>
>>>> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
>>>> index d78d117..e3ec8b4 100644
>>>> --- a/mm/vmalloc.c
>>>> +++ b/mm/vmalloc.c
>>>> @@ -1635,7 +1635,7 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
>>>>
>>>>      addr = __vmalloc_area_node(area, gfp_mask, prot, node, caller);
>>>>      if (!addr)
>>>> -            goto fail;
>>>> +            return NULL;
>>
>> The goto fail is introduced by commit (mm/vmalloc.c: emit the failure message
>> before return), and the commit author ignore there has already have warning in
>> __vmalloc_area_node.
>>
>> http://marc.info/?l=linux-mm&m=137818671125209&w=2
>
>But, module_alloc() directly calls __vmalloc_node_range(). Your fix
>makes another regression.

I'm not sure what's the regression you mentioned.

Before patch:

module_alloc
 -> __vmalloc_node_range (waring for the second time)   <-|
  -> __vmalloc_area_node  (warning for the first time)  --|

After patch:

module_alloc
 -> __vmalloc_node_range                  <-|
  -> __vmalloc_area_node (warning once)   --|

>
>
>>>This is not right fix. Now we have following call stack.
>>>
>>> __vmalloc_node
>>>       __vmalloc_node_range
>>>               __vmalloc_node
>>>
>>>Even if we remove a warning of __vmalloc_node_range, we still be able to see double warning
>>>because we call __vmalloc_node recursively.
>>
>> Different size allocation failure in your example actually.
>
>But, when we can not allocate small size memory, almost always we
>can't allocate large size too.
>
>You need some refactoring and make right fix.

There is warning in __vmalloc_area_node for different size which you
metioned, could you point out what need refactor? ;-)

Regards,
Wanpeng Li 




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
