Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9A2526B0270
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 09:06:41 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id 37-v6so6659302wrb.15
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 06:06:41 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g20-v6sor5476182wme.3.2018.10.31.06.06.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Oct 2018 06:06:40 -0700 (PDT)
MIME-Version: 1.0
References: <20181026075900.111462-1-marcorr@google.com> <20181026122948.GQ25444@bombadil.infradead.org>
 <20181026144528.GS25444@bombadil.infradead.org> <cd9934d3-2699-d705-9e66-88485fc74ead@intel.com>
In-Reply-To: <cd9934d3-2699-d705-9e66-88485fc74ead@intel.com>
From: Marc Orr <marcorr@google.com>
Date: Wed, 31 Oct 2018 13:06:27 +0000
Message-ID: <CAA03e5H+2Se7RDC3rdfnOgTkZdP9+R0DdR_=tmyp1MhtvKetQA@mail.gmail.com>
Subject: Re: [kvm PATCH v4 0/2] use vmalloc to allocate vmx vcpus
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave.hansen@intel.com
Cc: willy@infradead.org, kvm@vger.kernel.org, Jim Mattson <jmattson@google.com>, David Rientjes <rientjes@google.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-mm@kvack.org, akpm@linux-foundation.org, pbonzini@redhat.com, rkrcmar@redhat.com, sean.j.christopherson@intel.com, dave.hansen@linux.intel.com

On Fri, Oct 26, 2018 at 7:49 AM Dave Hansen <dave.hansen@intel.com> wrote:
>
> On 10/26/18 7:45 AM, Matthew Wilcox wrote:
> >         struct fpu                 user_fpu;             /*  2176  4160 */
> >         struct fpu                 guest_fpu;            /*  6336  4160 */
>
> Those are *not* supposed to be embedded in any other structures.  My bad
> for not documenting this better.
>
> It also seems really goofy that we need an xsave buffer in the
> task_struct for user fpu state, then another in the vcpu.  Isn't one for
> user state enough?
>
> In any case, I'd suggest getting rid of 'user_fpu', then either moving
> 'guest_fpu' to the bottom of the structure, or just make it a 'struct
> fpu *' and dynamically allocating it separately.

I've written a patch to get rid of user_fpu, as suggested here and
will be sending that out shortly.

>
> To do this, I'd take fpu__init_task_struct_size(), and break it apart a
> bit to tell you the size of the 'struct fpu' separately from the size of
> the 'task struct'.

I've written a 2nd patch to make guest_cpu  a 'struct fpu *' and
dynamically allocate it separately. The reason I went with this
suggestion, rather than moving 'struct fpu' to the bottom of
kvm_vcpu_arch is because I believe that solution would still expand
the kvm_vcpu_arch by the size of the fpu, according to which
fpregs_state was in use.
