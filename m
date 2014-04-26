Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 0DBAE6B003A
	for <linux-mm@kvack.org>; Fri, 25 Apr 2014 22:13:34 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id w10so3738371pde.40
        for <linux-mm@kvack.org>; Fri, 25 Apr 2014 19:13:34 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id hp1si5921589pad.467.2014.04.25.19.13.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 25 Apr 2014 19:13:33 -0700 (PDT)
Message-ID: <535B1618.5030504@huawei.com>
Date: Sat, 26 Apr 2014 10:12:40 +0800
From: Jianguo Wu <wujianguo@huawei.com>
MIME-Version: 1.0
Subject: Re: ARM: mm: Could I change module space size or place modules in
 vmalloc area?
References: <002001cf07a1$fd4bdc10$f7e39430$@lge.com> <20140102101359.GU6589@tarshish> <002e01cf081c$44a11e70$cde35b50$@lge.com> <20140103004716.GG7383@n2100.arm.linux.org.uk>
In-Reply-To: <20140103004716.GG7383@n2100.arm.linux.org.uk>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Gioh Kim <gioh.kim@lge.com>, 'Baruch Siach' <baruch@tkos.co.il>, linux-mm@kvack.org, 'linux-arm-kernel' <linux-arm-kernel@lists.infradead.org>, 'HyoJun Im' <hyojun.im@lge.com>, arnd@arndb.de, Will Deacon <will.deacon@arm.com>

On 2014/1/3 8:47, Russell King - ARM Linux wrote:

> On Fri, Jan 03, 2014 at 09:39:31AM +0900, Gioh Kim wrote:
>> Thank you for reply.
>>
>>> -----Original Message-----
>>> From: Baruch Siach [mailto:baruch@tkos.co.il]
>>> Sent: Thursday, January 02, 2014 7:14 PM
>>> To: Gioh Kim
>>> Cc: Russell King; linux-mm@kvack.org; linux-arm-kernel; HyoJun Im
>>> Subject: Re: ARM: mm: Could I change module space size or place modules in
>>> vmalloc area?
>>>
>>> Hi Gioh,
>>>
>>> On Thu, Jan 02, 2014 at 07:04:13PM +0900, Gioh Kim wrote:
>>>> I run out of module space because I have several big driver modules.
>>>> I know I can strip the modules to decrease size but I need debug info
>>> now.
>>>
>>> Are you sure you need the debug info in kernel memory? I don't think the
>>> kernel is actually able to parse DWARF. You can load stripped binaries
>>> into the kernel, and still use the debug info with whatever tool you have.
>>
>> I agree you but driver developers of another team don't agree.
>> I don't know why but they say they will strip drivers later :-(
>> So I need to increase modules space size.
> 
> ARM can only branch relatively within +/- 32MB.  Hence, with a module
> space of 16MB, modules can reach up to a maximum 16MB into the direct-
> mapped kernel image.  As module space increases in size, so that figure
> decreases.  So, if module space were to be 40MB, the maximum size of the
> kernel binary would be 8MB.
> 

Hi Russell ,Arnd or Will,

I encountered the same situation in arm64, I loaded 80+ modules in arm64, and
run out of module address space(64M). Why the module space is restricted to 64M,
can it be expanded?  

In commit 257cb2519(arm64: Loadable modules), it mentioned that " Loadable modules
are loaded 64MB below the kernel image due to branch relocation restrictions",
"branch relocation restrictions" is a AArch64 instruction set restrictions?

Thanks,
Jianguo Wu.

> You want to look at a line similar to this:
> 
>       .text : 0xc0008000 - 0xc031eda0   (3164 kB)
> 
> Also, note this:
> 
>     modules : 0xbf000000 - 0xc0000000   (  16 MB)
> 
> If the difference between the lowest module address (0xbf000000) and the
> highest of .text is greater than 32MB, it's impossible to load modules -
> they will fail to link.
> 
> What is the size of your kernel text? (show us the line(s) like the above.)
> 
> Thanks.
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
