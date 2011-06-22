Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id EE31790015D
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 00:48:02 -0400 (EDT)
Received: by iyl8 with SMTP id 8so503740iyl.14
        for <linux-mm@kvack.org>; Tue, 21 Jun 2011 21:48:00 -0700 (PDT)
From: Nai Xia <nai.xia@gmail.com>
Reply-To: nai.xia@gmail.com
Subject: Re: [PATCH 2/2 V2] ksm: take dirty bit as reference to avoid volatile pages scanning
Date: Wed, 22 Jun 2011 12:47:39 +0800
References: <201106212055.25400.nai.xia@gmail.com> <201106220804.12508.nai.xia@gmail.com> <20110622003536.GQ25383@sequoia.sous-sol.org>
In-Reply-To: <20110622003536.GQ25383@sequoia.sous-sol.org>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Message-Id: <201106221247.39827.nai.xia@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wright <chrisw@sous-sol.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <izik.eidus@ravellosystems.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Wednesday 22 June 2011 08:35:36 Chris Wright wrote:
> * Nai Xia (nai.xia@gmail.com) wrote:
> > (Sorry for repeated mail, I forgot to Cc the list..)
> > 
> > On Wednesday 22 June 2011 06:38:00 you wrote:
> > > * Nai Xia (nai.xia@gmail.com) wrote:
> > > > Introduced ksm_page_changed() to reference the dirty bit of a pte. We clear 
> > > > the dirty bit for each pte scanned but don't flush the tlb. For a huge page, 
> > > > if one of the subpage has changed, we try to skip the whole huge page 
> > > > assuming(this is true by now) that ksmd linearly scans the address space.
> > > 
> > > This doesn't build w/ kvm as a module.
> > 
> > I think it's because of the name-error of a related kvm patch, which I only sent
> > in a same email thread. http://marc.info/?l=linux-mm&m=130866318804277&w=2
> > The patch split is not clean...I'll redo it.
> > 
> 
> It needs an export as it is.
> ERROR: "kvm_dirty_update" [arch/x86/kvm/kvm-intel.ko] undefined!

Oops, yes, I forgot to do that! I'll correct it in the next submission.

Thanks,
Nai

> 
> Although perhaps could be done w/out that dirty_update altogether (as I
> mentioned in other email)?
> 
> > > 
> > > > A NEW_FLAG is also introduced as a status of rmap_item to make ksmd scan
> > > > more aggressively for new VMAs - only skip the pages considered to be volatile
> > > > by the dirty bits. This can be enabled/disabled through KSM's sysfs interface.
> > > 
> > > This seems like it should be separated out.  And while it might be useful
> > > to enable/disable for testing, I don't think it's worth supporting for
> > > the long term.  Would also be useful to see the value of this flag.
> > 
> > I think it maybe useful for uses who want to turn on/off this scan policy explicitly
> > according to their working sets? 
> 
> Can you split it out, and show the benefit of it directly?  I think it
> only benefits:
> 
> p = mmap()
> memset(p, $value, entire buffer);
> ...
> very slowly (w.r.t scan times) touch bits of buffer and trigger cow to
> break sharing.
> 
> Would you agree?
> 
> thanks,
> -chris
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
