Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 659746B0279
	for <linux-mm@kvack.org>; Wed, 31 May 2017 09:38:00 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id p29so11287950pgn.3
        for <linux-mm@kvack.org>; Wed, 31 May 2017 06:38:00 -0700 (PDT)
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (mail-cys01nam02on0073.outbound.protection.outlook.com. [104.47.37.73])
        by mx.google.com with ESMTPS id t61si48242728plb.200.2017.05.31.06.37.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 31 May 2017 06:37:59 -0700 (PDT)
Subject: Re: [PATCH v5 32/32] x86/mm: Add support to make use of Secure Memory
 Encryption
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
 <20170418212223.10190.85121.stgit@tlendack-t1.amdoffice.net>
 <20170519112703.voajtn4t7uy6nwa3@pd.tnic>
 <7c522f65-c5c8-9362-e1eb-d0765e3ea6c9@amd.com>
 <20170530145459.tyuy6veqxnrqkhgw@pd.tnic>
 <115ca39d-6ae7-f603-a415-ead7c4e8193d@amd.com>
 <20170531084923.mmlpefxfx53f3okp@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <706d6ae0-bc4c-5ba7-529c-b0fc5e4ad464@amd.com>
Date: Wed, 31 May 2017 08:37:50 -0500
MIME-Version: 1.0
In-Reply-To: <20170531084923.mmlpefxfx53f3okp@pd.tnic>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S.
 Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 5/31/2017 3:49 AM, Borislav Petkov wrote:
> On Tue, May 30, 2017 at 10:37:03AM -0500, Tom Lendacky wrote:
>> I can define the command line option and the "on" and "off" values as
>> character buffers in the function and initialize them on a per character
>> basis (using a static string causes the same issues as referencing a
>> string constant), i.e.:
>>
>> char cmdline_arg[] = {'m', 'e', 'm', '_', 'e', 'n', 'c', 'r', 'y', 'p', 't', '\0'};
>> char cmdline_off[] = {'o', 'f', 'f', '\0'};
>> char cmdline_on[] = {'o', 'n', '\0'};
>>
>> It doesn't look the greatest, but it works and removes the need for the
>> rip-relative addressing.
> 
> Well, I'm not thrilled about this one either. It's like being between a
> rock and a hard place. :-\
> 
> On the one hand, we need the encryption mask before we do the fixups and
> OTOH we need to do the fixups in order to access the strings properly.
> Yuck.
> 
> Well, the only thing I can think of right now is maybe define
> "mem_encrypt=" at the end of head_64.S and pass it in from asm to
> sme_enable() and then do the "on"/"off" comparsion with local char
> buffers. That could make it less ugly...

I like keeping the command line option and the values together. It may
not look the greatest but I like it more than defining the command line
option in head_64.S and passing it in as an argument.

OTOH, I don't think the rip-relative addressing was that bad, I can
always go back to that...

Thanks,
Tom

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
