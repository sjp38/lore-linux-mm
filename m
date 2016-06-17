Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id F19EC6B0005
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 08:25:10 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id l184so38555920lfl.3
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 05:25:10 -0700 (PDT)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id i127si22026909lfd.61.2016.06.17.05.25.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jun 2016 05:25:09 -0700 (PDT)
Received: by mail-lf0-x243.google.com with SMTP id a2so8192657lfe.3
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 05:25:09 -0700 (PDT)
Date: Fri, 17 Jun 2016 15:25:06 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: fix account pmd page to the process
Message-ID: <20160617122506.GC6534@node.shutemov.name>
References: <1466076971-24609-1-git-send-email-zhongjiang@huawei.com>
 <20160616154214.GA12284@dhcp22.suse.cz>
 <20160616154324.GN6836@dhcp22.suse.cz>
 <71df66ac-df29-9542-bfa9-7c94f374df5b@oracle.com>
 <20160616163119.GP6836@dhcp22.suse.cz>
 <bf76cc6c-a0da-98f9-4a89-0bb6161f5adf@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <bf76cc6c-a0da-98f9-4a89-0bb6161f5adf@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Michal Hocko <mhocko@kernel.org>, zhongjiang <zhongjiang@huawei.com>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jun 16, 2016 at 09:47:46AM -0700, Mike Kravetz wrote:
> On 06/16/2016 09:31 AM, Michal Hocko wrote:
> > On Thu 16-06-16 09:05:23, Mike Kravetz wrote:
> >> On 06/16/2016 08:43 AM, Michal Hocko wrote:
> >>> [It seems that this patch has been sent several times and this
> >>> particular copy didn't add Kirill who has added this code CC him now]
> >>>
> >>> On Thu 16-06-16 17:42:14, Michal Hocko wrote:
> >>>> On Thu 16-06-16 19:36:11, zhongjiang wrote:
> >>>>> From: zhong jiang <zhongjiang@huawei.com>
> >>>>>
> >>>>> when a process acquire a pmd table shared by other process, we
> >>>>> increase the account to current process. otherwise, a race result
> >>>>> in other tasks have set the pud entry. so it no need to increase it.
> >>>>>
> >>>>> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
> >>>>> ---
> >>>>>  mm/hugetlb.c | 5 ++---
> >>>>>  1 file changed, 2 insertions(+), 3 deletions(-)
> >>>>>
> >>>>> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> >>>>> index 19d0d08..3b025c5 100644
> >>>>> --- a/mm/hugetlb.c
> >>>>> +++ b/mm/hugetlb.c
> >>>>> @@ -4189,10 +4189,9 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
> >>>>>  	if (pud_none(*pud)) {
> >>>>>  		pud_populate(mm, pud,
> >>>>>  				(pmd_t *)((unsigned long)spte & PAGE_MASK));
> >>>>> -	} else {
> >>>>> +	} else 
> >>>>>  		put_page(virt_to_page(spte));
> >>>>> -		mm_inc_nr_pmds(mm);
> >>>>> -	}
> >>>>
> >>>> The code is quite puzzling but is this correct? Shouldn't we rather do
> >>>> mm_dec_nr_pmds(mm) in that path to undo the previous inc?
> >>
> >> I agree that the code is quite puzzling. :(
> >>
> >> However, if this were an issue I would have expected to see some reports.
> >> Oracle DB makes use of this feature (shared page tables) and if the pmd
> >> count is wrong we would catch it in check_mm() at exit time.
> >>
> >> Upon closer examination, I believe the code in question is never executed.
> >> Note the callers of huge_pmd_share.  The calling code looks like:
> >>
> >>                         if (want_pmd_share() && pud_none(*pud))
> >>                                 pte = huge_pmd_share(mm, addr, pud);
> >>                         else
> >>                                 pte = (pte_t *)pmd_alloc(mm, pud, addr);
> >>
> >> Therefore, we do not call huge_pmd_share unless pud_none(*pud).  The
> >> code in question is only executed when !pud_none(*pud).
> > 
> > My understanding is that the check is needed after we retake page lock
> > because we might have raced with other thread. But it's been quite some
> > time since I've looked at hugetlb locking and page table sharing code.
> 
> That is correct, we could have raced. Duh!
> 
> In the case of a race, the other thread would have incremented the
> PMD count already.  Your suggestion of decrementing pmd count in
> this case seems to be the correct approach.  But, I need to think
> about this some more.

Yes, I made mistake by increasing nr_pmds, not descreasing here.

Testcase:

#include <errno.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/mman.h>
#include <sys/syscall.h>
#include <sys/time.h>

#define HPGSZ 2097152UL
int main(int argc, char **argv) {
	char *addr;

	system("echo 1024 > /proc/sys/vm/nr_hugepages");
	addr = mmap(NULL, 1024*HPGSZ, PROT_WRITE | PROT_READ,
			MAP_SHARED | MAP_ANONYMOUS | MAP_HUGETLB | MAP_POPULATE, -1, 0);
	if (addr == MAP_FAILED) {
		fprintf(stderr, "Failed to alloc hugepage\n");
		return -1;
	}

	addr[0] = 1;
	fork();
	printf("addr[0]: %d\n", addr[0]);

	sleep(1);
	return 0;
}

You can simulate race by replacing 'if (pud_none(*pud))' with "if (0)". It
would produce "BUG: non-zero nr_pmds on freeing mm: 2" on the test-case.

Fix:
