Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id EC0BA6B0253
	for <linux-mm@kvack.org>; Thu, 30 Jul 2015 17:34:18 -0400 (EDT)
Received: by pachj5 with SMTP id hj5so29220914pac.3
        for <linux-mm@kvack.org>; Thu, 30 Jul 2015 14:34:18 -0700 (PDT)
Received: from mail-pd0-x235.google.com (mail-pd0-x235.google.com. [2607:f8b0:400e:c02::235])
        by mx.google.com with ESMTPS id bi6si5027350pdb.129.2015.07.30.14.34.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Jul 2015 14:34:17 -0700 (PDT)
Received: by pdrg1 with SMTP id g1so30569531pdr.2
        for <linux-mm@kvack.org>; Thu, 30 Jul 2015 14:34:17 -0700 (PDT)
Date: Thu, 30 Jul 2015 14:34:12 -0700
From: =?iso-8859-1?Q?J=F6rn?= Engel <joern@purestorage.com>
Subject: Re: hugetlb pages not accounted for in rss
Message-ID: <20150730213412.GF17882@Sligo.logfs.org>
References: <55B6BE37.3010804@oracle.com>
 <20150728183248.GB1406@Sligo.logfs.org>
 <55B7F0F8.8080909@oracle.com>
 <alpine.DEB.2.10.1507281509420.23577@chino.kir.corp.google.com>
 <20150728222654.GA28456@Sligo.logfs.org>
 <alpine.DEB.2.10.1507281622470.10368@chino.kir.corp.google.com>
 <20150729005332.GB17938@Sligo.logfs.org>
 <alpine.DEB.2.10.1507291205590.24373@chino.kir.corp.google.com>
 <55B95FDB.1000801@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <55B95FDB.1000801@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: David Rientjes <rientjes@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Wed, Jul 29, 2015 at 04:20:59PM -0700, Mike Kravetz wrote:
> >
> >Since the hugetlb pool is a global resource, it would also be helpful to
> >determine if a process is mapping more than expected.  You can't do that
> >just by adding a huge rss metric, however: if you have 2MB and 1GB
> >hugepages configured you wouldn't know if a process was mapping 512 2MB
> >hugepages or 1 1GB hugepage.

Fair, although I believe 1GB hugepages are overrated.  If you assume
that per-page overhead is independent of page size (not quite true, but
close enough), going from 1% small pages to 0.8% small pages will
improve performance as much as going from 99% 2MB pages to 99% 1GB
pages.

> >That's the purpose of hugetlb_cgroup, after all, and it supports usage
> >counters for all hstates.  The test could be converted to use that to
> >measure usage if configured in the kernel.
> >
> >Beyond that, I'm not sure how a per-hstate rss metric would be exported to
> >userspace in a clean way and other ways of obtaining the same data are
> >possible with hugetlb_cgroup.  I'm not sure how successful you'd be in
> >arguing that we need separate rss counters for it.
> 
> If I want to track hugetlb usage on a per-task basis, do I then need to
> create one cgroup per task?
> 
> For example, suppose I have many tasks using hugetlb and the global pool
> is getting low on free pages.  It might be useful to know which tasks are
> using hugetlb pages, and how many they are using.
> 
> I don't actually have this need (I think), but it appears to be what
> Jorn is asking for.

Maybe some background is useful.  I would absolutely love to use
transparent hugepages.  They are absolutely perfect in every respect,
except for performance.  With transparent hugepages we get higher
latencies.  Small pages are unacceptable, so we are forced to use
non-transparent hugepages.

The part of our system that uses small pages is pretty much constant,
while total system memory follows Moore's law.  When possible we even
try to shrink that part.  Hugepages already dominate today and things
will get worse.

But otherwise we have all the problems that others also have.  There are
memory leaks and we would like to know how much memory each process
actually uses.  Most people use rss, while we have nothing good.  And I
am not sure if cgroup is the correct answer for essentially fixing a
regression introduced in 2002.

Jorn

--
You cannot suppose that Moliere ever troubled himself to be original in the
matter of ideas. You cannot suppose that the stories he tells in his plays
have never been told before. They were culled, as you very well know.
-- Andre-Louis Moreau in Scarabouche

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
