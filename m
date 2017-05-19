Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id F1EBE28073B
	for <linux-mm@kvack.org>; Fri, 19 May 2017 17:29:04 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id b28so6750440wrb.2
        for <linux-mm@kvack.org>; Fri, 19 May 2017 14:29:04 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTP id v108si4386501wrb.289.2017.05.19.14.29.03
        for <linux-mm@kvack.org>;
        Fri, 19 May 2017 14:29:03 -0700 (PDT)
Date: Fri, 19 May 2017 23:28:54 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v5 28/32] x86/mm, kexec: Allow kexec to be used with SME
Message-ID: <20170519212854.3dvtt3lawzij5cae@pd.tnic>
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
 <20170418212121.10190.94885.stgit@tlendack-t1.amdoffice.net>
 <20170517191755.h2xluopk2p6suw32@pd.tnic>
 <1b74e0e6-3dda-f638-461b-f73af9904360@amd.com>
 <20170519205836.3wvl3nztqyyouje3@pd.tnic>
 <5ef96f3a-6ebd-1d4d-7ac9-05dbed45d998@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <5ef96f3a-6ebd-1d4d-7ac9-05dbed45d998@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Fri, May 19, 2017 at 04:07:24PM -0500, Tom Lendacky wrote:
> As long as those never change from static inline everything will be
> fine. I can change it, but I really like how it explicitly indicates

I know what you want to do. But you're practically defining a helper
which contains two arbitrary instructions which probably no one else
will need.

So how about we simplify this function even more. We don't need to pay
attention to kexec being in progress because we're halting anyway so who
cares how fast we halt.

Might have to state that in the comment below though, instead of what's
there now.

And for the exact same moot reason, we don't need to look at SME CPUID
feature - we can just as well WBINVD unconditionally.

void stop_this_cpu(void *dummy)
{
        local_irq_disable();
        /*
         * Remove this CPU:
         */
        set_cpu_online(smp_processor_id(), false);
        disable_local_APIC();
        mcheck_cpu_clear(this_cpu_ptr(&cpu_info));

        for (;;) {
                /*
                 * If we are performing a kexec and the processor supports
                 * SME then we need to clear out cache information before
                 * halting. With kexec, going from SME inactive to SME active
                 * requires clearing cache entries so that addresses without
                 * the encryption bit set don't corrupt the same physical
                 * address that has the encryption bit set when caches are
                 * flushed. Perform a wbinvd followed by a halt to achieve
                 * this.
                 */
                asm volatile("wbinvd; hlt" ::: "memory");
        }
}

How's that?

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
