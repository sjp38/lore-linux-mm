Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 890966B0031
	for <linux-mm@kvack.org>; Tue, 17 Jun 2014 03:24:22 -0400 (EDT)
Received: by mail-wi0-f181.google.com with SMTP id n3so5237422wiv.2
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 00:24:21 -0700 (PDT)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.198])
        by mx.google.com with ESMTP id i9si22693622wjr.31.2014.06.17.00.24.20
        for <linux-mm@kvack.org>;
        Tue, 17 Jun 2014 00:24:21 -0700 (PDT)
Date: Tue, 17 Jun 2014 10:23:37 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm, thp: move invariant bug check out of loop in
 __split_huge_page_map
Message-ID: <20140617072337.GA19715@node.dhcp.inet.fi>
References: <1402947348-60655-1-git-send-email-Waiman.Long@hp.com>
 <20140616204934.GA14208@node.dhcp.inet.fi>
 <20140616205946.GB14208@node.dhcp.inet.fi>
 <539FB9E6.2030601@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <539FB9E6.2030601@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <waiman.long@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Scott J Norton <scott.norton@hp.com>

On Mon, Jun 16, 2014 at 11:45:42PM -0400, Waiman Long wrote:
> On 06/16/2014 04:59 PM, Kirill A. Shutemov wrote:
> >On Mon, Jun 16, 2014 at 11:49:34PM +0300, Kirill A. Shutemov wrote:
> >>On Mon, Jun 16, 2014 at 03:35:48PM -0400, Waiman Long wrote:
> >>>In the __split_huge_page_map() function, the check for
> >>>page_mapcount(page) is invariant within the for loop. Because of the
> >>>fact that the macro is implemented using atomic_read(), the redundant
> >>>check cannot be optimized away by the compiler leading to unnecessary
> >>>read to the page structure.
> >And atomic_read() is *not* atomic operation. It's implemented as
> >dereferencing though cast to volatile, which suppress compiler
> >optimization, but doesn't affect what CPU can do with the variable.
> >
> >So I doubt difference will be measurable anywhere.
> >
> 
> Because it is treated as an volatile object, the compiler will have to
> reread the value of the relevant page structure field in every iteration of
> the loop (512 for x86) when pmd_write(*pmd) is true. I saw some slight
> improvement (about 2%) of a microbench that I wrote to break up 1000 THPs
> with 1000 forked processes.

Then bring patch with performance data.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
