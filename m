Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 866DC6B005D
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 03:42:31 -0400 (EDT)
Message-ID: <4FFD2E65.5080307@kernel.org>
Date: Wed, 11 Jul 2012 16:42:29 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH 3/4] zsmalloc: add details to zs_map_object boiler plate
References: <1341263752-10210-1-git-send-email-sjenning@linux.vnet.ibm.com> <1341263752-10210-4-git-send-email-sjenning@linux.vnet.ibm.com> <4FFB94FF.8030401@kernel.org> <4FFC478C.4050505@linux.vnet.ibm.com>
In-Reply-To: <4FFC478C.4050505@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

On 07/11/2012 12:17 AM, Seth Jennings wrote:
> On 07/09/2012 09:35 PM, Minchan Kim wrote:
>> On 07/03/2012 06:15 AM, Seth Jennings wrote:
>>> Add information on the usage limits of zs_map_object()
>>>
>>> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
>>> ---
>>>  drivers/staging/zsmalloc/zsmalloc-main.c |    7 ++++++-
>>>  1 file changed, 6 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/drivers/staging/zsmalloc/zsmalloc-main.c b/drivers/staging/zsmalloc/zsmalloc-main.c
>>> index 4942d41..abf7c13 100644
>>> --- a/drivers/staging/zsmalloc/zsmalloc-main.c
>>> +++ b/drivers/staging/zsmalloc/zsmalloc-main.c
>>> @@ -747,7 +747,12 @@ EXPORT_SYMBOL_GPL(zs_free);
>>>   *
>>>   * Before using an object allocated from zs_malloc, it must be mapped using
>>>   * this function. When done with the object, it must be unmapped using
>>> - * zs_unmap_object
>>> + * zs_unmap_object.
>>> + *
>>> + * Only one object can be mapped per cpu at a time. There is no protection
>>> + * against nested mappings.
>>> + *
>>> + * This function returns with preemption and page faults disabled.
>>>  */
>>>  void *zs_map_object(struct zs_pool *pool, unsigned long handle)
>>>  {
>>>
>>
>> The comment is good but I hope we can detect it automatically with DEBUG
>> option. It wouldn't be hard but it's a debug patch so not critical
>> until we receive some report about the bug.
> 
> Yes, we could implement some detection scheme later.
> 
>>
>> The possibility for nesting is that it is used by irq context.
>>
>> A uses the mapping
>> .
>> .
>> .
>> IRQ happen
>> 	B uses the mapping in IRQ context
>> 	.
>> 	.
>> 	.
>>
>> Maybe we need local_irq_save/restore in zs_[un]map_object path.
> 
> I'd rather not disable interrupts since that will create
> unnecessary interrupt latency for all users, even if they

Agreed.
Although we guide k[un]map atomic is so fast, it isn't necessary
to force irq_[enable|disable]. Okay.

> don't need interrupt protection.  If a particular user uses
> zs_map_object() in an interrupt path, it will be up to that
> user to disable interrupts to ensure safety.

Nope. It shouldn't do that.
Any user in interrupt context can't assume that there isn't any other user using per-cpu buffer
right before interrupt happens.

The concern is that if such bug happens, it's very hard to find a bug.
So, how about adding this?

void zs_map_object(...)
{
	BUG_ON(in_interrupt());
}


> 
> Thanks,
> Seth
> 
> 


-- 
Kind regards,
Minchan Kim


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
