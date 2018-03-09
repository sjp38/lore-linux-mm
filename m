Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 928816B0005
	for <linux-mm@kvack.org>; Fri,  9 Mar 2018 14:06:12 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id h7so5427291oti.23
        for <linux-mm@kvack.org>; Fri, 09 Mar 2018 11:06:12 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id z48si493011otc.308.2018.03.09.11.06.11
        for <linux-mm@kvack.org>;
        Fri, 09 Mar 2018 11:06:11 -0800 (PST)
Subject: Re: [RFC PATCH 06/14] khwasan: enable top byte ignore for the kernel
References: <cover.1520017438.git.andreyknvl@google.com>
 <739eecf573b6342fc41c4f89d7f64eb8c183e312.1520017438.git.andreyknvl@google.com>
 <20180305143625.vtrfvsbw7loxngaj@lakrids.cambridge.arm.com>
 <b5f203ba-1f2f-d56e-9acf-6f269677f175@arm.com>
 <CAAeHK+yvG8Xc3PXBNM6Q6bqg8iNYJTRw+kx=R1Pqj6JG0ZkAkw@mail.gmail.com>
 <0377a2e1-ccc2-51bf-26b9-978eb685cdce@arm.com>
 <CAAeHK+zyGQtNxap6N5s11MWrQS-Y_uA7TRQnh5oP=HWZjPytsw@mail.gmail.com>
From: Marc Zyngier <marc.zyngier@arm.com>
Message-ID: <cd5c305a-407d-3dcd-7c4e-7a3bc13b0da9@arm.com>
Date: Fri, 9 Mar 2018 19:06:01 +0000
MIME-Version: 1.0
In-Reply-To: <CAAeHK+zyGQtNxap6N5s11MWrQS-Y_uA7TRQnh5oP=HWZjPytsw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Mark Rutland <mark.rutland@arm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Yury Norov <ynorov@caviumnetworks.com>, Nick Desaulniers <ndesaulniers@google.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <Dave.Martin@arm.com>, James Morse <james.morse@arm.com>, Julien Thierry <julien.thierry@arm.com>, Michael Weiser <michael.weiser@gmx.de>, Steve Capper <steve.capper@arm.com>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Sandipan Das <sandipan@linux.vnet.ibm.com>, Paul Lawrence <paullawrence@google.com>, David Woodhouse <dwmw@amazon.co.uk>, Kees Cook <keescook@chromium.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Arnd Bergmann <arnd@arndb.de>, kasan-dev <kasan-dev@googlegroups.com>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-ext4@vger.kernel.org, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>

On 09/03/18 18:42, Andrey Konovalov wrote:
> On Fri, Mar 9, 2018 at 7:32 PM, Marc Zyngier <marc.zyngier@arm.com> wrote:
>> Well, that's not quite how it works. KVM is an integral part of the
>> kernel, and I don't really want to have to deal with regression (not to
>> mention that KVM is an essential tool in our testing infrastructure).
>>
>> You could try and exclude KVM from the instrumentation (which we already
>> have for invasive things such as KASAN), but I'm afraid that having a
>> debugging option that conflicts with another essential part of the
>> kernel is not an option.
>>
>> I'm happy to help you with that though.
>>
> 
> Hm, KHWASAN instruments the very same parts of the kernel that KASAN
> does (it reuses the same flag). I've checked, I actually have
> CONFIG_KVM enabled in my test build, however I haven't tried to test
> KVM yet. I'm planning to perform extensive fuzzing of the kernel with
> syzkaller, so if there's any crashes caused by KHWASAN in kvm code
> I'll see them. However if some bugs don't manifest as crashes, that
> would be a difficult thing to detect for me.

Well, if something is wrong in KVM, it usually manifests itself
extremely quickly, and takes the whole box with it. I have the ugly
feeling that feeding coloured pointers to KVM is going to be a fun ride
though.

Also, last time I checked Clang couldn't even compile KVM correctly.
Hopefully, things have changed...

Thanks,

	M.
-- 
Jazz is not dead. It just smells funny...
