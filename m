Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id 023A66B0033
	for <linux-mm@kvack.org>; Mon, 15 Jan 2018 15:06:20 -0500 (EST)
Received: by mail-vk0-f70.google.com with SMTP id z134so8474431vkd.5
        for <linux-mm@kvack.org>; Mon, 15 Jan 2018 12:06:19 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 69sor195717uad.7.2018.01.15.12.06.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 15 Jan 2018 12:06:18 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180115122458.GI12608@e103592.cambridge.arm.com>
References: <1515636190-24061-1-git-send-email-keescook@chromium.org>
 <1515636190-24061-34-git-send-email-keescook@chromium.org> <20180115122458.GI12608@e103592.cambridge.arm.com>
From: Kees Cook <keescook@chromium.org>
Date: Mon, 15 Jan 2018 12:06:17 -0800
Message-ID: <CAGXu5jLHb3BQ9U7g6suoVZwVeETiXiCRbxsprpLNiFxcjcWk1A@mail.gmail.com>
Subject: Re: [PATCH 33/38] arm64: Implement thread_struct whitelist for
 hardened usercopy
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave P Martin <Dave.Martin@arm.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Catalin Marinas <Catalin.Marinas@arm.com>, Will Deacon <Will.Deacon@arm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Ingo Molnar <mingo@kernel.org>, James Morse <James.Morse@arm.com>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, zijun_hu <zijun_hu@htc.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, David Windsor <dave@nullcore.net>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Christoph Hellwig <hch@infradead.org>, Christoph Lameter <cl@linux.com>, "David S. Miller" <davem@davemloft.net>, Laura Abbott <labbott@redhat.com>, Mark Rutland <Mark.Rutland@arm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Christoffer Dall <christoffer.dall@linaro.org>, Dave Kleikamp <dave.kleikamp@oracle.com>, Jan Kara <jack@suse.cz>, Luis de Bethencourt <luisbg@kernel.org>, Marc Zyngier <Marc.Zyngier@arm.com>, Rik van Riel <riel@redhat.com>, Matthew Garrett <mjg59@google.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On Mon, Jan 15, 2018 at 4:24 AM, Dave P Martin <Dave.Martin@arm.com> wrote:
> On Thu, Jan 11, 2018 at 02:03:05AM +0000, Kees Cook wrote:
>> This whitelists the FPU register state portion of the thread_struct for
>> copying to userspace, instead of the default entire structure.
>>
>> Cc: Catalin Marinas <catalin.marinas@arm.com>
>> Cc: Will Deacon <will.deacon@arm.com>
>> Cc: Christian Borntraeger <borntraeger@de.ibm.com>
>> Cc: Ingo Molnar <mingo@kernel.org>
>> Cc: James Morse <james.morse@arm.com>
>> Cc: "Peter Zijlstra (Intel)" <peterz@infradead.org>
>> Cc: Dave Martin <Dave.Martin@arm.com>
>> Cc: zijun_hu <zijun_hu@htc.com>
>> Cc: linux-arm-kernel@lists.infradead.org
>> Signed-off-by: Kees Cook <keescook@chromium.org>
>> ---
>>  arch/arm64/Kconfig                 | 1 +
>>  arch/arm64/include/asm/processor.h | 8 ++++++++
>>  2 files changed, 9 insertions(+)
>>
>> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
>> index a93339f5178f..c84477e6a884 100644
>> --- a/arch/arm64/Kconfig
>> +++ b/arch/arm64/Kconfig
>> @@ -90,6 +90,7 @@ config ARM64
>>       select HAVE_ARCH_MMAP_RND_BITS
>>       select HAVE_ARCH_MMAP_RND_COMPAT_BITS if COMPAT
>>       select HAVE_ARCH_SECCOMP_FILTER
>> +     select HAVE_ARCH_THREAD_STRUCT_WHITELIST
>>       select HAVE_ARCH_TRACEHOOK
>>       select HAVE_ARCH_TRANSPARENT_HUGEPAGE
>>       select HAVE_ARCH_VMAP_STACK
>> diff --git a/arch/arm64/include/asm/processor.h b/arch/arm64/include/asm/processor.h
>> index 023cacb946c3..e58a5864ec89 100644
>> --- a/arch/arm64/include/asm/processor.h
>> +++ b/arch/arm64/include/asm/processor.h
>> @@ -113,6 +113,14 @@ struct thread_struct {
>>       struct debug_info       debug;          /* debugging */
>>  };
>>
>> +/* Whitelist the fpsimd_state for copying to userspace. */
>> +static inline void arch_thread_struct_whitelist(unsigned long *offset,
>> +                                             unsigned long *size)
>> +{
>> +     *offset = offsetof(struct thread_struct, fpsimd_state);
>> +     *size = sizeof(struct fpsimd_state);
>
> This should be fpsimd_state.user_fpsimd (fpsimd_state.cpu is important
> for correctly context switching and not supposed to be user-accessible.
> A user copy that encompasses that is definitely a bug).

So, I actually spent some more time looking at this due to the
comments from rmk on arm32, and I don't think any whitelist is needed
here at all. (i.e. it can be *offset = *size = 0) This is because all
the usercopying I could find uses static sizes or bounce buffers, both
of which bypass the dynamic-size hardened usercopy checks.

I've been running some arm64 builds now with this change, and I
haven't tripped over any problems yet...

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
