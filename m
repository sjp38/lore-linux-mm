Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 3A7256B0034
	for <linux-mm@kvack.org>; Sun,  8 Sep 2013 22:35:02 -0400 (EDT)
Message-ID: <522D33C5.9050707@numascale.com>
Date: Mon, 09 Sep 2013 10:34:45 +0800
From: Daniel J Blueman <daniel@numascale.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] thp: support split page table lock
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, kirill.shutemov@linux.intel.com, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Alex Thorlton <athorlton@sgi.com>, Steffen Persvold <sp@numascale.com>

On Saturday, 7 September 2013 02:10:02 UTC+8, Naoya Horiguchi  wrote:
> Hi Alex,
>
> On Fri, Sep 06, 2013 at 11:04:23AM -0500, Alex Thorlton wrote:
> > On Thu, Sep 05, 2013 at 05:27:46PM -0400, Naoya Horiguchi wrote:
> > > Thp related code also uses per process mm->page_table_lock now.
> > > So making it fine-grained can provide better performance.
> > >
> > > This patch makes thp support split page table lock by using page->ptl
> > > of the pages storing "pmd_trans_huge" pmds.
> > >
> > > Some functions like pmd_trans_huge_lock() and
page_check_address_pmd()
> > > are expected by their caller to pass back the pointer of ptl, so this
> > > patch adds to those functions new arguments for that. Rather than
that,
> > > this patch gives only straightforward replacement.
> > >
> > > ChangeLog v3:
> > >  - fixed argument of huge_pmd_lockptr() in copy_huge_pmd()
> > >  - added missing declaration of ptl in do_huge_pmd_anonymous_page()
> >
> > I've applied these and tested them using the same tests program that I
> > used when I was working on the same issue, and I'm running into some
> > bugs.  Here's a stack trace:
>
> Thank you for helping testing. This bug is new to me.

With 3.11, this patch series and CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS, I 
consistently hit the same failure when exiting one of my stress-testers 
[1] when using eg 24 cores.

Doesn't happen with 8 cores, so likely needs enough virtual memory to 
use multiple split locks. Otherwise, this is very promising work!

[1] http://quora.org/2013/fft3d.c
-- 
Daniel J Blueman
Principal Software Engineer, Numascale

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
