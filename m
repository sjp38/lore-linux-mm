Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 57E72831F4
	for <linux-mm@kvack.org>; Thu, 18 May 2017 13:24:34 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id y22so10624797wry.1
        for <linux-mm@kvack.org>; Thu, 18 May 2017 10:24:34 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k27si5702153edb.51.2017.05.18.10.24.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 18 May 2017 10:24:33 -0700 (PDT)
Date: Thu, 18 May 2017 19:24:24 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 1/6] mm, page_alloc: fix more premature OOM due to race
 with cpuset update
Message-ID: <20170518172424.GB30148@dhcp22.suse.cz>
References: <fda99ddc-94f5-456e-6560-d4991da452a6@suse.cz>
 <alpine.DEB.2.20.1704301628460.21533@east.gentwo.org>
 <20170517092042.GH18247@dhcp22.suse.cz>
 <alpine.DEB.2.20.1705170855430.7925@east.gentwo.org>
 <20170517140501.GM18247@dhcp22.suse.cz>
 <alpine.DEB.2.20.1705170943090.8714@east.gentwo.org>
 <20170517145645.GO18247@dhcp22.suse.cz>
 <alpine.DEB.2.20.1705171021570.9487@east.gentwo.org>
 <20170518090846.GD25462@dhcp22.suse.cz>
 <alpine.DEB.2.20.1705181154450.27641@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1705181154450.27641@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-api@vger.kernel.org

On Thu 18-05-17 11:57:55, Cristopher Lameter wrote:
> On Thu, 18 May 2017, Michal Hocko wrote:
> 
> > > Nope. The OOM in a cpuset gets the process doing the alloc killed. Or what
> > > that changed?
> 
> !!!!!
> 
> > >
> > > At this point you have messed up royally and nothing is going to rescue
> > > you anyways. OOM or not does not matter anymore. The app will fail.
> >
> > Not really. If you can trick the system to _think_ that the intersection
> > between mempolicy and the cpuset is empty then the OOM killer might
> > trigger an innocent task rather than the one which tricked it into that
> > situation.
> 
> See above. OOM Kill in a cpuset does not kill an innocent task but a task
> that does an allocation in that specific context meaning a task in that
> cpuset that also has a memory policty.

No, the oom killer will chose the largest task in the specific NUMA
domain. If you just fail such an allocation then a page fault would get
VM_FAULT_OOM and pagefault_out_of_memory would kill a task regardless of
the cpusets.
 
> Regardless of that the point earlier was that the moving logic can avoid
> creating temporary situations of empty sets of nodes by analysing the
> memory policies etc and only performing moves when doing so is safe.

How are you going to do that in a raceless way? Moreover the whole
discussion is about _failing_ allocations on an empty cpuset and
mempolicy intersection.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
