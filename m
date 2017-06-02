Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id C015D6B0279
	for <linux-mm@kvack.org>; Fri,  2 Jun 2017 07:11:03 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id w68so51302782itc.5
        for <linux-mm@kvack.org>; Fri, 02 Jun 2017 04:11:03 -0700 (PDT)
Received: from mail-it0-x229.google.com (mail-it0-x229.google.com. [2607:f8b0:4001:c0b::229])
        by mx.google.com with ESMTPS id l91si22154682ioi.104.2017.06.02.04.11.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Jun 2017 04:11:02 -0700 (PDT)
Received: by mail-it0-x229.google.com with SMTP id m47so3838163iti.1
        for <linux-mm@kvack.org>; Fri, 02 Jun 2017 04:11:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <59310F0A.1010804@huawei.com>
References: <1496323611-53377-1-git-send-email-zhongjiang@huawei.com>
 <CAKv+Gu-WL33LHKzwmNaw8-QDVEh6VjwhFohLUrOZH41CLUHG_w@mail.gmail.com> <59310F0A.1010804@huawei.com>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Fri, 2 Jun 2017 11:11:01 +0000
Message-ID: <CAKv+Gu8Q5E40Cf0aCKofopOcL+zSJUFfzTPx5mGAYxmBCqx-2g@mail.gmail.com>
Subject: Re: [PATCH v5] arm64: fix the overlap between the kernel image and
 vmalloc address
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Laura Abbott <labbott@redhat.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On 2 June 2017 at 07:08, zhong jiang <zhongjiang@huawei.com> wrote:
> Hi, Ard
>
> Thank you for reply.
> On 2017/6/2 1:40, Ard Biesheuvel wrote:
>> Hi all,
>>
>> On 1 June 2017 at 13:26, zhongjiang <zhongjiang@huawei.com> wrote:
>>> Recently, xiaojun report the following issue.
>>>
>>> [ 4544.984139] Unable to handle kernel paging request at virtual address ffff804392800000
>> This is not a vmalloc address ^^^
>  The mappings is not at a page granularity. but kernel image maaping use sections.
>  and this try a bogus walk to the pte level. so it will acess a abnormal address,
>  not in a vmalloc range.

Ah ok. It looks like you are crashing in __memcpy(), but it is
actually the __memcpy() call inside vread(), not the one in
read_kcore(). I missed that.

>> [...]
>>> I find the issue is introduced when applying commit f9040773b7bb
>>> ("arm64: move kernel image to base of vmalloc area"). This patch
>>> make the kernel image overlap with vmalloc area. It will result in
>>> vmalloc area have the huge page table. but the vmalloc_to_page is
>>> not realize the change. and the function is public to any arch.
>>>
>>> I fix it by adding the another kernel image condition in vmalloc_to_page
>>> to make it keep the accordance with previous vmalloc mapping.
>>>
>> ... so while I agree that there is probably an issue to be solved
>> here, I don't see how this patch fixes the problem. This particular
>> crash may be caused by an assumption on the part of the kcore code
>> that there are no holes in the linear region.
>>
>>> Fixes: f9040773b7bb ("arm64: move kernel image to base of vmalloc area")
>>> Reported-by: tan xiaojun <tanxiaojun@huawei.com>
>>> Reviewed-by: Laura Abbott <labbott@redhat.com>
>>> Signed-off-by: zhongjiang <zhongjiang@huawei.com>
>> So while I think we all agree that the kcore code is likely to get
>> confused due to the overlap between vmlinux and the vmalloc region, I
>> would like to better understand how it breaks things, and whether we'd
>> be better off simply teaching vread/vwrite how to interpret block
>> mappings.
>  I think the root reason is clear. and I test the patch, after applying the patch,
>  the issue will go away.
>> Could you check whether CONFIG_DEBUG_PAGEALLOC makes the issue go away
>> (once you have really managed to reproduce it?)
> Today, I enable the config and test it in newest kernel version. the issue still exist.
>
> [  396.495450] [<ffff00000839c400>] __memcpy+0x100/0x180
> [  396.501056] [<ffff00000826ae14>] read_kcore+0x21c/0x3a0
> [  396.506729] [<ffff00000825d37c>] proc_reg_read+0x64/0x90
> [  396.512706] [<ffff0000081f668c>] __vfs_read+0x1c/0xf8
> [  396.518188] [<ffff0000081f792c>] vfs_read+0x84/0x140
> [  396.523653] [<ffff0000081f8df4>] SyS_read+0x44/0xa0
> [  396.529205] [<ffff000008082f30>] el0_svc_naked+0x24/0x28
> [  396.535036] Code: d503201f d503201f d503201f d503201f (a8c12027)
>

Yeah, another bit of useless advice, sorry. DEBUG_PAGEALLOC does not
affect the granularity of the vmlinux segment mappings anymore.

Anyway, given that the vmalloc routines already contain partial
support for block mappings (i.e., vunmap() supports them), I think it
is reasonable to add support for them in vmalloc() as well. I will
send out a patch shortly, could you please try it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
