Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B7C626B004D
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 15:22:42 -0400 (EDT)
Date: Wed, 28 Oct 2009 20:22:33 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: RFC: Transparent Hugepage support
Message-ID: <20091028192233.GI9640@random.random>
References: <87ljiwk8el.fsf@basil.nowhere.org>
 <20091027193007.GA6043@random.random>
 <20091028042805.GJ7744@basil.fritz.box>
 <20091028120050.GD9640@random.random>
 <20091028141803.GQ7744@basil.fritz.box>
 <20091028154827.GF9640@random.random>
 <20091028160352.GS7744@basil.fritz.box>
 <20091028162206.GG9640@random.random>
 <20091028163458.GT7744@basil.fritz.box>
 <20091028190459.GH9640@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091028190459.GH9640@random.random>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> > Can always schedule and check for signals during the copy.
> 
> same is true for split_huge_page... if copy_page can work on a 1G page
> then we could even split it at the pte level, but frankly I think it
> would be a better fit to split the pud at the pmd level only without
> having to go down to the pte.

Note checking for signals is not enough, and even if it was enough we
would need to rollback from the middle and it's an huge
complexity... If it was so easy copy_huge_page in hugetlb.c would be
doing it too (I mean checking for signals, obviously it
doesn't... :). It already results in livelocks, I just recently had
bugreports about it and not easy to fix (they had not to cow to avoid
the livelock). And they were about 256M pages!!!! Not 1G
pages... ;). 256M already livelocks the application if one has to cow
256M and access 512M (not 2G!!) in a fault. Last but not the least
when cpus will be fast enough to execute copy_page(1G) as fast as it
does now copy_page(2M) we'll be running linux with PAGE_SIZE = 2M in
the first place...

Overall I liked to evaluate the feasibility of pud_trans_huge, and
discuss about it because one can never know somebody may have petabyte
of memory and slow enough cpu to require 4k page, but the notion of
providing transparent gigapages at the time being is absurd no matter
what design or implementation, hugetlbfs is as good as it can be for
it I think.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
