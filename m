Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id E2F896B0008
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 09:17:53 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id d16-v6so12820291wru.22
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 06:17:53 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 59-v6sor1746973wro.34.2018.10.31.06.17.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Oct 2018 06:17:52 -0700 (PDT)
MIME-Version: 1.0
References: <20181026075900.111462-1-marcorr@google.com> <CANRm+Cy2K08MCWq0mtqor66Uz8g-MaVKb=JDGD0WostFeogKSA@mail.gmail.com>
 <CALMp9eSAP6=3MOjcexZsrtGjg4z6ULjhaJZBOZCkpFKganKfhA@mail.gmail.com> <20181029164813.GH28520@bombadil.infradead.org>
In-Reply-To: <20181029164813.GH28520@bombadil.infradead.org>
From: Marc Orr <marcorr@google.com>
Date: Wed, 31 Oct 2018 13:17:40 +0000
Message-ID: <CAA03e5GT4gR4iN-na0PR_oTrXKVuD8BRcHcR8Y58==eRae3iXA@mail.gmail.com>
Subject: Re: [kvm PATCH v4 0/2] use vmalloc to allocate vmx vcpus
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: willy@infradead.org
Cc: Jim Mattson <jmattson@google.com>, Wanpeng Li <kernellwp@gmail.com>, kvm@vger.kernel.org, David Rientjes <rientjes@google.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-mm@kvack.org, akpm@linux-foundation.org, pbonzini@redhat.com, rkrcmar@redhat.com, sean.j.christopherson@intel.com

On Mon, Oct 29, 2018 at 9:48 AM Matthew Wilcox <willy@infradead.org> wrote:
>
> On Mon, Oct 29, 2018 at 09:25:05AM -0700, Jim Mattson wrote:
> > On Sun, Oct 28, 2018 at 6:58 PM, Wanpeng Li <kernellwp@gmail.com> wrote:
> > > We have not yet encounter memory is too fragmented to allocate kvm
> > > related metadata in our overcommit pools, is this true requirement
> > > from the product environments?
> >
> > Yes.
>
> Are your logs granular enough to determine if turning this into an
> order-2 allocation (by splitting out "struct fpu" allocations) will be
> sufficient to resolve your problem, or do we need to turn it into an
> order-1 or vmalloc allocation to achieve your production goals?

As noted in my response to Dave Hansen, I've got his suggestions done
and they were successful in drastically reducing the size of the
vcpu_vmx struct, which is great. Specifically, on an upstream kernel,
I've reduced the size of the struct from 23680 down to 15168, which is
order 2.

All that being said, I don't really understand why we wouldn't convert
this memory allocation from a kmalloc() into a vmalloc(). From my
point of view, we are still close to bloating vcpu_vmx into an order 3
allocation, and it's common for vendors to append to both vcpu_vmx
directly, or more likely to its embedded structs. Though, arguably,
vendors should not be doing that.

Most importantly, it just isn't obvious to me why kmalloc() is
preferred over vmalloc(). From my point of view, vmalloc() does the
exact same thing as kmalloc(), except that it works when contiguous
memory is sparse, which seems better to me.
