Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 99AF96B004D
	for <linux-mm@kvack.org>; Thu,  4 Jun 2009 02:31:57 -0400 (EDT)
Received: by yw-out-1718.google.com with SMTP id 5so274849ywm.26
        for <linux-mm@kvack.org>; Wed, 03 Jun 2009 23:31:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090528145021.GA5503@localhost>
References: <200905271012.668777061@firstfloor.org>
	 <20090527201239.C2C9C1D0294@basil.firstfloor.org>
	 <20090528082616.GG6920@wotan.suse.de>
	 <20090528093141.GD1065@one.firstfloor.org>
	 <20090528120854.GJ6920@wotan.suse.de>
	 <20090528134520.GH1065@one.firstfloor.org>
	 <20090528145021.GA5503@localhost>
Date: Thu, 4 Jun 2009 14:25:24 +0800
Message-ID: <ab418ea90906032325m302afbb6w6fa68f6b57f53e49@mail.gmail.com>
Subject: Re: [PATCH] [13/16] HWPOISON: The high level memory error handler in
	the VM v3
From: Nai Xia <nai.xia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, Nick Piggin <npiggin@suse.de>, "hugh@veritas.com" <hugh@veritas.com>, "riel@redhat.com" <riel@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, May 28, 2009 at 10:50 PM, Wu Fengguang <fengguang.wu@intel.com> wro=
te:
> On Thu, May 28, 2009 at 09:45:20PM +0800, Andi Kleen wrote:
>> On Thu, May 28, 2009 at 02:08:54PM +0200, Nick Piggin wrote:
>
> [snip]
>
>> >
>> > BTW. I don't know if you are checking for PG_writeback often enough?
>> > You can't remove a PG_writeback page from pagecache. The normal
>> > pattern is lock_page(page); wait_on_page_writeback(page); which I
>>
>> So pages can be in writeback without being locked? I still
>> wasn't able to find such a case (in fact unless I'm misreading
>> the code badly the writeback bit is only used by NFS and a few
>> obscure cases)
>
> Yes the writeback page is typically not locked. Only read IO requires
> to be exclusive. Read IO is in fact page *writer*, while writeback IO
> is page *reader* :-)

Sorry for maybe somewhat a little bit off topic,
I am trying to get a good understanding of PG_writeback & PG_locked ;)

So you are saying PG_writeback & PG_locked are acting like a read/write loc=
k?
I notice wait_on_page_writeback(page) seems always called with page locked =
--
that is the semantics of a writer waiting to get the lock while it's
acquired by
some reader:The caller(e.g. truncate_inode_pages_range()  and
invalidate_inode_pages2_range()) are the writers waiting for
writeback readers (as you clarified ) to finish their job, right ?

So do you think the idea is sane to group the two bits together
to form a real read/write lock, which does not care about the _number_
of readers ?


>
> The writeback bit is _widely_ used. =A0test_set_page_writeback() is
> directly used by NFS/AFS etc. But its main user is in fact
> set_page_writeback(), which is called in 26 places.
>
>> > think would be safest
>>
>> Okay. I'll just add it after the page lock.
>>
>> > (then you never have to bother with the writeback bit again)
>>
>> Until Fengguang does something fancy with it.
>
> Yes I'm going to do it without wait_on_page_writeback().
>
> The reason truncate_inode_pages_range() has to wait on writeback page
> is to ensure data integrity. Otherwise if there comes two events:
> =A0 =A0 =A0 =A0truncate page A at offset X
> =A0 =A0 =A0 =A0populate page B at offset X
> If A and B are all writeback pages, then B can hit disk first and then
> be overwritten by A. Which corrupts the data at offset X from user's POV.
>
> But for hwpoison, there are no such worries. If A is poisoned, we do
> our best to isolate it as well as intercepting its IO. If the interceptio=
n
> fails, it will trigger another machine check before hitting the disk.
>
> After all, poisoned A means the data at offset X is already corrupted.
> It doesn't matter if there comes another B page.
>
> Thanks,
> Fengguang
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" i=
n
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =A0http://www.tux.org/lkml/
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
