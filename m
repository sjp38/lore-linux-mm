Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id B51E96B0033
	for <linux-mm@kvack.org>; Fri,  3 Nov 2017 13:04:02 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id n137so9653413iod.18
        for <linux-mm@kvack.org>; Fri, 03 Nov 2017 10:04:02 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 38sor2867067ios.350.2017.11.03.10.03.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 03 Nov 2017 10:03:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171031184052.25253-5-marcandre.lureau@redhat.com>
References: <20171031184052.25253-1-marcandre.lureau@redhat.com> <20171031184052.25253-5-marcandre.lureau@redhat.com>
From: David Herrmann <dh.herrmann@gmail.com>
Date: Fri, 3 Nov 2017 18:03:54 +0100
Message-ID: <CANq1E4SC8Hi4h9hxUM70+qOL4K95cXuMF9DKGw4dGhfmktrqsA@mail.gmail.com>
Subject: Re: [PATCH 4/6] hugetlbfs: implement memfd sealing
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?TWFyYy1BbmRyw6kgTHVyZWF1?= <marcandre.lureau@redhat.com>
Cc: linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, aarcange@redhat.com, Hugh Dickins <hughd@google.com>, nyc@holomorphy.com, mike.kravetz@oracle.com

Hi

On Tue, Oct 31, 2017 at 7:40 PM, Marc-Andr=C3=A9 Lureau
<marcandre.lureau@redhat.com> wrote:
> Implements memfd sealing, similar to shmem:
> - WRITE: deny fallocate(PUNCH_HOLE). mmap() write is denied in
>   memfd_add_seals(). write() doesn't exist for hugetlbfs.
> - SHRINK: added similar check as shmem_setattr()
> - GROW: added similar check as shmem_setattr() & shmem_fallocate()
>
> Except write() operation that doesn't exist with hugetlbfs, that
> should make sealing as close as it can be to shmem support.

SEAL, SHRINK, and GROW look fine to me.

Regarding WRITE you need to make sure there are no page references
left around. For instance, on shmem any process might trigger the
kernel to GUP mapped shmem pages for asynchronous IO, then unmap the
file and request F_SEAL_WRITE. In this case the seal must be rejected
*iff* the pages are still pinned. shmem does this by requiring the
page-refcounts to be 0. Preferably there would be some better
infrastructure that tells us whether someone operates on those pages,
but this does not exist right now. See shmem_wait_for_pins() for
details.

I have little knowledge on how hugetlbs integrate with the page-cache
and radix-tree, hence I'd prefer if someone can explicitly ACK that
shmem_wait_for_pins() is suitable for hugetlbfs.

Otherwise, this series looks good to me (minus the #ifdef mess..).

Thanks
David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
