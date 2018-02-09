Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id BDFAF6B0011
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 06:18:06 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id e195so3721153wmd.9
        for <linux-mm@kvack.org>; Fri, 09 Feb 2018 03:18:06 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id y16si1582287wrd.203.2018.02.09.03.18.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Feb 2018 03:18:05 -0800 (PST)
Subject: Re: [kernel-hardening] [PATCH 4/6] Protectable Memory
References: <20180124175631.22925-1-igor.stoppa@huawei.com>
 <20180124175631.22925-5-igor.stoppa@huawei.com>
 <CAG48ez0JRU8Nmn7jLBVoy6SMMrcj46R0_R30Lcyouc4R9igi-g@mail.gmail.com>
 <20180126053542.GA30189@bombadil.infradead.org>
 <alpine.DEB.2.20.1802021236510.31548@nuc-kabylake>
 <f2ddaed0-313e-8664-8a26-9d10b66ed0c5@huawei.com>
 <alpine.DEB.2.20.1802050935300.10705@nuc-kabylake>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <4e113814-7d24-b48c-993f-46d5aee1755d@huawei.com>
Date: Fri, 9 Feb 2018 13:17:49 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1802050935300.10705@nuc-kabylake>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Matthew Wilcox <willy@infradead.org>, Boris Lukashev <blukashev@sempervictus.com>, Jann Horn <jannh@google.com>, jglisse@redhat.com, Kees Cook <keescook@chromium.org>, Michal Hocko <mhocko@kernel.org>, Laura Abbott <labbott@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-security-module@vger.kernel.org, linux-mm@kvack.org, kernel list <linux-kernel@vger.kernel.org>, Kernel
 Hardening <kernel-hardening@lists.openwall.com>



On 05/02/18 17:40, Christopher Lameter wrote:
> On Sat, 3 Feb 2018, Igor Stoppa wrote:
> 
>>> We could even do this in a more thorough way. Can we use a ring 1 / 2
>>> distinction to create a hardened OS core that policies the rest of
>>> the ever expanding kernel with all its modules and this and that feature?
>>
>> What would be the differentiating criteria? Furthermore, what are the
>> chances
>> of invalidating the entire concept, because there is already an
>> hypervisor using
>> the higher level features?
>> That is what you are proposing, if I understand correctly.
> 
> Were there not 4 rings as well as methods by the processor vendors to
> virtualize them as well?

I think you are talking x86, mostly.
On ARM there are ELx and they are often (typically?) already used.
For x86 I cannot comment.

>>> I think that will long term be a better approach and allow more than the
>>> current hardening approaches can get you. It seems that we are willing to
>>> tolerate significant performance regressions now. So lets use the
>>> protection mechanisms that the hardware offers.
>>
>> I would rather *not* propose significant performance regression :-P
> 
> But we already have implemented significant kernel hardening which causes
> performance regressions. Using hardware capabilities allows the processor
> vendor to further optimize these mechanisms whereas the software
> preventative measures are eating up more and more performance as the pile
> them on. Plus these are methods that can be worked around. Restrictions
> implemented in a higher ring can be enforced and are much better than
> just "hardening" (which is making life difficult for the hackers and
> throwing away performannce for the average user).

What you are proposing requires major restructuring of the memory
management - at the very least - provided that it doesn't cause the
conflicts I mentioned above.

Even after you do that, the system will still be working with memory
pages, there will be still a need to segregate data within certain
pages, or pay the penalty of handling exceptions, when data with
different permissions coexist within the same page.

The way the pmalloc API is designed is meant to facilitate the
segregation and to actually improve performance, by grouping types of
data with same scope and permission.

WRT the implementation, there is a minimal exposure to the memory
provider, both for allocation and release.

Same goes for the protection mechanism.
It's a single call to the function which makes pages read only.
It would be trivial to swap it out with a call to whatever framework you
want to come up with, for implementing ring/EL based protection.

>From this perspective, you can easily provide patches that implement
what you are proposing, against pmalloc, if you really think that it's
the way to go.

I'll be happy to use them, if they provide improved performance and same
or better protection.

The way I designed pmalloc was really to be able to switch to some
alternate memory provider and/or protection mechanism, should a better
one arise.

But it can be done in a separate step, I think, since you are not
proposing to just change pmalloc, you are proposing to re-design how the
overall kernel memory hardening works (including executable pages, const
data, __ro_after_init, etc.)

--
igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
