Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id 36F5A8296F
	for <linux-mm@kvack.org>; Fri, 11 Apr 2014 18:53:54 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id rr13so6019891pbb.11
        for <linux-mm@kvack.org>; Fri, 11 Apr 2014 15:53:52 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id ua2si5010087pab.364.2014.04.11.15.53.51
        for <linux-mm@kvack.org>;
        Fri, 11 Apr 2014 15:53:52 -0700 (PDT)
Message-ID: <5348727E.3040308@intel.com>
Date: Fri, 11 Apr 2014 15:53:50 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] drivers/base/node.c: export physical address range of
 given node (Re: NUMA node information for pages)
References: <87eh1ix7g0.fsf@x240.local.i-did-not-set--mail-host-address--so-tickle-me> <533a1563.ad318c0a.6a93.182bSMTPIN_ADDED_BROKEN@mx.google.com> <CAOPLpQc8R2SfTB+=BsMa09tcQ-iBNJHg+tGnPK-9EDH1M47MJw@mail.gmail.com> <5343806c.100cc30a.0461.ffffc401SMTPIN_ADDED_BROKEN@mx.google.com> <alpine.DEB.2.02.1404091734060.1857@chino.kir.corp.google.com> <5345fe27.82dab40a.0831.0af9SMTPIN_ADDED_BROKEN@mx.google.com> <alpine.DEB.2.02.1404101500280.11995@chino.kir.corp.google.com> <53474709.e59ec20a.3bd5.3b91SMTPIN_ADDED_BROKEN@mx.google.com> <alpine.DEB.2.02.1404110325210.30610@chino.kir.corp.google.com> <53481724.8020304@intel.com> <alpine.DEB.2.02.1404111513040.17724@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1404111513040.17724@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, drepper@gmail.com, anatol.pomozov@gmail.com, jkosina@suse.cz, akpm@linux-foundation.org, xemul@parallels.com, paul.gortmaker@windriver.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 04/11/2014 03:13 PM, David Rientjes wrote:
> What additional information, in your opinion, can we export to assist 
> userspace in making this determination that $address is on $nid?

In the case of overlapping nodes, the only place we actually have *all*
of the information is in the 'struct page' itself.  Ulrich's original
patch obviously _works_, and especially if it's an interface only for
debugging purposes, it seems silly to spend virtually any time
optimizing it.  Keeping it close to pagemap's implementation lessens the
likelihood that we'll screw things up.

I assume that the original problem was trying to figure out what NUMA
affinity a given range of pages mapped in to a _process_ have, and that
/proc/$pid/numamaps is too coarse.  Is that right, Ulrich?

If you want to go the route of calculating and exporting the physical
ranges that nodes uniquely own, you've *GOT* to handle the overlaps.
Naoya had the right idea.  His idea seemed to get shot down with the
misunderstanding that node pfn ranges never overlap.

The only other question is how many of these kpage* things we're going
to put in here until we've exported the entire contents of 'struct page'
5 times over. :)

We could add some tracepoints to the pagemap to dump lots of information
in to a trace buffer that could be later read back.  If you want
detailed information  (NUMA for instance), you turn the tracepoints and
read pagemap for the range you care about.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
