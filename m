Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0FA1F6B0038
	for <linux-mm@kvack.org>; Thu, 15 Sep 2016 13:08:16 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id mi5so99254638pab.2
        for <linux-mm@kvack.org>; Thu, 15 Sep 2016 10:08:16 -0700 (PDT)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-by2nam01on0075.outbound.protection.outlook.com. [104.47.34.75])
        by mx.google.com with ESMTPS id d186si40164146pfc.72.2016.09.15.10.08.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 15 Sep 2016 10:08:13 -0700 (PDT)
Subject: Re: [RFC PATCH v2 19/20] x86: Access the setup data through debugfs
 un-encrypted
References: <20160822223529.29880.50884.stgit@tlendack-t1.amdoffice.net>
 <20160822223859.29880.60652.stgit@tlendack-t1.amdoffice.net>
 <20160912165944.rpqbwxz2biathnt3@pd.tnic>
 <4a357b9b-7d53-5bd6-81db-9d8cc63a6c72@amd.com>
 <20160914145101.GB9295@nazgul.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <b734c2da-fee4-efae-fda2-bbcd74abbb33@amd.com>
Date: Thu, 15 Sep 2016 12:08:04 -0500
MIME-Version: 1.0
In-Reply-To: <20160914145101.GB9295@nazgul.tnic>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Paolo Bonzini <pbonzini@redhat.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 09/14/2016 09:51 AM, Borislav Petkov wrote:
> On Wed, Sep 14, 2016 at 09:29:41AM -0500, Tom Lendacky wrote:
>> This is still required because just using the __va() would still cause
>> the mapping created to have the encryption bit set. The ioremap call
>> will result in the mapping not having the encryption bit set.
> 
> I meant this: https://lkml.kernel.org/r/20160902181447.GA25328@nazgul.tnic
> 
> Wouldn't simply clearing the SME mask work?
> 
> #define __va(x)			((void *)(((unsigned long)(x)+PAGE_OFFSET) & ~sme_me_mask))
> 
> Or are you saying, one needs the whole noodling through ioremap_cache()
> because the data is already encrypted and accessing it with sme_me_mask
> cleared would simply give you the encrypted garbage?

The problem is that this physical address does not contain the
encryption bit, and even if it did, it wouldn't matter.  The __va()
define creates a virtual address that will be mapped as encrypted given
the current approach (which is how I found this).  It's only ioremap()
that would create a mapping without the encryption attribute and since
this is unencrypted data it needs to be access accordingly.

Thanks,
Tom

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
