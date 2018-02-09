Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1EDFD6B0005
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 08:54:48 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id b53so672260wrd.1
        for <linux-mm@kvack.org>; Fri, 09 Feb 2018 05:54:48 -0800 (PST)
Received: from SMTP.EU.CITRIX.COM (smtp.eu.citrix.com. [185.25.65.24])
        by mx.google.com with ESMTPS id x30si391200ede.375.2018.02.09.05.54.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Feb 2018 05:54:46 -0800 (PST)
Subject: Re: [PATCH 00/31 v2] PTI support for x86_32
References: <1518168340-9392-1-git-send-email-joro@8bytes.org>
 <35f19c79-7277-3ad8-50bf-8def929377b6@suse.com>
 <20180209133507.GD16484@8bytes.org>
From: Andrew Cooper <andrew.cooper3@citrix.com>
Message-ID: <9ca8429b-4ae4-e009-69b0-c4945be41e65@citrix.com>
Date: Fri, 9 Feb 2018 13:54:44 +0000
MIME-Version: 1.0
In-Reply-To: <20180209133507.GD16484@8bytes.org>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Content-Language: en-GB
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>, Juergen Gross <jgross@suse.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H .
 Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, jroedel@suse.de

On 09/02/18 13:35, Joerg Roedel wrote:
> Hi Juergen,
>
> On Fri, Feb 09, 2018 at 01:11:42PM +0100, Juergen Gross wrote:
>> On 09/02/18 10:25, Joerg Roedel wrote:
>>> XENPV is also untested from my side, but I added checks to
>>> not do the stack switches in the entry-code when XENPV is
>>> enabled, so hopefully it works. But someone should test it,
>>> of course.
>> That's unfortunate. 32 bit XENPV kernel is vulnerable to Meltdown, too.
>> I'll have a look whether 32 bit XENPV is still working, though.
>>
>> Adding support for KPTI with Xen PV should probably be done later. :-)
> Not sure how much is missing to make it work there, one point is
> certainly to write the right stack into tss.sp0 for xenpv on 32bit. This
> write has a check to only happen for !xenpv.
>
> But let's first test the code as-is on XENPV and see if it still boots
> :)

IMO, the only sensible way to do KPTI + Xen PV is to have Xen to do the
pagetable switch for 32bit like we already do for 64bit guests.A  All
context switches already pass through the hypervisor, and it saves the
guest having to make the updates itself (which will trap for auditing)
or having to juggle the set_stack_base() semantics.

~Andrew

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
