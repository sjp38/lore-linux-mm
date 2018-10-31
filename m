Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 117236B0266
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 10:21:27 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 14-v6so13662947pfk.22
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 07:21:27 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c38-v6si23775233pgl.166.2018.10.31.07.21.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 31 Oct 2018 07:21:25 -0700 (PDT)
Date: Wed, 31 Oct 2018 07:21:22 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [kvm PATCH v4 0/2] use vmalloc to allocate vmx vcpus
Message-ID: <20181031142122.GM10491@bombadil.infradead.org>
References: <20181026075900.111462-1-marcorr@google.com>
 <CANRm+Cy2K08MCWq0mtqor66Uz8g-MaVKb=JDGD0WostFeogKSA@mail.gmail.com>
 <CALMp9eSAP6=3MOjcexZsrtGjg4z6ULjhaJZBOZCkpFKganKfhA@mail.gmail.com>
 <20181029164813.GH28520@bombadil.infradead.org>
 <CAA03e5GT4gR4iN-na0PR_oTrXKVuD8BRcHcR8Y58==eRae3iXA@mail.gmail.com>
 <20181031132751.GL10491@bombadil.infradead.org>
 <CAA03e5F+o5svBe1HTOHukD6Z6ctnKB96+SQTfMZX39uhP2AS0g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA03e5F+o5svBe1HTOHukD6Z6ctnKB96+SQTfMZX39uhP2AS0g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marc Orr <marcorr@google.com>
Cc: Jim Mattson <jmattson@google.com>, Wanpeng Li <kernellwp@gmail.com>, kvm@vger.kernel.org, David Rientjes <rientjes@google.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-mm@kvack.org, akpm@linux-foundation.org, pbonzini@redhat.com, rkrcmar@redhat.com, sean.j.christopherson@intel.com

On Wed, Oct 31, 2018 at 01:48:44PM +0000, Marc Orr wrote:
> Thanks for the explanation. Is there a way to dynamically detect the
> memory allocation done by kvmalloc() (i.e., kmalloc() or vmalloc())?
> If so, we could use kvmalloc(), and add two code paths to do the
> physical mapping, according to whether the underlying memory was
> allocated with kmalloc() or vmalloc().

Yes -- it's used in the implementation of kvfree():

        if (is_vmalloc_addr(addr))
                vfree(addr);
        else
                kfree(addr);
