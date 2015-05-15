Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 894FA6B0032
	for <linux-mm@kvack.org>; Fri, 15 May 2015 09:41:14 -0400 (EDT)
Received: by wizk4 with SMTP id k4so287569904wiz.1
        for <linux-mm@kvack.org>; Fri, 15 May 2015 06:41:14 -0700 (PDT)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.227])
        by mx.google.com with ESMTP id hu2si3810410wib.17.2015.05.15.06.41.12
        for <linux-mm@kvack.org>;
        Fri, 15 May 2015 06:41:13 -0700 (PDT)
Date: Fri, 15 May 2015 16:41:03 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv5 07/28] thp, mlock: do not allow huge pages in mlocked
 area
Message-ID: <20150515134103.GC6625@node.dhcp.inet.fi>
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1429823043-157133-8-git-send-email-kirill.shutemov@linux.intel.com>
 <5555ED0A.5010702@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5555ED0A.5010702@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, May 15, 2015 at 02:56:42PM +0200, Vlastimil Babka wrote:
> On 04/23/2015 11:03 PM, Kirill A. Shutemov wrote:
> >With new refcounting THP can belong to several VMAs. This makes tricky
> >to track THP pages, when they partially mlocked. It can lead to leaking
> >mlocked pages to non-VM_LOCKED vmas and other problems.
> >
> >With this patch we will split all pages on mlock and avoid
> >fault-in/collapse new THP in VM_LOCKED vmas.
> >
> >I've tried alternative approach: do not mark THP pages mlocked and keep
> >them on normal LRUs. This way vmscan could try to split huge pages on
> >memory pressure and free up subpages which doesn't belong to VM_LOCKED
> >vmas.  But this is user-visible change: we screw up Mlocked accouting
> >reported in meminfo, so I had to leave this approach aside.
> >
> >We can bring something better later, but this should be good enough for
> >now.
> 
> I can imagine people won't be happy about losing benefits of THP's when they
> mlock().
> How difficult would it be to support mlocked THP pages without splitting
> until something actually tries to do a partial (un)mapping, and only then do
> the split? That will support the most common case, no?

Yes, it will.

But what will we do if we fail to split huge page on munmap()? Fail
munmap() with -EBUSY? 

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
