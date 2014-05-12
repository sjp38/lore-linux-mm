Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id ACD706B0035
	for <linux-mm@kvack.org>; Mon, 12 May 2014 01:16:39 -0400 (EDT)
Received: by mail-ig0-f180.google.com with SMTP id c1so3401815igq.1
        for <linux-mm@kvack.org>; Sun, 11 May 2014 22:16:39 -0700 (PDT)
Received: from mail-ig0-x22b.google.com (mail-ig0-x22b.google.com [2607:f8b0:4001:c05::22b])
        by mx.google.com with ESMTPS id pe7si8369022icc.60.2014.05.11.22.16.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 11 May 2014 22:16:39 -0700 (PDT)
Received: by mail-ig0-f171.google.com with SMTP id c1so3366892igq.4
        for <linux-mm@kvack.org>; Sun, 11 May 2014 22:16:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <87tx8v4qin.fsf@tassilo.jf.intel.com>
References: <1399552888-11024-1-git-send-email-kirill.shutemov@linux.intel.com>
	<CAMSv6X0+3-uNeiyEPD3sA5dA6Af_M+BT0aeVpa3qMv1aga0q9g@mail.gmail.com>
	<87tx8v4qin.fsf@tassilo.jf.intel.com>
Date: Mon, 12 May 2014 09:16:38 +0400
Message-ID: <CALYGNiNh9+pwxho-yjM=Pb8KCu0ag8mYarhpco8-Fquxp-1yEg@mail.gmail.com>
Subject: Re: [PATCHv2 0/2] remap_file_pages() decommission
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Armin Rigo <arigo@tunes.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, peterz@infradead.org, Ingo Molnar <mingo@kernel.org>

On Mon, May 12, 2014 at 7:36 AM, Andi Kleen <andi@firstfloor.org> wrote:
> Armin Rigo <arigo@tunes.org> writes:
>
>> Here is a note from the PyPy project (mentioned earlier in this
>> thread, and at https://lwn.net/Articles/587923/ ).
>
> Your use is completely bogus. remap_file_pages() pins everything
> and disables any swapping for the area.

Wait, what's wrong with swapping pages from non-linear vmas?
try_to_umap() can handle them, though not very effectively.

Some time ago I was thinking about tracking rmap for non-linear vmas, something
like second-level tree of sub-vmas stored in non-linear vma. This
could be done using
exising vm_area_struct, and in rmap tree everything will looks just as normal.
We'll waste some kernel memory, but it also will remove complexity from rmap and
make non-linear vmas usable for all filesystems not just for shmem.

But it's not worth. I ACK killing it.

Maybe we should keep flag on vma and hide/merge them in proc/maps.
Bloating files/dirs in proc might be bigger problem than non-existent
performance regression.

>
> -Andi
> --
> ak@linux.intel.com -- Speaking for myself only
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
