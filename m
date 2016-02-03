Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 38B8C82963
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 17:45:13 -0500 (EST)
Received: by mail-pf0-f177.google.com with SMTP id n128so21175711pfn.3
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 14:45:13 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id q2si11891179pfa.198.2016.02.03.14.45.12
        for <linux-mm@kvack.org>;
        Wed, 03 Feb 2016 14:45:12 -0800 (PST)
Date: Thu, 4 Feb 2016 01:45:07 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH 1/4] rmap: introduce rmap_walk_locked()
Message-ID: <20160203224507.GA22605@black.fi.intel.com>
References: <1454512459-94334-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1454512459-94334-2-git-send-email-kirill.shutemov@linux.intel.com>
 <20160203144019.9b58b1ba496371a11cc86568@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160203144019.9b58b1ba496371a11cc86568@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Feb 03, 2016 at 02:40:19PM -0800, Andrew Morton wrote:
> On Wed,  3 Feb 2016 18:14:16 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> 
> > rmap_walk_locked() is the same as rmap_walk(), but caller takes care
> > about relevant rmap lock. It only supports anonymous pages for now.
> > 
> > It's preparation to switch THP splitting from custom rmap walk in
> > freeze_page()/unfreeze_page() to generic one.
> > 
> > ...
> >
> > +/* Like rmap_walk, but caller holds relevant rmap lock */
> > +int rmap_walk_locked(struct page *page, struct rmap_walk_control *rwc)
> > +{
> > +	/* only for anon pages for now */
> > +	VM_BUG_ON_PAGE(!PageAnon(page) || PageKsm(page), page);
> > +	return rmap_walk_anon(page, rwc, true);
> > +}
> 
> Should be rmap_walk_anon_locked()?

I leave interface open for further extension for file mappings, once it
will be needed. Interface is mirroring plain rmap_walk()

If you prefer to rename the function, I can do it too.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
