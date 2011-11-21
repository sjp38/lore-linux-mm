Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 272456B006C
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 05:11:09 -0500 (EST)
Date: Mon, 21 Nov 2011 05:11:00 -0500
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [V2 PATCH] tmpfs: add fallocate support
Message-ID: <20111121101059.GB17887@infradead.org>
References: <1321612791-4764-1-git-send-email-amwang@redhat.com>
 <20111119100326.GA27967@infradead.org>
 <CAPXgP10q8Fba3vr0zf-XBBaRPwjP7MyJ=-QRL45_8WC-vtotOg@mail.gmail.com>
 <alpine.LSU.2.00.1111201322310.1264@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1111201322310.1264@sister.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Kay Sievers <kay.sievers@vrfy.org>, Christoph Hellwig <hch@infradead.org>, Cong Wang <amwang@redhat.com>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Pekka Enberg <penberg@kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Lennart Poettering <lennart@poettering.net>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org

On Sun, Nov 20, 2011 at 01:39:12PM -0800, Hugh Dickins wrote:
> > To be able to safely use mmap(), regarding SIGBUS, on files on the
> > /dev/shm filesystem. The glibc fallback loop for -ENOSYS on fallocate
> > is just ugly.
> 
> The fallback for -EOPNOTSUPP?

Probably for both.  Note that the fallocate man page actually documents
the errors incorrecly - it documents ENOSYS for filesystems not
supporting fallocate, and EOPNOTSUPP for not recognizing the mode, but
we actually return EOPNOTSUPP for either case.  ENOSYS is only returned
by kernels not implementing fallocate at all.

> Being unfamiliar with glibc, I failed to find the internal_fallocate()
> that it appears to use when the filesystem doesn't support the call;
> so I don't know if I would agree with you that it's uglier than doing
> the same(?) in the kernel.

Last time I looked it basically did a pwrite loop writing zeroes.
Unfortunately it did far too small I/O sizes and thus actually causes
some major overhead e.g. on ext3.

> But since the present situation is that tmpfs has one interface to
> punching holes, madvise(MADV_REMOVE), that IBM were pushing 5 years ago;
> but ext4 (and others) now a fallocate(FALLOC_FL_PUNCH_HOLE) interface
> which IBM have been pushing this year: we do want to normalize that
> situation and make them all behave the same way.

FALLOC_FL_PUNCH_HOLE was added by Josef Bacik, who happens to work for
Red Hat, but I doubt he was pushing any corporate agenda there, he was
mostly making btrfs catch up with the 15 year old XFS hole punching
ioctl.


> And if tmpfs is going to support fallocate(FALLOC_FL_PUNCH_HOLE),
> looking at Amerigo's much more attractive V2 patch, it would seem
> to me perverse to permit the deallocation but fail the allocation.

Agreed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
