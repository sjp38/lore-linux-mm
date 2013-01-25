Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id D549F6B0005
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 11:38:59 -0500 (EST)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Fri, 25 Jan 2013 11:38:58 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id A3FE2C90042
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 11:38:55 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0PGct8v290558
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 11:38:55 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0PGcsr6000691
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 14:38:55 -0200
Message-ID: <5102B51C.6070305@linux.vnet.ibm.com>
Date: Fri, 25 Jan 2013 10:38:52 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCHv2 4/9] staging: zsmalloc: make CLASS_DELTA relative to
 PAGE_SIZE
References: <1357590280-31535-1-git-send-email-sjenning@linux.vnet.ibm.com> <1357590280-31535-5-git-send-email-sjenning@linux.vnet.ibm.com> <CAPkvG_c48ZfwBRKCXSZrnVo=GgoLpqsRrF=8DEAwfFFVhb=1ZA@mail.gmail.com>
In-Reply-To: <CAPkvG_c48ZfwBRKCXSZrnVo=GgoLpqsRrF=8DEAwfFFVhb=1ZA@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nitin Gupta <ngupta@vflare.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On 01/24/2013 06:17 PM, Nitin Gupta wrote:
> On Mon, Jan 7, 2013 at 12:24 PM, Seth Jennings
> <sjenning@linux.vnet.ibm.com> wrote:
>> Right now ZS_SIZE_CLASS_DELTA is hardcoded to be 16.  This
>> creates 254 classes for systems with 4k pages. However, on
>> PPC64 with 64k pages, it creates 4095 classes which is far
>> too many.
>>
>> This patch makes ZS_SIZE_CLASS_DELTA relative to PAGE_SIZE
>> so that regardless of the page size, there will be the same
>> number of classes.
>>
>> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
>> ---
>>  drivers/staging/zsmalloc/zsmalloc-main.c |    2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/drivers/staging/zsmalloc/zsmalloc-main.c b/drivers/staging/zsmalloc/zsmalloc-main.c
>> index 825e124..3543047 100644
>> --- a/drivers/staging/zsmalloc/zsmalloc-main.c
>> +++ b/drivers/staging/zsmalloc/zsmalloc-main.c
>> @@ -141,7 +141,7 @@
>>   *  ZS_MIN_ALLOC_SIZE and ZS_SIZE_CLASS_DELTA must be multiple of ZS_ALIGN
>>   *  (reason above)
>>   */
>> -#define ZS_SIZE_CLASS_DELTA    16
>> +#define ZS_SIZE_CLASS_DELTA    (PAGE_SIZE >> 8)
>>  #define ZS_SIZE_CLASSES                ((ZS_MAX_ALLOC_SIZE - ZS_MIN_ALLOC_SIZE) / \
>>                                         ZS_SIZE_CLASS_DELTA + 1)
>>
> 
> Actually, there is no point creating size classes beyond [M/(M+1)] * PAGE_SIZE
> where M is the maximum number of system pages in a zspage.

Agreed.

> All size classes
> beyond this size can be collapsed with PAGE_SIZE size class.  This can
> significantly reduce number of size classes created but I think changes needed
> to do this would be more involved, so perhaps, should be done in another
> patch.

I agree there could be some optimization here, but those extra classes
really aren't doing any harm that I can see.

> Can you please resend part of this series  (patch 1  to patch 4) which deals
> just with zsmalloc separately?  I haven't yet looked into zswap itself so would
> help with zsmalloc bits are separated out.

Working it now.

Thanks,
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
