Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 556FF6B0032
	for <linux-mm@kvack.org>; Mon, 22 Jun 2015 09:18:47 -0400 (EDT)
Received: by wiga1 with SMTP id a1so76601411wig.0
        for <linux-mm@kvack.org>; Mon, 22 Jun 2015 06:18:46 -0700 (PDT)
Received: from johanna4.rokki.sonera.fi (mta-out1.inet.fi. [62.71.2.230])
        by mx.google.com with ESMTP id d6si1809931wjy.185.2015.06.22.06.18.44
        for <linux-mm@kvack.org>;
        Mon, 22 Jun 2015 06:18:45 -0700 (PDT)
Date: Mon, 22 Jun 2015 16:18:27 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv6 36/36] thp: update documentation
Message-ID: <20150622131827.GF7934@node.dhcp.inet.fi>
References: <1433351167-125878-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1433351167-125878-37-git-send-email-kirill.shutemov@linux.intel.com>
 <55797F57.8040001@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55797F57.8040001@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Jun 11, 2015 at 02:30:15PM +0200, Vlastimil Babka wrote:
> On 06/03/2015 07:06 PM, Kirill A. Shutemov wrote:
> >The patch updates Documentation/vm/transhuge.txt to reflect changes in
> >THP design.
> 
> One thing I'm missing is info about the deferred splitting.

Okay, I'll add this.

> >Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> >---
> >  Documentation/vm/transhuge.txt | 124 +++++++++++++++++++++++------------------
> >  1 file changed, 69 insertions(+), 55 deletions(-)
> >
> >diff --git a/Documentation/vm/transhuge.txt b/Documentation/vm/transhuge.txt
> >index 6b31cfbe2a9a..2352b12cae93 100644
> >--- a/Documentation/vm/transhuge.txt
> >+++ b/Documentation/vm/transhuge.txt
> >@@ -35,10 +35,10 @@ miss is going to run faster.
> >
> >  == Design ==
> >
> >-- "graceful fallback": mm components which don't have transparent
> >-  hugepage knowledge fall back to breaking a transparent hugepage and
> >-  working on the regular pages and their respective regular pmd/pte
> >-  mappings
> >+- "graceful fallback": mm components which don't have transparent hugepage
> >+  knowledge fall back to breaking huge pmd mapping into table of ptes and,
> >+  if nesessary, split a transparent hugepage. Therefore these components
> 
>         necessary
> >+
> >+split_huge_page uses migration entries to stabilize page->_count and
> >+page->_mapcount.
> 
> Hm, what if there's some physical memory scanner taking page->_count pins? I
> think compaction shouldn't be an issue, but maybe some others?

The only legitimate way scanner can get reference to a page is
get_page_unless_zero(), right?

All tail pages has zero ->_count until atomic_add() in
__split_huge_page_tail() -- get_page_unless_zero() will fail.
After the atomic_add() we don't care about ->_count value.
We already known how many references with should uncharge from 
head page.

For head page get_page_unless_zero() will succeed and we don't
mind. It's clear where reference should go after split: it will
stay on head page.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
