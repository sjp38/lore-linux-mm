Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 3A9686B0032
	for <linux-mm@kvack.org>; Fri,  6 Sep 2013 12:46:30 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <1378484835-8552fpnd-mutt-n-horiguchi@ah.jp.nec.com>
References: <1378416466-30913-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1378416466-30913-3-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20130906104803.0F39CE0090@blue.fi.intel.com>
 <1378484835-8552fpnd-mutt-n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 2/2] thp: support split page table lock
Content-Transfer-Encoding: 7bit
Message-Id: <20130906164625.353B1E0090@blue.fi.intel.com>
Date: Fri,  6 Sep 2013 19:46:25 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Alex Thorlton <athorlton@sgi.com>, linux-kernel@vger.kernel.org

Naoya Horiguchi wrote:
> Hi Kirill,
> 
> On Fri, Sep 06, 2013 at 01:48:03PM +0300, Kirill A. Shutemov wrote:
> > Naoya Horiguchi wrote:
> > > Thp related code also uses per process mm->page_table_lock now.
> > > So making it fine-grained can provide better performance.
> > > 
> > > This patch makes thp support split page table lock by using page->ptl
> > > of the pages storing "pmd_trans_huge" pmds.
> > > 
> > > Some functions like pmd_trans_huge_lock() and page_check_address_pmd()
> > > are expected by their caller to pass back the pointer of ptl, so this
> > > patch adds to those functions new arguments for that. Rather than that,
> > > this patch gives only straightforward replacement.
> > > 
> > > ChangeLog v3:
> > >  - fixed argument of huge_pmd_lockptr() in copy_huge_pmd()
> > >  - added missing declaration of ptl in do_huge_pmd_anonymous_page()
> > > 
> > > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > 
> > Generally, looks good. Few notes:
> > 
> > I believe you need to convert __pte_alloc() to new locking. Not sure about
> > __pte_alloc_kernel().
> > Have you check all rest mm->page_table_lock, that they shouldn't be
> > converted to new locking?
> 
> I thought that keeping __pte_alloc() using mm->page_table_lock was safe
> because it uses bare mm->page_table_lock instead of pte_lockptr() even
> before this patchset, but not 100% sure.
> __pte_alloc() (and its family) are used in normal page path, so if it's
> not safe, we've lived with unsafe code for very long (maybe since 2005).
> Anyway, converting __pte_alloc() into split ptl could improve performance
> (though we need testing to know what amount), so I'll try that.

No, before the patch mm->page_table_lock is what we need: it serializes
setting up pmd, not adding pte to pmd and it's subject to change with new
locking model.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
