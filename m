Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id E3BEE6B0003
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 09:24:20 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id j17so10467286oib.21
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 06:24:20 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id q16si4697219otq.377.2018.03.06.06.24.19
        for <linux-mm@kvack.org>;
        Tue, 06 Mar 2018 06:24:19 -0800 (PST)
Subject: Re: [RFC PATCH 06/14] khwasan: enable top byte ignore for the kernel
References: <cover.1520017438.git.andreyknvl@google.com>
 <739eecf573b6342fc41c4f89d7f64eb8c183e312.1520017438.git.andreyknvl@google.com>
 <20180305143625.vtrfvsbw7loxngaj@lakrids.cambridge.arm.com>
From: Marc Zyngier <marc.zyngier@arm.com>
Message-ID: <b5f203ba-1f2f-d56e-9acf-6f269677f175@arm.com>
Date: Tue, 6 Mar 2018 14:24:06 +0000
MIME-Version: 1.0
In-Reply-To: <20180305143625.vtrfvsbw7loxngaj@lakrids.cambridge.arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>, Andrey Konovalov <andreyknvl@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Yury Norov <ynorov@caviumnetworks.com>, Nick Desaulniers <ndesaulniers@google.com>, Bob Picco <bob.picco@oracle.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <Dave.Martin@arm.com>, James Morse <james.morse@arm.com>, Julien Thierry <julien.thierry@arm.com>, Michael Weiser <michael.weiser@gmx.de>, Steve Capper <steve.capper@arm.com>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Sandipan Das <sandipan@linux.vnet.ibm.com>, Paul Lawrence <paullawrence@google.com>, David Woodhouse <dwmw@amazon.co.uk>, Kees Cook <keescook@chromium.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Arnd Bergmann <arnd@arndb.de>, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ext4@vger.kernel.org, linux-sparse@vger.kernel.org, linux-mm@kvack.org, linux-kbuild@vger.kernel.org, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>

On 05/03/18 14:36, Mark Rutland wrote:
> On Fri, Mar 02, 2018 at 08:44:25PM +0100, Andrey Konovalov wrote:
>> KHWASAN uses the Top Byte Ignore feature of arm64 CPUs to store a pointer
>> tag in the top byte of each pointer. This commit enables the TCR_TBI1 bit,
>> which enables Top Byte Ignore for the kernel, when KHWASAN is used.
>> ---
>>  arch/arm64/include/asm/pgtable-hwdef.h | 1 +
>>  arch/arm64/mm/proc.S                   | 8 +++++++-
>>  2 files changed, 8 insertions(+), 1 deletion(-)
> 
> Before it's safe to do this, I also think you'll need to fix up at
> least:
> 
> * virt_to_phys()
> 
> * access_ok()
> 
> ... and potentially others which assume that bits [63:56] of kernel
> addresses are 0xff. For example, bits of the fault handling logic might
> need fixups.

Indeed. I have the ugly feeling that KVM (and anything that leaves in a
separate address space) will not be very happy with that change, as it
derives HYP VAs from the kernel VA, and doesn't expect lingering bits.
Nothing that cannot be addressed, but worth keeping in mind.

Thanks,

	M.
-- 
Jazz is not dead. It just smells funny...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
