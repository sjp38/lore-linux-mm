Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j1FNp9KU014267
	for <linux-mm@kvack.org>; Tue, 15 Feb 2005 18:51:09 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j1FNp9fN182166
	for <linux-mm@kvack.org>; Tue, 15 Feb 2005 18:51:09 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.12.11) with ESMTP id j1FNp8Bu023253
	for <linux-mm@kvack.org>; Tue, 15 Feb 2005 18:51:08 -0500
Date: Tue, 15 Feb 2005 15:51:04 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [RFC 2.6.11-rc2-mm2 7/7] mm: manual page migration -- sys_page_migrate
Message-ID: <31650000.1108511464@flay>
In-Reply-To: <421283E6.9030707@sgi.com>
References: <20050212032535.18524.12046.26397@tomahawk.engr.sgi.com>	<20050212032620.18524.15178.29731@tomahawk.engr.sgi.com>	<1108242262.6154.39.camel@localhost>	<20050214135221.GA20511@lnx-holt.americas.sgi.com>	<1108407043.6154.49.camel@localhost>	<20050214220148.GA11832@lnx-holt.americas.sgi.com>	<20050215074906.01439d4e.pj@sgi.com>	<20050215162135.GA22646@lnx-holt.americas.sgi.com>	<20050215083529.2f80c294.pj@sgi.com>	<20050215185943.GA24401@lnx-holt.americas.sgi.com> <16914.28795.316835.291470@wombat.chubb.wattle.id.au> <421283E6.9030707@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@sgi.com>, Peter Chubb <peterc@gelato.unsw.edu.au>
Cc: raybry@austin.rr.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>> A possibly stupid suggestion: 
>> 
>> Can page migration be done lazily, instead of all at once?  Move the
>> process, mark its pages as candidates for migration, and when 
>> the page faults, decide whether to copy across or not...
>> 
>> That way you only copy the pages the process is using, and only copy
>> each page once.  It makes copy for replication easier in some future
>> incarnation, too, because the same basic infrastructure can be used.
>> 
> 
> I think that part of the motivation here (e. g. the batch scheduler on
> a  large NUMA machine) is to push pages off of the old nodes so that
> a new job running on the old nodes can allocate memory quickly and
> efficiently (i. e. without having to swap out the old job's pages).

If our VM code wasn't crap, we'd do that automatically. It seems somewhat
excessive to do that from a manual interface?

> True enough, we may move pages that are not currently being used.
> But. on our large NUMA systems, we want the nodes where a new job
> starts to be relatively clean so that local page allocations are
> indeed satisfied by local pages and that these requests do not
> spill off node.

Yes. The objective was to kick the LRU page off this node onto some other
node, or to disk ... at the moment, if one node is more heavily used, we
will always allocate off node for all new pages. that's crap.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
