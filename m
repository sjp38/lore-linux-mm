Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 767C128073B
	for <linux-mm@kvack.org>; Fri, 19 May 2017 17:38:21 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id v80so92556562oie.10
        for <linux-mm@kvack.org>; Fri, 19 May 2017 14:38:21 -0700 (PDT)
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (mail-by2nam03on0054.outbound.protection.outlook.com. [104.47.42.54])
        by mx.google.com with ESMTPS id m2si4280337otd.313.2017.05.19.14.38.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 19 May 2017 14:38:20 -0700 (PDT)
Subject: Re: [PATCH v5 28/32] x86/mm, kexec: Allow kexec to be used with SME
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
 <20170418212121.10190.94885.stgit@tlendack-t1.amdoffice.net>
 <20170517191755.h2xluopk2p6suw32@pd.tnic>
 <1b74e0e6-3dda-f638-461b-f73af9904360@amd.com>
 <20170519205836.3wvl3nztqyyouje3@pd.tnic>
 <5ef96f3a-6ebd-1d4d-7ac9-05dbed45d998@amd.com>
 <20170519212854.3dvtt3lawzij5cae@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <8baa170c-f0bd-3e5d-17d9-a031f4ff943c@amd.com>
Date: Fri, 19 May 2017 16:38:07 -0500
MIME-Version: 1.0
In-Reply-To: <20170519212854.3dvtt3lawzij5cae@pd.tnic>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S.
 Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 5/19/2017 4:28 PM, Borislav Petkov wrote:
> On Fri, May 19, 2017 at 04:07:24PM -0500, Tom Lendacky wrote:
>> As long as those never change from static inline everything will be
>> fine. I can change it, but I really like how it explicitly indicates
>
> I know what you want to do. But you're practically defining a helper
> which contains two arbitrary instructions which probably no one else
> will need.
>
> So how about we simplify this function even more. We don't need to pay
> attention to kexec being in progress because we're halting anyway so who
> cares how fast we halt.
>
> Might have to state that in the comment below though, instead of what's
> there now.
>
> And for the exact same moot reason, we don't need to look at SME CPUID
> feature - we can just as well WBINVD unconditionally.
>
> void stop_this_cpu(void *dummy)
> {
>         local_irq_disable();
>         /*
>          * Remove this CPU:
>          */
>         set_cpu_online(smp_processor_id(), false);
>         disable_local_APIC();
>         mcheck_cpu_clear(this_cpu_ptr(&cpu_info));
>
>         for (;;) {
>                 /*
>                  * If we are performing a kexec and the processor supports
>                  * SME then we need to clear out cache information before
>                  * halting. With kexec, going from SME inactive to SME active
>                  * requires clearing cache entries so that addresses without
>                  * the encryption bit set don't corrupt the same physical
>                  * address that has the encryption bit set when caches are
>                  * flushed. Perform a wbinvd followed by a halt to achieve
>                  * this.
>                  */
>                 asm volatile("wbinvd; hlt" ::: "memory");
>         }
> }
>
> How's that?

I can live with that!

Thanks,
Tom

>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
