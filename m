Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4517D6B0033
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 16:35:52 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id q3so207266pgv.16
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 13:35:52 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id g9si72286pgr.775.2017.12.12.13.35.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Dec 2017 13:35:50 -0800 (PST)
Received: from mail-io0-f173.google.com (mail-io0-f173.google.com [209.85.223.173])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 2C4B320C0F
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 21:35:50 +0000 (UTC)
Received: by mail-io0-f173.google.com with SMTP id d14so578552ioc.5
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 13:35:50 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1712122124320.2289@nanos>
References: <20171212173221.496222173@linutronix.de> <20171212173334.345422294@linutronix.de>
 <CA+55aFwgGDa_JfZZPoaYtw5yE1oYnn1+0t51D=WU8a7__1Lauw@mail.gmail.com>
 <alpine.DEB.2.20.1712122017100.2289@nanos> <212680b8-6f8d-f785-42fd-61846553570d@intel.com>
 <alpine.DEB.2.20.1712122124320.2289@nanos>
From: Andy Lutomirski <luto@kernel.org>
Date: Tue, 12 Dec 2017 13:35:28 -0800
Message-ID: <CALCETrVt8zzfoszh83N0dT9TEax3pr+HLauprKWD2FssvFYXYA@mail.gmail.com>
Subject: Re: [patch 13/16] x86/ldt: Introduce LDT write fault handler
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Dave Hansen <dave.hansen@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, "Liguori, Anthony" <aliguori@amazon.com>, Will Deacon <will.deacon@arm.com>, linux-mm <linux-mm@kvack.org>

On Tue, Dec 12, 2017 at 12:37 PM, Thomas Gleixner <tglx@linutronix.de> wrote:
> On Tue, 12 Dec 2017, Dave Hansen wrote:
>
>> On 12/12/2017 11:21 AM, Thomas Gleixner wrote:
>> > The only critical interaction is the return to user path (user CS/SS) and
>> > we made sure with the LAR touching that these are precached in the CPU
>> > before we go into fragile exit code.
>>
>> How do we make sure that it _stays_ cached?
>>
>> Surely there is weird stuff like WBINVD or SMI's that can come at very
>> inconvenient times and wipe it out of the cache.
>
> This does not look like cache in the sense of memory cache. It seems to be
> CPU internal state and I just stuffed WBINVD and alternatively CLFLUSH'ed
> the entries after the 'touch' via LAR. Still works.
>

There *must* be some weird bug in this series.  I find it very hard to
believe that x86 CPUs have a magic cache that caches any part of a
not-actually-in-a-segment-register descriptor entry.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
