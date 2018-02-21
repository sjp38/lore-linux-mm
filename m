Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 837886B0003
	for <linux-mm@kvack.org>; Wed, 21 Feb 2018 17:22:13 -0500 (EST)
Received: by mail-vk0-f69.google.com with SMTP id x138so996131vkd.8
        for <linux-mm@kvack.org>; Wed, 21 Feb 2018 14:22:13 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l42sor11332736uae.9.2018.02.21.14.22.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 21 Feb 2018 14:22:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <b67209f5-4aa7-ffc0-99e6-3ab05e281ce5@huawei.com>
References: <20180124175631.22925-1-igor.stoppa@huawei.com>
 <20180126053542.GA30189@bombadil.infradead.org> <alpine.DEB.2.20.1802021236510.31548@nuc-kabylake>
 <f2ddaed0-313e-8664-8a26-9d10b66ed0c5@huawei.com> <b75b5903-0177-8ad9-5c2b-fc63438fb5f2@huawei.com>
 <CAFUG7CfrCpcbwgf5ixMC5EZZgiVVVp1NXhDHK1UoJJcC08R2qQ@mail.gmail.com>
 <8818bfd4-dd9f-f279-0432-69b59531bd41@huawei.com> <CAFUG7CeUhFcvA82uZ2ZH1j_6PM=aBo4XmYDN85pf8G0gPU44dg@mail.gmail.com>
 <17e5b515-84c8-dca2-1695-cdf819834ea2@huawei.com> <CAGXu5j+LS1pgOOroi7Yxp2nh=DwtTnU3p-NZa6bQu_wkvvVkwg@mail.gmail.com>
 <414027d3-dd73-cf11-dc2a-e8c124591646@redhat.com> <CAGXu5j++igQD4tMh0J8nZ9jNji5mU16C7OygFJ5Td+Bq-KSMgw@mail.gmail.com>
 <CAG48ez1utN_vwHUwk=BU6zM4Wa_53TPu8rm9JuTtY-vGP0Shqw@mail.gmail.com>
 <f4226a44-92fd-8ead-b458-7551ba82f96d@redhat.com> <CAGXu5j+zOCLerneUt2b-tvyLLg7fEbr9B0YYow-4DH6oV-nnCw@mail.gmail.com>
 <2f23544a-bd24-1e71-967b-e8d1cf5a20a3@redhat.com> <CAGXu5j+RRiZtYfO-4Peh=FAHmUS4FThKHp-djoFgY80rebKTxQ@mail.gmail.com>
 <b67209f5-4aa7-ffc0-99e6-3ab05e281ce5@huawei.com>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 21 Feb 2018 14:22:10 -0800
Message-ID: <CAGXu5jKbuGcrdtVjEqp72e0+enzg26p1EGVPJ7goorbOnvcniA@mail.gmail.com>
Subject: Re: arm64 physmap (was Re: [kernel-hardening] [PATCH 4/6] Protectable Memory)
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: Laura Abbott <labbott@redhat.com>, Jann Horn <jannh@google.com>, Boris Lukashev <blukashev@sempervictus.com>, Christopher Lameter <cl@linux.com>, Matthew Wilcox <willy@infradead.org>, Jerome Glisse <jglisse@redhat.com>, Michal Hocko <mhocko@kernel.org>, Christoph Hellwig <hch@infradead.org>, linux-security-module <linux-security-module@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>

On Tue, Feb 20, 2018 at 8:28 AM, Igor Stoppa <igor.stoppa@huawei.com> wrote:
>
>
> On 14/02/18 21:29, Kees Cook wrote:
>> On Wed, Feb 14, 2018 at 11:06 AM, Laura Abbott <labbott@redhat.com> wrote:
>
> [...]
>
>>> Kernel code should be fine, if it isn't that is a bug that should be
>>> fixed. Modules yes are not fully protected. The conclusion from past
>>
>> I think that's a pretty serious problem: we can't have aliases with
>> mismatched permissions; this degrades a deterministic protection
>> (read-only) to a probabilistic protection (knowing where the alias of
>> a target is mapped). Having an attack be "needs some info leaks"
>> instead of "need execution control to change perms" is a much lower
>> bar, IMO.
>
> Why "need execution control to change permission"?
> Or, iow, what does it mean exactly?
> ROP/JOP? Data-oriented control flow hijack?

Right, I mean, if an attacker has already gained execute control, they
can just call the needed functions to change memory permissions. But
that isn't needed if there is a mismatch between physmap and virtmap:
i.e. they can write to the physmap without needing to change perms
first.

> One can argue that this sort of R/W activity probably does require some
> form of execution control, but AFAIK, the only way to to prevent it, is
> to have CFI - btw, is there any standardization in that sense?

I meant that I don't want a difference in protection between physmap
and virtmap. I'd like to be able to reason the smae about the
exposures in either.

> So, from my (pessimistic?) perspective, the best that can be hoped for,
> is to make it much harder to figure out where the data is located.
>
> Virtual mapping has this side effect, compared to linear mapping.

Right, this is good, for sure. No complaints there at all. It's why I
think pmalloc and arm64 physmap perms are separate issues.

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
