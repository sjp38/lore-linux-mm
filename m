Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6B0186B0038
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 10:23:29 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id e186so5219494iof.9
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 07:23:29 -0800 (PST)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id k66si5364021itd.82.2018.01.17.07.23.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jan 2018 07:23:28 -0800 (PST)
Subject: Re: [PATCH 02/16] x86/entry/32: Enter the kernel via trampoline stack
References: <1516120619-1159-1-git-send-email-joro@8bytes.org>
 <1516120619-1159-3-git-send-email-joro@8bytes.org>
 <476d7100-2414-d09e-abf1-5aa4d369a3b7@oracle.com>
 <20180117090238.GH28161@8bytes.org>
 <97298add-9484-7d83-50a3-1c668ce3107d@citrix.com>
From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Message-ID: <b3357c67-15b9-3218-8b32-caa335a5ad1d@oracle.com>
Date: Wed, 17 Jan 2018 10:22:24 -0500
MIME-Version: 1.0
In-Reply-To: <97298add-9484-7d83-50a3-1c668ce3107d@citrix.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Cooper <andrew.cooper3@citrix.com>, Joerg Roedel <joro@8bytes.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, jroedel@suse.de

On 01/17/2018 09:04 AM, Andrew Cooper wrote:
> On 17/01/18 09:02, Joerg Roedel wrote:
>> Hi Boris,
>>
>> thanks for testing this :)
>>
>> On Tue, Jan 16, 2018 at 09:47:06PM -0500, Boris Ostrovsky wrote:
>>> On 01/16/2018 11:36 AM, Joerg Roedel wrote:
>>>> +.macro SWITCH_TO_KERNEL_STACK nr_regs=0 check_user=0
>>> This (and next patch's SWITCH_TO_ENTRY_STACK) need X86_FEATURE_PTI check.
>>>
>>> With those macros fixed I was able to boot 32-bit Xen PV guest.
>> Hmm, on bare metal the stack switch happens regardless of the
>> X86_FEATURE_PTI feature being set, because we always program tss.sp0
>> with the systenter stack. How is the kernel entry stack setup on xen-pv?
>> I think something is missing there instead.
> There is one single stack registered with Xen, on which you get a normal
> exception frame in all cases, even via the registered (virtual)
> syscall/sysenter/failsafe handlers.

And so the check should be at least against X86_FEATURE_XENPV, not
necessarily X86_FEATURE_PTI.

But I guess you can still check against X86_FEATURE_PTI since without it
there is not much reason to switch stacks?

-boris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
