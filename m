Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0B5CC6B0292
	for <linux-mm@kvack.org>; Tue, 30 May 2017 11:37:20 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id p86so101067452pfl.12
        for <linux-mm@kvack.org>; Tue, 30 May 2017 08:37:20 -0700 (PDT)
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-dm3nam03on0048.outbound.protection.outlook.com. [104.47.41.48])
        by mx.google.com with ESMTPS id u78si13592929pgb.391.2017.05.30.08.37.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 30 May 2017 08:37:19 -0700 (PDT)
Subject: Re: [PATCH v5 32/32] x86/mm: Add support to make use of Secure Memory
 Encryption
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
 <20170418212223.10190.85121.stgit@tlendack-t1.amdoffice.net>
 <20170519112703.voajtn4t7uy6nwa3@pd.tnic>
 <7c522f65-c5c8-9362-e1eb-d0765e3ea6c9@amd.com>
 <20170530145459.tyuy6veqxnrqkhgw@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <115ca39d-6ae7-f603-a415-ead7c4e8193d@amd.com>
Date: Tue, 30 May 2017 10:37:03 -0500
MIME-Version: 1.0
In-Reply-To: <20170530145459.tyuy6veqxnrqkhgw@pd.tnic>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S.
 Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 5/30/2017 9:55 AM, Borislav Petkov wrote:
> On Tue, May 30, 2017 at 09:38:36AM -0500, Tom Lendacky wrote:
>> In this case we're running identity mapped and the "on" constant ends up
>> as kernel address (0xffffffff81...) which results in a segfault.
> 
> Would
> 
> 	static const char *__on_str = "on";
> 
> 	...
> 
> 	if (!strncmp(buffer, __pa_nodebug(__on_str), 2))
> 		...
> 
> work?
> 
> __phys_addr_nodebug() seems to pay attention to phys_base and
> PAGE_OFFSET and so on...

Except that phys_base hasn't been adjusted yet so that doesn't work
either.

> 
> I'd like to avoid that rip-relative address finding in inline asm which
> looks fragile to me.

I can define the command line option and the "on" and "off" values as
character buffers in the function and initialize them on a per character
basis (using a static string causes the same issues as referencing a
string constant), i.e.:

char cmdline_arg[] = {'m', 'e', 'm', '_', 'e', 'n', 'c', 'r', 'y', 'p', 't', '\0'};
char cmdline_off[] = {'o', 'f', 'f', '\0'};
char cmdline_on[] = {'o', 'n', '\0'};

It doesn't look the greatest, but it works and removes the need for the
rip-relative addressing.

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
