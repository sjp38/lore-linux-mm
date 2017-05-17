Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 82EFC6B02EE
	for <linux-mm@kvack.org>; Wed, 17 May 2017 09:59:08 -0400 (EDT)
Received: by mail-ua0-f200.google.com with SMTP id 14so3397607uar.7
        for <linux-mm@kvack.org>; Wed, 17 May 2017 06:59:08 -0700 (PDT)
Received: from resqmta-ch2-08v.sys.comcast.net (resqmta-ch2-08v.sys.comcast.net. [2001:558:fe21:29:69:252:207:40])
        by mx.google.com with ESMTPS id k204si756993vke.71.2017.05.17.06.59.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 May 2017 06:59:07 -0700 (PDT)
Date: Wed, 17 May 2017 08:56:34 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC 1/6] mm, page_alloc: fix more premature OOM due to race
 with cpuset update
In-Reply-To: <20170517092042.GH18247@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.20.1705170855430.7925@east.gentwo.org>
References: <20170411140609.3787-1-vbabka@suse.cz> <20170411140609.3787-2-vbabka@suse.cz> <alpine.DEB.2.20.1704111152170.25069@east.gentwo.org> <a86ae57a-3efc-6ae5-ddf0-fd64c53c20fa@suse.cz> <alpine.DEB.2.20.1704121617040.28335@east.gentwo.org>
 <cf9628e9-20ed-68b0-6cbd-48af5133138c@suse.cz> <alpine.DEB.2.20.1704141526260.17435@east.gentwo.org> <fda99ddc-94f5-456e-6560-d4991da452a6@suse.cz> <alpine.DEB.2.20.1704301628460.21533@east.gentwo.org> <20170517092042.GH18247@dhcp22.suse.cz>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-api@vger.kernel.org

On Wed, 17 May 2017, Michal Hocko wrote:

> > We certainly can do that. The failure of the page faults are due to the
> > admin trying to move an application that is not aware of this and is using
> > mempols. That could be an error. Trying to move an application that
> > contains both absolute and relative node numbers is definitely something
> > that is potentiall so screwed up that the kernel should not muck around
> > with such an app.
> >
> > Also user space can determine if the application is using memory policies
> > and can then take appropriate measures (message to the sysadmin to eval
> > tge situation f.e.) or mess aroud with the processes memory policies on
> > its own.
> >
> > So this is certainly a way out of this mess.
>
> So how are you going to distinguish VM_FAULT_OOM from an empty mempolicy
> case in a raceless way?

You dont have to do that if you do not create an empty mempolicy in the
first place. The current kernel code avoids that by first allowing access
to the new set of nodes and removing the old ones from the set when done.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
