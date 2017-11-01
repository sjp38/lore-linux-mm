Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id F0EDF6B0033
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 14:46:33 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id l24so3240077pgu.17
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 11:46:33 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id n10si260368plp.818.2017.11.01.11.46.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Nov 2017 11:46:32 -0700 (PDT)
Subject: Re: [PATCH 00/23] KAISER: unmap most of the kernel from userspace
 page tables
References: <20171031223146.6B47C861@viggo.jf.intel.com>
 <CA+55aFzS8GZ7QHzMU-JsievHU5T9LBrFx2fRwkbCB8a_YAxmsw@mail.gmail.com>
 <9e45a167-3528-8f93-80bf-c333ae6acb71@linux.intel.com>
 <CA+55aFypdyt+3-JyD3U1da5EqznncxKZZKPGn4ykkD=4Q4rdvw@mail.gmail.com>
 <8bacac66-7d3e-b15d-a73b-92c55c0b1908@linux.intel.com>
 <CA+55aFxssHiO4f52UUCPXoxx+NOu5Epf6HhwsjUH8Ua+BP6Y=A@mail.gmail.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <5005a38e-4dbf-d302-9a82-97c92d0f8f07@linux.intel.com>
Date: Wed, 1 Nov 2017 11:46:31 -0700
MIME-Version: 1.0
In-Reply-To: <CA+55aFxssHiO4f52UUCPXoxx+NOu5Epf6HhwsjUH8Ua+BP6Y=A@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andy Lutomirski <luto@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>

On 11/01/2017 11:27 AM, Linus Torvalds wrote:
> So I'd like to see not just the comments about this, but I'd like to
> see the code itself actually making that very clear. Have *code* that
> verifies that nobody ever tries to use this on a user address (because
> that would *completely* screw up all coherency), but also I don't see
> why the code possibly looks up the old physical address in ther page
> table. Is there _any_ possible reason why you'd want to look up a page
> from an old page table? As far as I can tell, we should always know
> the physical page we are mapping a priori - we've never re-mapping
> random virtual addresses or a highmem page or anything like that.
> We're mapping the 1:1 kernel mapping only.

The vmalloc()'d stacks definitely need the page table walk.  That's yet
another thing that will get simpler once we stop needing to map the
process stacks.  I think there was also a need to do this for the fixmap
addresses for the GDT.

But, I'm totally with you on making this stuff less generic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
