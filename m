Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f182.google.com (mail-qc0-f182.google.com [209.85.216.182])
	by kanga.kvack.org (Postfix) with ESMTP id D4B2D6B0035
	for <linux-mm@kvack.org>; Wed, 17 Sep 2014 13:13:46 -0400 (EDT)
Received: by mail-qc0-f182.google.com with SMTP id c9so2521614qcz.41
        for <linux-mm@kvack.org>; Wed, 17 Sep 2014 10:13:46 -0700 (PDT)
Received: from mail-qc0-x236.google.com (mail-qc0-x236.google.com [2607:f8b0:400d:c01::236])
        by mx.google.com with ESMTPS id l10si22183347qaz.27.2014.09.17.10.13.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 17 Sep 2014 10:13:46 -0700 (PDT)
Received: by mail-qc0-f182.google.com with SMTP id c9so2658393qcz.27
        for <linux-mm@kvack.org>; Wed, 17 Sep 2014 10:13:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140917170841.GG26540@minantech.com>
References: <1410811885-17267-1-git-send-email-andreslc@google.com>
	<20140917102635.GA30733@minantech.com>
	<20140917112713.GB1273@potion.brq.redhat.com>
	<20140917114214.GB30733@minantech.com>
	<CAJu=L58O147YQJyODD8MFtdvQ6+TSG6gi6qGySgH3EigP32MrQ@mail.gmail.com>
	<20140917170841.GG26540@minantech.com>
Date: Wed, 17 Sep 2014 10:13:45 -0700
Message-ID: <CAJu=L599fJABew7Oe6Bmp40VzMXY9wnE7P=c1xFaa+cU_KSoMw@mail.gmail.com>
Subject: Re: [PATCH] kvm: Faults which trigger IO release the mmap_sem
From: Andres Lagar-Cavilla <andreslc@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gleb Natapov <gleb@kernel.org>
Cc: =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Jianyu Zhan <nasa4836@gmail.com>, Paul Cassella <cassella@cray.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Sep 17, 2014 at 10:08 AM, Gleb Natapov <gleb@kernel.org> wrote:
> On Wed, Sep 17, 2014 at 10:00:32AM -0700, Andres Lagar-Cavilla wrote:
>> On Wed, Sep 17, 2014 at 4:42 AM, Gleb Natapov <gleb@kernel.org> wrote:
>> > On Wed, Sep 17, 2014 at 01:27:14PM +0200, Radim Kr=C4=8Dm=C3=A1=C5=99 =
wrote:
>> >> 2014-09-17 13:26+0300, Gleb Natapov:
>> >> > For async_pf_execute() you do not need to even retry. Next guest's =
page fault
>> >> > will retry it for you.
>> >>
>> >> Wouldn't that be a waste of vmentries?
>> > This is how it will work with or without this second gup. Page is not
>> > mapped into a shadow page table on this path, it happens on a next fau=
lt.
>>
>> The point is that the gup in the async pf completion from the work
>> queue will not relinquish the mmap semaphore. And it most definitely
>> should, given that we are likely looking at swap/filemap.
>>
> I get this point and the patch looks good in general, but my point is
> that when _retry() is called from async_pf_execute() second gup is not
> needed. In the original code gup is called to do IO and nothing else.
> In your patch this is accomplished by the first gup already, so you
> can skip second gup if pagep =3D=3D nullptr.

I see. However, if this function were to be used elsewhere in the
future, then the "if pagep =3D=3D NULL don't retry" semantics may not
match the new caller's intention. Would you prefer an explicit flag?

Andres

>
> --
>                         Gleb.



--=20
Andres Lagar-Cavilla | Google Kernel Team | andreslc@google.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
