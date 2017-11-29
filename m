Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2504E6B0253
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 14:03:52 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id e26so3036299pfi.15
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 11:03:52 -0800 (PST)
Received: from mail.zytor.com (terminus.zytor.com. [65.50.211.136])
        by mx.google.com with ESMTPS id z23si1685102pgn.90.2017.11.29.11.03.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Nov 2017 11:03:50 -0800 (PST)
Subject: Re: [PATCHv2 0/4] x86: 5-level related changes into decompression
 code
References: <20171110220645.59944-1-kirill.shutemov@linux.intel.com>
 <20171129154908.6y4st6xc7hbsey2v@pd.tnic>
 <20171129161349.d7ksuhwhdamloty6@node.shutemov.name>
 <alpine.DEB.2.20.1711291740050.1825@nanos>
 <20171129170831.2iqpop2u534mgrbc@node.shutemov.name>
 <20171129174851.jk2ai37uumxve6sg@pd.tnic>
From: "H. Peter Anvin" <hpa@zytor.com>
Message-ID: <793b9c55-e85b-97b5-c857-dd8edcda4081@zytor.com>
Date: Wed, 29 Nov 2017 11:01:35 -0800
MIME-Version: 1.0
In-Reply-To: <20171129174851.jk2ai37uumxve6sg@pd.tnic>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@suse.de>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Thomas Gleixner <tglx@linutronix.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 11/29/17 09:48, Borislav Petkov wrote:
> On Wed, Nov 29, 2017 at 08:08:31PM +0300, Kirill A. Shutemov wrote:
>> We're really early in the boot -- startup_64 in decompression code -- and
>> I don't know a way print a message there. Is there a way?
>>
>> no_longmode handled by just hanging the machine. Is it enough for no_la57
>> case too?
> 
> Patch pls.
> 

I don't think there is any way to get a message out here.  It's too late
to use the firmware, and too early to use anything native.

no_longmode in startup_64 is an oxymoron -- it simply can't happen,
although of course we can enter at the 32-bit entry point with that problem.

We can hang the machine, or we can triple-fault it in the hope of
triggering a reset, and that way if the bootloader has been configured
with a backup kernel there is a hope of recovery.

Triple-faulting is trivial:

	push $0
	push $0
	lidt (%rsp)		/* %esp for 32-bit mode */
	ud2
	/* WTF? */
1:	hlt
	jmp 1b

This will either hang the machine or reboot it, depending on if the
reboot-on-triple-fault logic in the chipset actually works.

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
