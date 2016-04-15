Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id E0A1C6B0005
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 08:52:39 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id a125so17671053wmd.0
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 05:52:39 -0700 (PDT)
Received: from mail-wm0-x231.google.com (mail-wm0-x231.google.com. [2a00:1450:400c:c09::231])
        by mx.google.com with ESMTPS id y4si33382500wjy.204.2016.04.15.05.52.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Apr 2016 05:52:38 -0700 (PDT)
Received: by mail-wm0-x231.google.com with SMTP id v188so29840586wme.1
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 05:52:38 -0700 (PDT)
Date: Fri, 15 Apr 2016 15:52:36 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: post-copy is broken?
Message-ID: <20160415125236.GA3376@node.shutemov.name>
References: <F2CBF3009FA73547804AE4C663CAB28E0417E6B1@shsmsx102.ccr.corp.intel.com>
 <20160412175501.GB6415@work-vm>
 <F2CBF3009FA73547804AE4C663CAB28E0417EE92@shsmsx102.ccr.corp.intel.com>
 <F2CBF3009FA73547804AE4C663CAB28E0417EEE4@shsmsx102.ccr.corp.intel.com>
 <20160413080545.GA2270@work-vm>
 <20160413114103.GB2270@work-vm>
 <20160413125053.GC2270@work-vm>
 <20160413205132.GG26364@redhat.com>
 <20160414123441.GF2252@work-vm>
 <20160414162230.GC9976@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160414162230.GC9976@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Dr. David Alan Gilbert" <dgilbert@redhat.com>, kirill.shutemov@linux.intel.com, "Li, Liang Z" <liang.z.li@intel.com>, Amit Shah <amit.shah@redhat.com>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "quintela@redhat.com" <quintela@redhat.com>, linux-mm@kvack.org

On Thu, Apr 14, 2016 at 12:22:30PM -0400, Andrea Arcangeli wrote:
> Adding linux-mm too,
> 
> On Thu, Apr 14, 2016 at 01:34:41PM +0100, Dr. David Alan Gilbert wrote:
> > * Andrea Arcangeli (aarcange@redhat.com) wrote:
> > 
> > > The next suspect is the massive THP refcounting change that went
> > > upstream recently:
> > 
> > > As further debug hint, can you try to disable THP and see if that
> > > makes the problem go away?
> > 
> > Yep, this seems to be the problem (cc'ing in Kirill).
> > 
> > 122afea9626ab3f717b250a8dd3d5ebf57cdb56c - works (just before Kirill disables THP)
> > 61f5d698cc97600e813ca5cf8e449b1ea1c11492 - breaks (when THP is reenabled)
> > 
> > It's pretty reliable; as you say disabling THP makes it work again
> > and putting it back to THP/madvise mode makes it break.  And you need
> > to test on a machine with some free ram to make sure THP has a chance
> > to have happened.
> > 
> > I'm not sure of all of the rework that happened in that series,
> > but my reading of it is that splitting of THP pages gets deferred;
> > so I wonder if when I do the madvise to turn THP off, if it's actually
> > still got THP pages and thus we end up with a whole THP mapped
> > when I'm expecting to be userfaulting those pages.
> 
> Good thing at least I didn't make UFFDIO_COPY THP aware yet so there's
> less variables (as no user was interested to handle userfaults at THP
> granularity yet, and from userland such an improvement would be
> completely invisible in terms of API, so if an user starts doing that
> we can just optimize the kernel for it, criu restore could do that as
> the faults will come from disk-I/O, when network is involved THP
> userfaults wouldn't have a great tradeoff with regard to the increased
> fault latency).
> 
> I suspect there is an handle_userfault missing somewhere in connection
> with trans_huge_pmd splits (not anymore THP splits) that you're doing
> with MADV_DONTNEED to zap those pages in the destination that got
> redirtied in source during the last precopy stage. Or more simply
> MADV_DONTNEED isn't zapping all the right ptes after the trans huge
> pmd got splitted.
> 
> The fact the page isn't splitted shouldn't matter too much, all we care
> about is the pte triggers handle_userfault after MADV_DONTNEED.
> 
> The userfaultfd testcase in the kernel isn't exercising this case
> unfortunately, that should probably be improved too, so there is a
> simpler way to reproduce than running precopy before postcopy in qemu.

I've tested current Linus' tree and v4.5 using qemu postcopy test case for
both x86-64 and i386 and it never failed for me:

/x86_64/postcopy: first_byte = 7e last_byte = 7d hit_edge = 1 OK
OK
/i386/postcopy: first_byte = f6 last_byte = f5 hit_edge = 1 OK
OK

I've run it directly, setting relevant QTEST_QEMU_BINARY.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
