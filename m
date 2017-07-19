Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id E78526B025F
	for <linux-mm@kvack.org>; Wed, 19 Jul 2017 15:41:06 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 125so11480866pgi.2
        for <linux-mm@kvack.org>; Wed, 19 Jul 2017 12:41:06 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id y70si321878plh.556.2017.07.19.12.41.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jul 2017 12:41:05 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id o88so705570pfk.1
        for <linux-mm@kvack.org>; Wed, 19 Jul 2017 12:41:05 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: Potential race in TLB flush batching?
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <20170719074131.75wexoal3fiyoxw5@suse.de>
Date: Wed, 19 Jul 2017 12:41:01 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <E9EE838F-F1E3-43A8-BB87-8B5B8388FF61@gmail.com>
References: <20170711191823.qthrmdgqcd3rygjk@suse.de>
 <20170711200923.gyaxfjzz3tpvreuq@suse.de>
 <20170711215240.tdpmwmgwcuerjj3o@suse.de>
 <9ECCACFE-6006-4C19-8FC0-C387EB5F3BEE@gmail.com>
 <20170712082733.ouf7yx2bnvwwcfms@suse.de>
 <591A2865-13B8-4B3A-B094-8B83A7F9814B@gmail.com>
 <20170713060706.o2cuko5y6irxwnww@suse.de>
 <A9CB595E-7C6D-438F-9835-A9EB8DA90892@gmail.com>
 <20170715155518.ok2q62efc2vurqk5@suse.de>
 <F7E154AB-5C1D-477F-A6BF-EFCAE5381B2D@gmail.com>
 <20170719074131.75wexoal3fiyoxw5@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andy Lutomirski <luto@kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

Mel Gorman <mgorman@suse.de> wrote:

> On Tue, Jul 18, 2017 at 02:28:27PM -0700, Nadav Amit wrote:
>>> If there are separate address spaces using a shared mapping then the
>>> same race does not occur.
>>=20
>> I missed the fact you reverted the two operations since the previous =
version
>> of the patch. This specific scenario should be solved with this =
patch.
>>=20
>> But in general, I think there is a need for a simple locking scheme.
>=20
> Such as?

Something like:

bool is_potentially_stale_pte(pte_t pte, pgprot_t prot, int lock_state);

which would get the current PTE, the protection bits that the user is
interested in, and whether mmap_sem is taken read/write/none.=20

It would return whether this PTE may be potentially stale and needs to =
be
invalidated. Obviously, any code that removes protection or unmaps need =
to
be updated for this information to be correct.

[snip]

>> As a result, concurrent operation such as KSM???s =
write_protect_page() or
>=20
> write_protect_page operates under the page lock and cannot race with =
reclaim.

I still do not understand this claim. IIUC, reclaim can unmap the page =
in
some page table, decide not to reclaim the page and release the =
page-lock
before flush.

>> page_mkclean_one() can consider the page write-protected while in =
fact it is
>> still accessible - since the TLB flush was deferred.
>=20
> As long as it's flushed before any IO occurs that would lose a data =
update,
> it's not a data integrity issue.
>=20
>> As a result, they may
>> mishandle the PTE without flushing the page. In the case of
>> page_mkclean_one(), I suspect it may even lead to memory corruption. =
I admit
>> that in x86 there are some mitigating factors that would make such =
???attack???
>> complicated, but it still seems wrong to me, no?
>=20
> I worry that you're beginning to see races everywhere. I admit that =
the
> rules and protections here are varied and complex but it's worth =
keeping
> in mind that data integrity is the key concern (no false reads to =
wrong
> data, no lost writes) and the first race you identified found some =
problems
> here. However, with or without batching, there is always a delay =
between
> when a PTE is cleared and when the TLB entries are removed.

Sure, but usually the delay occurs while the page-table lock is taken so
there is no race.

Now, it is not fair to call me a paranoid, considering that these races =
are
real - I confirmed that at least two can happen in practice. There are =
many
possibilities for concurrent TLB batching and you cannot expect =
developers
to consider all of them. I don=E2=80=99t think many people are capable =
of doing the
voodoo tricks of avoiding a TLB flush if the page-lock is taken or the =
VMA
is anonymous. I doubt that these tricks work and anyhow IMHO they are =
likely
to fail in the future since they are undocumented and complicated.

As for =E2=80=9Cdata integrity is the key concern=E2=80=9D - violating =
the memory management
API can cause data integrity issues for programs. It may not cause the =
OS to
crash, but it should not be acceptable either, and may potentially raise
security concerns. If you think that the current behavior is ok, let the
documentation and man pages clarify that mprotect may not protect, =
madvise
may not advise and so on.

And although you would use it against me, I would say: Nobody knew that =
TLB
flushing could be so complicated.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
