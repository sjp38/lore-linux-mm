Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f172.google.com (mail-we0-f172.google.com [74.125.82.172])
	by kanga.kvack.org (Postfix) with ESMTP id EC90E6B0038
	for <linux-mm@kvack.org>; Fri, 20 Mar 2015 17:35:07 -0400 (EDT)
Received: by weop45 with SMTP id p45so91708726weo.0
        for <linux-mm@kvack.org>; Fri, 20 Mar 2015 14:35:07 -0700 (PDT)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.227])
        by mx.google.com with ESMTP id ex5si489831wic.96.2015.03.20.14.35.06
        for <linux-mm@kvack.org>;
        Fri, 20 Mar 2015 14:35:06 -0700 (PDT)
Date: Fri, 20 Mar 2015 23:34:49 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 03/16] page-flags: introduce page flags policies wrt
 compound pages
Message-ID: <20150320213449.GA19774@node.dhcp.inet.fi>
References: <1426784902-125149-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1426784902-125149-4-git-send-email-kirill.shutemov@linux.intel.com>
 <20150320133553.eb8576a5ff1e85f201690628@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150320133553.eb8576a5ff1e85f201690628@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Mar 20, 2015 at 01:35:53PM -0700, Andrew Morton wrote:
> On Thu, 19 Mar 2015 19:08:09 +0200 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> 
> > This patch third argument to macros which create function definitions
> > for page flags. This arguments defines how page-flags helpers behave
> > on compound functions.
> > 
> > For now we define four policies:
> > 
> >  - ANY: the helper function operates on the page it gets, regardless if
> >    it's non-compound, head or tail.
> > 
> >  - HEAD: the helper function operates on the head page of the compound
> >    page if it gets tail page.
> > 
> >  - NO_TAIL: only head and non-compond pages are acceptable for this
> >    helper function.
> > 
> >  - NO_COMPOUND: only non-compound pages are acceptable for this helper
> >    function.
> > 
> > For now we use policy ANY for all helpers, which match current
> > behaviour.
> > 
> > We do not enforce the policy for TESTPAGEFLAG, because we have flags
> > checked for random pages all over the kernel. Noticeable exception to
> > this is PageTransHuge() which triggers VM_BUG_ON() for tail page.
> > 
> > +/* Page flags policies wrt compound pages */
> > +#define ANY(page, enforce)	page
> > +#define HEAD(page, enforce)	compound_head(page)
> > +#define NO_TAIL(page, enforce) ({					\
> > +#define NO_COMPOUND(page, enforce) ({					\
> > ...
> >
> > +#undef ANY
> > +#undef HEAD
> > +#undef NO_TAIL
> > +#undef NO_COMPOUND
> >  #endif /* !__GENERATING_BOUNDS_H */
> 
> This is risky - there are existing definitions of ANY and HEAD, and
> this code may go and undefine them.  This is improbable at present, as
> those definitions are in .c, after all includes.  But still, it's not
> good to chew off great hunks of the namespace like this.
> 
> So I think I'll prefix all these with "PF_", OK?

Yeah. That's fine.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
