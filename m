Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id DB44F6B004D
	for <linux-mm@kvack.org>; Sat,  2 Jun 2012 00:59:17 -0400 (EDT)
Received: by wefh52 with SMTP id h52so2365370wef.14
        for <linux-mm@kvack.org>; Fri, 01 Jun 2012 21:59:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1206012108430.11308@eggly.anvils>
References: <20120530163317.GA13189@redhat.com> <20120531005739.GA4532@redhat.com>
 <20120601023107.GA19445@redhat.com> <alpine.LSU.2.00.1206010030050.8462@eggly.anvils>
 <20120601161205.GA1918@redhat.com> <20120601171606.GA3794@redhat.com>
 <alpine.LSU.2.00.1206011511560.12839@eggly.anvils> <CA+55aFy2-X92EqpiuyvkBp_2-UaYDUpaC2c3XT3gXMN1O+T7sw@mail.gmail.com>
 <alpine.LSU.2.00.1206012108430.11308@eggly.anvils>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 1 Jun 2012 21:58:50 -0700
Message-ID: <CA+55aFytGfGm2mmF-9BwjqiDCtNpz40AkQrmGOqduss2YAiEvQ@mail.gmail.com>
Subject: Re: WARNING: at mm/page-writeback.c:1990 __set_page_dirty_nobuffers+0x13a/0x170()
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Cong Wang <amwang@redhat.com>, Markus Trippelsdorf <markus@trippelsdorf.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Jun 1, 2012 at 9:40 PM, Hugh Dickins <hughd@google.com> wrote:
>
> Move the lock after the loop, I think you meant.

Well, I wasn't sure if anything inside the loop might need it. I don't
*think* so, but at the same time, what protects "page_order(page)"
(or, indeed PageBuddy()) from being stable while that loop content
uses them?

I don't understand that code at all. It does that crazy iteration over
page, and changes "page" in random ways, and then finishes up with a
totally new "page" value that is some random thing that is *after* the
end_page thing. WHAT?

The code makes no sense. It tests all those pages within the
page-block, but then after it has done all those tests, it does the
final

  set_pageblock_migratetype(..)
  move_freepages_block(..)

using a page that is *beyond* the pageblock (and with the whole
page_order() thing, who knows just how far beyond it?)

It looks entirely too much like random-monkey code to me.

            Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
