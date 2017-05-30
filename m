Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 71FC96B0292
	for <linux-mm@kvack.org>; Tue, 30 May 2017 12:06:14 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id t81so32456585qke.2
        for <linux-mm@kvack.org>; Tue, 30 May 2017 09:06:14 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t14si8742221qkl.145.2017.05.30.09.06.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 May 2017 09:06:13 -0700 (PDT)
Date: Tue, 30 May 2017 18:06:10 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm: introduce MADV_CLR_HUGEPAGE
Message-ID: <20170530160610.GC8412@redhat.com>
References: <c59a0893-d370-130b-5c33-d567a4621903@suse.cz>
 <20170524103947.GC3063@rapoport-lnx>
 <20170524111800.GD14733@dhcp22.suse.cz>
 <20170524142735.GF3063@rapoport-lnx>
 <20170530074408.GA7969@dhcp22.suse.cz>
 <20170530101921.GA25738@rapoport-lnx>
 <20170530103930.GB7969@dhcp22.suse.cz>
 <20170530140456.GA8412@redhat.com>
 <20170530143941.GK7969@dhcp22.suse.cz>
 <20170530145632.GL7969@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170530145632.GL7969@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Tue, May 30, 2017 at 04:56:33PM +0200, Michal Hocko wrote:
> On Tue 30-05-17 16:39:41, Michal Hocko wrote:
> > On Tue 30-05-17 16:04:56, Andrea Arcangeli wrote:
> [...]
> > > About the proposed madvise, it just clear bits, but it doesn't change
> > > at all how those bits are computed in THP code. So I don't see it as
> > > convoluted.
> > 
> > But we already have MADV_HUGEPAGE, MADV_NOHUGEPAGE and prctl to
> > enable/disable thp. Doesn't that sound little bit too much for a single
> > feature to you?
> 
> And also I would argue that the prctl should be usable for this specific
> usecase. The man page says
> "
> Setting this flag provides a method for disabling transparent huge pages
> for jobs where the code cannot be modified
> "
> 
> and that fits into the described case AFAIU. The thing that the current
> implementation doesn't work is a mere detail. I would even argue that
> it is non-intuitive if not buggy right away. Whoever calls this prctl
> later in the process life time will simply not stop THP from creating.
> 
> So again, why cannot we fix that? There was some handwaving about
> potential overhead but has anybody actually measured that?

I'm not sure if it should be considered a bug, the prctl is intended
to use normally by wrappers so it looks optimal as implemented this
way: affecting future vmas only, which will all be created after
execve executed by the wrapper.

What's the point of messing with the prctl so it mangles over the
wrapper process own vmas before exec? Messing with those vmas is pure
wasted CPUs for the wrapper use case which is what the prctl was
created for.

Furthermore there would be the risk a program that uses the prctl not
as a wrapper and then calls the prctl to clear VM_NOHUGEPAGE from
def_flags assuming the current kABI. The program could assume those
vmas that were instantiated before disabling the prctl are still with
VM_NOHUGEPAGE set (they would not after the change you propose).

Adding a scan of all vmas to PR_SET_THP_DISABLE to clear VM_NOHUGEPAGE
on existing vmas looks more complex too and less finegrined so
probably more complex for userland to manage, but ignoring all above
considerations it would be a functional alternative for CRIU's
needs. However if you didn't like the complexity of the new madvise
which is functionally a one-liner equivalent to MADV_NORMAL, I
wouldn't expect you to prefer to make the prctl even more complex with
a loop over all vmas that despite being fairly simple it'll still be
more than a trivial one liner.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
