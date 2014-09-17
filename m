Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f169.google.com (mail-qc0-f169.google.com [209.85.216.169])
	by kanga.kvack.org (Postfix) with ESMTP id 12AC66B0035
	for <linux-mm@kvack.org>; Wed, 17 Sep 2014 13:00:34 -0400 (EDT)
Received: by mail-qc0-f169.google.com with SMTP id r5so2678745qcx.28
        for <linux-mm@kvack.org>; Wed, 17 Sep 2014 10:00:33 -0700 (PDT)
Received: from mail-qg0-x22d.google.com (mail-qg0-x22d.google.com [2607:f8b0:400d:c04::22d])
        by mx.google.com with ESMTPS id a17si23184594qai.28.2014.09.17.10.00.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 17 Sep 2014 10:00:33 -0700 (PDT)
Received: by mail-qg0-f45.google.com with SMTP id j107so2268303qga.18
        for <linux-mm@kvack.org>; Wed, 17 Sep 2014 10:00:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140917114214.GB30733@minantech.com>
References: <1410811885-17267-1-git-send-email-andreslc@google.com>
	<20140917102635.GA30733@minantech.com>
	<20140917112713.GB1273@potion.brq.redhat.com>
	<20140917114214.GB30733@minantech.com>
Date: Wed, 17 Sep 2014 10:00:32 -0700
Message-ID: <CAJu=L58O147YQJyODD8MFtdvQ6+TSG6gi6qGySgH3EigP32MrQ@mail.gmail.com>
Subject: Re: [PATCH] kvm: Faults which trigger IO release the mmap_sem
From: Andres Lagar-Cavilla <andreslc@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gleb Natapov <gleb@kernel.org>
Cc: =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Gleb Natapov <gleb@redhat.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Jianyu Zhan <nasa4836@gmail.com>, Paul Cassella <cassella@cray.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Sep 17, 2014 at 4:42 AM, Gleb Natapov <gleb@kernel.org> wrote:
> On Wed, Sep 17, 2014 at 01:27:14PM +0200, Radim Kr=C4=8Dm=C3=A1=C5=99 wro=
te:
>> 2014-09-17 13:26+0300, Gleb Natapov:
>> > For async_pf_execute() you do not need to even retry. Next guest's pag=
e fault
>> > will retry it for you.
>>
>> Wouldn't that be a waste of vmentries?
> This is how it will work with or without this second gup. Page is not
> mapped into a shadow page table on this path, it happens on a next fault.

The point is that the gup in the async pf completion from the work
queue will not relinquish the mmap semaphore. And it most definitely
should, given that we are likely looking at swap/filemap.

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
