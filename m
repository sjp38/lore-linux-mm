Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 38C576B0035
	for <linux-mm@kvack.org>; Wed, 17 Sep 2014 13:08:46 -0400 (EDT)
Received: by mail-wg0-f46.google.com with SMTP id n12so1732414wgh.5
        for <linux-mm@kvack.org>; Wed, 17 Sep 2014 10:08:45 -0700 (PDT)
Received: from mail-we0-f177.google.com (mail-we0-f177.google.com [74.125.82.177])
        by mx.google.com with ESMTPS id bv19si7336898wib.61.2014.09.17.10.08.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 17 Sep 2014 10:08:45 -0700 (PDT)
Received: by mail-we0-f177.google.com with SMTP id u57so1763387wes.36
        for <linux-mm@kvack.org>; Wed, 17 Sep 2014 10:08:44 -0700 (PDT)
Date: Wed, 17 Sep 2014 20:08:42 +0300
From: Gleb Natapov <gleb@kernel.org>
Subject: Re: [PATCH] kvm: Faults which trigger IO release the mmap_sem
Message-ID: <20140917170841.GG26540@minantech.com>
References: <1410811885-17267-1-git-send-email-andreslc@google.com>
 <20140917102635.GA30733@minantech.com>
 <20140917112713.GB1273@potion.brq.redhat.com>
 <20140917114214.GB30733@minantech.com>
 <CAJu=L58O147YQJyODD8MFtdvQ6+TSG6gi6qGySgH3EigP32MrQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <CAJu=L58O147YQJyODD8MFtdvQ6+TSG6gi6qGySgH3EigP32MrQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andres Lagar-Cavilla <andreslc@google.com>
Cc: Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Gleb Natapov <gleb@redhat.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Jianyu Zhan <nasa4836@gmail.com>, Paul Cassella <cassella@cray.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Sep 17, 2014 at 10:00:32AM -0700, Andres Lagar-Cavilla wrote:
> On Wed, Sep 17, 2014 at 4:42 AM, Gleb Natapov <gleb@kernel.org> wrote:
> > On Wed, Sep 17, 2014 at 01:27:14PM +0200, Radim Kr=C4=8Dm=C3=A1=C5=99 w=
rote:
> >> 2014-09-17 13:26+0300, Gleb Natapov:
> >> > For async_pf_execute() you do not need to even retry. Next guest's p=
age fault
> >> > will retry it for you.
> >>
> >> Wouldn't that be a waste of vmentries?
> > This is how it will work with or without this second gup. Page is not
> > mapped into a shadow page table on this path, it happens on a next faul=
t.
>=20
> The point is that the gup in the async pf completion from the work
> queue will not relinquish the mmap semaphore. And it most definitely
> should, given that we are likely looking at swap/filemap.
>=20
I get this point and the patch looks good in general, but my point is
that when _retry() is called from async_pf_execute() second gup is not
needed. In the original code gup is called to do IO and nothing else.
In your patch this is accomplished by the first gup already, so you
can skip second gup if pagep =3D=3D nullptr.

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
