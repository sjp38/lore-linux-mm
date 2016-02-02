Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f176.google.com (mail-io0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id 410696B0009
	for <linux-mm@kvack.org>; Tue,  2 Feb 2016 11:24:30 -0500 (EST)
Received: by mail-io0-f176.google.com with SMTP id g73so22908938ioe.3
        for <linux-mm@kvack.org>; Tue, 02 Feb 2016 08:24:30 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTPS id p9si5580147ioe.174.2016.02.02.08.24.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 02 Feb 2016 08:24:29 -0800 (PST)
Date: Wed, 3 Feb 2016 01:24:27 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [REGRESSION] [BISECTED] kswapd high CPU usage
Message-ID: <20160202162427.GA21239@bbox>
References: <CAPKbV49wfVWqwdgNu9xBnXju-4704t2QF97C+6t3aff_8bVbdA@mail.gmail.com>
 <20160121161656.GA16564@node.shutemov.name>
 <loom.20160123T165232-709@post.gmane.org>
 <20160125103853.GD11095@node.shutemov.name>
 <loom.20160125T174557-678@post.gmane.org>
 <20160202135950.GA5026@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160202135950.GA5026@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Hugh Greenberg <hugh@galliumos.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@redhat.com>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Tue, Feb 02, 2016 at 03:59:50PM +0200, Kirill A. Shutemov wrote:
> On Mon, Jan 25, 2016 at 04:46:58PM +0000, Hugh Greenberg wrote:
> > Kirill A. Shutemov <kirill <at> shutemov.name> writes:
> > 
> > > 
> > > On Sat, Jan 23, 2016 at 03:57:21PM +0000, Hugh Greenberg wrote:
> > > > Kirill A. Shutemov <kirill <at> shutemov.name> writes:
> > > > > 
> > > > > Could you try to insert 
> > "late_initcall(set_recommended_min_free_kbytes);"
> > > > > back and check if makes any difference.
> > > > > 
> > > > 
> > > > We tested adding late_initcall(set_recommended_min_free_kbytes); 
> > > > back in 4.1.14 and it made a huge difference. We aren't sure if the
> > > > issue is 100% fixed, but it could be. We will keep testing it.
> > > 
> > > It would be nice to have values of min_free_kbytes before and after
> > > set_recommended_min_free_kbytes() in your configuration.
> > > 
> > 
> > Before adding set_recommended_min_free_kbytes: 5391
> > After: 67584
> 
> [ add more people to the thread ]
> 
> The 'before' value look low to me for machine with 2G of RAM.
> 
> In the bugzilla[1], you've mentioned zram. I wounder if we need to
> increase min_free_kbytes when zram is in use as we do for THP.
> 
> [1] https://bugzilla.kernel.org/show_bug.cgi?id=110501

Normally, it's recommended to increate min_free_kbytes when zram is
used for swap because zram should allocate a page in reclaim path
dynamically to keep compressed page.

However, when I read bugzilla's perf profile, I can't find
any zram related things and if there is lack of free memory for
zram page allocation due to changing min_free_kbytes, user will see
below error message.

pr_err("Error allocating memory for compressed page: %u, size=%zu\n"

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
