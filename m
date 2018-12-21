Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id C4D108E0001
	for <linux-mm@kvack.org>; Fri, 21 Dec 2018 17:18:48 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id o17so5544904pgi.14
        for <linux-mm@kvack.org>; Fri, 21 Dec 2018 14:18:48 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n87sor42377912pfh.64.2018.12.21.14.18.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Dec 2018 14:18:47 -0800 (PST)
Date: Fri, 21 Dec 2018 14:18:45 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [LKP] [mm] ac5b2c1891: vm-scalability.throughput -61.3%
 regression
In-Reply-To: <0700f5c3-66a8-338a-0ba0-2231cc3bb637@suse.cz>
Message-ID: <alpine.DEB.2.21.1812211416020.219499@chino.kir.corp.google.com>
References: <64a4aec6-3275-a716-8345-f021f6186d9b@suse.cz> <20181204104558.GV23260@techsingularity.net> <20181205204034.GB11899@redhat.com> <CAHk-=whi8Ju-cTDL4cYtwuLA7BYgGJYyy6HVMoknZaLHnRc83g@mail.gmail.com> <20181205233632.GE11899@redhat.com>
 <CAHk-=wguXjkbK8BUU998s7HD7AXJgBkuc9JmuNxiN7uGQyfSfQ@mail.gmail.com> <CAHk-=wjm9V843eg0uesMrxKnCCq7UfWn8VJ+z-cNztb_0fVW6A@mail.gmail.com> <alpine.DEB.2.21.1812061505010.162675@chino.kir.corp.google.com> <CAHk-=wjVuLjZ1Wr52W=hNqh=_8gbzuKA+YpsVb4NBHCJsE6cyA@mail.gmail.com>
 <alpine.DEB.2.21.1812091538310.215735@chino.kir.corp.google.com> <20181210044916.GC24097@redhat.com> <alpine.DEB.2.21.1812111609060.255489@chino.kir.corp.google.com> <0bbf4202-6187-28fb-37b7-da6885b89cce@suse.cz> <alpine.DEB.2.21.1812141244450.186427@chino.kir.corp.google.com>
 <0700f5c3-66a8-338a-0ba0-2231cc3bb637@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, mgorman@techsingularity.net, Michal Hocko <mhocko@kernel.org>, ying.huang@intel.com, s.priebe@profihost.ag, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, alex.williamson@redhat.com, lkp@01.org, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, zi.yan@cs.rutgers.edu, Linux-MM layout <linux-mm@kvack.org>

On Fri, 14 Dec 2018, Vlastimil Babka wrote:

> > It would be interesting to know if anybody has tried using the per-zone 
> > free_area's to determine migration targets and set a bit if it should be 
> > considered a migration source or a migration target.  If all pages for a 
> > pageblock are not on free_areas, they are fully used.
> 
> Repurposing/adding a new pageblock bit was in my mind to help multiple
> compactors not undo each other's work in the scheme where there's no
> free page scanner, but I didn't implement it yet.
> 

It looks like Mel has a series posted that still is implemented with 
linear scans through memory, so I'm happy to move the discussion there; I 
think the goal for compaction with regard to this thread is determining 
whether reclaim in the page allocator would actually be useful and 
targeted reclaim to make memory available for isolate_freepages() could be 
expensive.  I'd hope that we could move in a direction where compaction 
doesn't care where the pageblock is and does the minimal amount of work 
possible to make a high-order page available, not sure if that's possible 
with a linear scan.  I'll take a look at Mel's series though.
