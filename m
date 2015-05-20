Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f171.google.com (mail-qk0-f171.google.com [209.85.220.171])
	by kanga.kvack.org (Postfix) with ESMTP id 685196B0120
	for <linux-mm@kvack.org>; Wed, 20 May 2015 10:17:36 -0400 (EDT)
Received: by qkgx75 with SMTP id x75so32481340qkg.1
        for <linux-mm@kvack.org>; Wed, 20 May 2015 07:17:36 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z71si6584560qkz.34.2015.05.20.07.17.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 May 2015 07:17:35 -0700 (PDT)
Date: Wed, 20 May 2015 16:17:30 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00/23] userfaultfd v4
Message-ID: <20150520141730.GO19097@redhat.com>
References: <1431624680-20153-1-git-send-email-aarcange@redhat.com>
 <20150519143801.8ba477c3813e93a2637c19cf@linux-foundation.org>
 <CAFLxGvwGGZH1bbMw+qReZFMK+dc6zoOTCNsuOMdp+xw_jPzPDg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFLxGvwGGZH1bbMw+qReZFMK+dc6zoOTCNsuOMdp+xw_jPzPDg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Weinberger <richard.weinberger@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, qemu-devel@nongnu.org, kvm <kvm@vger.kernel.org>, "open list:ABI/API" <linux-api@vger.kernel.org>, Pavel Emelyanov <xemul@parallels.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave.hansen@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>

Hello Richard,

On Tue, May 19, 2015 at 11:59:42PM +0200, Richard Weinberger wrote:
> On Tue, May 19, 2015 at 11:38 PM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
> > On Thu, 14 May 2015 19:30:57 +0200 Andrea Arcangeli <aarcange@redhat.com> wrote:
> >
> >> This is the latest userfaultfd patchset against mm-v4.1-rc3
> >> 2015-05-14-10:04.
> >
> > It would be useful to have some userfaultfd testcases in
> > tools/testing/selftests/.  Partly as an aid to arch maintainers when
> > enabling this.  And also as a standalone thing to give people a
> > practical way of exercising this interface.
> >
> > What are your thoughts on enabling userfaultfd for other architectures,
> > btw?  Are there good use cases, are people working on it, etc?
> 
> UML is using SIGSEGV for page faults.
> i.e. the UML processes receives a SIGSEGV, learns the faulting address
> from the mcontext
> and resolves the fault by installing a new mapping.
> 
> If userfaultfd is faster that the SIGSEGV notification it could speed
> up UML a bit.
> For UML I'm only interested in the notification, not the resolving
> part. The "missing"
> data is present, only a new mapping is needed. No copy of data.
> 
> Andrea, what do you think?

I think you need some kind of UFFDIO_MPROTECT ioctl that is the same
ioctl wrprotect tracking also needs. At the moment we focused the
future plans mostly on wrprotection tracking but it could be extended
to protnone tracking, either with the same feature flag as
wrprotection (with a generic UFFDIO_MPROTECT) or with two separate
feature flags and two separate ioctl.

Your pages are not missing, like in the postcopy live snapshotting
case the pages are not missing. The userfaultfd memory protection
ioctl will not modify the VMA, but it'll just selectively mark
pte/trans_huge_pmd wrprotected/protnone in order to get the faults. In
the case of postcopy live snapshotting a single ioctl call will mark
the entire guest address space readonly.

For live snapshotting the fault resolution is a no brainer: when you
get the fault the page is still readable and it just needs to be
copied off by the live snapshotting thread to a different location,
and then the UFFDIO_MPROTECT will be called again to make the page
writable and wake the blocked fault.

For the protnone, you need to modify the page before waking the
blocked userfault, you can't just remove the protnone or other threads
could modify it (if there are other threads). You'd need a further
ioctl to copy the page off to a different place by using its kernel
address (the userland address is not mapped) and copy it back to
overwrite the original page.

Alternatively once we extend the handle_userfault to tmpfs you could
map the page in two virtual mappings and track the faults in one
mapping (where the tracked app runs) and read/write the page contents
in the other mapping that isn't tracked by the userfault.

These are the first thoughts that comes to mind without knowing
exactly what you need to do after you get the fault address, and
without knowing exactly why you need to mark the region PROT_NONE.

There will be some complications in adding the wrprotection/protnone
feature: if faults could already happen when the wrprotect/protnone is
armed, the handle_userfault() could be invoked in a retry-fault, that
is not ok without allowing the userfault to return VM_FAULT_RETRY even
during a refault (i.e. FAULT_FLAG_TRIED set but FAULT_FLAG_ALLOW_RETRY
not set). The invariants of vma->vm_page_prot and pte/trans_huge_pmd
permissions must also not break anywhere. These are the two main
reasons why these features that requires to flip protection bits are
left implemented later and made visible later with uffdio_api.feature
flags and/or through uffdio_register.ioctl during UFFDIO_REGISTER.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
