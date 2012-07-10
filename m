Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id DB1BB6B0073
	for <linux-mm@kvack.org>; Tue, 10 Jul 2012 11:26:29 -0400 (EDT)
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Tue, 10 Jul 2012 09:26:28 -0600
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id E61533C60008
	for <linux-mm@kvack.org>; Tue, 10 Jul 2012 11:17:49 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6AFHf9X17891530
	for <linux-mm@kvack.org>; Tue, 10 Jul 2012 11:17:42 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6AKmXqE011771
	for <linux-mm@kvack.org>; Tue, 10 Jul 2012 16:48:33 -0400
Message-ID: <4FFC478C.4050505@linux.vnet.ibm.com>
Date: Tue, 10 Jul 2012 10:17:32 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/4] zsmalloc: add details to zs_map_object boiler plate
References: <1341263752-10210-1-git-send-email-sjenning@linux.vnet.ibm.com> <1341263752-10210-4-git-send-email-sjenning@linux.vnet.ibm.com> <4FFB94FF.8030401@kernel.org>
In-Reply-To: <4FFB94FF.8030401@kernel.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

On 07/09/2012 09:35 PM, Minchan Kim wrote:
> On 07/03/2012 06:15 AM, Seth Jennings wrote:
>> Add information on the usage limits of zs_map_object()
>>
>> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
>> ---
>>  drivers/staging/zsmalloc/zsmalloc-main.c |    7 ++++++-
>>  1 file changed, 6 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/staging/zsmalloc/zsmalloc-main.c b/drivers/staging/zsmalloc/zsmalloc-main.c
>> index 4942d41..abf7c13 100644
>> --- a/drivers/staging/zsmalloc/zsmalloc-main.c
>> +++ b/drivers/staging/zsmalloc/zsmalloc-main.c
>> @@ -747,7 +747,12 @@ EXPORT_SYMBOL_GPL(zs_free);
>>   *
>>   * Before using an object allocated from zs_malloc, it must be mapped using
>>   * this function. When done with the object, it must be unmapped using
>> - * zs_unmap_object
>> + * zs_unmap_object.
>> + *
>> + * Only one object can be mapped per cpu at a time. There is no protection
>> + * against nested mappings.
>> + *
>> + * This function returns with preemption and page faults disabled.
>>  */
>>  void *zs_map_object(struct zs_pool *pool, unsigned long handle)
>>  {
>>
> 
> The comment is good but I hope we can detect it automatically with DEBUG
> option. It wouldn't be hard but it's a debug patch so not critical
> until we receive some report about the bug.

Yes, we could implement some detection scheme later.

> 
> The possibility for nesting is that it is used by irq context.
> 
> A uses the mapping
> .
> .
> .
> IRQ happen
> 	B uses the mapping in IRQ context
> 	.
> 	.
> 	.
> 
> Maybe we need local_irq_save/restore in zs_[un]map_object path.

I'd rather not disable interrupts since that will create
unnecessary interrupt latency for all users, even if they
don't need interrupt protection.  If a particular user uses
zs_map_object() in an interrupt path, it will be up to that
user to disable interrupts to ensure safety.

Thanks,
Seth


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
