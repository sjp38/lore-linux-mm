Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id B73246B0009
	for <linux-mm@kvack.org>; Tue,  2 Feb 2016 09:43:33 -0500 (EST)
Received: by mail-pf0-f173.google.com with SMTP id w123so13590936pfb.0
        for <linux-mm@kvack.org>; Tue, 02 Feb 2016 06:43:33 -0800 (PST)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com. [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id p11si2337912par.72.2016.02.02.06.43.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Feb 2016 06:43:32 -0800 (PST)
Received: by mail-pa0-x22a.google.com with SMTP id yy13so99932451pab.3
        for <linux-mm@kvack.org>; Tue, 02 Feb 2016 06:43:32 -0800 (PST)
Date: Tue, 2 Feb 2016 23:41:40 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [REGRESSION] [BISECTED] kswapd high CPU usage
Message-ID: <20160202144140.GA460@swordfish>
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
Cc: Hugh Greenberg <hugh@galliumos.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Seth Jennings <sjennings@variantweb.net>

On (02/02/16 15:59), Kirill A. Shutemov wrote:
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

[add Seth Jennings]


additional info: http://marc.info/?l=linux-mm&m=145373987224270
> The reports are coming from 2GB Haswell chromebooks. I have a 4GB haswell
> chromebook and I cannot reproduce the issue, even if I boot the kernel with
> 2GB or less.
>
> After more testing, we were still able to reproduce the issue. It seems to
> have taken longer to show up this time.


a small note,
I assume, IF min_free_kbytes must be set then probably in zsmalloc (zbud?)
init, not in zram. zswap can use both -- zsmalloc and zbud.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
