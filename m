Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7434A6B038C
	for <linux-mm@kvack.org>; Tue, 14 Mar 2017 18:45:22 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id k13so1406206ywk.2
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 15:45:22 -0700 (PDT)
Received: from mail.zytor.com ([2001:1868:a000:17::138])
        by mx.google.com with ESMTPS id g81si13729ywe.195.2017.03.14.15.45.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Mar 2017 15:45:21 -0700 (PDT)
From: "H. Peter Anvin" <hpa@zytor.com>
Message-Id: <201703142243.v2EMh8Nn010676@mail.zytor.com>
Date: Tue, 14 Mar 2017 15:43:01 -0700
In-Reply-To: <CAJcbSZG7ds+q76dHtzOkYtMkkTXWwG3e7MAxKJi0=SmdmqA6tA@mail.gmail.com>
References: <20170314170508.100882-1-thgarnie@google.com> <20170314170508.100882-3-thgarnie@google.com> <20170314210424.GA5023@amd> <CAJcbSZG7ds+q76dHtzOkYtMkkTXWwG3e7MAxKJi0=SmdmqA6tA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Subject: Re: [PATCH v7 3/3] x86: Make the GDT remapping read-only on 64-bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Garnier <thgarnie@google.com>, Pavel Machek <pavel@ucw.cz>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Lorenzo Stoakes <lstoakes@gmail.com>, Kees Cook <keescook@chromium.org>, Juergen Gross <jgross@suse.com>, Andy Lutomirski <luto@kernel.org>, Paul Gortmaker <paul.gortmaker@windriver.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, zijun_hu <zijun_hu@htc.com>, Chris Wilson <chris@chris-wilson.co.uk>, Andy Lutomirski <luto@amacapital.net>, "Rafael J . Wysocki" <rjw@rjwysocki.net>, Len Brown <len.brown@intel.com>, Jiri Kosina <jikos@kernel.org>, Matt Fleming <matt@codeblueprint.co.uk>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Rusty Russell <rusty@rustcorp.com.au>, Paolo Bonzini <pbonzini@redhat.com>, Borislav Petkov <bp@suse.de>, Christian Borntraeger <borntraeger@de.ibm.com>, Frederic.Weisbecker@zytor.com

<fweisbec@gmail.com>,"Luis R . Rodriguez" <mcgrof@kernel.org>,Stanislaw Gruszka <sgruszka@redhat.com>,Peter Zijlstra <peterz@infradead.org>,Josh Poimboeuf <jpoimboe@redhat.com>,Vitaly Kuznetsov <vkuznets@redhat.com>,Tim Chen <tim.c.chen@linux.intel.com>,Joerg Roedel <joro@8bytes.org>,=?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>,the arch/x86 maintainers <x86@kernel.org>,LKML <linux-kernel@vger.kernel.org>,linux-doc@vger.kernel.org,kasan-dev <kasan-dev@googlegroups.com>,Linux-MM <linux-mm@kvack.org>,Linux PM list <linux-pm@vger.kernel.org>,linux-efi@vger.kernel.org,xen-devel@lists.xenproject.org,lguest@lists.ozlabs.org,kvm list <kvm@vger.kernel.org>,Kernel Hardening <kernel-hardening@lists.openwall.com>
From: hpa@zytor.com
Message-ID: <550F6209-025A-45E2-84E2-F00A3771C0B1@zytor.com>

On March 14, 2017 2:20:19 PM PDT, Thomas Garnier <thgarnie@google=2Ecom> wr=
ote:
>On Tue, Mar 14, 2017 at 2:04 PM, Pavel Machek <pavel@ucw=2Ecz> wrote:
>> On Tue 2017-03-14 10:05:08, Thomas Garnier wrote:
>>> This patch makes the GDT remapped pages read-only to prevent
>corruption=2E
>>> This change is done only on 64-bit=2E
>>>
>>> The native_load_tr_desc function was adapted to correctly handle a
>>> read-only GDT=2E The LTR instruction always writes to the GDT TSS
>entry=2E
>>> This generates a page fault if the GDT is read-only=2E This change
>checks
>>> if the current GDT is a remap and swap GDTs as needed=2E This function
>was
>>> tested by booting multiple machines and checking hibernation works
>>> properly=2E
>>>
>>> KVM SVM and VMX were adapted to use the writeable GDT=2E On VMX, the
>>> per-cpu variable was removed for functions to fetch the original
>GDT=2E
>>> Instead of reloading the previous GDT, VMX will reload the fixmap
>GDT as
>>> expected=2E For testing, VMs were started and restored on multiple
>>> configurations=2E
>>>
>>> Signed-off-by: Thomas Garnier <thgarnie@google=2Ecom>
>>
>> Can we get the same change for 32-bit, too? Growing differences
>> between 32 and 64 bit are a bit of a problem=2E=2E=2E
>>                                                                 Pavel
>
>It was discussed on previous versions that 32-bit read-only support
>would create issues that why it was favor for 64-bit only right now=2E
>
>>
>> --
>> (english) http://www=2Elivejournal=2Ecom/~pavelmachek
>> (cesky, pictures)
>http://atrey=2Ekarlin=2Emff=2Ecuni=2Ecz/~pavel/picture/horses/blog=2Ehtml

We can't make the GDT read-only on 32 bits since we use task switches for =
last-resort recovery=2E  64 bits has IST instead=2E
--=20
Sent from my Android device with K-9 Mail=2E Please excuse my brevity=2E

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
