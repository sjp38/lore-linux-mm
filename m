Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f174.google.com (mail-io0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 29A636B0253
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 17:09:10 -0400 (EDT)
Received: by ioeg141 with SMTP id g141so97671600ioe.3
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 14:09:10 -0700 (PDT)
Received: from mail-pd0-x232.google.com (mail-pd0-x232.google.com. [2607:f8b0:400e:c02::232])
        by mx.google.com with ESMTPS id b3si12900420pat.66.2015.07.31.14.09.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Jul 2015 14:09:09 -0700 (PDT)
Received: by pdjr16 with SMTP id r16so49521939pdj.3
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 14:09:09 -0700 (PDT)
Date: Fri, 31 Jul 2015 14:09:07 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: hugetlb pages not accounted for in rss
In-Reply-To: <20150730213412.GF17882@Sligo.logfs.org>
Message-ID: <alpine.DEB.2.10.1507311358541.5910@chino.kir.corp.google.com>
References: <55B6BE37.3010804@oracle.com> <20150728183248.GB1406@Sligo.logfs.org> <55B7F0F8.8080909@oracle.com> <alpine.DEB.2.10.1507281509420.23577@chino.kir.corp.google.com> <20150728222654.GA28456@Sligo.logfs.org> <alpine.DEB.2.10.1507281622470.10368@chino.kir.corp.google.com>
 <20150729005332.GB17938@Sligo.logfs.org> <alpine.DEB.2.10.1507291205590.24373@chino.kir.corp.google.com> <55B95FDB.1000801@oracle.com> <20150730213412.GF17882@Sligo.logfs.org>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="397176738-1092654570-1438376948=:5910"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?J=C3=B6rn_Engel?= <joern@purestorage.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--397176738-1092654570-1438376948=:5910
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Thu, 30 Jul 2015, Jorn Engel wrote:

> > If I want to track hugetlb usage on a per-task basis, do I then need to
> > create one cgroup per task?
> > 

I think this would only be used for debugging or testing, but if you have 
root and are trying to organize processes into a hugetlb_cgroup hierarchy, 
presumably you would just look at smaps and find each thread's hugetlb 
memory usage and not bother.

> Maybe some background is useful.  I would absolutely love to use
> transparent hugepages.  They are absolutely perfect in every respect,
> except for performance.  With transparent hugepages we get higher
> latencies.  Small pages are unacceptable, so we are forced to use
> non-transparent hugepages.
> 

Believe me, we are on the same page that way :)  We still deploy 
configurations with hugetlb memory because we need to meet certain 
allocation requirements and it is only possible to do at boot.

With regard to the performance of thp, I can think of two things that are 
affecting you:

 - allocation cost

   Async memory compaction in the page fault path for thp memory is very
   lightweight and it happily falls back to using small pages instead.
   Memory compaction is always being improved upon and there is on-going
   work to do memory compaction both periodically and in the background to
   keep fragmentation low.  The ultimate goal would be to remove async
   compaction entirely from the thp page fault path and rely on 
   improvements to memory compaction such that we have a great allocation
   success rate and less cost when we fail.

 - NUMA cost

   Until very recently, thp pages could easily be allocated remotely
   instead of small pages locally.  That has since been improved and we
   only allocate thp locally and then fallback to small pages locally
   first.  Khugepaged can still migrate memory remotely, but it will
   allocate the hugepage on the node where the majority of smallpages
   are from.

> The part of our system that uses small pages is pretty much constant,
> while total system memory follows Moore's law.  When possible we even
> try to shrink that part.  Hugepages already dominate today and things
> will get worse.
> 

I wrote a patchset, hugepages overcommit, that allows unmapped hugetlb 
pages to be freed in oom conditions before calling the oom killer up to a 
certain threshold and then kickoff a background thread to try to 
reallocate them.  The idea is to keep the hugetlb pool as large as 
possible up to oom and then only reclaim what is needed and then try to 
reallocate them.  Not sure if it would help your particular usecase or 
not.
--397176738-1092654570-1438376948=:5910--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
