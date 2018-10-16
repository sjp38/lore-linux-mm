Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3D73E6B0005
	for <linux-mm@kvack.org>; Tue, 16 Oct 2018 19:11:53 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id t18-v6so523937qki.22
        for <linux-mm@kvack.org>; Tue, 16 Oct 2018 16:11:53 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t22-v6si207241qtj.158.2018.10.16.16.11.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Oct 2018 16:11:52 -0700 (PDT)
Date: Tue, 16 Oct 2018 19:11:49 -0400
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/2] mm: thp:  relax __GFP_THISNODE for MADV_HUGEPAGE
 mappings
Message-ID: <20181016231149.GJ30832@redhat.com>
References: <20181009094825.GC6931@suse.de>
 <20181009122745.GN8528@dhcp22.suse.cz>
 <20181009130034.GD6931@suse.de>
 <20181009142510.GU8528@dhcp22.suse.cz>
 <20181009230352.GE9307@redhat.com>
 <alpine.DEB.2.21.1810101410530.53455@chino.kir.corp.google.com>
 <alpine.DEB.2.21.1810151525460.247641@chino.kir.corp.google.com>
 <20181015154459.e870c30df5c41966ffb4aed8@linux-foundation.org>
 <20181016074606.GH6931@suse.de>
 <20181016153715.b40478ff2eebe8d6cf1aead5@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181016153715.b40478ff2eebe8d6cf1aead5@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Andrea Argangeli <andrea@kernel.org>, Zi Yan <zi.yan@cs.rutgers.edu>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Stable tree <stable@vger.kernel.org>

Hello,

On Tue, Oct 16, 2018 at 03:37:15PM -0700, Andrew Morton wrote:
> we'll still make it into 4.19.1.  Am reluctant to merge this while
> discussion, testing and possibly more development are ongoing.

I think there can be definitely more developments primarily to make
the compact deferred logic NUMA aware. Instead of a global deferred
logic, we should split it per zone per node so that it backs off
exponentially with an higher cap in remote nodes. The current global
"backoff" limit will still apply to the "local" zone compaction. Who
would like to work on that?

However I don't think it's worth waiting for that, because it's not a
trivial change.

Certainly we can't ship upstream in production with this bug, so if it
doesn't get fixed upstream we'll fix it downstream first until the
more developments are production ready. This was a severe regression
compared to previous kernels that made important workloads unusable
and it starts when __GFP_THISNODE was added to THP allocations under
MADV_HUGEPAGE. It is not a significant risk to go to the previous
behavior before __GFP_THISNODE was added, it worked like that for
years.

This was simply an optimization to some lucky workloads that can fit
in a single node, but it ended up breaking the VM for others that
can't possibly fit in a single node, so going back is safe.

Thanks,
Andrea
