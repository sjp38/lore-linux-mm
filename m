Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 28F066B02C3
	for <linux-mm@kvack.org>; Tue,  4 Jul 2017 04:10:12 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id v88so44828715wrb.1
        for <linux-mm@kvack.org>; Tue, 04 Jul 2017 01:10:12 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 61si13025252wri.179.2017.07.04.01.10.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 04 Jul 2017 01:10:10 -0700 (PDT)
Date: Tue, 4 Jul 2017 10:10:07 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] vmalloc: respect the GFP_NOIO and GFP_NOFS flags
Message-ID: <20170704081007.GA14722@dhcp22.suse.cz>
References: <alpine.LRH.2.02.1706292221250.21823@file01.intranet.prod.int.rdu2.redhat.com>
 <20170630081245.GA22917@dhcp22.suse.cz>
 <alpine.LRH.2.02.1706301410160.8272@file01.intranet.prod.int.rdu2.redhat.com>
 <20170630204059.GA17255@dhcp22.suse.cz>
 <alpine.LRH.2.02.1706302033230.13879@file01.intranet.prod.int.rdu2.redhat.com>
 <20170703062905.GB3217@dhcp22.suse.cz>
 <alpine.LRH.2.02.1707031703590.20792@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1707031703590.20792@file01.intranet.prod.int.rdu2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, Andrew Morton <akpm@linux-foundation.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Vlastimil Babka <vbabka@suse.cz>, Andreas Dilger <adilger@dilger.ca>, John Hubbard <jhubbard@nvidia.com>, David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org

On Mon 03-07-17 18:57:14, Mikulas Patocka wrote:
> 
> 
> On Mon, 3 Jul 2017, Michal Hocko wrote:
> 
> > We can add a warning (or move it from kvmalloc) and hope that the
> > respective maintainers will fix those places properly. The reason I
> > didn't add the warning to vmalloc and kept it in kvmalloc was to catch
> > only new users rather than suddenly splat on existing ones. Note that
> > there are users with panic_on_warn enabled.
> > 
> > Considering how many NOFS users we have in tree I would rather work with
> > maintainers to fix them.
> 
> So - do you want this patch?

no, see below
 
> I still believe that the previous patch that pushes 
> memalloc_noio/nofs_save into __vmalloc is better than this.

It is, but both of them are actually wrong. Why? Because that would be
just a mindless application of the scope where the scope doesn't match
the actual reclaim recursion restricted scope. Really, the right way to
go is to simply talk to the respective maintainers. Find out whether
NOFS context is really needed and if so find the scope (e.g. a lock
which would be needed in the reclaim context) and document it. This is
not a trivial work to do but a) we do not seem to have any bug reports
complaining about these call sites so there is no need to hurry and b)
this will result in a cleaner and easier to maintain code.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
