Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 0D49E6B006E
	for <linux-mm@kvack.org>; Wed, 14 Jan 2015 03:06:35 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id y13so8433317pdi.2
        for <linux-mm@kvack.org>; Wed, 14 Jan 2015 00:06:34 -0800 (PST)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id c8si29891443pat.105.2015.01.14.00.06.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 14 Jan 2015 00:06:33 -0800 (PST)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NI500DD4QPKT260@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 14 Jan 2015 08:10:32 +0000 (GMT)
Message-id: <54B6237C.5090500@samsung.com>
Date: Wed, 14 Jan 2015 09:06:20 +0100
From: Andrzej Hajda <a.hajda@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH 0/5] kstrdup optimization
References: <1421054323-14430-1-git-send-email-a.hajda@samsung.com>
 <20150113153731.43eefac721964d165396e5af@linux-foundation.org>
In-reply-to: <20150113153731.43eefac721964d165396e5af@linux-foundation.org>
Content-type: text/plain; charset=windows-1252
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, linux-kernel@vger.kernel.org, andi@firstfloor.org, andi@lisas.de, Mike Turquette <mturquette@linaro.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Tejun Heo <tj@kernel.org>

On 01/14/2015 12:37 AM, Andrew Morton wrote:
> On Mon, 12 Jan 2015 10:18:38 +0100 Andrzej Hajda <a.hajda@samsung.com> wrote:
>
>> Hi,
>>
>> kstrdup if often used to duplicate strings where neither source neither
>> destination will be ever modified. In such case we can just reuse the source
>> instead of duplicating it. The problem is that we must be sure that
>> the source is non-modifiable and its life-time is long enough.
>>
>> I suspect the good candidates for such strings are strings located in kernel
>> .rodata section, they cannot be modifed because the section is read-only and
>> their life-time is equal to kernel life-time.
>>
>> This small patchset proposes alternative version of kstrdup - kstrdup_const,
>> which returns source string if it is located in .rodata otherwise it fallbacks
>> to kstrdup.
>> To verify if the source is in .rodata function checks if the address is between
>> sentinels __start_rodata, __end_rodata. I guess it should work with all
>> architectures.
>>
>> The main patch is accompanied by four patches constifying kstrdup for cases
>> where situtation described above happens frequently.
>>
>> As I have tested the patchset on mobile platform (exynos4210-trats) it saves
>> 3272 string allocations. Since minimal allocation is 32 or 64 bytes depending
>> on Kconfig options the patchset saves respectively about 100KB or 200KB of memory.
> That's a lot of memory.  I wonder where it's all going to.  sysfs,
> probably?

Stats from tested platform.
By caller:
  2260 __kernfs_new_node
    631 clk_register+0xc8/0x1b8
    318 clk_register+0x34/0x1b8
      51 kmem_cache_create
      12 alloc_vfsmnt

By string (with count >= 5):
    883 power
    876 subsystem
    135 parameters
    132 device
     61 iommu_group
     44 sclk_mpll
     42 aclk100
     41 driver
     36 sclk_vpll
     35 none
     34 sclk_epll
     34 aclk160
     32 sclk_hdmi24m
     31 xxti
     31 xusbxti
     31 sclk_usbphy0
     30 sclk_hdmiphy
     28 bdi
     28 aclk133
     14 sclk_apll
     14 aclk200
      9 module
      9 fin_pll
      5 div_core2
   


>
> What the heck does (the cheerily undocumented) KERNFS_STATIC_NAME do
> and can we remove it if this patchset is in place?
>
>

The only call path when this flag is set starts from
sysfs_add_file_mode_ns function.
But I guess this function can be called also for non-const names.

Regards
Andrzej


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
