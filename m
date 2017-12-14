Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9AF5A6B0253
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 19:17:19 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id m9so2929209pff.0
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 16:17:19 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id k19si2279464pfa.118.2017.12.13.16.17.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Dec 2017 16:17:18 -0800 (PST)
Received: from mail-it0-f48.google.com (mail-it0-f48.google.com [209.85.214.48])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 27CA021879
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 00:17:18 +0000 (UTC)
Received: by mail-it0-f48.google.com with SMTP id d16so7062323itj.1
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 16:17:18 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171214001012.GA22639@bombadil.infradead.org>
References: <20171212173221.496222173@linutronix.de> <20171212173333.669577588@linutronix.de>
 <20171213215022.GA27778@bombadil.infradead.org> <20171213221233.GC3326@worktop>
 <20171214001012.GA22639@bombadil.infradead.org>
From: Andy Lutomirski <luto@kernel.org>
Date: Wed, 13 Dec 2017 16:16:56 -0800
Message-ID: <CALCETrXP5e=kiqNiB2_BgGx=RV6=KGS+1FL-M0K1BumqH6Q01g@mail.gmail.com>
Subject: Re: [patch 05/16] mm: Allow special mappings with user access cleared
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, "Liguori, Anthony" <aliguori@amazon.com>, Will Deacon <will.deacon@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, Dec 13, 2017 at 4:10 PM, Matthew Wilcox <willy@infradead.org> wrote:
> On Wed, Dec 13, 2017 at 11:12:33PM +0100, Peter Zijlstra wrote:
>> On Wed, Dec 13, 2017 at 01:50:22PM -0800, Matthew Wilcox wrote:
>> > On Tue, Dec 12, 2017 at 06:32:26PM +0100, Thomas Gleixner wrote:
>> > > From: Peter Zijstra <peterz@infradead.org>
>> > > In order to create VMAs that are not accessible to userspace create a new
>> > > VM_NOUSER flag. This can be used in conjunction with
>> > > install_special_mapping() to inject 'kernel' data into the userspace map.
>> >
>> > Maybe I misunderstand the intent behind this, but I was recently looking
>> > at something kind of similar.  I was calling it VM_NOTLB and it wouldn't
>> > put TLB entries into the userspace map at all.  The idea was to be able
>> > to use the user address purely as a handle for specific kernel pages,
>> > which were guaranteed to never be mapped into userspace, so we didn't
>> > need to send TLB invalidations when we took those pages away from the user
>> > process again.  But we'd be able to pass the address to read() or write().
>>
>> Since the LDT is strictly per process, the idea was to actually inject
>> it into the userspace map. Except of course, userspace must not actually
>> be able to access it. So by mapping it !_PAGE_USER its 'invisible'.
>>
>> But the CPU very much needs the mapping, it will load the LDT entries
>> through them.
>
> So can I use your VM_NOUSER VMAs for my purpose?  That is, can I change
> the page table without flushing the TLB?  The only access to these PTEs
> will be through the kernel mapping, so I don't see why I'd need to.

I doubt it, since if it's in the kernel pagetables at all, then the
mapping can be cached for kernel purposes.

But I still think this discussion is off in the weeds.  x86 does not
actually need any of this stuff.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
