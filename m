Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 378166B0253
	for <linux-mm@kvack.org>; Wed, 29 Jul 2015 15:08:09 -0400 (EDT)
Received: by pacan13 with SMTP id an13so10255289pac.1
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 12:08:09 -0700 (PDT)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id cl3si11299121pad.39.2015.07.29.12.08.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Jul 2015 12:08:08 -0700 (PDT)
Received: by pachj5 with SMTP id hj5so10001094pac.3
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 12:08:07 -0700 (PDT)
Date: Wed, 29 Jul 2015 12:08:05 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: hugetlb pages not accounted for in rss
In-Reply-To: <20150729005332.GB17938@Sligo.logfs.org>
Message-ID: <alpine.DEB.2.10.1507291205590.24373@chino.kir.corp.google.com>
References: <55B6BE37.3010804@oracle.com> <20150728183248.GB1406@Sligo.logfs.org> <55B7F0F8.8080909@oracle.com> <alpine.DEB.2.10.1507281509420.23577@chino.kir.corp.google.com> <20150728222654.GA28456@Sligo.logfs.org> <alpine.DEB.2.10.1507281622470.10368@chino.kir.corp.google.com>
 <20150729005332.GB17938@Sligo.logfs.org>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="397176738-1464267060-1438196886=:24373"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?J=C3=B6rn_Engel?= <joern@purestorage.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--397176738-1464267060-1438196886=:24373
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Tue, 28 Jul 2015, Jorn Engel wrote:

> Well, we definitely need something.  Having a 100GB process show 3GB of
> rss is not very useful.  How would we notice a memory leak if it only
> affects hugepages, for example?
> 

Since the hugetlb pool is a global resource, it would also be helpful to  
determine if a process is mapping more than expected.  You can't do that  
just by adding a huge rss metric, however: if you have 2MB and 1GB
hugepages configured you wouldn't know if a process was mapping 512 2MB   
hugepages or 1 1GB hugepage.
  
That's the purpose of hugetlb_cgroup, after all, and it supports usage 
counters for all hstates.  The test could be converted to use that to 
measure usage if configured in the kernel.

Beyond that, I'm not sure how a per-hstate rss metric would be exported to 
userspace in a clean way and other ways of obtaining the same data are 
possible with hugetlb_cgroup.  I'm not sure how successful you'd be in 
arguing that we need separate rss counters for it.
--397176738-1464267060-1438196886=:24373--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
