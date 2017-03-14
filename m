Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0CC966B0392
	for <linux-mm@kvack.org>; Tue, 14 Mar 2017 17:20:21 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id u69so9624079ita.1
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 14:20:21 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 10sor107550iti.2.1969.12.31.16.00.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 14 Mar 2017 14:20:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170314210424.GA5023@amd>
References: <20170314170508.100882-1-thgarnie@google.com> <20170314170508.100882-3-thgarnie@google.com>
 <20170314210424.GA5023@amd>
From: Thomas Garnier <thgarnie@google.com>
Date: Tue, 14 Mar 2017 14:20:19 -0700
Message-ID: <CAJcbSZG7ds+q76dHtzOkYtMkkTXWwG3e7MAxKJi0=SmdmqA6tA@mail.gmail.com>
Subject: Re: [PATCH v7 3/3] x86: Make the GDT remapping read-only on 64-bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, Jonathan Corbet <corbet@lwn.net>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Lorenzo Stoakes <lstoakes@gmail.com>, Kees Cook <keescook@chromium.org>, Juergen Gross <jgross@suse.com>, Andy Lutomirski <luto@kernel.org>, Paul Gortmaker <paul.gortmaker@windriver.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, zijun_hu <zijun_hu@htc.com>, Chris Wilson <chris@chris-wilson.co.uk>, Andy Lutomirski <luto@amacapital.net>, "Rafael J . Wysocki" <rjw@rjwysocki.net>, Len Brown <len.brown@intel.com>, Jiri Kosina <jikos@kernel.org>, Matt Fleming <matt@codeblueprint.co.uk>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Rusty Russell <rusty@rustcorp.com.au>, Paolo Bonzini <pbonzini@redhat.com>, Borislav Petkov <bp@suse.de>, Christian Borntraeger <borntraeger@de.ibm.com>, Frederic Weisbecker <fweisbec@gmail.com>, "Luis R . Rodriguez" <mcgrof@kernel.org>, Stanislaw Gruszka <sgruszka@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, Tim Chen <tim.c.chen@linux.intel.com>, Joerg Roedel <joro@8bytes.org>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, the arch/x86 maintainers <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>, Linux PM list <linux-pm@vger.kernel.org>, linux-efi@vger.kernel.org, xen-devel@lists.xenproject.org, lguest@lists.ozlabs.org, kvm list <kvm@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

On Tue, Mar 14, 2017 at 2:04 PM, Pavel Machek <pavel@ucw.cz> wrote:
> On Tue 2017-03-14 10:05:08, Thomas Garnier wrote:
>> This patch makes the GDT remapped pages read-only to prevent corruption.
>> This change is done only on 64-bit.
>>
>> The native_load_tr_desc function was adapted to correctly handle a
>> read-only GDT. The LTR instruction always writes to the GDT TSS entry.
>> This generates a page fault if the GDT is read-only. This change checks
>> if the current GDT is a remap and swap GDTs as needed. This function was
>> tested by booting multiple machines and checking hibernation works
>> properly.
>>
>> KVM SVM and VMX were adapted to use the writeable GDT. On VMX, the
>> per-cpu variable was removed for functions to fetch the original GDT.
>> Instead of reloading the previous GDT, VMX will reload the fixmap GDT as
>> expected. For testing, VMs were started and restored on multiple
>> configurations.
>>
>> Signed-off-by: Thomas Garnier <thgarnie@google.com>
>
> Can we get the same change for 32-bit, too? Growing differences
> between 32 and 64 bit are a bit of a problem...
>                                                                 Pavel

It was discussed on previous versions that 32-bit read-only support
would create issues that why it was favor for 64-bit only right now.

>
> --
> (english) http://www.livejournal.com/~pavelmachek
> (cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html



-- 
Thomas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
