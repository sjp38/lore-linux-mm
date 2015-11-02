Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 08A826B0038
	for <linux-mm@kvack.org>; Mon,  2 Nov 2015 13:44:51 -0500 (EST)
Received: by wmff134 with SMTP id f134so66625302wmf.1
        for <linux-mm@kvack.org>; Mon, 02 Nov 2015 10:44:50 -0800 (PST)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id 13si23608426wml.77.2015.11.02.10.44.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Nov 2015 10:44:49 -0800 (PST)
Date: Mon, 2 Nov 2015 10:16:24 -0800
From: Shaohua Li <shli@fb.com>
Subject: Re: [RFC] mm: add a new vector based madvise syscall
Message-ID: <20151102181623.GA3751821@devbig084.prn1.facebook.com>
References: <20151029215516.GA3864685@devbig084.prn1.facebook.com>
 <871tccaz65.fsf@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <871tccaz65.fsf@tassilo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, hughd@google.com, hannes@cmpxchg.org, aarcange@redhat.com, je@fb.com, Kernel-team@fb.com

On Fri, Oct 30, 2015 at 01:17:54PM -0700, Andi Kleen wrote:
> Shaohua Li <shli@fb.com> writes:
> > +		vmas[i] = find_vma(current->mm, start);
> > +		/*
> > +		 * don't allow range cross vma, it doesn't make sense for
> > +		 * DONTNEED
> > +		 */
> > +		if (!vmas[i] || start < vmas[i]->vm_start ||
> > +		    start + len > vmas[i]->vm_end) {
> > +			error = -ENOMEM;
> > +			goto up_out;
> > +		}
> > +		if (vmas[i]->vm_flags & (VM_LOCKED|VM_HUGETLB|VM_PFNMAP)) {
> > +			error = -EINVAL;
> > +			goto up_out;
> > +		}
> > +	}
> 
> Needs a cond_resched() somewhere in case the list is very long?

Yep, the zap_pmd_range() has cond_resched(). 
> BTW one trick that may be interesting here is to add a new mode
> that skips the TLB flush completely, but instead waits with
> the freeing until enough context switches to non kernel tasks occurred
> (and flushed the TLB this way). This could be done as part of RCU.

that would not work if the app madvise(DONTNEED) first and then access the
virtual address again.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
