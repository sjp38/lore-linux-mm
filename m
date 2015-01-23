Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f171.google.com (mail-we0-f171.google.com [74.125.82.171])
	by kanga.kvack.org (Postfix) with ESMTP id 21A3D6B0032
	for <linux-mm@kvack.org>; Fri, 23 Jan 2015 10:58:11 -0500 (EST)
Received: by mail-we0-f171.google.com with SMTP id q58so999073wes.2
        for <linux-mm@kvack.org>; Fri, 23 Jan 2015 07:58:10 -0800 (PST)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id fx9si3357807wib.22.2015.01.23.07.58.08
        for <linux-mm@kvack.org>;
        Fri, 23 Jan 2015 07:58:09 -0800 (PST)
Date: Fri, 23 Jan 2015 17:58:02 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: incorporate read-only pages into transparent huge
 pages
Message-ID: <20150123155802.GA7011@node.dhcp.inet.fi>
References: <1421999256-3881-1-git-send-email-ebru.akagunduz@gmail.com>
 <20150123113701.GB5975@node.dhcp.inet.fi>
 <54C2613F.6080403@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54C2613F.6080403@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Ebru Akagunduz <ebru.akagunduz@gmail.com>, linux-mm@kvack.org, akpm@linux-foundation.org, mhocko@suse.cz, mgorman@suse.de, rientjes@google.com, sasha.levin@oracle.com, hughd@google.com, hannes@cmpxchg.org, vbabka@suse.cz, linux-kernel@vger.kernel.org, aarcange@redhat.com

On Fri, Jan 23, 2015 at 09:57:03AM -0500, Rik van Riel wrote:
> On 01/23/2015 06:37 AM, Kirill A. Shutemov wrote:
> > On Fri, Jan 23, 2015 at 09:47:36AM +0200, Ebru Akagunduz wrote:
> >> This patch aims to improve THP collapse rates, by allowing
> >> THP collapse in the presence of read-only ptes, like those
> >> left in place by do_swap_page after a read fault.
> >>
> >> Currently THP can collapse 4kB pages into a THP when
> >> there are up to khugepaged_max_ptes_none pte_none ptes
> >> in a 2MB range. This patch applies the same limit for
> >> read-only ptes.
> 
> >> @@ -2179,6 +2179,17 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
> >>  		 */
> >>  		if (!trylock_page(page))
> >>  			goto out;
> >> +		if (!pte_write(pteval)) {
> >> +			if (PageSwapCache(page) && !reuse_swap_page(page)) {
> >> +					unlock_page(page);
> >> +					goto out;
> >> +			}
> >> +			/*
> >> +			 * Page is not in the swap cache, and page count is
> >> +			 * one (see above). It can be collapsed into a THP.
> >> +			 */
> >> +		}
> > 
> > Hm. As a side effect it will effectevely allow collapse in PROT_READ vmas,
> > right? I'm not convinced it's a good idea.
> 
> It will only allow a THP collapse if there is at least one
> read-write pte.
> 
> I suspect that excludes read-only VMAs automatically.

Ah. Okay. I missed that condition.

Looks good to me.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
