Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id F398D60021B
	for <linux-mm@kvack.org>; Wed,  9 Dec 2009 11:12:24 -0500 (EST)
Date: Wed, 9 Dec 2009 17:12:19 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 2/9] ksm: let shared pages be swappable
Message-ID: <20091209161219.GV28697@random.random>
References: <20091202125501.GD28697@random.random>
 <20091203134610.586E.A69D9226@jp.fujitsu.com>
 <20091204135938.5886.A69D9226@jp.fujitsu.com>
 <20091204141617.f4c491e7.kamezawa.hiroyu@jp.fujitsu.com>
 <20091204171640.GE19624@x200.localdomain>
 <20091209094331.a1f53e6d.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091209094331.a1f53e6d.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Chris Wright <chrisw@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Dec 09, 2009 at 09:43:31AM +0900, KAMEZAWA Hiroyuki wrote:
> cache-line ping-pong at fork beacause of page->mapcount. And KSM introduces
> zero-pages which have mapcount again. If no problems in realitsitc usage of
> KVM, ignore me.

The whole memory marked MADV_MERGEABLE by KVM is also marked
MADV_DONTFORK, so if KVM was to fork (and if it did, if it wasn't for
MADV_DONTFORK, it would also trigger all O_DIRECT vs fork race
conditions too, as KVM is one of the many apps that uses threads and
O_DIRECT - we try not to fork though but we sure did in the past), no
slowdown could ever happen in mapcount because of KSM, all KSM pages
aren't visibile by child.

It's still something to keep in mind for other KSM users, but I don't
think mapcount is big deal if compared to the risk of triggering COWs
later on those pages, in general KSM is all about saving tons of
memory at the expense of some CPU cycle (kksmd, cows, mapcount with
parallel forks etc...).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
