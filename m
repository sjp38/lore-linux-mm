Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id EDE486B005C
	for <linux-mm@kvack.org>; Sun,  3 Jun 2012 18:18:04 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so6654209pbb.14
        for <linux-mm@kvack.org>; Sun, 03 Jun 2012 15:18:04 -0700 (PDT)
Date: Sun, 3 Jun 2012 15:17:36 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: WARNING: at mm/page-writeback.c:1990
 __set_page_dirty_nobuffers+0x13a/0x170()
In-Reply-To: <20120603205332.GA5412@redhat.com>
Message-ID: <alpine.LSU.2.00.1206031459450.15427@eggly.anvils>
References: <20120601023107.GA19445@redhat.com> <alpine.LSU.2.00.1206010030050.8462@eggly.anvils> <20120601161205.GA1918@redhat.com> <20120601171606.GA3794@redhat.com> <alpine.LSU.2.00.1206011511560.12839@eggly.anvils> <CA+55aFy2-X92EqpiuyvkBp_2-UaYDUpaC2c3XT3gXMN1O+T7sw@mail.gmail.com>
 <alpine.LSU.2.00.1206012108430.11308@eggly.anvils> <20120603181548.GA306@redhat.com> <CA+55aFwZ5PsBLqM7K8vDQdbS3sf+vi3yeoWx6XKV=nF8k2r7DQ@mail.gmail.com> <20120603183139.GA1061@redhat.com> <20120603205332.GA5412@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Cong Wang <amwang@redhat.com>, Markus Trippelsdorf <markus@trippelsdorf.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun, 3 Jun 2012, Dave Jones wrote:
> On Sun, Jun 03, 2012 at 02:31:39PM -0400, Dave Jones wrote:
>  > On Sun, Jun 03, 2012 at 11:23:29AM -0700, Linus Torvalds wrote:
>  >  > On Sun, Jun 3, 2012 at 11:15 AM, Dave Jones <davej@redhat.com> wrote:
>  >  > >
>  >  > > Things aren't happy with that patch at all.
>  >  > 
>  >  > Yeah, at this point I think we need to just revert the compaction changes.
>  >  > 
>  >  > Guys, what's the minimal set of commits to revert? That clearly buggy
>  >  > "rescue_unmovable_pageblock()" function was introduced by commit
>  >  > 5ceb9ce6fe94, but is that actually involved with the particular bug?
>  >  > That commit seems to revert cleanly still, but is that sufficient or
>  >  > does it even matter?
>  > 
>  > I'l rerun the test with that (and Hugh's last patch) backed out, and see
>  > if that makes any difference.
> 
> running just over two hours with that commit reverted with no obvious ill effects so far.

Yes, and I ran happily with precisely that commit reverted on Friday -
though I've never got the list corruption that you saw with it in.  

The locking bug certainly comes in with that commit, it's an isolated
commit that reverts cleanly, and I think you got the list corruption
rather sooner than two hours before (9min, 30min, 41min from the traces
you sent).

Maybe we should let you run a little longer, or wait for others to comment.

But another strike against that commit: I tried fixing it up to use
start_page instead of page at the end, with the worrying but safer
locking I suggested at first, with a count of how many times it went
there, and how many times it succeeded.

While I ran my usual swapping test (perhaps that's a very unfair test
to run on this, I've no idea) for seven hours, it went there 25406
times (once per second, it appears) and it succeeded... 0 times.

Let's hope it failed quickly each time, I wasn't capturing that.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
