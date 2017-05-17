Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7F67B6B02EE
	for <linux-mm@kvack.org>; Wed, 17 May 2017 10:05:05 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id g12so2697933wrg.15
        for <linux-mm@kvack.org>; Wed, 17 May 2017 07:05:05 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y15si2727678edb.30.2017.05.17.07.05.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 17 May 2017 07:05:04 -0700 (PDT)
Date: Wed, 17 May 2017 16:05:01 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 1/6] mm, page_alloc: fix more premature OOM due to race
 with cpuset update
Message-ID: <20170517140501.GM18247@dhcp22.suse.cz>
References: <20170411140609.3787-2-vbabka@suse.cz>
 <alpine.DEB.2.20.1704111152170.25069@east.gentwo.org>
 <a86ae57a-3efc-6ae5-ddf0-fd64c53c20fa@suse.cz>
 <alpine.DEB.2.20.1704121617040.28335@east.gentwo.org>
 <cf9628e9-20ed-68b0-6cbd-48af5133138c@suse.cz>
 <alpine.DEB.2.20.1704141526260.17435@east.gentwo.org>
 <fda99ddc-94f5-456e-6560-d4991da452a6@suse.cz>
 <alpine.DEB.2.20.1704301628460.21533@east.gentwo.org>
 <20170517092042.GH18247@dhcp22.suse.cz>
 <alpine.DEB.2.20.1705170855430.7925@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1705170855430.7925@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-api@vger.kernel.org

On Wed 17-05-17 08:56:34, Cristopher Lameter wrote:
> On Wed, 17 May 2017, Michal Hocko wrote:
> 
> > > We certainly can do that. The failure of the page faults are due to the
> > > admin trying to move an application that is not aware of this and is using
> > > mempols. That could be an error. Trying to move an application that
> > > contains both absolute and relative node numbers is definitely something
> > > that is potentiall so screwed up that the kernel should not muck around
> > > with such an app.
> > >
> > > Also user space can determine if the application is using memory policies
> > > and can then take appropriate measures (message to the sysadmin to eval
> > > tge situation f.e.) or mess aroud with the processes memory policies on
> > > its own.
> > >
> > > So this is certainly a way out of this mess.
> >
> > So how are you going to distinguish VM_FAULT_OOM from an empty mempolicy
> > case in a raceless way?
> 
> You dont have to do that if you do not create an empty mempolicy in the
> first place. The current kernel code avoids that by first allowing access
> to the new set of nodes and removing the old ones from the set when done.

which is racy and as Vlastimil pointed out. If we simply fail such an
allocation the failure will go up the call chain until we hit the OOM
killer due to VM_FAULT_OOM. How would you want to handle that?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
