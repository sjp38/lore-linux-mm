Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 5FC006B0032
	for <linux-mm@kvack.org>; Mon, 23 Feb 2015 08:52:23 -0500 (EST)
Received: by mail-wi0-f172.google.com with SMTP id l15so17209383wiw.5
        for <linux-mm@kvack.org>; Mon, 23 Feb 2015 05:52:22 -0800 (PST)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.227])
        by mx.google.com with ESMTP id v1si17775925wiz.74.2015.02.23.05.52.21
        for <linux-mm@kvack.org>;
        Mon, 23 Feb 2015 05:52:22 -0800 (PST)
Date: Mon, 23 Feb 2015 15:52:06 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv3 05/24] mm, proc: adjust PSS calculation
Message-ID: <20150223135206.GC7322@node.dhcp.inet.fi>
References: <1423757918-197669-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1423757918-197669-6-git-send-email-kirill.shutemov@linux.intel.com>
 <54E76F63.7020203@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54E76F63.7020203@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Marchand <jmarchan@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Feb 20, 2015 at 06:31:15PM +0100, Jerome Marchand wrote:
> On 02/12/2015 05:18 PM, Kirill A. Shutemov wrote:
> > With new refcounting all subpages of the compound page are not nessessary
> > have the same mapcount. We need to take into account mapcount of every
> > sub-page.
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > ---
> >  fs/proc/task_mmu.c | 43 ++++++++++++++++++++++---------------------
> >  1 file changed, 22 insertions(+), 21 deletions(-)
> > 
> > diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> > index 98826d08a11b..8a0a78174cc6 100644
> > --- a/fs/proc/task_mmu.c
> > +++ b/fs/proc/task_mmu.c
> > @@ -449,9 +449,10 @@ struct mem_size_stats {
> >  };
> >  
> >  static void smaps_account(struct mem_size_stats *mss, struct page *page,
> > -		unsigned long size, bool young, bool dirty)
> > +		bool compound, bool young, bool dirty)
> >  {
> > -	int mapcount;
> > +	int i, nr = compound ? hpage_nr_pages(page) : 1;
> > +	unsigned long size = 1UL << nr;
> 
> Shouldn't that be:
> 	unsigned long size = nr << PAGE_SHIFT;

Yes, thanks you.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
