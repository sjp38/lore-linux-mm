Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2D0B56B0388
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 12:58:50 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id 2so144854813oif.7
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 09:58:50 -0800 (PST)
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (mail-cys01nam02on0051.outbound.protection.outlook.com. [104.47.37.51])
        by mx.google.com with ESMTPS id t44si8345637otc.306.2017.03.06.09.58.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 06 Mar 2017 09:58:49 -0800 (PST)
Subject: Re: [RFC PATCH v4 26/28] x86: Allow kexec to be used with SME
References: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
 <20170216154755.19244.51276.stgit@tlendack-t1.amdoffice.net>
 <20170217155756.GJ30272@char.us.ORACLE.com>
 <d2f16b24-f2ef-a22b-3c72-2d8ad585553e@amd.com>
 <20170301092536.GB8353@dhcp-128-65.nay.redhat.com>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <998eb58b-eefd-3093-093f-9ae25ddda472@amd.com>
Date: Mon, 6 Mar 2017 11:58:40 -0600
MIME-Version: 1.0
In-Reply-To: <20170301092536.GB8353@dhcp-128-65.nay.redhat.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Young <dyoung@redhat.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S.
 Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Paolo Bonzini <pbonzini@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Larry Woodman <lwoodman@redhat.com>, Dmitry Vyukov <dvyukov@google.com>

On 3/1/2017 3:25 AM, Dave Young wrote:
> Hi Tom,

Hi Dave,

>
> On 02/17/17 at 10:43am, Tom Lendacky wrote:
>> On 2/17/2017 9:57 AM, Konrad Rzeszutek Wilk wrote:
>>> On Thu, Feb 16, 2017 at 09:47:55AM -0600, Tom Lendacky wrote:
>>>> Provide support so that kexec can be used to boot a kernel when SME is
>>>> enabled.
>>>
>>> Is the point of kexec and kdump to ehh, dump memory ? But if the
>>> rest of the memory is encrypted you won't get much, will you?
>>
>> Kexec can be used to reboot a system without going back through BIOS.
>> So you can use kexec without using kdump.
>>
>> For kdump, just taking a quick look, the option to enable memory
>> encryption can be provided on the crash kernel command line and then
>
> Is there a simple way to get the SME status? Probably add some sysfs
> file for this purpose.

Currently there is not.  I can look at adding something, maybe just the
sme_me_mask value, which if non-zero, would indicate SME is active.

>
>> crash kernel can would be able to copy the memory decrypted if the
>> pagetable is set up properly. It looks like currently ioremap_cache()
>> is used to map the old memory page.  That might be able to be changed
>> to a memremap() so that the encryption bit is set in the mapping. That
>> will mean that memory that is not marked encrypted (EFI tables, swiotlb
>> memory, etc) would not be read correctly.
>
> Manage to store info about those ranges which are not encrypted so that
> memremap can handle them?

I can look into whether something can be done in this area. Any input
you can provide as to what would be the best way/place to store the
range info so kdump can make use of it, would be greatly appreciated.

>
>>
>>>
>>> Would it make sense to include some printk to the user if they
>>> are setting up kdump that they won't get anything out of it?
>>
>> Probably a good idea to add something like that.
>
> It will break kdump functionality, it should be fixed instead of
> just adding printk to warn user..

I do want kdump to work. I'll investigate further what can be done in
this area.

Thanks,
Tom

>
> Thanks
> Dave
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
