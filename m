Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id C49596B02B0
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 21:12:05 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id zm5so21583634pac.0
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 18:12:05 -0700 (PDT)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id cz6si588266pad.230.2016.04.05.18.12.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Apr 2016 18:12:05 -0700 (PDT)
Received: by mail-pa0-x22f.google.com with SMTP id fe3so21556952pab.1
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 18:12:05 -0700 (PDT)
Date: Tue, 5 Apr 2016 18:12:02 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 17/31] kvm: teach kvm to map page teams as huge pages.
In-Reply-To: <57044C3A.7060109@redhat.com>
Message-ID: <alpine.LSU.2.11.1604051756020.7348@eggly.anvils>
References: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils> <alpine.LSU.2.11.1604051439340.5965@eggly.anvils> <57044C3A.7060109@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paolo Bonzini <pbonzini@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org

On Wed, 6 Apr 2016, Paolo Bonzini wrote:
> On 05/04/2016 23:41, Hugh Dickins wrote:
> > +/*
> > + * We are holding kvm->mmu_lock, serializing against mmu notifiers.
> > + * We have a ref on page.
> > ...
> > +static bool is_huge_tmpfs(struct kvm_vcpu *vcpu,
> > +			  unsigned long address, struct page *page)
> 
> vcpu is only used to access vcpu->kvm->mm.  If it's still possible to

Hah, you've lighted on precisely a line of code where I changed around
what Andres had - I thought it nicer to pass down vcpu, because that
matched the function above, and in many cases vcpu is not dereferenced
here at all.  So, definitely blame me not Andres for that interface.

> give a sensible rule for locking, I wouldn't mind if is_huge_tmpfs took
> the mm directly and was moved out of KVM.  Otherwise, it would be quite
> easy for people touch mm code to miss it.

Good point.  On the other hand, as you acknowledge in your "If...",
it might turn out to be too special-purpose in its assumptions to be
a safe export from core mm: Andres and I need to give it more thought.

> 
> Apart from this, both patches look good.

Thanks so much for such a quick response; and contrary to what I'd
expected in my "FYI" comment, Andrew has taken them into his tree,
to give them some early exposure via mmotm and linux-next - but
of course that doesn't stop us from changing it as you suggest -
we'll think it over again.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
