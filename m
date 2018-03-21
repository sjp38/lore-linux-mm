Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id A4BEC6B002A
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 11:08:22 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id u186so3260502qkc.6
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 08:08:22 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id p57si3259180qtf.335.2018.03.21.08.08.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Mar 2018 08:08:21 -0700 (PDT)
Date: Wed, 21 Mar 2018 11:08:19 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 13/15] mm/hmm: factor out pte and pmd handling to
 simplify hmm_vma_walk_pmd()
Message-ID: <20180321150819.GC3214@redhat.com>
References: <20180320020038.3360-1-jglisse@redhat.com>
 <20180320020038.3360-14-jglisse@redhat.com>
 <e0fd4348-8b8c-90b2-a9d8-91a30768fddc@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <e0fd4348-8b8c-90b2-a9d8-91a30768fddc@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Evgeny Baskakov <ebaskakov@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>

On Tue, Mar 20, 2018 at 10:07:29PM -0700, John Hubbard wrote:
> On 03/19/2018 07:00 PM, jglisse@redhat.com wrote:
> > From: Jerome Glisse <jglisse@redhat.com>
> > 
> > No functional change, just create one function to handle pmd and one
> > to handle pte (hmm_vma_handle_pmd() and hmm_vma_handle_pte()).
> > 
> > Signed-off-by: Jerome Glisse <jglisse@redhat.com>
> > Cc: Evgeny Baskakov <ebaskakov@nvidia.com>
> > Cc: Ralph Campbell <rcampbell@nvidia.com>
> > Cc: Mark Hairgrove <mhairgrove@nvidia.com>
> > Cc: John Hubbard <jhubbard@nvidia.com>
> > ---
> >  mm/hmm.c | 174 +++++++++++++++++++++++++++++++++++++--------------------------
> >  1 file changed, 102 insertions(+), 72 deletions(-)
> > 
> > diff --git a/mm/hmm.c b/mm/hmm.c
> > index 52cdceb35733..dc703e9c3a95 100644
> > --- a/mm/hmm.c
> > +++ b/mm/hmm.c
> > @@ -351,6 +351,99 @@ static int hmm_vma_walk_hole(unsigned long addr,
> >  	return hmm_vma_walk->fault ? -EAGAIN : 0;
> >  }
> >  
> > +static int hmm_vma_handle_pmd(struct mm_walk *walk,
> > +			      unsigned long addr,
> > +			      unsigned long end,
> > +			      uint64_t *pfns,
> 
> Hi Jerome,
> 
> Nice cleanup, it makes it much easier to follow the code now.
> 
> Let's please rename the pfns argument above to "pfn", because in this
> helper (and the _pte helper too), there is only one pfn involved, rather
> than an array of them.

This is only true to handle_pte, for handle_pmd it will go over several
pfn entries. But they will all get fill with same value modulo pfn which
will increase monotically (ie same flag as pmd permissions apply to all
entries).

Note sure s/pfns/pfn for hmm_vma_handle_pte() warrant a respin.

Cheers,
Jerome
