Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3A6CE6B0387
	for <linux-mm@kvack.org>; Fri, 24 Feb 2017 10:23:00 -0500 (EST)
Received: by mail-lf0-f70.google.com with SMTP id l6so11151302lfb.2
        for <linux-mm@kvack.org>; Fri, 24 Feb 2017 07:23:00 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTP id c184si4394412lfg.357.2017.02.24.07.22.57
        for <linux-mm@kvack.org>;
        Fri, 24 Feb 2017 07:22:57 -0800 (PST)
Date: Fri, 24 Feb 2017 16:22:26 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [RFC PATCH v4 14/28] Add support to access boot related data in
 the clear
Message-ID: <20170224152226.gzs4qquv7b7gmamu@pd.tnic>
References: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
 <20170216154508.19244.58580.stgit@tlendack-t1.amdoffice.net>
 <20170221150625.lohyskz5bjuey7fa@pd.tnic>
 <031277bf-25ad-3d41-d189-1ad6b4d27c93@amd.com>
 <20170224102155.4pauis3acrzp3rwz@pd.tnic>
 <8c8bf255-c48d-ac7f-e344-8059e1ffedb3@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <8c8bf255-c48d-ac7f-e344-8059e1ffedb3@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Larry Woodman <lwoodman@redhat.com>, Dmitry Vyukov <dvyukov@google.com>

On Fri, Feb 24, 2017 at 09:04:21AM -0600, Tom Lendacky wrote:
> I looked at doing that but you get into this cyclical situation unless
> you specifically map each setup data elemement as decrypted. This is ok
> for early_memremap since we have early_memremap_decrypted() but a new
> memremap_decrypted() would have to be added. But I was trying to avoid
> having to do multiple mapping calls inside the current mapping call.
> 
> I can always look at converting the setup_data_list from an array
> into a list to eliminate the 32 entry limit, too.
> 
> Let me look at adding the early_memremap_decrypted() type support to
> memremap() and see how that looks.

Yes, so this sounds better than the cyclic thing you explained
where you have to add and update since early_memremap() calls into
memremap_should_map_encrypted() which touches the list we're updating at
the same time.

So in the case where you absolutely know that those ranges should
be mapped decrypted, we should have special helpers which do that
explicitly and they are called when we access those special regions.
Well, special for SME. I'm thinking that should simplify the handling
but you'll know better once you write it. :)

Thanks.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
