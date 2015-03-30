Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id AC8A46B0032
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 16:32:16 -0400 (EDT)
Received: by padcy3 with SMTP id cy3so177313734pad.3
        for <linux-mm@kvack.org>; Mon, 30 Mar 2015 13:32:16 -0700 (PDT)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id u12si7094123pbs.132.2015.03.30.13.32.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Mar 2015 13:32:15 -0700 (PDT)
Received: by patj18 with SMTP id j18so21470447pat.2
        for <linux-mm@kvack.org>; Mon, 30 Mar 2015 13:32:15 -0700 (PDT)
Date: Mon, 30 Mar 2015 13:32:13 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [patch][resend] MAP_HUGETLB munmap fails with size not 2MB
 aligned
In-Reply-To: <CAHGf_=p8yYDGVn-utH7UUOnoF9+W15_WG_xGwN-h3=hMKbYDyw@mail.gmail.com>
Message-ID: <alpine.LSU.2.11.1503301323440.2485@eggly.anvils>
References: <alpine.DEB.2.10.1410221518160.31326@davide-lnx3> <alpine.LSU.2.11.1503251708530.5592@eggly.anvils> <alpine.DEB.2.10.1503251754320.26501@davide-lnx3> <alpine.DEB.2.10.1503251938170.16714@chino.kir.corp.google.com> <alpine.DEB.2.10.1503260431290.2755@mbplnx>
 <551412FB.4090406@akamai.com> <CAHGf_=p8yYDGVn-utH7UUOnoF9+W15_WG_xGwN-h3=hMKbYDyw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Eric B Munson <emunson@akamai.com>, Davide Libenzi <davidel@xmailserver.org>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Joern Engel <joern@logfs.org>, Jianguo Wu <wujianguo@huawei.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Mon, 30 Mar 2015, KOSAKI Motohiro wrote:
> On Thu, Mar 26, 2015 at 10:08 AM, Eric B Munson <emunson@akamai.com> wrote:
> > On 03/26/2015 07:56 AM, Davide Libenzi wrote:
> >> On Wed, 25 Mar 2015, David Rientjes wrote:
> >>
> >>> I looked at this thread at http://marc.info/?t=141392508800001
> >>> since I didn't have it in my mailbox, and I didn't get a chance
> >>> to actually run your test code.
> >>>
> >>> In short, I think what you're saying is that
> >>>
> >>> ptr = mmap(..., 4KB, ..., MAP_HUGETLB | ..., ...) munmap(ptr,
> >>> 4KB) == EINVAL
> >>
> >> I am not sure you have read the email correctly:
> >>
> >> munmap(mmap(size, HUGETLB), size) = EFAIL
> >>
> >> For every size not multiple of the huge page size. Whereas:
> >>
> >> munmap(mmap(size, HUGETLB), ALIGN(size, HUGEPAGE_SIZE)) = OK
> >
> > I think Davide is right here, this is a long existing bug in the
> > MAP_HUGETLB implementation.  Specifically, the mmap man page says:
> >
> > All pages containing a part of the indicated range are unmapped, and
> > subsequent references to these pages will generate SIGSEGV.
> >
> > I realize that huge pages may not have been considered by those that
> > wrote the spec.  But if I read this I would assume that all pages,
> > regardless of size, touched by the munmap() request should be unmapped.
> >
> > Please include
> > Acked-by: Eric B Munson <emunson@akamai.com>
> > to the original patch.  I would like to see the mmap man page adjusted
> > to make note of this behavior as well.
> 
> This is just a bug fix and I never think this has large risk. But
> caution, we might revert immediately
> if this patch arise some regression even if it's come from broken
> application code.
> 
> Acked-by: KOSAKI Motohiro <kosaki.motohiro@gmail.com>

and, without wishing to be confrontational,
Nacked-by: Hugh Dickins <hughd@google.com>

I agree with you that the risk on munmap is probably not large;
but I still have no interest in spending more time on changing
twelve-year-old established behaviour in this way, then looking
out for the regressions and preparing to revert.

The risk is larger on mprotect, and the other calls which this
patch as is would leave inconsistent with munmap.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
