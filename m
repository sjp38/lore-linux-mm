Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E56536B016A
	for <linux-mm@kvack.org>; Fri, 26 Aug 2011 15:28:17 -0400 (EDT)
Date: Fri, 26 Aug 2011 21:28:10 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] thp: tail page refcounting fix #2
Message-ID: <20110826192810.GA6439@redhat.com>
References: <1313740111-27446-1-git-send-email-walken@google.com>
 <20110822213347.GF2507@redhat.com>
 <CANN689HE=TKyr-0yDQgXEoothGJ0Cw0HLB2iOvCKrOXVF2DNww@mail.gmail.com>
 <20110824000914.GH23870@redhat.com>
 <20110824002717.GI23870@redhat.com>
 <20110824133459.GP23870@redhat.com>
 <20110826062436.GA5847@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110826062436.GA5847@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Thu, Aug 25, 2011 at 11:24:36PM -0700, Michel Lespinasse wrote:
> In __get_page_tail(), you could add a VM_BUG_ON(page_mapcount(page) <= 0)
> to reflect the fact that get_page() callers are expected to have already
> gotten a reference on the page through a gup call.

Turns out this is going to generate false positives. For THP it should
have been always ok, but if you allocate a compound page (that can't
be splitted) and then map it on 4k pagetables and doing
get_page/put_page in the map/unmap of the pte, it'll fail because the
page fault will be the first occurrence where the tail page refcount
is elevated. I'll check it in more detail tomorrow... So you may want
to delete the bugcheck above before testing #3.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
