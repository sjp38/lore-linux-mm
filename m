Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4681D6B025F
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 03:59:28 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e64so1611463pfk.0
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 00:59:28 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id e26si935496pgn.162.2017.11.01.00.59.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Nov 2017 00:59:27 -0700 (PDT)
Received: from mail-io0-f181.google.com (mail-io0-f181.google.com [209.85.223.181])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 7EE172191E
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 07:59:26 +0000 (UTC)
Received: by mail-io0-f181.google.com with SMTP id 97so4309388iok.7
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 00:59:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <9e45a167-3528-8f93-80bf-c333ae6acb71@linux.intel.com>
References: <20171031223146.6B47C861@viggo.jf.intel.com> <CA+55aFzS8GZ7QHzMU-JsievHU5T9LBrFx2fRwkbCB8a_YAxmsw@mail.gmail.com>
 <9e45a167-3528-8f93-80bf-c333ae6acb71@linux.intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Wed, 1 Nov 2017 00:59:05 -0700
Message-ID: <CALCETrUA_30d_9eARH=kbKTUOCDkf9mO=aYnd8TnbO=nOdEhhg@mail.gmail.com>
Subject: Re: [PATCH 00/23] KAISER: unmap most of the kernel from userspace
 page tables
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>

On Tue, Oct 31, 2017 at 4:44 PM, Dave Hansen
<dave.hansen@linux.intel.com> wrote:
> On 10/31/2017 04:27 PM, Linus Torvalds wrote:
>> Inconveniently, the people you cc'd on the actual patches did *not*
>> get cc'd with this 00/23 cover letter email.
>
> Urg, sorry about that.
>
>>  (a) is this on top of Andy's entry cleanups?
>>
>>      If not, that probably needs to be sorted out.
>
> It is not.  However, I did a version on top of his earlier cleanups, so
> I know this can be easily ported on top of them.  It didn't make a major
> difference in the number of places that KAISER had to patch, unfortunately.
>
>>  (b) the TLB global bit really is nastily done. You basically disable
>> _PAGE_GLOBAL entirely.
>>
>>      I can see how/why that would make things simpler, but it's almost
>> certainly the wrong approach. The small subset of kernel pages that
>> are always mapped should definitely retain the global bit, so that you
>> don't always take a TLB miss on those! Those are probably some of the
>> most latency-critical pages, since there's generally no prefetching
>> for the kernel entry code or for things like IDT/GDT accesses..
>>
>>      So even if you don't want to have global pages for normal kernel
>> entries, you don't want to just make _PAGE_GLOBAL be defined as zero.
>> You'd want to just use _PAGE_GLOBAL conditionally.
>>
>>      Hmm?
>
> That's a good point.  Shouldn't be hard to implement at all.  We'll just
> need to take _PAGE_GLOBAL out of the default _KERNPG_TABLE definition, I
> think.
>
>>  (c) am I reading the code correctly, and the shadow page tables are
>> *completely* duplicated?
>>
>>      That seems insane. Why isn't only tyhe top level shadowed, and
>> then lower levels are shared between the shadowed and the "kernel"
>> page tables?
>
> There are obviously two PGDs.  The userspace half of the PGD is an exact
> copy so all the lower levels are shared.  You can see this bit in the
> memcpy that we do in clone_pgd_range().
>
> For the kernel half, we don't share any of the lower levels.  That's
> mostly because the stuff that we're mapping into the user/shadow copy is
> only 4k aligned and (probably) never >2MB, so there's really no
> opportunity to share.
>

I think we should map exactly two kernel PGDs: one for the fixmap and
one for the special shared stuff.  Those PGDs should be mapped
identically in the user tables.  We can eventually (or immediately)
get rid of the fixmap, too, by moving the IDT and GDT and making a
special user fixmap table for the vsyscall page.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
