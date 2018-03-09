Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3A0366B0005
	for <linux-mm@kvack.org>; Fri,  9 Mar 2018 13:32:34 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id b23so5021281oib.16
        for <linux-mm@kvack.org>; Fri, 09 Mar 2018 10:32:34 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id h22si447633otj.532.2018.03.09.10.32.32
        for <linux-mm@kvack.org>;
        Fri, 09 Mar 2018 10:32:33 -0800 (PST)
Subject: Re: [RFC PATCH 06/14] khwasan: enable top byte ignore for the kernel
References: <cover.1520017438.git.andreyknvl@google.com>
 <739eecf573b6342fc41c4f89d7f64eb8c183e312.1520017438.git.andreyknvl@google.com>
 <20180305143625.vtrfvsbw7loxngaj@lakrids.cambridge.arm.com>
 <b5f203ba-1f2f-d56e-9acf-6f269677f175@arm.com>
 <CAAeHK+yvG8Xc3PXBNM6Q6bqg8iNYJTRw+kx=R1Pqj6JG0ZkAkw@mail.gmail.com>
From: Marc Zyngier <marc.zyngier@arm.com>
Message-ID: <0377a2e1-ccc2-51bf-26b9-978eb685cdce@arm.com>
Date: Fri, 9 Mar 2018 18:32:16 +0000
MIME-Version: 1.0
In-Reply-To: <CAAeHK+yvG8Xc3PXBNM6Q6bqg8iNYJTRw+kx=R1Pqj6JG0ZkAkw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Mark Rutland <mark.rutland@arm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Yury Norov <ynorov@caviumnetworks.com>, Nick Desaulniers <ndesaulniers@google.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <Dave.Martin@arm.com>, James Morse <james.morse@arm.com>, Julien Thierry <julien.thierry@arm.com>, Michael Weiser <michael.weiser@gmx.de>, Steve Capper <steve.capper@arm.com>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Sandipan Das <sandipan@linux.vnet.ibm.com>, Paul Lawrence <paullawrence@google.com>, David Woodhouse <dwmw@amazon.co.uk>, Kees Cook <keescook@chromium.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Arnd Bergmann <arnd@arndb.de>, kasan-dev <kasan-dev@googlegroups.com>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-ext4@vger.kernel.org, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>

Hi Andrey,

On 09/03/18 18:21, Andrey Konovalov wrote:
> On Tue, Mar 6, 2018 at 3:24 PM, Marc Zyngier <marc.zyngier@arm.com> wrote:
>> On 05/03/18 14:36, Mark Rutland wrote:
>>> On Fri, Mar 02, 2018 at 08:44:25PM +0100, Andrey Konovalov wrote:
>>>> KHWASAN uses the Top Byte Ignore feature of arm64 CPUs to store a pointer
>>>> tag in the top byte of each pointer. This commit enables the TCR_TBI1 bit,
>>>> which enables Top Byte Ignore for the kernel, when KHWASAN is used.
>>>> ---
>>>>  arch/arm64/include/asm/pgtable-hwdef.h | 1 +
>>>>  arch/arm64/mm/proc.S                   | 8 +++++++-
>>>>  2 files changed, 8 insertions(+), 1 deletion(-)
>>>
>>> Before it's safe to do this, I also think you'll need to fix up at
>>> least:
>>>
>>> * virt_to_phys()
>>>
>>> * access_ok()
>>>
>>> ... and potentially others which assume that bits [63:56] of kernel
>>> addresses are 0xff. For example, bits of the fault handling logic might
>>> need fixups.
>>
>> Indeed. I have the ugly feeling that KVM (and anything that leaves in a
>> separate address space) will not be very happy with that change, as it
>> derives HYP VAs from the kernel VA, and doesn't expect lingering bits.
>> Nothing that cannot be addressed, but worth keeping in mind.
>>
> 
> Hi Marc!
> 
> Yes, I would expect there would be issues with KVM. I'll see if I can
> figure them out, but I think I'll just add a depends on !KVM or
> something like this, and will have to deal with KVM once the main part
> is committed.
Well, that's not quite how it works. KVM is an integral part of the
kernel, and I don't really want to have to deal with regression (not to
mention that KVM is an essential tool in our testing infrastructure).

You could try and exclude KVM from the instrumentation (which we already
have for invasive things such as KASAN), but I'm afraid that having a
debugging option that conflicts with another essential part of the
kernel is not an option.

I'm happy to help you with that though.

Thanks,

	M.
-- 
Jazz is not dead. It just smells funny...
