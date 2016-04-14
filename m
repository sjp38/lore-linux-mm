Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id B11196B0274
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 12:22:34 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id h185so149348090vkg.0
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 09:22:34 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n81si33007769qhc.54.2016.04.14.09.22.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Apr 2016 09:22:33 -0700 (PDT)
Date: Thu, 14 Apr 2016 12:22:30 -0400
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: post-copy is broken?
Message-ID: <20160414162230.GC9976@redhat.com>
References: <F2CBF3009FA73547804AE4C663CAB28E0417E6B1@shsmsx102.ccr.corp.intel.com>
 <20160412175501.GB6415@work-vm>
 <F2CBF3009FA73547804AE4C663CAB28E0417EE92@shsmsx102.ccr.corp.intel.com>
 <F2CBF3009FA73547804AE4C663CAB28E0417EEE4@shsmsx102.ccr.corp.intel.com>
 <20160413080545.GA2270@work-vm>
 <20160413114103.GB2270@work-vm>
 <20160413125053.GC2270@work-vm>
 <20160413205132.GG26364@redhat.com>
 <20160414123441.GF2252@work-vm>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160414123441.GF2252@work-vm>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Dr. David Alan Gilbert" <dgilbert@redhat.com>
Cc: kirill.shutemov@linux.intel.com, "Li, Liang Z" <liang.z.li@intel.com>, Amit Shah <amit.shah@redhat.com>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "quintela@redhat.com" <quintela@redhat.com>, linux-mm@kvack.org

Adding linux-mm too,

On Thu, Apr 14, 2016 at 01:34:41PM +0100, Dr. David Alan Gilbert wrote:
> * Andrea Arcangeli (aarcange@redhat.com) wrote:
> 
> > The next suspect is the massive THP refcounting change that went
> > upstream recently:
> 
> > As further debug hint, can you try to disable THP and see if that
> > makes the problem go away?
> 
> Yep, this seems to be the problem (cc'ing in Kirill).
> 
> 122afea9626ab3f717b250a8dd3d5ebf57cdb56c - works (just before Kirill disables THP)
> 61f5d698cc97600e813ca5cf8e449b1ea1c11492 - breaks (when THP is reenabled)
> 
> It's pretty reliable; as you say disabling THP makes it work again
> and putting it back to THP/madvise mode makes it break.  And you need
> to test on a machine with some free ram to make sure THP has a chance
> to have happened.
> 
> I'm not sure of all of the rework that happened in that series,
> but my reading of it is that splitting of THP pages gets deferred;
> so I wonder if when I do the madvise to turn THP off, if it's actually
> still got THP pages and thus we end up with a whole THP mapped
> when I'm expecting to be userfaulting those pages.

Good thing at least I didn't make UFFDIO_COPY THP aware yet so there's
less variables (as no user was interested to handle userfaults at THP
granularity yet, and from userland such an improvement would be
completely invisible in terms of API, so if an user starts doing that
we can just optimize the kernel for it, criu restore could do that as
the faults will come from disk-I/O, when network is involved THP
userfaults wouldn't have a great tradeoff with regard to the increased
fault latency).

I suspect there is an handle_userfault missing somewhere in connection
with trans_huge_pmd splits (not anymore THP splits) that you're doing
with MADV_DONTNEED to zap those pages in the destination that got
redirtied in source during the last precopy stage. Or more simply
MADV_DONTNEED isn't zapping all the right ptes after the trans huge
pmd got splitted.

The fact the page isn't splitted shouldn't matter too much, all we care
about is the pte triggers handle_userfault after MADV_DONTNEED.

The userfaultfd testcase in the kernel isn't exercising this case
unfortunately, that should probably be improved too, so there is a
simpler way to reproduce than running precopy before postcopy in qemu.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
