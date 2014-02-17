Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 0C4686B0031
	for <linux-mm@kvack.org>; Mon, 17 Feb 2014 08:57:31 -0500 (EST)
Received: by mail-wg0-f54.google.com with SMTP id l18so2243802wgh.33
        for <linux-mm@kvack.org>; Mon, 17 Feb 2014 05:57:31 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id vg1si10771864wjc.43.2014.02.17.05.57.30
        for <linux-mm@kvack.org>;
        Mon, 17 Feb 2014 05:57:30 -0800 (PST)
Date: Mon, 17 Feb 2014 08:56:22 -0500
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: Re: [PATCH 4/4] hugetlb: add hugepages_node= command-line option
Message-ID: <20140217085622.39b39cac@redhat.com>
In-Reply-To: <alpine.DEB.2.02.1402150159540.28883@chino.kir.corp.google.com>
References: <1392339728-13487-1-git-send-email-lcapitulino@redhat.com>
	<1392339728-13487-5-git-send-email-lcapitulino@redhat.com>
	<alpine.DEB.2.02.1402141511200.13935@chino.kir.corp.google.com>
	<20140214225810.57e854cb@redhat.com>
	<alpine.DEB.2.02.1402150159540.28883@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, mtosatti@redhat.com, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, davidlohr@hp.com, isimatu.yasuaki@jp.fujitsu.com, yinghai@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, 15 Feb 2014 02:06:38 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Fri, 14 Feb 2014, Luiz Capitulino wrote:
> 
> > > Again, I think this syntax is horrendous and doesn't couple well with the 
> > > other hugepage-related kernel command line options.  We already have 
> > > hugepages= and hugepagesz= which you can interleave on the command line to 
> > > get 100 2M hugepages and 10 1GB hugepages, for example.
> > > 
> > > This patchset is simply introducing another variable to the matter: the 
> > > node that the hugepages should be allocated on.  So just introduce a 
> > > hugepagesnode= parameter to couple with the others so you can do
> > > 
> > > 	hugepagesz=<size> hugepagesnode=<nid> hugepages=<#>
> > 
> > That was my first try but it turned out really bad. First, for every node
> > you specify you need three options.
> 
> Just like you need two options today to specify a number of hugepages of a 
> particular non-default size.  You only need to use hugepagesz= or 
> hugepagenode= if you want a non-default size or a specify a particular 
> node.
> 
> > So, if you want to setup memory for
> > three nodes you'll need to specify nine options.
> 
> And you currently need six if you want to specify three different hugepage 
> sizes (?).  But who really specifies three different hugepage sizes on the 
> command line that are needed to be reserved at boot?

hugepages= and hugepages_node= are similar, but have different semantics.

hugepagesz= and hugepages= create a pool of huge pages of the specified size.
This means that the number of times you specify those options are limited by
the number of different huge pages sizes an arch supports. For x86_64 for
example, this limit is two so one would not specify those options more than
two times. And this doesn't count default_hugepagesz=, which allows you to
drop one hugepagesz= option.

hugepages_node= allows you to allocate huge pages per node, so the number of
times you can specify this option is limited by the number of nodes. Also,
hugepages_node= create the pools, if necessary (at least one will be). For
this reason I think it makes a lot of sense to have different options.

> If that's really the usecase, it seems like you want the old 
> CONFIG_PAGE_SHIFT patch.
> 
> > And it gets worse, because
> > hugepagesz= and hugepages= have strict ordering (which is a mistake, IMHO) so
> > you have to specify them in the right order otherwise things don't work as
> > expected and you have no idea why (have been there myself).
> > 
> 
> How is that difficult?  hugepages= is the "noun", hugepagesz= is the 
> "adjective".  hugepages=100 hugepagesz=1G hugepages=4 makes perfect sense 
> to me, and I actually don't allocate hugepages on the command line, nor 
> have I looked at Documentation/kernel-parameters.txt to check if I'm 
> constructing it correctly.  It just makes sense and once you learn it it's 
> just natural.
> 
> > IMO, hugepages_node=<nid>:<nr_pages>:<size>,... is good enough. It's concise,
> > and don't depend on any other option to function. Also, there are lots of other
> > kernel command-line options that require you to specify multiple fields, so
> > it's not like hugepages_node= is totally different in that regard.
> > 
> 
> I doubt Andrew is going to want a completely different format for hugepage 
> allocations that want to specify a node and have to deal with people who 
> say hugepages_node=2:1:1G and constantly have to lookup if it's 2 
> hugepages on node 1 or 1 hugepage on node 2.

Andrew?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
