Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0E2922808E3
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 16:58:02 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id w189so130366092pfb.4
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 13:58:02 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id b1si905870pfa.254.2017.03.09.13.58.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Mar 2017 13:58:01 -0800 (PST)
Subject: Re: [Xen-devel] [PATCH v5 2/3] x86: Remap GDT tables in the Fixmap
 section
References: <20170306220348.79702-1-thgarnie@google.com>
 <20170306220348.79702-2-thgarnie@google.com>
 <CALCETrVXHc-EAhBtdhL9FXSW1G2VbohRY4UJuOtpRG1K0Q-Ogg@mail.gmail.com>
 <17ffcc5b-1c9a-51b6-272a-5eaecf1bc0c4@citrix.com>
 <CALCETrWv-u7OdjWDY+5eF7p-ngPun-yYf0QegMzYc6MGVQd-4w@mail.gmail.com>
 <CAJcbSZExVWA0jvAoxLLc+58Ag9cHchifrHP=fFfzU_onHo2PyA@mail.gmail.com>
From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Message-ID: <5cf31779-45c5-d37f-86bc-d5afb3fb7ab6@oracle.com>
Date: Thu, 9 Mar 2017 16:56:33 -0500
MIME-Version: 1.0
In-Reply-To: <CAJcbSZExVWA0jvAoxLLc+58Ag9cHchifrHP=fFfzU_onHo2PyA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Garnier <thgarnie@google.com>, Andy Lutomirski <luto@amacapital.net>
Cc: Andrew Cooper <andrew.cooper3@citrix.com>, Michal Hocko <mhocko@suse.com>, Stanislaw Gruszka <sgruszka@redhat.com>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, kvm list <kvm@vger.kernel.org>, Fenghua Yu <fenghua.yu@intel.com>, Matt Fleming <matt@codeblueprint.co.uk>, Frederic Weisbecker <fweisbec@gmail.com>, X86 ML <x86@kernel.org>, Chris Wilson <chris@chris-wilson.co.uk>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Paul Gortmaker <paul.gortmaker@windriver.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, Alexander Potapenko <glider@google.com>, Pavel Machek <pavel@ucw.cz>, "H . Peter Anvin" <hpa@zytor.com>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Jiri Olsa <jolsa@redhat.com>, zijun_hu <zijun_hu@htc.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <ak@linux.intel.com>, "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>, Jonathan Corbet <corbet@lwn.net>, Michael Ellerman <mpe@ellerman.id.au>, Joerg Roedel <joro@8bytes.org>, Prarit Bhargava <prarit@redhat.com>, kasan-dev <kasan-dev@googlegroups.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Ingo Molnar <mingo@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Borislav Petkov <bp@suse.de>, Len Brown <len.brown@intel.com>, Rusty Russell <rusty@rustcorp.com.au>, Kees Cook <keescook@chromium.org>, Arnd Bergmann <arnd@arndb.de>, He Chen <he.chen@linux.intel.com>, Brian Gerst <brgerst@gmail.com>, Jiri Kosina <jikos@kernel.org>, lguest@lists.ozlabs.org, Andy Lutomirski <luto@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Lorenzo Stoakes <lstoakes@gmail.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "linux-pm@vger.kernel.org" <linux-pm@vger.kernel.org>, "Rafael J . Wysocki" <rjw@rjwysocki.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Luis R . Rodriguez" <mcgrof@kernel.org>, David Vrabel <david.vrabel@citrix.com>, Paolo Bonzini <pbonzini@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Tim Chen <tim.c.chen@linux.intel.com>

On 03/09/2017 04:54 PM, Thomas Garnier wrote:
> On Thu, Mar 9, 2017 at 1:46 PM, Andy Lutomirski <luto@amacapital.net> wrote:
>> On Thu, Mar 9, 2017 at 1:43 PM, Andrew Cooper <andrew.cooper3@citrix.com> wrote:
>>> On 09/03/2017 21:32, Andy Lutomirski wrote:
>>>> On Mon, Mar 6, 2017 at 2:03 PM, Thomas Garnier <thgarnie@google.com> wrote:
>>>>
>>>>> --- a/arch/x86/xen/enlighten.c
>>>>> +++ b/arch/x86/xen/enlighten.c
>>>>> @@ -710,7 +710,7 @@ static void load_TLS_descriptor(struct thread_struct *t,
>>>>>
>>>>>         *shadow = t->tls_array[i];
>>>>>
>>>>> -       gdt = get_cpu_gdt_table(cpu);
>>>>> +       gdt = get_cpu_gdt_rw(cpu);
>>>>>         maddr = arbitrary_virt_to_machine(&gdt[GDT_ENTRY_TLS_MIN+i]);
>>>>>         mc = __xen_mc_entry(0);
>>>> Boris, is this right?  I don't see why it wouldn't be, but Xen is special.
>>> Under Xen PV, the GDT is already read-only at this point.  (It is not
>>> safe to let the guest have writeable access to system tables, so the
>>> guest must relinquish write access to the frames wishing to be used as
>>> LDTs or GDTs.)
>>>
>>> The hypercall acts on the frame, not a virtual address, so either alias
>>> should be fine here.
>>>
>>> Under this new scheme, there will be two read-only aliases.  I guess
>>> this is easier to maintain the split consistently across Linux, than to
>>> special case Xen PV because it doesn't need the second alias.
>>>
>> I think we would gain nothing at all by special-casing Xen PV -- Linux
>> allocates the fixmap vaddrs at compile time, so we'd still allocate
>> them even if we rejigger all the helpers to avoid using them.
>>
> I don't have any experience with Xen so it would be great if virtme can test it.


I am pretty sure I tested this series at some point but I'll test it again.

-boris


>
> I can remove the unused functions, I just thought they were useful
> shortcuts given some of them are already used.
>
>> --Andy
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
