Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7BFC26B0038
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 10:22:44 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id h201so14156436qke.7
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 07:22:44 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l39si9299141qtb.185.2016.11.22.07.22.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Nov 2016 07:22:43 -0800 (PST)
Date: Tue, 22 Nov 2016 17:22:38 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH v3 13/20] x86: DMA support for memory encryption
Message-ID: <20161122171455-mutt-send-email-mst@kernel.org>
References: <20161110003426.3280.2999.stgit@tlendack-t1.amdoffice.net>
 <20161110003723.3280.62636.stgit@tlendack-t1.amdoffice.net>
 <20161115171443-mutt-send-email-mst@kernel.org>
 <4d97f998-5835-f4e0-9840-7f7979251275@amd.com>
 <20161122113859.5dtlrfgizwpum6st@pd.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161122113859.5dtlrfgizwpum6st@pd.tnic>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Tom Lendacky <thomas.lendacky@amd.com>, linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Tue, Nov 22, 2016 at 12:38:59PM +0100, Borislav Petkov wrote:
> On Tue, Nov 15, 2016 at 12:29:35PM -0600, Tom Lendacky wrote:
> > > Makes sense, but I think at least a dmesg warning here
> > > might be a good idea.
> > 
> > Good idea.  Should it be a warning when it is first being set up or
> > a warning the first time the bounce buffers need to be used.  Or maybe
> > both?
> 
> Ok, let me put my user hat on...
> 
> (... puts a felt hat ...)
> 
> so what am I supposed to do about this as a user? Go and physically
> remove those devices because I want to enable SME?!
> 
> IMO, the only thing we should do is issue a *single* warning -
> pr_warn_once - along the lines of:
> 
> "... devices present which due to SME will use bounce buffers and will
> cause their speed to diminish. Boot with sme=debug to see full info".
> 
> And then sme=debug will dump the whole gory details. I don't think
> screaming for each device is going to change anything in many cases.
> 99% of people don't care - they just want shit to work.

The issue is it's a (potential) security hole, not a slowdown.


> > > A boot flag that says "don't enable devices that don't support
> > > encryption" might be a good idea, too, since most people
> > > don't read dmesg output and won't notice the message.
> > 
> > I'll look into this. It might be something that can be checked as
> > part of the device setting its DMA mask or the first time a DMA
> > API is used if the device doesn't explicitly set its mask.
> 
> Still with my user hat on, what would be the purpose of such an option?
> 
> We already use bounce buffers so those devices do support encryption,
> albeit slower.
> 
> felt hat is confused.

To disable unsecure things. If someone enables SEV one might have an
expectation of security.  Might help push vendors to do the right thing
as a side effect.

> -- 
> Regards/Gruss,
>     Boris.
> 
> Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
