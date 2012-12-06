Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 065636B00B4
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 12:10:38 -0500 (EST)
Received: by mail-da0-f41.google.com with SMTP id e20so2972168dak.14
        for <linux-mm@kvack.org>; Thu, 06 Dec 2012 09:10:38 -0800 (PST)
Message-ID: <50C0D189.7020306@gmail.com>
Date: Fri, 07 Dec 2012 01:10:33 +0800
From: Jiang Liu <liuj97@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v3 0/3] acpi: Introduce prepare_remove device operation
References: <1353693037-21704-1-git-send-email-vasilis.liaskovitis@profitbricks.com> <1354221570.7776.11.camel@misato.fc.hp.com> <1354222577.7776.22.camel@misato.fc.hp.com> <7256354.mIkI9CW3OY@vostro.rjw.lan>
In-Reply-To: <7256354.mIkI9CW3OY@vostro.rjw.lan>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Toshi Kani <toshi.kani@hp.com>, linux-acpi@vger.kernel.org, Hanjun Guo <guohanjun@huawei.com>, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, lenb@kernel.org, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tang Chen <tangchen@cn.fujitsu.com>

On 11/30/2012 05:25 AM, Rafael J. Wysocki wrote:
> On Thursday, November 29, 2012 01:56:17 PM Toshi Kani wrote:
>> On Thu, 2012-11-29 at 13:39 -0700, Toshi Kani wrote:
>>> On Thu, 2012-11-29 at 21:30 +0100, Rafael J. Wysocki wrote:
>>>> On Thursday, November 29, 2012 10:03:12 AM Toshi Kani wrote:
>>>>> On Thu, 2012-11-29 at 11:15 +0100, Rafael J. Wysocki wrote:
>>>>>> On Wednesday, November 28, 2012 11:41:36 AM Toshi Kani wrote:
>>>>>>> 1. Validate phase - Verify if the request is a supported operation.  All
>>>>>>> known restrictions are verified at this phase.  For instance, if a
>>>>>>> hot-remove request involves kernel memory, it is failed in this phase.
>>>>>>> Since this phase makes no change, no rollback is necessary to fail.  
>>>>>>
>>>>>> Actually, we can't do it this way, because the conditions may change between
>>>>>> the check and the execution.  So the first phase needs to involve execution
>>>>>> to some extent, although only as far as it remains reversible.
>>>>>
>>>>> For memory hot-remove, we can check if the target memory ranges are
>>>>> within ZONE_MOVABLE.  We should not allow user to change this setup
>>>>> during hot-remove operation.  Other things may be to check if a target
>>>>> node contains cpu0 (until it is supported), the console UART (assuming
>>>>> we cannot delete it), etc.  We should avoid doing rollback as much as we
>>>>> can.
>>>>
>>>> Yes, we can make some checks upfront as an optimization and fail early if
>>>> the conditions are not met, but for correctness we need to repeat those
>>>> checks later anyway.  Once we've decided to go for the eject, the conditions
>>>> must hold whatever happens.
>>>
>>> Agreed.
>>
>> BTW, it is not an optimization I am after for this phase.  There are
>> many error cases during hot-plug operations.  It is difficult to assure
>> that rollback is successful for every error condition in terms of
>> testing and maintaining the code.  So, it is easier to fail beforehand
>> when possible.
> 
> OK, but as I said it is necessary to ensure that the conditions will be met
> in the next phases as well if we don't fail.
Yes, that's absolutely an requirement. Otherwise QA people will call you
when doing stress tests.

> 
> Thanks,
> Rafael
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
