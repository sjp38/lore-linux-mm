Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id E4BB96B0068
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 14:31:01 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id l73so2259930qke.9
        for <linux-mm@kvack.org>; Fri, 09 Feb 2018 11:31:01 -0800 (PST)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id h190si2977454qkc.177.2018.02.09.11.31.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Feb 2018 11:31:01 -0800 (PST)
Subject: Re: [PATCH 09/31] x86/entry/32: Leave the kernel via trampoline stack
References: <1518168340-9392-1-git-send-email-joro@8bytes.org>
 <1518168340-9392-10-git-send-email-joro@8bytes.org>
 <CA+55aFzB9H=RT6YB3onZCephZMs9ccz4aJ_jcPcfEkKJD_YDCQ@mail.gmail.com>
 <20180209190226.lqh6twf7thfg52cq@suse.de>
From: Denys Vlasenko <dvlasenk@redhat.com>
Message-ID: <4a047ea5-7717-d089-48bf-597434be7c4c@redhat.com>
Date: Fri, 9 Feb 2018 20:30:55 +0100
MIME-Version: 1.0
In-Reply-To: <20180209190226.lqh6twf7thfg52cq@suse.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <jroedel@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>

On 02/09/2018 08:02 PM, Joerg Roedel wrote:
> On Fri, Feb 09, 2018 at 09:05:02AM -0800, Linus Torvalds wrote:
>> On Fri, Feb 9, 2018 at 1:25 AM, Joerg Roedel <joro@8bytes.org> wrote:
>>> +
>>> +       /* Copy over the stack-frame */
>>> +       cld
>>> +       rep movsb
>>
>> Ugh. This is going to be horrendous. Maybe not noticeable on modern
>> CPU's, but the whole 32-bit code is kind of pointless on a modern CPU.
>>
>> At least use "rep movsl". If the kernel stack isn't 4-byte aligned,
>> you have issues.
>
> Okay, I used movsb because I remembered that being the recommendation
> for the most efficient memcpy, and it safes me an instruction. But that
> is probably only true on modern CPUs.

It's fast (copies data with full-width loads and stores,
up to 64-byte wide on latest Intel CPUs), but this kicks in only for
largish blocks. In your case, you are copying less than 100 bytes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
