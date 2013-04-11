Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id C20196B0005
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 05:09:14 -0400 (EDT)
Date: Thu, 11 Apr 2013 10:09:09 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 02/10] mm: vmscan: Obey proportional scanning
 requirements for kswapd
Message-ID: <20130411090909.GF3710@suse.de>
References: <1365505625-9460-1-git-send-email-mgorman@suse.de>
 <1365505625-9460-3-git-send-email-mgorman@suse.de>
 <516511DF.5020805@jp.fujitsu.com>
 <20130410140824.GC3710@suse.de>
 <5166005B.3060607@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <5166005B.3060607@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Apr 11, 2013 at 09:14:19AM +0900, Kamezawa Hiroyuki wrote:
> >
> >nr[lru] at the end there is pages remaining to be scanned not pages
> >scanned already.
> 
> yes.
> 
> >Did you mean something like this?
> >
> >nr[lru] = scantarget[lru] * percentage / 100 - (scantarget[lru] - nr[lru])
> >
> 
> For clarification, this "percentage" means the ratio of remaining scan target of
> another LRU. So, *scanned* percentage is "100 - percentage", right ?
> 

Yes, correct.

> If I understand the changelog correctly, you'd like to keep
> 
>    scantarget[anon] : scantarget[file]
>    == really_scanned_num[anon] : really_scanned_num[file]
> 

Yes.

> even if we stop scanning in the middle of scantarget. And you introduced "percentage"
> to make sure that both scantarget should be done in the same ratio.
> 

Yes.

> So...another lru should scan  scantarget[x] * (100 - percentage)/100 in total.
> 
> nr[lru] = scantarget[lru] * (100 - percentage)/100 - (scantarget[lru] - nr[lru])
>           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^    ^^^^^^^^^^^^^^^^^^^^^^^^^
>              proportionally adjusted scan target        already scanned num
> 
>        =  nr[lru] - scantarget[lru] * percentage/100.
> 

Yes, you are completely correct. This preserves the original ratio of
anon:file scanning properly.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
