Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 9A3BD44044D
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 09:37:42 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id g62so7425293wme.0
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 06:37:42 -0800 (PST)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id n67si11125454wmf.61.2016.02.04.06.37.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Feb 2016 06:37:41 -0800 (PST)
Received: by mail-wm0-x242.google.com with SMTP id r129so12488698wmr.0
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 06:37:41 -0800 (PST)
Date: Thu, 4 Feb 2016 16:37:37 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 1/4] rmap: introduce rmap_walk_locked()
Message-ID: <20160204143737.GC20399@node.shutemov.name>
References: <1454512459-94334-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1454512459-94334-2-git-send-email-kirill.shutemov@linux.intel.com>
 <20160203144019.9b58b1ba496371a11cc86568@linux-foundation.org>
 <20160203224507.GA22605@black.fi.intel.com>
 <20160203145607.ec7fe6f46208a5da1a8f795a@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160203145607.ec7fe6f46208a5da1a8f795a@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Feb 03, 2016 at 02:56:07PM -0800, Andrew Morton wrote:
> On Thu, 4 Feb 2016 01:45:07 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> 
> > On Wed, Feb 03, 2016 at 02:40:19PM -0800, Andrew Morton wrote:
> > > On Wed,  3 Feb 2016 18:14:16 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> > > 
> > > > rmap_walk_locked() is the same as rmap_walk(), but caller takes care
> > > > about relevant rmap lock. It only supports anonymous pages for now.
> > > > 
> > > > It's preparation to switch THP splitting from custom rmap walk in
> > > > freeze_page()/unfreeze_page() to generic one.
> > > > 
> > > > ...
> > > >
> > > > +/* Like rmap_walk, but caller holds relevant rmap lock */
> > > > +int rmap_walk_locked(struct page *page, struct rmap_walk_control *rwc)
> > > > +{
> > > > +	/* only for anon pages for now */
> > > > +	VM_BUG_ON_PAGE(!PageAnon(page) || PageKsm(page), page);
> > > > +	return rmap_walk_anon(page, rwc, true);
> > > > +}
> > > 
> > > Should be rmap_walk_anon_locked()?
> > 
> > I leave interface open for further extension for file mappings, once it
> > will be needed. Interface is mirroring plain rmap_walk()
> 
> hm, yes, I see.
> 
> > If you prefer to rename the function, I can do it too.
> 
> Well, what does "unlocked" mean in the context of rmap_walk_ksm() and
> rmap_walk_file()?

For rmap_walk_file(), caller should take i_mmap_lock for page->mapping at
least for read.

Not sure about KSM..

> That the caller holds totally different locks.  I expect that sitting
> down and writing out the interface definition for such an
> rmap_walk_locked() would reveal that we shouldn't have created it.
> 
> I mean, if the caller is to call such an rmap_walk_locked(), he first
> needs to work out if it's a ksm page or an anon page or a file page,
> then take the appropriate lock and then call rmap_walk_locked(). 
> That's silly - at this point he should directly call
> rmap_walk_ksm_locked()?

It makes sense if you have multiple pages to process and it's known that
they share reverse mapping.

Or if you want to keep the reverse mapping locked to keep continuity with
other operations.

In THP case, we have 512 subpages to unmap and we want to keep anon_vma
locked until the THP is split.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
