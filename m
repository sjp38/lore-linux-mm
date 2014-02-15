Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f173.google.com (mail-ea0-f173.google.com [209.85.215.173])
	by kanga.kvack.org (Postfix) with ESMTP id 5E6926B0031
	for <linux-mm@kvack.org>; Fri, 14 Feb 2014 23:02:30 -0500 (EST)
Received: by mail-ea0-f173.google.com with SMTP id d10so6131886eaj.32
        for <linux-mm@kvack.org>; Fri, 14 Feb 2014 20:02:29 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id b7si15503362eez.134.2014.02.14.20.02.28
        for <linux-mm@kvack.org>;
        Fri, 14 Feb 2014 20:02:28 -0800 (PST)
Date: Fri, 14 Feb 2014 22:58:10 -0500
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: Re: [PATCH 4/4] hugetlb: add hugepages_node= command-line option
Message-ID: <20140214225810.57e854cb@redhat.com>
In-Reply-To: <alpine.DEB.2.02.1402141511200.13935@chino.kir.corp.google.com>
References: <1392339728-13487-1-git-send-email-lcapitulino@redhat.com>
	<1392339728-13487-5-git-send-email-lcapitulino@redhat.com>
	<alpine.DEB.2.02.1402141511200.13935@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mtosatti@redhat.com, mgorman@suse.de, aarcange@redhat.com, andi@firstfloor.org, riel@redhat.com, davidlohr@hp.com, isimatu.yasuaki@jp.fujitsu.com, yinghai@kernel.org

On Fri, 14 Feb 2014 15:14:22 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Thu, 13 Feb 2014, Luiz Capitulino wrote:
> 
> > From: Luiz capitulino <lcapitulino@redhat.com>
> > 
> > The HugeTLB command-line option hugepages= allows a user to specify how
> > many huge pages should be allocated at boot. This option is needed because
> > it improves reliability when allocating 1G huge pages, which are better
> > allocated as early as possible due to fragmentation.
> > 
> > However, hugepages= has a limitation. On NUMA systems, hugepages= will
> > automatically distribute memory allocation equally among nodes. For
> > example, if you have a 2-node NUMA system and allocate 200 huge pages,
> > than hugepages= will try to allocate 100 huge pages from node0 and 100
> > from node1.
> > 
> > This is very unflexible, as it doesn't allow you to specify which nodes
> > the huge pages should be allocated from. For example, there are use-cases
> > where the user wants to specify that a 1GB huge page should be allocated
> > from node 2 or that 300 2MB huge pages should be allocated from node 0.
> > 
> > The hugepages_node= command-line option introduced by this commit allows
> > just that.
> > 
> > The syntax is:
> > 
> >   hugepages_node=nid:nr_pages:size,...
> > 
> 
> Again, I think this syntax is horrendous and doesn't couple well with the 
> other hugepage-related kernel command line options.  We already have 
> hugepages= and hugepagesz= which you can interleave on the command line to 
> get 100 2M hugepages and 10 1GB hugepages, for example.
> 
> This patchset is simply introducing another variable to the matter: the 
> node that the hugepages should be allocated on.  So just introduce a 
> hugepagesnode= parameter to couple with the others so you can do
> 
> 	hugepagesz=<size> hugepagesnode=<nid> hugepages=<#>

That was my first try but it turned out really bad. First, for every node
you specify you need three options. So, if you want to setup memory for
three nodes you'll need to specify nine options. And it gets worse, because
hugepagesz= and hugepages= have strict ordering (which is a mistake, IMHO) so
you have to specify them in the right order otherwise things don't work as
expected and you have no idea why (have been there myself).

IMO, hugepages_node=<nid>:<nr_pages>:<size>,... is good enough. It's concise,
and don't depend on any other option to function. Also, there are lots of other
kernel command-line options that require you to specify multiple fields, so
it's not like hugepages_node= is totally different in that regard.

> 
> instead of having completely confusing interfaces where you want to do 
> hugepages_node=1:1:1G for a 1GB hugepage on page 1 (and try remembering 
> which "1" means what, yuck) and "hugepagesz=1GB hugepages=1" if you're 
> indifferent to the node.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
