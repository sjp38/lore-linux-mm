Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4D1F56B025F
	for <linux-mm@kvack.org>; Wed, 19 Jul 2017 16:20:06 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id y62so10756938pfa.3
        for <linux-mm@kvack.org>; Wed, 19 Jul 2017 13:20:06 -0700 (PDT)
Received: from mail-pg0-x230.google.com (mail-pg0-x230.google.com. [2607:f8b0:400e:c05::230])
        by mx.google.com with ESMTPS id o12si504296pfa.545.2017.07.19.13.20.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jul 2017 13:20:05 -0700 (PDT)
Received: by mail-pg0-x230.google.com with SMTP id 123so4808181pgj.1
        for <linux-mm@kvack.org>; Wed, 19 Jul 2017 13:20:05 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: Potential race in TLB flush batching?
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <20170719195820.drtfmweuhdc4eca6@suse.de>
Date: Wed, 19 Jul 2017 13:20:01 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <4BD983A1-724B-4FD7-B502-55351717BC5F@gmail.com>
References: <20170711215240.tdpmwmgwcuerjj3o@suse.de>
 <9ECCACFE-6006-4C19-8FC0-C387EB5F3BEE@gmail.com>
 <20170712082733.ouf7yx2bnvwwcfms@suse.de>
 <591A2865-13B8-4B3A-B094-8B83A7F9814B@gmail.com>
 <20170713060706.o2cuko5y6irxwnww@suse.de>
 <A9CB595E-7C6D-438F-9835-A9EB8DA90892@gmail.com>
 <20170715155518.ok2q62efc2vurqk5@suse.de>
 <F7E154AB-5C1D-477F-A6BF-EFCAE5381B2D@gmail.com>
 <20170719074131.75wexoal3fiyoxw5@suse.de>
 <E9EE838F-F1E3-43A8-BB87-8B5B8388FF61@gmail.com>
 <20170719195820.drtfmweuhdc4eca6@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andy Lutomirski <luto@kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

Mel Gorman <mgorman@suse.de> wrote:

> On Wed, Jul 19, 2017 at 12:41:01PM -0700, Nadav Amit wrote:
>> Mel Gorman <mgorman@suse.de> wrote:
>>=20
>>> On Tue, Jul 18, 2017 at 02:28:27PM -0700, Nadav Amit wrote:
>>>>> If there are separate address spaces using a shared mapping then =
the
>>>>> same race does not occur.
>>>>=20
>>>> I missed the fact you reverted the two operations since the =
previous version
>>>> of the patch. This specific scenario should be solved with this =
patch.
>>>>=20
>>>> But in general, I think there is a need for a simple locking =
scheme.
>>>=20
>>> Such as?
>>=20
>> Something like:
>>=20
>> bool is_potentially_stale_pte(pte_t pte, pgprot_t prot, int =
lock_state);
>>=20
>> which would get the current PTE, the protection bits that the user is
>> interested in, and whether mmap_sem is taken read/write/none.
>=20
> =46rom a PTE you cannot know the state of mmap_sem because you can =
rmap
> back to multiple mm's for shared mappings. It's also fairly heavy =
handed.
> Technically, you could lock on the basis of the VMA but that has other
> consequences for scalability. The staleness is also a factor because
> it's a case of "does the staleness matter". Sometimes it does, =
sometimes
> it doesn't.  mmap_sem even if it could be used does not always tell us
> the right information either because it can matter whether we are =
racing
> against a userspace reference or a kernel operation.
>=20
> It's possible your idea could be made work, but right now I'm not =
seeing a
> solution that handles every corner case. I asked to hear what your =
ideas
> were because anything I thought of that could batch TLB flushing in =
the
> general case had flaws that did not improve over what is already =
there.

I don=E2=80=99t disagree with what you say - perhaps my scheme is too =
simplistic.
But the bottom line, if you cannot form simple rules for when TLB needs =
to
be flushed, what are the chances others would get it right?

>> [snip]
>>=20
>>>> As a result, concurrent operation such as KSM???s =
write_protect_page() or
>>>=20
>>> write_protect_page operates under the page lock and cannot race with =
reclaim.
>>=20
>> I still do not understand this claim. IIUC, reclaim can unmap the =
page in
>> some page table, decide not to reclaim the page and release the =
page-lock
>> before flush.
>=20
> shrink_page_list is the caller of try_to_unmap in reclaim context. It
> has this check
>=20
>                if (!trylock_page(page))
>                        goto keep;
>=20
> For pages it cannot lock, they get put back on the LRU and recycled =
instead
> of reclaimed. Hence, if KSM or anything else holds the page lock, =
reclaim
> can't unmap it.

Yes, of course, since KSM does not batch TLB flushes. I regarded the =
other
direction - first try_to_unmap() removes the PTE (but still does not =
flush),
unlocks the page, and then KSM acquires the page lock and calls
write_protect_page(). It finds out the PTE is not present and does not =
flush
the TLB.

>>>> page_mkclean_one() can consider the page write-protected while in =
fact it is
>>>> still accessible - since the TLB flush was deferred.
>>>=20
>>> As long as it's flushed before any IO occurs that would lose a data =
update,
>>> it's not a data integrity issue.
>>>=20
>>>> As a result, they may
>>>> mishandle the PTE without flushing the page. In the case of
>>>> page_mkclean_one(), I suspect it may even lead to memory =
corruption. I admit
>>>> that in x86 there are some mitigating factors that would make such =
???attack???
>>>> complicated, but it still seems wrong to me, no?
>>>=20
>>> I worry that you're beginning to see races everywhere. I admit that =
the
>>> rules and protections here are varied and complex but it's worth =
keeping
>>> in mind that data integrity is the key concern (no false reads to =
wrong
>>> data, no lost writes) and the first race you identified found some =
problems
>>> here. However, with or without batching, there is always a delay =
between
>>> when a PTE is cleared and when the TLB entries are removed.
>>=20
>> Sure, but usually the delay occurs while the page-table lock is taken =
so
>> there is no race.
>>=20
>> Now, it is not fair to call me a paranoid, considering that these =
races are
>> real - I confirmed that at least two can happen in practice.
>=20
> It's less an accusation of paranoia and more a caution that the fact =
that
> pte_clear_flush is not atomic means that it can be difficult to find =
what
> races matter and what ones don't.
>=20
>> As for ???data integrity is the key concern??? - violating the memory =
management
>> API can cause data integrity issues for programs.
>=20
> The madvise one should be fixed too. It could also be "fixed" by
> removing all batching but the performance cost will be sufficiently =
high
> that there will be pressure to find an alternative.
>=20
>> It may not cause the OS to
>> crash, but it should not be acceptable either, and may potentially =
raise
>> security concerns. If you think that the current behavior is ok, let =
the
>> documentation and man pages clarify that mprotect may not protect, =
madvise
>> may not advise and so on.
>=20
> The madvise one should be fixed, not because because it allows a case
> whereby userspace thinks it has initialised a structure that is =
actually
> in a page that is freed after a TLB is flushed resulting in a lost
> write. It wouldn't cause any issues with shared or file-backed =
mappings
> but it is a problem for anonymous.
>=20
>> And although you would use it against me, I would say: Nobody knew =
that TLB
>> flushing could be so complicated.
>=20
> There is no question that the area is complicated.

My comment was actually an unfunny joke... Never mind.

Thanks,
Nadav

p.s.: Thanks for your patience.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
