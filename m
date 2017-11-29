Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0A7656B0069
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 18:27:15 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id w22so3060954pge.10
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 15:27:15 -0800 (PST)
Received: from mail.zytor.com (terminus.zytor.com. [65.50.211.136])
        by mx.google.com with ESMTPS id o33si2018930plb.354.2017.11.29.15.27.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Nov 2017 15:27:13 -0800 (PST)
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
 <e4463396-9b7c-2fe8-534c-73820c0bce5f@zytor.com>
 <20171129223103.in4qmtxbj2sawhpw@pd.tnic>
From: "H. Peter Anvin" <hpa@zytor.com>
Message-ID: <f0c0db4a-6196-d36d-cd1e-8dfc9c09767a@zytor.com>
Date: Wed, 29 Nov 2017 15:24:53 -0800
MIME-Version: 1.0
In-Reply-To: <20171129223103.in4qmtxbj2sawhpw@pd.tnic>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@suse.de>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Thomas Gleixner <tglx@linutronix.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 11/29/17 14:31, Borislav Petkov wrote:
> 
> A couple of points:
> 
> * so this box here has a normal grub installation and apparently grub
> jumps to some other entry point.
> 

Yes, Grub as a matter of policy(!) does everything in the most braindead
way possible.  You have to use "linux16" or "linuxefi" to make it do
something sane.

> * I'm not convinced we need to do everything you typed because this is
> only a temporary issue and once X86_5LEVEL is complete, it should work.
> I mean, it needs to work otherwise forget single-system image and I
> don't think we want to give that up.
> 
>> However, if the bootloader jumps straight into the code what do you
>> expect it to do?  We have no real concept about what we'd need to do to
>> issue a message as we really don't know what devices are available on
>> the system, etc.  If the screen_info field in struct boot_params has
>> been initialized then we actually *do* know how to write to the screen
>> -- if you are okay with including a text font etc. since modern systems
>> boot in graphics mode.
> 
> We switch to text mode and dump our message. Can we do that?

What is text mode?  It is hardware that is going away(*), and you don't
even know if you have a display screen on your system at all, or how
you'd have to configure your display hardware even if it is "mostly" VGA.

> I wouldn't want to do any of this back'n'forth between kernel and boot
> loader because that sounds fragile, at least to me. And again, I'm
> not convinced we should spend too much energy on this as the issue is
> temporary AFAICT.

Well, it's not just limited to 5-level mode; it's kind a general issue.
We have had this issue for a very, very long time -- all the way back to
i386 PAE at the very least.  I'm personally OK with triple-faulting the
CPU in this case.

	-hpa


(*) And for good reason -- it is completely memory-latency-bound as you
    have an indirect reference for every byte you fetch.  In a UMA
    system this sucks up an insane amount of system bandwidth, unless
    you are willing to burn the area of having a 16K SRAM cache.

    VGA hardware, additionally, has a bunch of insane operations that
    have to be memory-mapped.  The resulting hardware screws with
    pretty much any sane GPU implementation, so I'm fully expecting that
    as soon as GPUs no longer come with a CBIOS option ROM VGA hardware
    will be dropped more or less immediately.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
