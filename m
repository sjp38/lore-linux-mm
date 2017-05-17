Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 865B26B02C4
	for <linux-mm@kvack.org>; Wed, 17 May 2017 05:20:50 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 204so791042wmy.1
        for <linux-mm@kvack.org>; Wed, 17 May 2017 02:20:50 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q4si1449542wrc.151.2017.05.17.02.20.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 17 May 2017 02:20:49 -0700 (PDT)
Date: Wed, 17 May 2017 11:20:43 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 1/6] mm, page_alloc: fix more premature OOM due to race
 with cpuset update
Message-ID: <20170517092042.GH18247@dhcp22.suse.cz>
References: <20170411140609.3787-1-vbabka@suse.cz>
 <20170411140609.3787-2-vbabka@suse.cz>
 <alpine.DEB.2.20.1704111152170.25069@east.gentwo.org>
 <a86ae57a-3efc-6ae5-ddf0-fd64c53c20fa@suse.cz>
 <alpine.DEB.2.20.1704121617040.28335@east.gentwo.org>
 <cf9628e9-20ed-68b0-6cbd-48af5133138c@suse.cz>
 <alpine.DEB.2.20.1704141526260.17435@east.gentwo.org>
 <fda99ddc-94f5-456e-6560-d4991da452a6@suse.cz>
 <alpine.DEB.2.20.1704301628460.21533@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1704301628460.21533@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-api@vger.kernel.org

On Sun 30-04-17 16:33:10, Cristopher Lameter wrote:
> On Wed, 26 Apr 2017, Vlastimil Babka wrote:
> 
> > > Such an application typically already has such logic and executes a
> > > binding after discovering its numa node configuration on startup. It would
> > > have to be modified to redo that action when it gets some sort of a signal
> > > from the script telling it that the node config would be changed.
> > >
> > > Having this logic in the application instead of the kernel avoids all the
> > > kernel messes that we keep on trying to deal with and IMHO is much
> > > cleaner.
> >
> > That would be much simpler for us indeed. But we still IMHO can't
> > abruptly start denying page fault allocations for existing applications
> > that don't have the necessary awareness.
> 
> We certainly can do that. The failure of the page faults are due to the
> admin trying to move an application that is not aware of this and is using
> mempols. That could be an error. Trying to move an application that
> contains both absolute and relative node numbers is definitely something
> that is potentiall so screwed up that the kernel should not muck around
> with such an app.
> 
> Also user space can determine if the application is using memory policies
> and can then take appropriate measures (message to the sysadmin to eval
> tge situation f.e.) or mess aroud with the processes memory policies on
> its own.
> 
> So this is certainly a way out of this mess.

So how are you going to distinguish VM_FAULT_OOM from an empty mempolicy
case in a raceless way?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
