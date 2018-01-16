Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id E64DC6B0038
	for <linux-mm@kvack.org>; Mon, 15 Jan 2018 21:14:52 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id c33so2316662itf.8
        for <linux-mm@kvack.org>; Mon, 15 Jan 2018 18:14:52 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id e15sor503777ioe.155.2018.01.15.18.14.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 15 Jan 2018 18:14:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <201801160115.w0G1FOIG057203@www262.sakura.ne.jp>
References: <201801142054.FAD95378.LVOOFQJOFtMFSH@I-love.SAKURA.ne.jp>
 <CA+55aFwvgm+KKkRLaFsuAjTdfQooS=UaMScC0CbZQ9WnX_AF=g@mail.gmail.com> <201801160115.w0G1FOIG057203@www262.sakura.ne.jp>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 15 Jan 2018 18:14:49 -0800
Message-ID: <CA+55aFxOn5n4O2JNaivi8rhDmeFhTQxEHD4xE33J9xOrFu=7kQ@mail.gmail.com>
Subject: Re: [mm 4.15-rc8] Random oopses under memory pressure.
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Dave Hansen <dave.hansen@linux.intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, the arch/x86 maintainers <x86@kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>

On Mon, Jan 15, 2018 at 5:15 PM, Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
>
> I can't reproduce this with CONFIG_FLATMEM=y . But I'm not sure whether
> we are hitting a bug in CONFIG_SPARSEMEM=y code, for the bug is highly
> timing dependent.

Hmm. Maybe. But sparsemem really also generates *much* more complex
code particularly for the pfn_to_page() case.

It also has much less testing. For example, on x86-64 we do use
sparsemem, but we use the VMEMMAP version of sparsemem: the version
that does *not* play really odd and complex games with that whole
pfn_to_page().

I've always felt like sparsemem was really damn complicated.  The
whole "section_mem_map" encoding is really subtle and odd.

And considering that we're getting what appears to be a invalid page,
in one of the more complicated sequences that very much does that
whole pfn_to_page(), I really wonder.

I wonder if somebody could add some VM_BUG_ON() checks to the
non-vmemmap case of sparsemem in include/asm-generic/memory_model.h.

Because this:

  #define __pfn_to_page(pfn)                              \
  ({      unsigned long __pfn = (pfn);                    \
          struct mem_section *__sec = __pfn_to_section(__pfn);    \
          __section_mem_map_addr(__sec) + __pfn;          \
  })

is really subtle, and if we have some case where we pass in an
out-of-range pfn, or some case where we get the section wrong (because
the pfn is between sections or whatever due to some subtle setup bug),
things will really go sideways.

The reason I was hoping you could do this for FLATMEM is that it's
much easier to verify the pfn range in that case.  The sparsemem cases
really makes it much nastier.

That said, all of that code is really old. Most of it goes back to
-05/06 or so. But since you seem to be able to reproduce at least back
to 4.8, I guess this bug does back years too.

But I'm adding Dave Hansen explicitly to the cc, in case he has any
ideas. Not because I blame him, but he's touched the sparsemem code
fairly recently, so maybe he'd have some idea on adding sanity
checking to the sparsemem version of pfn_to_page().

> I dont know why but selecting CONFIG_FLATMEM=y seems to avoid a different bug
> where bootup of qemu randomly fails at

Hmm. That looks very different indeed. But if CONFIG_SPARSEMEM
(presumably together with HIGHMEM) has some odd off-by-one corner case
or similar, who knows *what* issues it could trigger.

                 Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
