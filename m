Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 69AFB6B0007
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 12:17:14 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id g3so173710qtj.13
        for <linux-mm@kvack.org>; Fri, 09 Feb 2018 09:17:14 -0800 (PST)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id r9si2340342qtm.387.2018.02.09.09.17.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Feb 2018 09:17:13 -0800 (PST)
Subject: Re: [PATCH 09/31] x86/entry/32: Leave the kernel via trampoline stack
References: <1518168340-9392-1-git-send-email-joro@8bytes.org>
 <1518168340-9392-10-git-send-email-joro@8bytes.org>
 <CA+55aFzB9H=RT6YB3onZCephZMs9ccz4aJ_jcPcfEkKJD_YDCQ@mail.gmail.com>
From: Denys Vlasenko <dvlasenk@redhat.com>
Message-ID: <aa52108c-4874-9810-8ff5-e6415189cd73@redhat.com>
Date: Fri, 9 Feb 2018 18:17:07 +0100
MIME-Version: 1.0
In-Reply-To: <CA+55aFzB9H=RT6YB3onZCephZMs9ccz4aJ_jcPcfEkKJD_YDCQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Joerg Roedel <joro@8bytes.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, Joerg Roedel <jroedel@suse.de>

On 02/09/2018 06:05 PM, Linus Torvalds wrote:
> On Fri, Feb 9, 2018 at 1:25 AM, Joerg Roedel <joro@8bytes.org> wrote:
>> +
>> +       /* Copy over the stack-frame */
>> +       cld
>> +       rep movsb
> 
> Ugh. This is going to be horrendous. Maybe not noticeable on modern
> CPU's, but the whole 32-bit code is kind of pointless on a modern CPU.
> 
> At least use "rep movsl". If the kernel stack isn't 4-byte aligned,
> you have issues.

Indeed, "rep movs" has some setup overhead that makes it undesirable
for small sizes. In my testing, moving less than 128 bytes with "rep movs"
is a loss.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
