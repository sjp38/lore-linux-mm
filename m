Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f180.google.com (mail-lb0-f180.google.com [209.85.217.180])
	by kanga.kvack.org (Postfix) with ESMTP id 4B49A6B0038
	for <linux-mm@kvack.org>; Tue,  7 Oct 2014 06:53:32 -0400 (EDT)
Received: by mail-lb0-f180.google.com with SMTP id f15so5785637lbj.25
        for <linux-mm@kvack.org>; Tue, 07 Oct 2014 03:53:31 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.226])
        by mx.google.com with ESMTP id p5si28049359laf.101.2014.10.07.03.53.30
        for <linux-mm@kvack.org>;
        Tue, 07 Oct 2014 03:53:30 -0700 (PDT)
Date: Tue, 7 Oct 2014 13:52:45 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [Qemu-devel] [PATCH 08/17] mm: madvise MADV_USERFAULT
Message-ID: <20141007105245.GC30762@node.dhcp.inet.fi>
References: <1412356087-16115-1-git-send-email-aarcange@redhat.com>
 <1412356087-16115-9-git-send-email-aarcange@redhat.com>
 <20141007103645.GB30762@node.dhcp.inet.fi>
 <20141007104603.GI2404@work-vm>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141007104603.GI2404@work-vm>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Dr. David Alan Gilbert" <dgilbert@redhat.com>
Cc: Robert Love <rlove@google.com>, Dave Hansen <dave@sr71.net>, Jan Kara <jack@suse.cz>, kvm@vger.kernel.org, Neil Brown <neilb@suse.de>, Stefan Hajnoczi <stefanha@gmail.com>, qemu-devel@nongnu.org, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Taras Glek <tglek@mozilla.com>, Andrew Jones <drjones@redhat.com>, Juan Quintela <quintela@redhat.com>, Hugh Dickins <hughd@google.com>, Isaku Yamahata <yamahata@valinux.co.jp>, Mel Gorman <mgorman@suse.de>, Sasha Levin <sasha.levin@oracle.com>, Android Kernel Team <kernel-team@android.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Andres Lagar-Cavilla <andreslc@google.com>, Christopher Covington <cov@codeaurora.org>, Anthony Liguori <anthony@codemonkey.ws>, Mike Hommey <mh@glandium.org>, Keith Packard <keithp@keithp.com>, Wenchao Xia <wenchaoqemu@gmail.com>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Andy Lutomirski <luto@amacapital.net>, Minchan Kim <minchan@kernel.org>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Paolo Bonzini <pbonzini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Feiner <pfeiner@google.com>

On Tue, Oct 07, 2014 at 11:46:04AM +0100, Dr. David Alan Gilbert wrote:
> * Kirill A. Shutemov (kirill@shutemov.name) wrote:
> > On Fri, Oct 03, 2014 at 07:07:58PM +0200, Andrea Arcangeli wrote:
> > > MADV_USERFAULT is a new madvise flag that will set VM_USERFAULT in the
> > > vma flags. Whenever VM_USERFAULT is set in an anonymous vma, if
> > > userland touches a still unmapped virtual address, a sigbus signal is
> > > sent instead of allocating a new page. The sigbus signal handler will
> > > then resolve the page fault in userland by calling the
> > > remap_anon_pages syscall.
> > 
> > Hm. I wounder if this functionality really fits madvise(2) interface: as
> > far as I understand it, it provides a way to give a *hint* to kernel which
> > may or may not trigger an action from kernel side. I don't think an
> > application will behaive reasonably if kernel ignore the *advise* and will
> > not send SIGBUS, but allocate memory.
> 
> Aren't DONTNEED and DONTDUMP  similar cases of madvise operations that are
> expected to do what they say ?

No. If kernel would ignore MADV_DONTNEED or MADV_DONTDUMP it will not
affect correctness, just behaviour will be suboptimal: more than needed
memory used or wasted space in coredump.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
