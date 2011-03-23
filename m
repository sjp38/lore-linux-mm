Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id A3EF98D0040
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 23:23:59 -0400 (EDT)
Received: by qyk30 with SMTP id 30so7574800qyk.14
        for <linux-mm@kvack.org>; Tue, 22 Mar 2011 20:23:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110322114756.GI25925@linux-sh.org>
References: <1299575863-7069-1-git-send-email-lliubbo@gmail.com>
	<alpine.LSU.2.00.1103201258280.3776@sister.anvils>
	<20110322114756.GI25925@linux-sh.org>
Date: Wed, 23 Mar 2011 11:23:57 +0800
Message-ID: <AANLkTimwnr+owuje9RhNR9LhRx=bGWJfWu-Osior4duF@mail.gmail.com>
Subject: Re: [BUG?] shmem: memory leak on NO-MMU arch
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Mundt <lethal@linux-sh.org>
Cc: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, viro@zeniv.linux.org.uk, hch@lst.de, npiggin@kernel.dk, tj@kernel.org, David Howells <dhowells@redhat.com>, Magnus Damm <magnus.damm@gmail.com>

On Tue, Mar 22, 2011 at 7:47 PM, Paul Mundt <lethal@linux-sh.org> wrote:
> On Sun, Mar 20, 2011 at 01:35:50PM -0700, Hugh Dickins wrote:
>> On Tue, 8 Mar 2011, Bob Liu wrote:
>> > Hi, folks
>>
>> Of course I agree with Al and Andrew about your other patch,
>> I don't know of any shmem inode leak in the MMU case.
>>
>> I'm afraid we MM folks tend to be very ignorant of the NOMMU case.
>> I've sometimes wished we had a NOMMU variant of the x86 architecture,
>> that we could at least build and test changes on.
>>
> NOMMU folks tend to be very ignorant of the MM cases, so it all balances
> out :-)
>
>> Let's Cc David, Paul and Magnus: they do understand NOMMU.
>>
>> > root:/> ./shmem
>> > run ok...
>> > root:/> free
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 total =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 used =C2=A0 =C2=A0 =C2=A0 =C2=A0 free =C2=A0 =C2=A0 =C2=A0 sh=
ared =C2=A0 =C2=A0 =C2=A0buffers
>> > =C2=A0 Mem: =C2=A0 =C2=A0 =C2=A0 =C2=A060528 =C2=A0 =C2=A0 =C2=A0 =C2=
=A019904 =C2=A0 =C2=A0 =C2=A0 =C2=A040624 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00
>> > root:/> ./shmem
>> > run ok...
>> > root:/> free
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 total =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 used =C2=A0 =C2=A0 =C2=A0 =C2=A0 free =C2=A0 =C2=A0 =C2=A0 sh=
ared =C2=A0 =C2=A0 =C2=A0buffers
>> > =C2=A0 Mem: =C2=A0 =C2=A0 =C2=A0 =C2=A060528 =C2=A0 =C2=A0 =C2=A0 =C2=
=A021104 =C2=A0 =C2=A0 =C2=A0 =C2=A039424 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00
>> > root:/>
>> >
>> > It seems the shmem didn't free it's memory after using shmctl(IPC_RMID=
) to rm
>> > it.
>>
>> There does indeed appear to be a leak there. =C2=A0But I'm feeling very
>> stupid, the leak of ~1200kB per run looks a lot more than the ~20kB
>> that each run of your test program would lose if the bug is as you say.
>> Maybe I can't count today.
>>
> Your 1200 figure looks accurate, I came up with the same figure. In any
> event, it would be interesting to know what page size is being used. It's
> not uncommon to see a 64kB PAGE_SIZE on a system with 64M of memory, but
> that still wouldn't account for that level of discrepancy.
>

I am very sorry that I attached the wrong test source file by mistake.

The loop  "for ( i=3D0; i<2; ++i) {"  should be  "for (i =3D 0; i < 100; ++=
i) {".

I changed 100 to 2 for some tests, but I forgot it.

>
> My initial thought was that perhaps we were missing a
> truncate_pagecache() for a caller of ramfs_nommu_expand_for_mapping() on
> an existing inode with an established size (which assumes that one is
> always expanding from 0 up, and so doesn't bother with truncating), but
> the shmem user in this case is fetching a new inode on each iteration so
> this seems improbable, and the same 1200kB discrepancy is visible even
> after the initial shmget. I'm likely overlooking something obvious.
>
>> Yet it does look to me that you're right that ramfs_nommu_expand_for_map=
ping
>> forgets to release a reference to its pages; though it's hard to believe
>> that could go unnoticed for so long - more likely we're both overlooking
>> something.
>>
> page refcounting on nommu has a rather tenuous relationship with reality
> at the best of times; surprise was indeed not the first thought that came
> to mind.
>
> My guess is that this used to be caught by virtue of the __put_page()
> hack we used to have in __free_pages_ok() for the nommu case, prior to
> the conversion to compound pages.
>
>> Here's my own suggestion for a patch; but I've not even tried to
>> compile it, let alone test it, so I'm certainly not signing it.
>>
> This definitely looks like an improvement, but I wonder if it's not
> easier to simply use alloc_pages_exact() and throw out the bulk of the
> function entirely (a __GFP_ZERO would further simplify things, too)?
>
>> @@ -114,11 +110,14 @@ int ramfs_nommu_expand_for_mapping(struc
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unlock_page(page);
>> =C2=A0 =C2=A0 =C2=A0 }
>>
>> - =C2=A0 =C2=A0 return 0;
>> + =C2=A0 =C2=A0 /*
>> + =C2=A0 =C2=A0 =C2=A0* release our reference to the pages now added to =
cache,
>> + =C2=A0 =C2=A0 =C2=A0* and trim off any pages we don't actually require=
.
>> + =C2=A0 =C2=A0 =C2=A0* truncate inode back to 0 if not all pages could =
be added??
>> + =C2=A0 =C2=A0 =C2=A0*/
>> + =C2=A0 =C2=A0 for (loop =3D 0; loop < xpages; loop++)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 put_page(pages + loop);
>>
> Unless you have some callchain in mind that I'm not aware of, an error is
> handed back when add_to_page_cache_lru() fails and the inode is destroyed
> by the caller in each case. As such, we should make it down to
> truncate_inode_pages(..., 0) via natural iput() eviction.
>

What about this is?
-----------
--- a/fs/ramfs/file-nommu.c
+++ b/fs/ramfs/file-nommu.c
@@ -112,6 +112,7 @@ int ramfs_nommu_expand_for_mapping(struct inode
*inode, size_t newsize)
                SetPageDirty(page);

                unlock_page(page);
+               put_page(page);
        }

Thanks
--=20
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
