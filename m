Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 13D406B0005
	for <linux-mm@kvack.org>; Sat,  3 Feb 2018 17:29:25 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id b3so6933351plr.23
        for <linux-mm@kvack.org>; Sat, 03 Feb 2018 14:29:25 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id t4-v6sor1569475plb.103.2018.02.03.14.29.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 03 Feb 2018 14:29:23 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <8818bfd4-dd9f-f279-0432-69b59531bd41@huawei.com>
References: <20180124175631.22925-1-igor.stoppa@huawei.com>
 <20180124175631.22925-5-igor.stoppa@huawei.com> <CAG48ez0JRU8Nmn7jLBVoy6SMMrcj46R0_R30Lcyouc4R9igi-g@mail.gmail.com>
 <20180126053542.GA30189@bombadil.infradead.org> <alpine.DEB.2.20.1802021236510.31548@nuc-kabylake>
 <f2ddaed0-313e-8664-8a26-9d10b66ed0c5@huawei.com> <b75b5903-0177-8ad9-5c2b-fc63438fb5f2@huawei.com>
 <CAFUG7CfrCpcbwgf5ixMC5EZZgiVVVp1NXhDHK1UoJJcC08R2qQ@mail.gmail.com> <8818bfd4-dd9f-f279-0432-69b59531bd41@huawei.com>
From: Boris Lukashev <blukashev@sempervictus.com>
Date: Sat, 3 Feb 2018 17:29:22 -0500
Message-ID: <CAFUG7CeUhFcvA82uZ2ZH1j_6PM=aBo4XmYDN85pf8G0gPU44dg@mail.gmail.com>
Subject: Re: [kernel-hardening] [PATCH 4/6] Protectable Memory
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: Christopher Lameter <cl@linux.com>, Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, Jerome Glisse <jglisse@redhat.com>, Kees Cook <keescook@chromium.org>, Michal Hocko <mhocko@kernel.org>, Laura Abbott <labbott@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-security-module <linux-security-module@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

On Sat, Feb 3, 2018 at 3:32 PM, Igor Stoppa <igor.stoppa@huawei.com> wrote:
>
>
> On 03/02/18 22:12, Boris Lukashev wrote:
>
>> Regarding the notion of validated protected memory, is there a method
>> by which the resulting checksum could be used in a lookup
>> table/function to resolve the location of the protected data?
>
> What I have in mind is a checksum at page/vmap_area level, so there
> would be no 1:1 mapping between a specific allocation and the checksum.
>
> An extreme case would be the one where an allocation crosses one or more
> page boundaries, while the checksum refers to a (partially) overlapping
> memory area.
>
> Code accessing a pool could perform one (relatively expensive)
> validation. But still something that would require a more sophisticated
> attack, to subvert.
>
>> Effectively a hash table of protected allocations, with a benefit of
>> dedup since any data matching the same key would be the same data
>> (multiple identical cred structs being pushed around). Should leave
>> the resolver address/csum in recent memory to check against, right?
>
> I see where you are trying to land, but I do not see how it would work
> without a further intermediate step.
>
> pmalloc dishes out virtual memory addresses, when called.
>
> It doesn't know what the user of the allocation will put in it.
> The user, otoh, has the direct address of the memory it got.
>
> What you are suggesting, if I have understood it correctly, is that,
> when the pool is protected, the addresses already given out, will become
> traps that get resolved through a lookup table that is built based on
> the content of each allocation.
>
> That seems to generate a lot of overhead, not to mention the fact that
> it might not play very well with the MMU.

That is effectively what i'm suggesting - as a form of protection for
consumers against direct reads of data which may have been corrupted
by some irrelevant means. In the context of pmalloc, it would probably
be a separate type of ro+verified pool which consumers would
explicitly opt into. Say there's a maintenance cycle on a <name some
scary thing controlled by Linux> and it wants to make sure that the
instructions it read in are what they should have been before running
them, those consumers might well take the penalty if it keeps <said
scary big thing> from doing <the thing we're scared of it doing>.
If such a resolver could be implemented in a manner which doesnt break
all the things (including acceptable performance for at least a
significant number of workloads), it might be useful as a general tool
for handing out memory to userspace, even in rw, as it provides
execution context in which other requirements can be forcibly
resolved, preventing unauthorized access to pages the consumer
shouldn't get in a very generic way. Spectre comes to mind as a
potential class of issues to be addressed this way, since speculative
load could be prevented if the resolution were to fail.

>
> If I misunderstood, then I'd need a step by step description of what
> happens, because it's not clear to me how else the data would be
> accessed if not through the address that was obtained when pmalloc was
> invoked.
>
> --
> igor



-- 
Boris Lukashev
Systems Architect
Semper Victus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
