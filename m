Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id AB2F46B0007
	for <linux-mm@kvack.org>; Wed, 20 Jun 2018 03:18:20 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id 39-v6so1358909ple.6
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 00:18:20 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v31-v6si1773650plg.339.2018.06.20.00.18.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 20 Jun 2018 00:18:19 -0700 (PDT)
Date: Wed, 20 Jun 2018 09:18:17 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC v2 PATCH 2/2] mm: mmap: zap pages with read mmap_sem for
 large mapping
Message-ID: <20180620071817.GJ13685@dhcp22.suse.cz>
References: <1529364856-49589-1-git-send-email-yang.shi@linux.alibaba.com>
 <1529364856-49589-3-git-send-email-yang.shi@linux.alibaba.com>
 <3DDF2672-FCC4-4387-9624-92F33C309CAE@gmail.com>
 <158a4e4c-d290-77c4-a595-71332ede392b@linux.alibaba.com>
 <BFD6A249-B1D7-43D5-8D7C-9FAED4A168A1@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <BFD6A249-B1D7-43D5-8D7C-9FAED4A168A1@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, Matthew Wilcox <willy@infradead.org>, ldufour@linux.vnet.ibm.com, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On Tue 19-06-18 17:31:27, Nadav Amit wrote:
> at 4:08 PM, Yang Shi <yang.shi@linux.alibaba.com> wrote:
> 
> > 
> > 
> > On 6/19/18 3:17 PM, Nadav Amit wrote:
> >> at 4:34 PM, Yang Shi <yang.shi@linux.alibaba.com>
> >>  wrote:
> >> 
> >> 
> >>> When running some mmap/munmap scalability tests with large memory (i.e.
> >>> 
> >>>> 300GB), the below hung task issue may happen occasionally.
> >>>> 
> >>> INFO: task ps:14018 blocked for more than 120 seconds.
> >>>       Tainted: G            E 4.9.79-009.ali3000.alios7.x86_64 #1
> >>> "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this
> >>> message.
> >>> ps              D    0 14018      1 0x00000004
> >>> 
> >>> 
> >> (snip)
> >> 
> >> 
> >>> Zapping pages is the most time consuming part, according to the
> >>> suggestion from Michal Hock [1], zapping pages can be done with holding
> >>> read mmap_sem, like what MADV_DONTNEED does. Then re-acquire write
> >>> mmap_sem to manipulate vmas.
> >>> 
> >> Does munmap() == MADV_DONTNEED + munmap() ?
> > 
> > Not exactly the same. So, I basically copied the page zapping used by munmap instead of calling MADV_DONTNEED.
> > 
> >> 
> >> For example, what happens with userfaultfd in this case? Can you get an
> >> extra #PF, which would be visible to userspace, before the munmap is
> >> finished?
> >> 
> > 
> > userfaultfd is handled by regular munmap path. So, no change to userfaultfd part.
> 
> Right. I see it now.
> 
> > 
> >> 
> >> In addition, would it be ok for the user to potentially get a zeroed page in
> >> the time window after the MADV_DONTNEED finished removing a PTE and before
> >> the munmap() is done?
> >> 
> > 
> > This should be undefined behavior according to Michal. This has been discussed in  https://lwn.net/Articles/753269/.
> 
> Thanks for the reference.
> 
> Reading the man page I see: "All pages containing a part of the indicated
> range are unmapped, and subsequent references to these pages will generate
> SIGSEGV.a??

Yes, this is true but I guess what Yang Shi meant was that an userspace
access racing with munmap is not well defined. You never know whether
you get your data, #PTF or SEGV because it depends on timing. The user
visible change might be that you lose content and get zero page instead
if you hit the race window while we are unmapping which was not possible
before. But whouldn't such an access pattern be buggy anyway? You need
some form of external synchronization AFAICS.

But maybe some userspace depends on "getting right data or get SEGV"
semantic. If we have to preserve that then we can come up with a VM_DEAD
flag set before we tear it down and force the SEGV on the #PF path.
Something similar we already do for MMF_UNSTABLE.
-- 
Michal Hocko
SUSE Labs
