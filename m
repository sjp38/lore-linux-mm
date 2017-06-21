Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 38EAF6B0292
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 14:40:26 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id r145so9871418itr.0
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 11:40:26 -0700 (PDT)
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (mail-cys01nam02on0066.outbound.protection.outlook.com. [104.47.37.66])
        by mx.google.com with ESMTPS id 13si2604803iog.99.2017.06.21.11.40.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 21 Jun 2017 11:40:25 -0700 (PDT)
Subject: Re: [PATCH v6 26/34] iommu/amd: Allow the AMD IOMMU to work with
 memory encryption
References: <20170607191309.28645.15241.stgit@tlendack-t1.amdoffice.net>
 <20170607191745.28645.81756.stgit@tlendack-t1.amdoffice.net>
 <20170614174208.p2yr5exs4b6pjxhf@pd.tnic>
 <0611d01a-19f8-d6ae-2682-932789855518@amd.com>
 <20170615094111.wga334kg2bhxqib3@pd.tnic> <20170621153721.GP30388@8bytes.org>
 <20170621165921.tv2jfhf5dz7hsjsy@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <26d48eb1-4d33-4abf-f169-3ce86aef22fe@amd.com>
Date: Wed, 21 Jun 2017 13:40:14 -0500
MIME-Version: 1.0
In-Reply-To: <20170621165921.tv2jfhf5dz7hsjsy@pd.tnic>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>, Joerg Roedel <joro@8bytes.org>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 6/21/2017 11:59 AM, Borislav Petkov wrote:
> On Wed, Jun 21, 2017 at 05:37:22PM +0200, Joerg Roedel wrote:
>>> Do you mean this is like the last exception case in that document above:
>>>
>>> "
>>>    - Pointers to data structures in coherent memory which might be modified
>>>      by I/O devices can, sometimes, legitimately be volatile.  A ring buffer
>>>      used by a network adapter, where that adapter changes pointers to
>>>      indicate which descriptors have been processed, is an example of this
>>>      type of situation."
>>>
>>> ?
>>
>> So currently (without this patch) the build_completion_wait function
>> does not take a volatile parameter, only wait_on_sem() does.
>>
>> Wait_on_sem() needs it because its purpose is to poll a memory location
>> which is changed by the iommu-hardware when its done with command
>> processing.
> 
> Right, the reason above - memory modifiable by an IO device. You could
> add a comment there explaining the need for the volatile.
> 
>> But the 'volatile' in build_completion_wait() looks unnecessary, because
>> the function does not poll the memory location. It only uses the
>> pointer, converts it to a physical address and writes it to the command
>> to be queued.
> 
> Ok.

Ok, so the (now) current version of the patch that doesn't change the
function signature is the right way to go.

Thanks,
Tom

> 
> Thanks.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
