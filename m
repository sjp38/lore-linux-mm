Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 82EC46B0253
	for <linux-mm@kvack.org>; Tue, 28 Jul 2015 18:15:20 -0400 (EDT)
Received: by pabkd10 with SMTP id kd10so76331471pab.2
        for <linux-mm@kvack.org>; Tue, 28 Jul 2015 15:15:20 -0700 (PDT)
Received: from mail-pd0-x22d.google.com (mail-pd0-x22d.google.com. [2607:f8b0:400e:c02::22d])
        by mx.google.com with ESMTPS id bz5si4072069pdb.210.2015.07.28.15.15.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Jul 2015 15:15:19 -0700 (PDT)
Received: by pdbbh15 with SMTP id bh15so77467163pdb.1
        for <linux-mm@kvack.org>; Tue, 28 Jul 2015 15:15:18 -0700 (PDT)
Date: Tue, 28 Jul 2015 15:15:17 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: hugetlb pages not accounted for in rss
In-Reply-To: <55B7F0F8.8080909@oracle.com>
Message-ID: <alpine.DEB.2.10.1507281509420.23577@chino.kir.corp.google.com>
References: <55B6BE37.3010804@oracle.com> <20150728183248.GB1406@Sligo.logfs.org> <55B7F0F8.8080909@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: =?UTF-8?Q?J=C3=B6rn_Engel?= <joern@purestorage.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Tue, 28 Jul 2015, Mike Kravetz wrote:

> > > The easiest way to resolve this issue would be to remove the test and
> > > perhaps document that hugetlb pages are not accounted for in rss.
> > > However, it does seem like a big oversight that hugetlb pages are not
> > > accounted for in rss.  From a quick scan of the code it appears THP
> > > pages are properly accounted for.
> > > 
> > > Thoughts?
> > 
> > Unsurprisingly I agree that hugepages should count towards rss.  Keeping
> > the test in keeps us honest.  Actually fixing the issue would make us
> > honest and correct.
> > 
> > Increasingly we have tiny processes (by rss) that actually consume large
> > fractions of total memory.  Makes rss somewhat useless as a measure of
> > anything.
> 
> I'll take a look at what it would take to get the accounting in place.

I'm not sure that I would agree that accounting hugetlb pages in rss would 
always be appropriate.

For reserved hugetlb pages, not surplus, the hugetlb pages are always 
resident even when unmapped.  Unmapping the memory is not going to cause 
them to be freed.  That's different from thp where the hugepages are 
actually freed when you do munmap().

The oom killer looks at rss as the metric to determine which process to 
kill that will result in a large amount of memory freeing.  If hugetlb 
pages are accounted in rss, this may lead to unnecessary killing since 
little memory may be freed as a result.

For that reason, we've added hugetlb statistics to the oom killer output 
since we've been left wondering in the past where all the memory on the 
system went :)

We also have a separate hugetlb cgroup that tracks hugetlb memory usage 
rather than memcg.

Starting to account hugetlb pages in rss may lead to breakage in userspace 
and I would agree with your earlier suggestion that just removing any test 
for rss would be appropriate.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
