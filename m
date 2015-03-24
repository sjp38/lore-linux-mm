Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 171DF6B0038
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 19:43:04 -0400 (EDT)
Received: by pabxg6 with SMTP id xg6so8947932pab.0
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 16:43:03 -0700 (PDT)
Received: from mail-pd0-x22a.google.com (mail-pd0-x22a.google.com. [2607:f8b0:400e:c02::22a])
        by mx.google.com with ESMTPS id og4si1002608pdb.24.2015.03.24.16.43.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Mar 2015 16:43:03 -0700 (PDT)
Received: by pdbni2 with SMTP id ni2so8802991pdb.1
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 16:43:03 -0700 (PDT)
Date: Tue, 24 Mar 2015 16:42:48 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 00/16] Sanitize usage of ->flags and ->mapping for tail
 pages
In-Reply-To: <20150323100433.GA30088@node.dhcp.inet.fi>
Message-ID: <alpine.LSU.2.11.1503241621050.2532@eggly.anvils>
References: <1426784902-125149-1-git-send-email-kirill.shutemov@linux.intel.com> <alpine.LSU.2.11.1503221713370.3913@eggly.anvils> <20150323100433.GA30088@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 23 Mar 2015, Kirill A. Shutemov wrote:
> On Sun, Mar 22, 2015 at 05:28:47PM -0700, Hugh Dickins wrote:
> > On Thu, 19 Mar 2015, Kirill A. Shutemov wrote:
> > 
> > > Currently we take naive approach to page flags on compound -- we set the
> > > flag on the page without consideration if the flag makes sense for tail
> > > page or for compound page in general. This patchset try to sort this out
> > > by defining per-flag policy on what need to be done if page-flag helper
> > > operate on compound page.
> > > 
> > > The last patch in patchset also sanitize usege of page->mapping for tail
> > > pages. We don't define meaning of page->mapping for tail pages. Currently
> > > it's always NULL, which can be inconsistent with head page and potentially
> > > lead to problems.
> > > 
> > > For now I catched one case of illigal usage of page flags or ->mapping:
> > > sound subsystem allocates pages with __GFP_COMP and maps them with PTEs.
> > > It leads to setting dirty bit on tail pages and access to tail_page's
> > > ->mapping. I don't see any bad behaviour caused by this, but worth fixing
> > > anyway.
> > 
> > But there's nothing to fix there.  We're more used to having page->mapping
> > set by filesystems, but it is normal for drivers to have pages with NULL
> > page->mapping mapped into userspace (and it's not accidental that they
> > appear !PageAnon); and subpages of compound pages mapped into userspace,
> > and set_page_dirty applied to them.
> 
> Yes, it works until some sound driver decide it wants to use
> page->mappging.

(a) Why would it want to use page->mapping?
(b) What's the problem if it wants to use page->mapping?
(c) Or perhaps some __GFP_COMP driver does already use page->mapping?

The code works fine as is (er, modulo the fact that someone has tried
to use page_mapcount for two different things at the same time), and
has worked for years.

If new needs emerge, we can make suitable changes.  If your refcounting
rework needs a change here, fine, then just make these patches a part
of that set.  But please don't impose new rules for no reason.

> 
> It's just pure luck that it happened to work in this particular case.

We were lucky that it fitted together without needing extra code, yes.
But this didn't happen by accident, it was known and considered.

> 
> > > This patchset makes more sense if you take my THP refcounting into
> > > account: we will see more compound pages mapped with PTEs and we need to
> > > define behaviour of flags on compound pages to avoid bugs.
> > 
> > Yes, I quite understand that you want to clarify the usage of different
> > page flags to yourself, to help towards a policy of what to do with each
> > of them when subpages of a huge compound page are mapped into userspace;
> > but I don't see that we need this patchset in the kernel now, given that
> > it adds unnecessary overhead into several low-level inline functions.
> 
> We already have subpages of compound page mapped to userspace -- the sound
> case.
> 
> And what overhead are you talking about?
> 
> Check for compound or head bit is practically free in most cases since you
> are going to check other bits in the same cache line anyway. Probably a
> bit more expensive if the flag is encoded in ->mapping or somewhere else.
> (on 32-bit x86 ->mapping case is also free, since it's in the same cache
> line as ->flags).

Good that it's practically free on x86 (though your "practically"
suggests it's not quite free).  Then there's also the extra icache.

This is small stuff, I do agree (though small stuff concealed in
common inline functions we tend to think of as lightweight).

I care more about not adding unnecessary code,
and not fixing what's not broken.

> 
> You only need to pay the expense if you hit tail page which is very rare
> in current kernel. I think we can pay this cost for correctness.

But it's correct as is.

> 
> We will shave some cost of compound_head() if/when my refcounting patchset
> get merged: no need of barrier anymore.

And if these changes are necessary for that, sure, go ahead:
but as part of that work.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
