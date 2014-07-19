Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f180.google.com (mail-vc0-f180.google.com [209.85.220.180])
	by kanga.kvack.org (Postfix) with ESMTP id 1ED496B0035
	for <linux-mm@kvack.org>; Sat, 19 Jul 2014 12:40:48 -0400 (EDT)
Received: by mail-vc0-f180.google.com with SMTP id ij19so9640900vcb.39
        for <linux-mm@kvack.org>; Sat, 19 Jul 2014 09:40:47 -0700 (PDT)
Received: from mail-ig0-x22b.google.com (mail-ig0-x22b.google.com [2607:f8b0:4001:c05::22b])
        by mx.google.com with ESMTPS id cf10si30675286icc.76.2014.07.19.09.40.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 19 Jul 2014 09:40:47 -0700 (PDT)
Received: by mail-ig0-f171.google.com with SMTP id l13so1595421iga.16
        for <linux-mm@kvack.org>; Sat, 19 Jul 2014 09:40:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1407090155250.7841@eggly.anvils>
References: <1402655819-14325-1-git-send-email-dh.herrmann@gmail.com>
	<1402655819-14325-8-git-send-email-dh.herrmann@gmail.com>
	<alpine.LSU.2.11.1407090155250.7841@eggly.anvils>
Date: Sat, 19 Jul 2014 18:40:47 +0200
Message-ID: <CANq1E4S=QUv_T0mYZM2qx70Bgp1eoZeORYZUFTtVmV4iFcooig@mail.gmail.com>
Subject: Re: [RFC v3 7/7] shm: isolate pinned pages when sealing files
From: David Herrmann <dh.herrmann@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, Michael Kerrisk <mtk.manpages@gmail.com>, Ryan Lortie <desrt@desrt.ca>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Greg Kroah-Hartman <greg@kroah.com>, John Stultz <john.stultz@linaro.org>, Lennart Poettering <lennart@poettering.net>, Daniel Mack <zonque@gmail.com>, Kay Sievers <kay@vrfy.org>, Tony Battersby <tonyb@cybernetics.com>, Andy Lutomirski <luto@amacapital.net>

Hi

On Wed, Jul 9, 2014 at 10:57 AM, Hugh Dickins <hughd@google.com> wrote:
> On Fri, 13 Jun 2014, David Herrmann wrote:
>
>> When setting SEAL_WRITE, we must make sure nobody has a writable reference
>> to the pages (via GUP or similar). We currently check references and wait
>> some time for them to be dropped. This, however, might fail for several
>> reasons, including:
>>  - the page is pinned for longer than we wait
>>  - while we wait, someone takes an already pinned page for read-access
>>
>> Therefore, this patch introduces page-isolation. When sealing a file with
>> SEAL_WRITE, we copy all pages that have an elevated ref-count. The newpage
>> is put in place atomically, the old page is detached and left alone. It
>> will get reclaimed once the last external user dropped it.
>>
>> Signed-off-by: David Herrmann <dh.herrmann@gmail.com>
>
> I've not checked it line by line, but this seems to be very good work;
> and I'm glad you have posted it, where we can refer back to it in future.
>
> However, I'm NAKing this patch, at least for now.
>
> The reason is simple and twofold.
>
> I absolutely do not want to be maintaining an alternative form of
> page migration in mm/shmem.c.  Shmem has its own peculiar problems
> (mostly because of swap): adding a new dimension of very rarely
> exercised complication, and dependence on the rest mm, is not wise.
>
> And sealing just does not need this.  It is clearly technically
> superior to, and more satisfying than, the "wait-a-while-then-give-up"
> technique which it would replace.  But in practice, the wait-a-while
> technique is quite good enough (and much better self-contained than this).
>
> I've heard no requirement to support sealing of objects pinned for I/O,
> and the sealer just would not have given the object out for that; the
> requirement is to give the recipient of a sealed object confidence
> that it cannot be susceptible to modification in that way.
>
> I doubt there will ever be an actual need for sealing to use this
> migration technique; but I can imagine us referring back to your work in
> future, when/if implementing revoke on regular files.  And integrating
> this into mm/migrate.c's unmap_and_move() as an extra-force mode
> (proceed even when the page count is raised).
>
> I think the concerns I had, when Tony first proposed this migration copy
> technique, were in fact unfounded - I was worried by the new inverse COW.
> On reflection, I don't think this introduces any new risks, which are
> not already present in page migration, truncation and orphaned pages.
>
> I didn't begin to test it at all, but the only defects that stood out
> in your code were in the areas of memcg and mlock.  I think that if we
> go down the road of duplicating pinned pages, then we do have to make
> a memcg charge on the new page in addition to the old page.  And if
> any pages happen to be mlock'ed into an address space, then we ought
> to map in the replacement pages afterwards (as page migration does,
> whether mlock'ed or not).
>
> (You were perfectly correct to use unmap_mapping_range(), rather than
> try_to_unmap() as page migration does: because unmap_mapping_range()
> manages the VM_NONLINEAR case.  But our intention, under way, is to
> scrap all VM_NONLINEAR code, and just emulate it with multiple vmas,
> in which case try_to_unmap() should do.)

Dropping VM_NONLINEAR would make a lot of stuff so much easier.

I'm fine with dropping this patch again. The mlock and memcg issues
you raised are valid and should get fixed. And indeed, my testing
never triggered any real evelated page-refs except if I pinned them
via FUSE. Therefore, the wait-for-pins function should be sufficient,
indeed.

Thanks for the reviews! I will send v4 shortly.
David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
