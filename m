Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 2008F6B0069
	for <linux-mm@kvack.org>; Thu, 17 Nov 2011 20:42:09 -0500 (EST)
Received: by vcbfo1 with SMTP id fo1so2114181vcb.14
        for <linux-mm@kvack.org>; Thu, 17 Nov 2011 17:42:05 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20111117184252.GK3306@redhat.com>
References: <20111104235603.GT18879@redhat.com>
	<CAPQyPG5i87VcnwU5UoKiT6_=tzqO_NOPXFvyEooA1Orbe_ztGQ@mail.gmail.com>
	<20111105013317.GU18879@redhat.com>
	<CAPQyPG5Y1e2dac38OLwZAinWb6xpPMWCya2vTaWLPi9+vp1JXQ@mail.gmail.com>
	<20111107131413.GA18279@suse.de>
	<20111107154235.GE3249@redhat.com>
	<20111107162808.GA3083@suse.de>
	<20111109012542.GC5075@redhat.com>
	<20111116140042.GD3306@redhat.com>
	<alpine.LSU.2.00.1111161540060.1861@sister.anvils>
	<20111117184252.GK3306@redhat.com>
Date: Fri, 18 Nov 2011 09:42:05 +0800
Message-ID: <CAPQyPG7MvO8Qw3jrOMShQcG5Z-RwbzpKnu-AheoS6aRYNhW14w@mail.gmail.com>
Subject: Re: [PATCH] mremap: enforce rmap src/dst vma ordering in case of
 vma_merge succeeding in copy_vma
From: Nai Xia <nai.xia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Pawel Sikora <pluto@agmk.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, jpiszcz@lucidpixels.com, arekm@pld-linux.org, linux-kernel@vger.kernel.org

On Fri, Nov 18, 2011 at 2:42 AM, Andrea Arcangeli <aarcange@redhat.com> wrote:
> Hi Hugh,
>
> On Wed, Nov 16, 2011 at 04:16:57PM -0800, Hugh Dickins wrote:
>> As you found, the mremap locking long predates truncation's double unmap.
>>
>> That's an interesting point, and you may be right - though, what about
>> the *very* unlikely case where unmap_mapping_range looks at new vma
>> when pte is in old, then at old vma when pte is in new, then
>> move_page_tables runs out of memory and cannot complete, then the
>> second unmap_mapping_range looks at old vma while pte is still in new
>> (I guess this needs some other activity to have jumbled the prio_tree,
>> and may just be impossible), then at new (to be abandoned) vma after
>> pte has moved back to old.
>
> I tend to think it should still work fine. The second loop is needed
> to take care of the "reverse" order. If the first move_page_tables is
> not in order the second move_page_tables will be in order. So it
> should catch it. If the first move_page_tables is in order, the double
> loop will catch any skip in the second move_page_tables.


First of all, I believe that at the POSIX level, it's ok for
truncate_inode_page()
not scanning  COWed pages, since basically we does not provide any guarantee
for privately mapped file pages for this behavior. But missing a file
mapped pte after its
cache page is already removed from the the page cache is a
fundermental malfuntion for
a shared mapping when some threads see the file cache page is gone
while some thread
is still r/w from/to it! No matter how short the gap between
truncate_inode_page() and
the second loop, this is wrong.

Second, even if the we don't care about this POSIX flaw that may
introduce, a pte can still
missed by the second loop. mremap can happen serveral times during
these non-atomic
firstpass-trunc-secondpass operations, a proper events can happily
make the wrong order
for every scan, and miss them all -- That's just what in Hugh's mind
in the post you just
replied. Without lock and proper ordering( which patial mremap cannot provide),
this *will* happen.

You may disagree with me and have that locking removed, and I am
already have that
one line patch prepared waiting fora bug bumpping up again, what a
cheap patch submission!

:P


Thanks,

Nai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
