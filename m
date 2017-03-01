Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6D6D06B038B
	for <linux-mm@kvack.org>; Wed,  1 Mar 2017 04:25:50 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id c85so52429543qkg.0
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 01:25:50 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v15si3796940qtb.224.2017.03.01.01.25.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Mar 2017 01:25:49 -0800 (PST)
Date: Wed, 1 Mar 2017 17:25:36 +0800
From: Dave Young <dyoung@redhat.com>
Subject: Re: [RFC PATCH v4 26/28] x86: Allow kexec to be used with SME
Message-ID: <20170301092536.GB8353@dhcp-128-65.nay.redhat.com>
References: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
 <20170216154755.19244.51276.stgit@tlendack-t1.amdoffice.net>
 <20170217155756.GJ30272@char.us.ORACLE.com>
 <d2f16b24-f2ef-a22b-3c72-2d8ad585553e@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d2f16b24-f2ef-a22b-3c72-2d8ad585553e@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Paolo Bonzini <pbonzini@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Larry Woodman <lwoodman@redhat.com>, Dmitry Vyukov <dvyukov@google.com>

Hi Tom,

On 02/17/17 at 10:43am, Tom Lendacky wrote:
> On 2/17/2017 9:57 AM, Konrad Rzeszutek Wilk wrote:
> > On Thu, Feb 16, 2017 at 09:47:55AM -0600, Tom Lendacky wrote:
> > > Provide support so that kexec can be used to boot a kernel when SME is
> > > enabled.
> > 
> > Is the point of kexec and kdump to ehh, dump memory ? But if the
> > rest of the memory is encrypted you won't get much, will you?
> 
> Kexec can be used to reboot a system without going back through BIOS.
> So you can use kexec without using kdump.
> 
> For kdump, just taking a quick look, the option to enable memory
> encryption can be provided on the crash kernel command line and then

Is there a simple way to get the SME status? Probably add some sysfs
file for this purpose.

> crash kernel can would be able to copy the memory decrypted if the
> pagetable is set up properly. It looks like currently ioremap_cache()
> is used to map the old memory page.  That might be able to be changed
> to a memremap() so that the encryption bit is set in the mapping. That
> will mean that memory that is not marked encrypted (EFI tables, swiotlb
> memory, etc) would not be read correctly.

Manage to store info about those ranges which are not encrypted so that
memremap can handle them?

> 
> > 
> > Would it make sense to include some printk to the user if they
> > are setting up kdump that they won't get anything out of it?
> 
> Probably a good idea to add something like that.

It will break kdump functionality, it should be fixed instead of
just adding printk to warn user..

Thanks
Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
