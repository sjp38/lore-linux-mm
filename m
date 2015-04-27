Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 3A77A6B0038
	for <linux-mm@kvack.org>; Mon, 27 Apr 2015 19:33:31 -0400 (EDT)
Received: by widdi4 with SMTP id di4so118470797wid.0
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 16:33:30 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.227])
        by mx.google.com with ESMTP id y6si35600297wje.63.2015.04.27.16.33.29
        for <linux-mm@kvack.org>;
        Mon, 27 Apr 2015 16:33:29 -0700 (PDT)
Date: Tue, 28 Apr 2015 02:33:12 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv5 00/28] THP refcounting redesign
Message-ID: <20150427233312.GB32576@node.dhcp.inet.fi>
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20150427160348.fa3aefc5fc557e429d6b0295@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150427160348.fa3aefc5fc557e429d6b0295@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Apr 27, 2015 at 04:03:48PM -0700, Andrew Morton wrote:
> On Fri, 24 Apr 2015 00:03:35 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> 
> > Hello everybody,
> > 
> > Here's reworked version of my patchset. All known issues were addressed.
> > 
> > The goal of patchset is to make refcounting on THP pages cheaper with
> > simpler semantics and allow the same THP compound page to be mapped with
> > PMD and PTEs. This is required to get reasonable THP-pagecache
> > implementation.
> 
> Are there any measurable performance improvements?

I was focused on stability up to this point. I'll bring some numbers.

> > With the new refcounting design it's much easier to protect against
> > split_huge_page(): simple reference on a page will make you the deal.
> > It makes gup_fast() implementation simpler and doesn't require
> > special-case in futex code to handle tail THP pages.
> > 
> > It should improve THP utilization over the system since splitting THP in
> > one process doesn't necessary lead to splitting the page in all other
> > processes have the page mapped.
> > 
> > The patchset drastically lower complexity of get_page()/put_page()
> > codepaths. I encourage reviewers look on this code before-and-after to
> > justify time budget on reviewing this patchset.
> >
> > ...
> >
> >  59 files changed, 1144 insertions(+), 1509 deletions(-)
> 
> It's huge.  I'm going to need help reviewing this.  Have earlier
> versions been reviewed much?

The most helpful was feedback from Aneesh for v4. Hugh pointed to few weak
parts. But I can't say that the patchset was reviewed much.

Sasha helped with testing. Few bugs he found was fixed during preparing v5
for posting. One more issue was pointed after posting the patchset. I work
on it now.

> Who do you believe are suitable reviewers?

Andrea is obvious candidate. Hugh looked recently into the same area with
his team pages idea.

In general, I tried to keep people who can be helpful with review or
testing on CC list.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
