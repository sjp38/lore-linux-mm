Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9AA626B02B4
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 02:58:51 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id h76so43424814pfh.15
        for <linux-mm@kvack.org>; Wed, 31 May 2017 23:58:51 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id z184si19560432pgb.151.2017.05.31.23.58.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 May 2017 23:58:50 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v516t68e012578
	for <linux-mm@kvack.org>; Thu, 1 Jun 2017 02:58:50 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2at43rfxfx-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 01 Jun 2017 02:58:50 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 1 Jun 2017 07:58:46 +0100
Date: Thu, 1 Jun 2017 09:58:39 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm: introduce MADV_CLR_HUGEPAGE
References: <20170524142735.GF3063@rapoport-lnx>
 <20170530074408.GA7969@dhcp22.suse.cz>
 <20170530101921.GA25738@rapoport-lnx>
 <20170530103930.GB7969@dhcp22.suse.cz>
 <20170530140456.GA8412@redhat.com>
 <20170530143941.GK7969@dhcp22.suse.cz>
 <20170530154326.GB8412@redhat.com>
 <20170531120822.GL27783@dhcp22.suse.cz>
 <8FA5E4C2-D289-4AF5-AA09-6C199E58F9A5@linux.vnet.ibm.com>
 <20170531141809.GB302@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170531141809.GB302@redhat.com>
Message-Id: <20170601065838.GB30495@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Wed, May 31, 2017 at 04:18:09PM +0200, Andrea Arcangeli wrote:
> On Wed, May 31, 2017 at 03:39:22PM +0300, Mike Rapoport wrote:
> > For the CRIU usecase, disabling THP for a while and re-enabling it
> > back will do the trick, provided VMAs flags are not affected, like
> > in the patch you've sent.  Moreover, we may even get away with
> 
> Are you going to check uname -r to know when the kABI changed in your
> favor (so CRIU cannot ever work with enterprise backports unless you
> expand the uname -r coverage), or how do you know the patch is
> applied?

CRIU does not rely on uname -r. We have code that checks what kernel
features we can actually use. For instance, we use UFFDIO_API to see if we
can do post-copy at all.
 
> Optimistically assuming people is going to run new CRIU code only on
> new kernels looks very risky, it would leads to silent random memory
> corruption, so I doubt you can get away without a uname -r check.
> 
> This is fairly simple change too, its main cons is that it adds a
> branch to the page fault fast path, the old behavior of the prctl and
> the new madvise were both zero cost.
> 
> Still if the prctl is preferred despite the added branch, to avoid
> uname -r clashes, to me it sounds better to add a new prctl ID and
> keep the old one too. The old one could be implemented the same way as
> the new one if you want to save a few bytes of .text. But the old one
> should probably do a printk_once to print a deprecation warning so the
> old ID with weaker (zero runtime cost) semantics can be removed later.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
