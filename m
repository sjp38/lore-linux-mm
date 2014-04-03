Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f173.google.com (mail-ie0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id BDF326B0031
	for <linux-mm@kvack.org>; Thu,  3 Apr 2014 12:41:40 -0400 (EDT)
Received: by mail-ie0-f173.google.com with SMTP id rl12so2108949iec.32
        for <linux-mm@kvack.org>; Thu, 03 Apr 2014 09:41:40 -0700 (PDT)
Received: from qmta02.emeryville.ca.mail.comcast.net (qmta02.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:24])
        by mx.google.com with ESMTP id mg5si6662481icc.174.2014.04.03.09.41.39
        for <linux-mm@kvack.org>;
        Thu, 03 Apr 2014 09:41:40 -0700 (PDT)
Date: Thu, 3 Apr 2014 11:41:37 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Bug in reclaim logic with exhausted nodes?
In-Reply-To: <20140401013346.GD5144@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.10.1404031139090.21739@nuc>
References: <20140311210614.GB946@linux.vnet.ibm.com> <20140313170127.GE22247@linux.vnet.ibm.com> <20140324230550.GB18778@linux.vnet.ibm.com> <alpine.DEB.2.10.1403251116490.16557@nuc> <20140325162303.GA29977@linux.vnet.ibm.com> <alpine.DEB.2.10.1403251152250.16870@nuc>
 <20140325181010.GB29977@linux.vnet.ibm.com> <alpine.DEB.2.10.1403251323030.26744@nuc> <20140327203354.GA16651@linux.vnet.ibm.com> <alpine.DEB.2.10.1403290038200.24286@nuc> <20140401013346.GD5144@linux.vnet.ibm.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, rientjes@google.com, linuxppc-dev@lists.ozlabs.org, anton@samba.org, mgorman@suse.de

On Mon, 31 Mar 2014, Nishanth Aravamudan wrote:

> Yep. The node exists, it's just fully exhausted at boot (due to the
> presence of 16GB pages reserved at boot-time).

Well if you want us to support that then I guess you need to propose
patches to address this issue.

> I'd appreciate a bit more guidance? I'm suggesting that in this case the
> node functionally has no memory. So the page allocator should not allow
> allocations from it -- except (I need to investigate this still)
> userspace accessing the 16GB pages on that node, but that, I believe,
> doesn't go through the page allocator at all, it's all from hugetlb
> interfaces. It seems to me there is a bug in SLUB that we are noting
> that we have a useless per-node structure for a given nid, but not
> actually preventing requests to that node or reclaim because of those
> allocations.

Well if you can address that without impacting the fastpath then we could
do this. Otherwise we would need a fake structure here to avoid adding
checks to the fastpath

> I think there is a logical bug (even if it only occurs in this
> particular corner case) where if reclaim progresses for a THISNODE
> allocation, we don't check *where* the reclaim is progressing, and thus
> may falsely be indicating that we have done some progress when in fact
> the allocation that is causing reclaim will not possibly make any more
> progress.

Ok maybe we could address this corner case. How would you do this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
