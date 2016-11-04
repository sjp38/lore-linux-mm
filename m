Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4D17E6B0265
	for <linux-mm@kvack.org>; Fri,  4 Nov 2016 12:40:50 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id o68so90949469qkf.3
        for <linux-mm@kvack.org>; Fri, 04 Nov 2016 09:40:50 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o76si8166687qkl.29.2016.11.04.09.40.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Nov 2016 09:40:49 -0700 (PDT)
Date: Fri, 4 Nov 2016 17:40:45 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 12/33] userfaultfd: non-cooperative: Add madvise() event
 for MADV_DONTNEED requestg
Message-ID: <20161104164045.GR4611@redhat.com>
References: <1478115245-32090-1-git-send-email-aarcange@redhat.com>
 <1478115245-32090-13-git-send-email-aarcange@redhat.com>
 <072b01d235a8$7238d230$56aa7690$@alibaba-inc.com>
 <20161103172441.GA14111@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161103172441.GA14111@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Hillf Danton <hillf.zj@alibaba-inc.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Shaohua Li <shli@fb.com>, Pavel Emelyanov <xemul@virtuozzo.com>

On Thu, Nov 03, 2016 at 11:24:46AM -0600, Mike Rapoport wrote:
> (changed 'CC:
> - Michael Rapoport <RAPOPORT@il.ibm.com>,
> - Dr. David Alan Gilbert@v2.random,  <dgilbert@redhat.com>,
> + Dr. David Alan Gilbert  <dgilbert@redhat.com>,
> - Pavel Emelyanov <xemul@parallels.com>@v2.random
> + Pavel Emelyanov <xemul@virtuozzo.com>

Sorry for this mess, so it turns out git will crunch a non rfc2822
compliant email address just fine, but postfix will not be happy and
it rewrites the header in a best effort way. The email is still
delivered because send-email specifies the addresses that git can cope
with on the sendmail command line instead of using -t, that's why the
email is delivered by the header is garbled.

On the git list they're discussing if the parsing of the email
addresses can be made more strict to follow rfc2822, otherwise from
--dry-run things look ok, but then when you removed --dry-run you find
out the hard way you left a trailing " in an email address...

> On Thu, Nov 03, 2016 at 04:01:12PM +0800, Hillf Danton wrote:
> > On Thursday, November 03, 2016 3:34 AM Andrea Arcangeli wrote:
> > > +void madvise_userfault_dontneed(struct vm_area_struct *vma,
> > > +				struct vm_area_struct **prev,
> > > +				unsigned long start, unsigned long end)
> > > +{
> > > +	struct userfaultfd_ctx *ctx;
> > > +	struct userfaultfd_wait_queue ewq;
> > > +
> > > +	ctx = vma->vm_userfaultfd_ctx.ctx;
> > > +	if (!ctx || !(ctx->features & UFFD_FEATURE_EVENT_MADVDONTNEED))
> > > +		return;
> > > +
> > > +	userfaultfd_ctx_get(ctx);
> > > +	*prev = NULL; /* We wait for ACK w/o the mmap semaphore */
> > > +	up_read(&vma->vm_mm->mmap_sem);
> > > +
> > > +	msg_init(&ewq.msg);
> > > +
> > > +	ewq.msg.event = UFFD_EVENT_MADVDONTNEED;
> > > +	ewq.msg.arg.madv_dn.start = start;
> > > +	ewq.msg.arg.madv_dn.end = end;
> > > +
> > > +	userfaultfd_event_wait_completion(ctx, &ewq);
> > > +
> > > +	down_read(&vma->vm_mm->mmap_sem);
> > 
> > After napping with mmap_sem released, is vma still valid?

Wow, nice catch Hillf. There was zero chance to catch this at runtime,
we don't munmap the vma while the testcase runs, plus even if we did
such thing, to notice it would need to be reused fast enough. It was
just a single instruction window for a pointer dereference...

> You are right, vma may be invalid at that point. Thanks for spotting.
> 
> Andrea, how do you prefer the fix, incremental or the entire patch updated?

I'm applying your updated patch, fix you sent is correct.

I will also move *prev= NULL just after up_read too, doing it before
up_read looks like it has to be done before before releasing the lock
which is not the case. Furthermore it's a microoptimization for
scalability to do it after, but it won't make any runtime difference
of course.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
