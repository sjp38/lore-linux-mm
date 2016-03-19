Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 711A1828DF
	for <linux-mm@kvack.org>; Fri, 18 Mar 2016 21:01:05 -0400 (EDT)
Received: by mail-wm0-f51.google.com with SMTP id p65so58212167wmp.0
        for <linux-mm@kvack.org>; Fri, 18 Mar 2016 18:01:05 -0700 (PDT)
Received: from mail-wm0-x22a.google.com (mail-wm0-x22a.google.com. [2a00:1450:400c:c09::22a])
        by mx.google.com with ESMTPS id y75si1978375wmc.42.2016.03.18.18.01.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Mar 2016 18:01:04 -0700 (PDT)
Received: by mail-wm0-x22a.google.com with SMTP id l68so48611099wml.0
        for <linux-mm@kvack.org>; Fri, 18 Mar 2016 18:01:04 -0700 (PDT)
Date: Sat, 19 Mar 2016 04:01:01 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv4 04/25] rmap: support file thp
Message-ID: <20160319010101.GA29883@node.shutemov.name>
References: <1457737157-38573-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1457737157-38573-5-git-send-email-kirill.shutemov@linux.intel.com>
 <87d1qs9lah.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87d1qs9lah.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Fri, Mar 18, 2016 at 03:10:06PM +0530, Aneesh Kumar K.V wrote:
> "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> writes:
> 
> > [ text/plain ]
> > Naive approach: on mapping/unmapping the page as compound we update
> > ->_mapcount on each 4k page. That's not efficient, but it's not obvious
> > how we can optimize this. We can look into optimization later.
> >
> > PG_double_map optimization doesn't work for file pages since lifecycle
> > of file pages is different comparing to anon pages: file page can be
> > mapped again at any time.
> >
> 
> Can you explain this more ?. We added PG_double_map so that we can keep
> page_remove_rmap simpler. So if it isn't a compound page we still can do
> 
> 	if (!atomic_add_negative(-1, &page->_mapcount))
> 
> I am trying to understand why we can't use that with file pages ?

The first thing: for non-compound pages we still have simple
atomic_inc_and_test() / atomic_add_negative(-1), nothing changed here.

About compound pages:

For anon-THP PG_double_map allowed to not touch _mapcount in all subpages
until a PMD which maps the page is split.  This way we significantly lower
overhead on refcounting as long as we have the page mapped with PMD-only,
since we only need to increment compound_mapcount().

The optimization is possible due to relatively simple lifecycle of
anonymous THP page:

  - anon-THPs always mapped with PMD first;

  - new mapping of THP can only be created via fork();

  - the page only can get mapped with PTEs via split_huge_pmd();

For file-THP the situation is different. Once we allocated a huge page and
put it on radix tree, the page can be mapped with PTEs or PMDs at any
time. It makes the same optimization inapplicable there.

I think there *can* be some room for optimization, but I don't want to
invest more time here, until it's identified as bottleneck. It can lead to
more complex code on rmap side.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
