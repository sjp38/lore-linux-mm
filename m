Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id ACAC46B0279
	for <linux-mm@kvack.org>; Wed, 31 May 2017 02:30:11 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id k30so952214wrc.9
        for <linux-mm@kvack.org>; Tue, 30 May 2017 23:30:11 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e5si16536738wrc.304.2017.05.30.23.30.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 30 May 2017 23:30:10 -0700 (PDT)
Subject: Re: [PATCH] mm: introduce MADV_CLR_HUGEPAGE
References: <c59a0893-d370-130b-5c33-d567a4621903@suse.cz>
 <20170524103947.GC3063@rapoport-lnx> <20170524111800.GD14733@dhcp22.suse.cz>
 <20170524142735.GF3063@rapoport-lnx> <20170530074408.GA7969@dhcp22.suse.cz>
 <20170530101921.GA25738@rapoport-lnx> <20170530103930.GB7969@dhcp22.suse.cz>
 <20170530140456.GA8412@redhat.com> <20170530143941.GK7969@dhcp22.suse.cz>
 <20170530145632.GL7969@dhcp22.suse.cz> <20170530160610.GC8412@redhat.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <e371b76b-d091-72d0-16c3-5227820595f0@suse.cz>
Date: Wed, 31 May 2017 08:30:08 +0200
MIME-Version: 1.0
In-Reply-To: <20170530160610.GC8412@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On 05/30/2017 06:06 PM, Andrea Arcangeli wrote:
> 
> I'm not sure if it should be considered a bug, the prctl is intended
> to use normally by wrappers so it looks optimal as implemented this
> way: affecting future vmas only, which will all be created after
> execve executed by the wrapper.
> 
> What's the point of messing with the prctl so it mangles over the
> wrapper process own vmas before exec? Messing with those vmas is pure
> wasted CPUs for the wrapper use case which is what the prctl was
> created for.
> 
> Furthermore there would be the risk a program that uses the prctl not
> as a wrapper and then calls the prctl to clear VM_NOHUGEPAGE from
> def_flags assuming the current kABI. The program could assume those
> vmas that were instantiated before disabling the prctl are still with
> VM_NOHUGEPAGE set (they would not after the change you propose).
> 
> Adding a scan of all vmas to PR_SET_THP_DISABLE to clear VM_NOHUGEPAGE
> on existing vmas looks more complex too and less finegrined so
> probably more complex for userland to manage

I would expect the prctl wouldn't iterate all vma's, nor would it modify
def_flags anymore. It would just set a flag somewhere in mm struct that
would be considered in addition to the per-vma flags when deciding
whether to use THP. We could consider whether MADV_HUGEPAGE should be
able to override the prctl or not.

> but ignoring all above
> considerations it would be a functional alternative for CRIU's
> needs. However if you didn't like the complexity of the new madvise
> which is functionally a one-liner equivalent to MADV_NORMAL, I
> wouldn't expect you to prefer to make the prctl even more complex with
> a loop over all vmas that despite being fairly simple it'll still be
> more than a trivial one liner.
> 
> Thanks,
> Andrea
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
