Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6310D6B0388
	for <linux-mm@kvack.org>; Fri, 24 Feb 2017 10:04:39 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id 186so41246770oid.2
        for <linux-mm@kvack.org>; Fri, 24 Feb 2017 07:04:39 -0800 (PST)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0066.outbound.protection.outlook.com. [104.47.38.66])
        by mx.google.com with ESMTPS id m124si1858220itd.13.2017.02.24.07.04.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 24 Feb 2017 07:04:38 -0800 (PST)
Subject: Re: [RFC PATCH v4 14/28] Add support to access boot related data in
 the clear
References: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
 <20170216154508.19244.58580.stgit@tlendack-t1.amdoffice.net>
 <20170221150625.lohyskz5bjuey7fa@pd.tnic>
 <031277bf-25ad-3d41-d189-1ad6b4d27c93@amd.com>
 <20170224102155.4pauis3acrzp3rwz@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <8c8bf255-c48d-ac7f-e344-8059e1ffedb3@amd.com>
Date: Fri, 24 Feb 2017 09:04:21 -0600
MIME-Version: 1.0
In-Reply-To: <20170224102155.4pauis3acrzp3rwz@pd.tnic>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S.
 Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Larry Woodman <lwoodman@redhat.com>, Dmitry Vyukov <dvyukov@google.com>

On 2/24/2017 4:21 AM, Borislav Petkov wrote:
> On Thu, Feb 23, 2017 at 03:34:30PM -0600, Tom Lendacky wrote:
>> Hmm... maybe I'm missing something here.  This doesn't have anything to
>> do with kexec or efi_reuse_config.  This has to do with the fact that
>
> I said kexec because kexec uses the setup_data mechanism to pass config
> tables to the second kernel, for example.
>
>> when a system boots the setup data and the EFI data are not encrypted.
>> Since it's not encrypted we need to be sure that any early_memremap()
>> and memremap() calls remove the encryption mask from the resulting
>> pagetable entry that is created so the data can be accessed properly.
>
> Anyway, I'd prefer not to do this ad-hoc caching if it can be
> helped. You're imposing an arbitrary limit of 32 there which the
> setup_data linked list doesn't have. So if you really want to go
> inspect those elements, you could iterate over them starting from
> boot_params.hdr.setup_data, just like parse_setup_data() does. Most of
> the time that list should be non-existent and if it is, it will be short
> anyway.
>

I looked at doing that but you get into this cyclical situation unless
you specifically map each setup data elemement as decrypted. This is ok
for early_memremap since we have early_memremap_decrypted() but a new
memremap_decrypted() would have to be added. But I was trying to avoid
having to do multiple mapping calls inside the current mapping call.

I can always look at converting the setup_data_list from an array
into a list to eliminate the 32 entry limit, too.

Let me look at adding the early_memremap_decrypted() type support to
memremap() and see how that looks.

> And if we really decide that we need to cache it for later inspection
> due to speed considerations, as you do in memremap_is_setup_data(), you
> could do that in the default: branch of parse_setup_data() and do it
> just once: I don't see why you need to do add_to_setup_data_list() *and*
> update_setup_data_list() when you could add both pointer and updated
> size once.

I do the add followed by the update because we can't determine the true
size of the setup data until it is first mapped so that the data->len
field can be accessed. In order to map it properly the physical
address range needs to be added to the list before it is mapped. After
it's mapped, the true physical address range can be calculated and
updated.

Thanks,
Tom

>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
