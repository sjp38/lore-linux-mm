Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 788A46B0038
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 16:35:54 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id y62so3316616pfd.3
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 13:35:54 -0800 (PST)
Received: from mail.zytor.com (terminus.zytor.com. [65.50.211.136])
        by mx.google.com with ESMTPS id 33si1904283ply.166.2017.11.29.13.35.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Nov 2017 13:35:53 -0800 (PST)
Subject: Re: [PATCHv2 0/4] x86: 5-level related changes into decompression
 code
References: <20171110220645.59944-1-kirill.shutemov@linux.intel.com>
 <20171129154908.6y4st6xc7hbsey2v@pd.tnic>
 <20171129161349.d7ksuhwhdamloty6@node.shutemov.name>
 <alpine.DEB.2.20.1711291740050.1825@nanos>
 <20171129170831.2iqpop2u534mgrbc@node.shutemov.name>
 <20171129174851.jk2ai37uumxve6sg@pd.tnic>
 <793b9c55-e85b-97b5-c857-dd8edcda4081@zytor.com>
 <20171129191902.2iamm3m23e3gwnj4@pd.tnic>
From: "H. Peter Anvin" <hpa@zytor.com>
Message-ID: <e4463396-9b7c-2fe8-534c-73820c0bce5f@zytor.com>
Date: Wed, 29 Nov 2017 13:33:28 -0800
MIME-Version: 1.0
In-Reply-To: <20171129191902.2iamm3m23e3gwnj4@pd.tnic>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@suse.de>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Thomas Gleixner <tglx@linutronix.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 11/29/17 11:19, Borislav Petkov wrote:
> On Wed, Nov 29, 2017 at 11:01:35AM -0800, H. Peter Anvin wrote:
>> We can hang the machine, or we can triple-fault it in the hope of
>> triggering a reset, and that way if the bootloader has been configured
>> with a backup kernel there is a hope of recovery.
> 
> Well, it triple-faults right now and that's not really user-friendly. If
> we can't dump a message than we should make X86_5LEVEL depend on BROKEN
> for the time being...
> 

You can't dump a message about *anything* if the bootloader bypasses the
checks that happen before we leave the firmware behind.  This is what
this is about.  For BIOS or EFI boot that go through the proper stub
functions we will print a message just fine, as we already validate the
"required features" structure (although please do verify that the
relevant words are indeed being checked.)

However, if the bootloader jumps straight into the code what do you
expect it to do?  We have no real concept about what we'd need to do to
issue a message as we really don't know what devices are available on
the system, etc.  If the screen_info field in struct boot_params has
been initialized then we actually *do* know how to write to the screen
-- if you are okay with including a text font etc. since modern systems
boot in graphics mode.

What else could we do?  I guess we could add a new field -- which
bootloaders would have to add support for -- for a callback to the
bootloader in case of an early-detected fatal kernel initialization
error.  This would have some... interesting(*)... issues with it, and
wouldn't resolve anything for existing bootloaders, but perhaps it is a
worthwhile extension going forward.

	-hpa

(*) The bootloader would have to be prepared for a largely undefined CPU
    state, in a rarely executed path.  However, it is arguably no worse
    than what we have now.  Current bootloaders *can* at least know all
    the memory the kernel will use before the kernel's own memory
    management takes over, so it is possible for it to allocate the
    kernel in such a way that its own code/data is preserved.

    It is at least possible to determine which major CPU mode we are
    running in when we get to that entrypoint.  The following code
    snippet will do it:

entry:
	.code16
	dec %ax
	mov $0,%ax
	jmp 16f
	nop
	nop
	jmp 32f
	.code64
	jmp code_64
	.code32
32:	jmp code_32
	.code16
16:	/* Arbitrary 16-bit code can start here */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
