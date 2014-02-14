Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 8E75F6B0031
	for <linux-mm@kvack.org>; Fri, 14 Feb 2014 18:14:27 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id v10so12599307pde.0
        for <linux-mm@kvack.org>; Fri, 14 Feb 2014 15:14:27 -0800 (PST)
Received: from mail-pd0-x229.google.com (mail-pd0-x229.google.com [2607:f8b0:400e:c02::229])
        by mx.google.com with ESMTPS id l8si7293486paa.228.2014.02.14.15.14.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 14 Feb 2014 15:14:25 -0800 (PST)
Received: by mail-pd0-f169.google.com with SMTP id v10so12520193pde.14
        for <linux-mm@kvack.org>; Fri, 14 Feb 2014 15:14:24 -0800 (PST)
Date: Fri, 14 Feb 2014 15:14:22 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 4/4] hugetlb: add hugepages_node= command-line option
In-Reply-To: <1392339728-13487-5-git-send-email-lcapitulino@redhat.com>
Message-ID: <alpine.DEB.2.02.1402141511200.13935@chino.kir.corp.google.com>
References: <1392339728-13487-1-git-send-email-lcapitulino@redhat.com> <1392339728-13487-5-git-send-email-lcapitulino@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luiz Capitulino <lcapitulino@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mtosatti@redhat.com, mgorman@suse.de, aarcange@redhat.com, andi@firstfloor.org, riel@redhat.com, davidlohr@hp.com, isimatu.yasuaki@jp.fujitsu.com, yinghai@kernel.org

On Thu, 13 Feb 2014, Luiz Capitulino wrote:

> From: Luiz capitulino <lcapitulino@redhat.com>
> 
> The HugeTLB command-line option hugepages= allows a user to specify how
> many huge pages should be allocated at boot. This option is needed because
> it improves reliability when allocating 1G huge pages, which are better
> allocated as early as possible due to fragmentation.
> 
> However, hugepages= has a limitation. On NUMA systems, hugepages= will
> automatically distribute memory allocation equally among nodes. For
> example, if you have a 2-node NUMA system and allocate 200 huge pages,
> than hugepages= will try to allocate 100 huge pages from node0 and 100
> from node1.
> 
> This is very unflexible, as it doesn't allow you to specify which nodes
> the huge pages should be allocated from. For example, there are use-cases
> where the user wants to specify that a 1GB huge page should be allocated
> from node 2 or that 300 2MB huge pages should be allocated from node 0.
> 
> The hugepages_node= command-line option introduced by this commit allows
> just that.
> 
> The syntax is:
> 
>   hugepages_node=nid:nr_pages:size,...
> 

Again, I think this syntax is horrendous and doesn't couple well with the 
other hugepage-related kernel command line options.  We already have 
hugepages= and hugepagesz= which you can interleave on the command line to 
get 100 2M hugepages and 10 1GB hugepages, for example.

This patchset is simply introducing another variable to the matter: the 
node that the hugepages should be allocated on.  So just introduce a 
hugepagesnode= parameter to couple with the others so you can do

	hugepagesz=<size> hugepagesnode=<nid> hugepages=<#>

instead of having completely confusing interfaces where you want to do 
hugepages_node=1:1:1G for a 1GB hugepage on page 1 (and try remembering 
which "1" means what, yuck) and "hugepagesz=1GB hugepages=1" if you're 
indifferent to the node.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
