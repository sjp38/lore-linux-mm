Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 3A6296B01DC
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 10:09:42 -0400 (EDT)
Date: Mon, 21 Jun 2010 16:09:39 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [Lsf10-pc] Current MM topics for LSF10/MM Summit 8-9 August in
 Boston
Message-ID: <20100621140939.GY5787@random.random>
References: <1276721459.2847.399.camel@mulgrave.site>
 <20100621120526.GA31679@laptop>
 <20100621131608.GW5787@random.random>
 <20100621132238.GK4689@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100621132238.GK4689@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, lsf10-pc@lists.linuxfoundation.org, linux-scsi@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 21, 2010 at 04:22:38PM +0300, Gleb Natapov wrote:
> On Mon, Jun 21, 2010 at 03:16:08PM +0200, Andrea Arcangeli wrote:
> > > KOSAKI Motohiro		get_user_pages vs COW problem
> > 
> > Just a side note, not sure exactly what is meant to be discussed about
> > this bug, considering the fact this is still unsolved isn't technical
> > problem as there were plenty of fixes available, and the one that seem
> > to had better chance to get included was the worst one in my view, as
> > it tried to fix it in a couple of gup caller (but failed, also because
> > finding all put_page pin release is kind of a pain as they're spread
> > all over the place and not identified as gup_put_page, and in addition
> > to the instability and lack of completeness of the fix, it was also
> > the most inefficient as it added unnecessary and coarse locking) plus
> > all gup callers are affected, not just a few. I normally call it gup
> > vs fork race. Luckily not all threaded apps uses O_DIRECT and fork and
> > pretend to do the direct-io in different sub-page chunks of the same
> > page from different threads (KVM would probably be affected if it
> > didn't use MADV_DONTFORK on the O_DIRECT memory, as it might run fork
> > to execute some network script when adding an hotplug pci net device
> > for example). But surely we can discuss the fix we prefer for this
> > bug, or at least we can agree it needs fixing.
> > 
> KVM is actually affected by the bug. The fix was posted today:
> http://www.mail-archive.com/kvm@vger.kernel.org/msg36759.html

Interesting... so this is the page returned by gup that doesn't match
anymore the page after an user write into qemu context after
fork. Clearly any of the fixes proposed would have prevented this bug
in the first place as they would assign a copy to the child, so yes
it's likely this same bug. It's quite sad to have this workload that
is superfluous if gup would behave as supposed by the caller. Also I'd
prefer if you would use MADV_DONTFORK for the fix, as that will at
least optimize fork and it would still be ok to keep even after we fix
the VM while this workaround of using tmpfs should be backed out.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
