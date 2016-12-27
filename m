Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 970F56B0038
	for <linux-mm@kvack.org>; Tue, 27 Dec 2016 14:23:20 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id c135so89392426ioe.6
        for <linux-mm@kvack.org>; Tue, 27 Dec 2016 11:23:20 -0800 (PST)
Received: from mail-io0-x243.google.com (mail-io0-x243.google.com. [2607:f8b0:4001:c06::243])
        by mx.google.com with ESMTPS id q186si32535267iod.126.2016.12.27.11.23.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Dec 2016 11:23:19 -0800 (PST)
Received: by mail-io0-x243.google.com with SMTP id j76so17192407ioe.0
        for <linux-mm@kvack.org>; Tue, 27 Dec 2016 11:23:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+55aFw22e6njM9L4sareRRJw3RjW9XwGH3B7p-ND86EtTWWDQ@mail.gmail.com>
References: <20161225030030.23219-1-npiggin@gmail.com> <20161225030030.23219-3-npiggin@gmail.com>
 <CA+55aFzqgtz-782MmLOjQ2A2nB5YVyLAvveo6G_c85jqqGDA0Q@mail.gmail.com>
 <20161226111654.76ab0957@roar.ozlabs.ibm.com> <CA+55aFz1n_JSTc_u=t9Qgafk2JaffrhPAwMLn_Dr-L9UKxqHMg@mail.gmail.com>
 <20161227211946.3770b6ce@roar.ozlabs.ibm.com> <CA+55aFw22e6njM9L4sareRRJw3RjW9XwGH3B7p-ND86EtTWWDQ@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 27 Dec 2016 11:23:19 -0800
Message-ID: <CA+55aFzKuiLS0CvTTqo5=8eyoksC1==30+XMiXZhQqzXr9JM3A@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: add PageWaiters indicating tasks are waiting for
 a page bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Bob Peterson <rpeterso@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Steven Whitehouse <swhiteho@redhat.com>, Andrew Lutomirski <luto@kernel.org>, Andreas Gruenbacher <agruenba@redhat.com>, Peter Zijlstra <peterz@infradead.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>

On Tue, Dec 27, 2016 at 10:58 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> The other alternative is to keep the lock bit as bit #0, and just make
> the contention bit be the high bit. Then, on x86, you can do
>
>     lock andb $0xfe,flags
>     js contention
>
> which might be even better. Again, it would be a very special
> operation just for unlock. Something like
>
>    bit_clear_and_branch_if_negative_byte(mem, label);
>
> and again, it would be trivial to do on most architectures.
>
> Let me try to write a patch or two for testing.

Ok, that was easy.

Of course, none of this is *tested*, but it looks superficially
correct, and allows other architectures to do the same optimization if
they want.

On x86, the unlock_page() code now generates

        lock; andb $1,(%rdi)    #, MEM[(volatile long int *)_7]
        js      .L114   #,
        popq    %rbp    #
        ret

for the actual unlock itself.

Now to actually compile the whole thing and see if it boots..

                 Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
