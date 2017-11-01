Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5443628025A
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 12:08:11 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id k9so8947370iok.4
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 09:08:11 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 70sor418498ior.358.2017.11.01.09.08.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 01 Nov 2017 09:08:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <9e45a167-3528-8f93-80bf-c333ae6acb71@linux.intel.com>
References: <20171031223146.6B47C861@viggo.jf.intel.com> <CA+55aFzS8GZ7QHzMU-JsievHU5T9LBrFx2fRwkbCB8a_YAxmsw@mail.gmail.com>
 <9e45a167-3528-8f93-80bf-c333ae6acb71@linux.intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 1 Nov 2017 09:08:09 -0700
Message-ID: <CA+55aFypdyt+3-JyD3U1da5EqznncxKZZKPGn4ykkD=4Q4rdvw@mail.gmail.com>
Subject: Re: [PATCH 00/23] KAISER: unmap most of the kernel from userspace
 page tables
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andy Lutomirski <luto@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>

On Tue, Oct 31, 2017 at 4:44 PM, Dave Hansen
<dave.hansen@linux.intel.com> wrote:
> On 10/31/2017 04:27 PM, Linus Torvalds wrote:
>>  (c) am I reading the code correctly, and the shadow page tables are
>> *completely* duplicated?
>>
>>      That seems insane. Why isn't only tyhe top level shadowed, and
>> then lower levels are shared between the shadowed and the "kernel"
>> page tables?
>
> There are obviously two PGDs.  The userspace half of the PGD is an exact
> copy so all the lower levels are shared.  The userspace copying is
> done via the code we add to native_set_pgd().

So the thing that made me think you do all levels was that confusing
kaiser_pagetable_walk() code (and to a lesser degree
get_pa_from_mapping()).

That code definitely walks and allocates all levels.

So it really doesn't seem to be just sharing the top page table entry.

And that worries me because that seems to be a very fundamental coherency issue.

I'm assuming that this is about mapping only the individual kernel
parts, but I'd like to get comments and clarification about that.

                  Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
