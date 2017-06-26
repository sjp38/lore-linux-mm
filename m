Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8C54A6B0292
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 12:35:12 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 76so5046583pgh.11
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 09:35:12 -0700 (PDT)
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-dm3nam03on0050.outbound.protection.outlook.com. [104.47.41.50])
        by mx.google.com with ESMTPS id 34si328620pln.382.2017.06.26.09.35.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 26 Jun 2017 09:35:11 -0700 (PDT)
Subject: Re: [PATCH v7 34/36] x86/mm: Add support to encrypt the kernel
 in-place
References: <20170616184947.18967.84890.stgit@tlendack-t1.amdoffice.net>
 <20170616185619.18967.38945.stgit@tlendack-t1.amdoffice.net>
 <20170623100013.upd4or6esjvulmvg@pd.tnic>
 <af9a50f7-17ea-a840-6456-b6479e5d7e82@amd.com>
 <20170626154543.fsuxfhxidytgo2ia@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <aed44ee3-dd6c-e6e1-4de5-5629bf61e688@amd.com>
Date: Mon, 26 Jun 2017 11:34:49 -0500
MIME-Version: 1.0
In-Reply-To: <20170626154543.fsuxfhxidytgo2ia@pd.tnic>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, xen-devel@lists.xen.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Brijesh Singh <brijesh.singh@amd.com>, Toshimitsu Kani <toshi.kani@hpe.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Matt Fleming <matt@codeblueprint.co.uk>, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Larry Woodman <lwoodman@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, "Michael S. Tsirkin" <mst@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dave Young <dyoung@redhat.com>, Rik van Riel <riel@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dmitry Vyukov <dvyukov@google.com>, Juergen Gross <jgross@suse.com>, Thomas Gleixner <tglx@linutronix.de>, Paolo Bonzini <pbonzini@redhat.com>

On 6/26/2017 10:45 AM, Borislav Petkov wrote:
> On Fri, Jun 23, 2017 at 12:44:46PM -0500, Tom Lendacky wrote:
>> Normally the __p4d() macro would be used and that would be ok whether
>> CONFIG_X86_5LEVEL is defined or not. But since __p4d() is part of the
>> paravirt ops path I have to use native_make_p4d().
> 
> So __p4d is in !CONFIG_PARAVIRT path.
> 
> Regardless, we use the native_* variants in generic code to mean, not
> paravirt. Just define it in a separate patch like the rest of the p4*
> machinery and use it in your code. Sooner or later someone else will
> need it.

Ok, will do.

> 
>> True, 5-level will only be turned on for specific hardware which is why
>> I originally had this as only 4-level pagetables. But in a comment from
>> you back on the v5 version you said it needed to support 5-level. I
>> guess we should have discussed this more,
> 
> AFAIR, I said something along the lines of "what about 5-level page
> tables?" and whether we care.

My bad, I took the meaning of that question the wrong way then.

Thanks,
Tom

> 
>> but I also thought that should our hardware ever support 5-level
>> paging in the future then this would be good to go.
> 
> There it is :-)
> 
>> The macros work great if you are not running identity mapped. You could
>> use p*d_offset() to move easily through the tables, but those functions
>> use __va() to generate table virtual addresses. I've seen where
>> boot/compressed/pagetable.c #defines __va() to work with identity mapped
>> pages but that would only work if I create a separate file just for this
>> function.
>>
>> Given when this occurs it's very similar to what __startup_64() does in
>> regards to the IS_ENABLED(CONFIG_X86_5LEVEL) checks.
> 
> Ok.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
