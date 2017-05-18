Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id A0EB2831F4
	for <linux-mm@kvack.org>; Thu, 18 May 2017 13:07:27 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id a10so30951873itg.3
        for <linux-mm@kvack.org>; Thu, 18 May 2017 10:07:27 -0700 (PDT)
Received: from resqmta-ch2-11v.sys.comcast.net (resqmta-ch2-11v.sys.comcast.net. [2001:558:fe21:29:69:252:207:43])
        by mx.google.com with ESMTPS id j3si20162955itb.45.2017.05.18.10.07.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 May 2017 10:07:26 -0700 (PDT)
Date: Thu, 18 May 2017 12:07:25 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC 1/6] mm, page_alloc: fix more premature OOM due to race
 with cpuset update
In-Reply-To: <8889d67a-adab-91e1-c320-d8bd88d7e1e0@suse.cz>
Message-ID: <alpine.DEB.2.20.1705181158250.27641@east.gentwo.org>
References: <20170411140609.3787-2-vbabka@suse.cz> <alpine.DEB.2.20.1704111152170.25069@east.gentwo.org> <a86ae57a-3efc-6ae5-ddf0-fd64c53c20fa@suse.cz> <alpine.DEB.2.20.1704121617040.28335@east.gentwo.org> <cf9628e9-20ed-68b0-6cbd-48af5133138c@suse.cz>
 <alpine.DEB.2.20.1704141526260.17435@east.gentwo.org> <fda99ddc-94f5-456e-6560-d4991da452a6@suse.cz> <alpine.DEB.2.20.1704301628460.21533@east.gentwo.org> <20170517092042.GH18247@dhcp22.suse.cz> <alpine.DEB.2.20.1705170855430.7925@east.gentwo.org>
 <20170517140501.GM18247@dhcp22.suse.cz> <alpine.DEB.2.20.1705170943090.8714@east.gentwo.org> <8889d67a-adab-91e1-c320-d8bd88d7e1e0@suse.cz>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-api@vger.kernel.org

On Thu, 18 May 2017, Vlastimil Babka wrote:

> > The race is where? If you expand the node set during the move of the
> > application then you are safe in terms of the legacy apps that did not
> > include static bindings.
>
> No, that expand/shrink by itself doesn't work against parallel

Parallel? I think we are clear that ithis is inherently racy against the
app changing policies etc etc? There is a huge issue there already. The
app needs to be well behaved in some heretofore undefined way in order to
make moves clean.

> get_page_from_freelist going through a zonelist. Moving from node 0 to
> 1, with zonelist containing nodes 1 and 0 in that order:
>
> - mempolicy mask is 0
> - zonelist iteration checks node 1, it's not allowed, skip

There is an allocation from node 1? This is not allowed before the move.
So it should fail. Not skipping to another node.

> - mempolicy mask is 0,1 (expand)
> - mempolicy mask is 1 (shrink)
> - zonelist iteration checks node 0, it's not allowed, skip
> - OOM

Are you talking about a race here between zonelist scanning and the
moving? That has been there forever.

And frankly there are gazillions of these races. The best thing to do is
to get the cpuset moving logic out of the kernel and into user space.

Understand that this is a heuristic and maybe come up with a list of
restrictions that make an app safe. An safe app that can be moved must f.e

1. Not allocate new memory while its being moved
2. Not change memory policies after its initialization and while its being
moved.
3. Not save memory policy state in some variable (because the logic to
translate the memory policies for the new context cannot find it).

...

Again cpuset process migration  is a huge mess that you do not want to
have in the kernel and AFAICT this is a corner case with difficult
semantics. Better have that in user space...


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
