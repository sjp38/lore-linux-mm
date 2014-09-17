Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 578A16B0038
	for <linux-mm@kvack.org>; Wed, 17 Sep 2014 13:21:42 -0400 (EDT)
Received: by mail-wi0-f180.google.com with SMTP id ex7so1666411wid.1
        for <linux-mm@kvack.org>; Wed, 17 Sep 2014 10:21:41 -0700 (PDT)
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
        by mx.google.com with ESMTPS id lc8si29146404wjb.43.2014.09.17.10.21.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 17 Sep 2014 10:21:40 -0700 (PDT)
Received: by mail-wi0-f178.google.com with SMTP id ho1so1659010wib.5
        for <linux-mm@kvack.org>; Wed, 17 Sep 2014 10:21:40 -0700 (PDT)
Date: Wed, 17 Sep 2014 20:21:37 +0300
From: Gleb Natapov <gleb@kernel.org>
Subject: Re: [PATCH] kvm: Faults which trigger IO release the mmap_sem
Message-ID: <20140917172137.GH26540@minantech.com>
References: <1410811885-17267-1-git-send-email-andreslc@google.com>
 <20140917102635.GA30733@minantech.com>
 <20140917112713.GB1273@potion.brq.redhat.com>
 <20140917114214.GB30733@minantech.com>
 <CAJu=L58O147YQJyODD8MFtdvQ6+TSG6gi6qGySgH3EigP32MrQ@mail.gmail.com>
 <20140917170841.GG26540@minantech.com>
 <CAJu=L599fJABew7Oe6Bmp40VzMXY9wnE7P=c1xFaa+cU_KSoMw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <CAJu=L599fJABew7Oe6Bmp40VzMXY9wnE7P=c1xFaa+cU_KSoMw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andres Lagar-Cavilla <andreslc@google.com>
Cc: Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Jianyu Zhan <nasa4836@gmail.com>, Paul Cassella <cassella@cray.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Sep 17, 2014 at 10:13:45AM -0700, Andres Lagar-Cavilla wrote:
> On Wed, Sep 17, 2014 at 10:08 AM, Gleb Natapov <gleb@kernel.org> wrote:
> > On Wed, Sep 17, 2014 at 10:00:32AM -0700, Andres Lagar-Cavilla wrote:
> >> On Wed, Sep 17, 2014 at 4:42 AM, Gleb Natapov <gleb@kernel.org> wrote:
> >> > On Wed, Sep 17, 2014 at 01:27:14PM +0200, Radim Kr=C4=8Dm=C3=A1=C5=
=99 wrote:
> >> >> 2014-09-17 13:26+0300, Gleb Natapov:
> >> >> > For async_pf_execute() you do not need to even retry. Next guest'=
s page fault
> >> >> > will retry it for you.
> >> >>
> >> >> Wouldn't that be a waste of vmentries?
> >> > This is how it will work with or without this second gup. Page is not
> >> > mapped into a shadow page table on this path, it happens on a next f=
ault.
> >>
> >> The point is that the gup in the async pf completion from the work
> >> queue will not relinquish the mmap semaphore. And it most definitely
> >> should, given that we are likely looking at swap/filemap.
> >>
> > I get this point and the patch looks good in general, but my point is
> > that when _retry() is called from async_pf_execute() second gup is not
> > needed. In the original code gup is called to do IO and nothing else.
> > In your patch this is accomplished by the first gup already, so you
> > can skip second gup if pagep =3D=3D nullptr.
>=20
> I see. However, if this function were to be used elsewhere in the
> future, then the "if pagep =3D=3D NULL don't retry" semantics may not
> match the new caller's intention. Would you prefer an explicit flag?
>=20
We can add explicit flag whenever such caller will be added, if ever.

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
