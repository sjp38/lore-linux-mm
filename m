Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 614538E0001
	for <linux-mm@kvack.org>; Mon, 24 Sep 2018 11:55:06 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id z18-v6so22257266qki.22
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 08:55:06 -0700 (PDT)
Received: from a9-99.smtp-out.amazonses.com (a9-99.smtp-out.amazonses.com. [54.240.9.99])
        by mx.google.com with ESMTPS id d3-v6si4036616qvs.263.2018.09.24.08.55.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 24 Sep 2018 08:55:04 -0700 (PDT)
Date: Mon, 24 Sep 2018 15:55:04 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: WARNING: kmalloc bug in input_mt_init_slots
In-Reply-To: <CACT4Y+ayX8vzd2JPrLeFhf3K_Quf4x6SDtmtkNJuwNLyOh67tQ@mail.gmail.com>
Message-ID: <010001660c4a8bbe-91200766-00df-48bd-bc60-a03da2ccdb7d-000000@email.amazonses.com>
References: <000000000000e5f76c057664e73d@google.com> <CAKdAkRS7PSXv65MTnvKOewqESxt0_FtKohd86ioOuYR3R0z9dw@mail.gmail.com> <CACT4Y+YOb6M=xuPG64PAvd=0bcteicGtwQO60CevN_V67SJ=MQ@mail.gmail.com> <010001660c1fafb2-6d0dc7e1-d898-4589-874c-1be1af94e22d-000000@email.amazonses.com>
 <CACT4Y+ayX8vzd2JPrLeFhf3K_Quf4x6SDtmtkNJuwNLyOh67tQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Dmitry Torokhov <dmitry.torokhov@gmail.com>, syzbot+87829a10073277282ad1@syzkaller.appspotmail.com, Pekka Enberg <penberg@kernel.org>, "linux-input@vger.kernel.org" <linux-input@vger.kernel.org>, lkml <linux-kernel@vger.kernel.org>, Henrik Rydberg <rydberg@bitmath.org>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Linux-MM <linux-mm@kvack.org>

On Mon, 24 Sep 2018, Dmitry Vyukov wrote:

> On Mon, Sep 24, 2018 at 5:08 PM, Christopher Lameter <cl@linux.com> wrote:
> > On Sun, 23 Sep 2018, Dmitry Vyukov wrote:
> >
> >> What was the motivation behind that WARNING about large allocations in
> >> kmalloc? Why do we want to know about them? Is the general policy that
> >> kmalloc calls with potentially large size requests need to use NOWARN?
> >> If this WARNING still considered useful? Or we should change it to
> >> pr_err?
> >
> > In general large allocs should be satisfied by the page allocator. The
> > slab allocators are used for allocating and managing small objects. The
> > page allocator has mechanisms to deal with large objects (compound pages,
> > multiple page sized allocs etc).
>
> I am asking more about the status of this warning. If it fires in
> input_mt_init_slots(), does it mean that input_mt_init_slots() needs
> to be fixed? If not, then we need to change this warning to something
> else.

Hmmm.. kmalloc falls back to the page allocator already?

See

static __always_inline void *kmalloc(size_t size, gfp_t flags)
{
        if (__builtin_constant_p(size)) {
                if (size > KMALLOC_MAX_CACHE_SIZE)
                        return kmalloc_large(size, flags);


Note that this uses KMALLOC_MAX_CACHE_SIZE which should be smaller than
KMALLOC_MAX_SIZE.


How large is the allocation? AFACIT nRequests larger than KMALLOC_MAX_SIZE
are larger than the maximum allowed by the page allocator. Thus the warning
and the NULL return.
