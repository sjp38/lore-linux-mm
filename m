Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 4C028828FD
	for <linux-mm@kvack.org>; Fri,  6 Feb 2015 00:51:19 -0500 (EST)
Received: by pdjy10 with SMTP id y10so12570850pdj.9
        for <linux-mm@kvack.org>; Thu, 05 Feb 2015 21:51:19 -0800 (PST)
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com. [209.85.192.182])
        by mx.google.com with ESMTPS id ko6si7931269pab.154.2015.02.05.21.51.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Feb 2015 21:51:17 -0800 (PST)
Received: by pdbft15 with SMTP id ft15so12597246pdb.11
        for <linux-mm@kvack.org>; Thu, 05 Feb 2015 21:51:17 -0800 (PST)
Date: Fri, 6 Feb 2015 14:51:03 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v17 1/7] mm: support madvise(MADV_FREE)
Message-ID: <20150206055103.GA13244@blaptop>
References: <20141127144725.GB19157@dhcp22.suse.cz>
 <20141130235652.GA10333@bbox>
 <20141202100125.GD27014@dhcp22.suse.cz>
 <20141203000026.GA30217@bbox>
 <20141203101329.GB23236@dhcp22.suse.cz>
 <20141205070816.GB3358@bbox>
 <20141205083249.GA2321@dhcp22.suse.cz>
 <54D0F9BC.4060306@gmail.com>
 <20150203234722.GB3583@blaptop>
 <20150206003311.GA2347@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150206003311.GA2347@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Jason Evans <je@fb.com>, zhangyanfei@cn.fujitsu.com, "Kirill A. Shutemov" <kirill@shutemov.name>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Hi Shaohua,

On Thu, Feb 05, 2015 at 04:33:11PM -0800, Shaohua Li wrote:
> 
> Hi Minchan,
> 
> Sorry to jump in this thread so later, and if some issues are discussed before.
> I'm interesting in this patch, so tried it here. I use a simple test with

No problem at all. Interest is always win over ignorance.

> jemalloc. Obviously this can improve performance when there is no memory
> pressure. Did you try setup with memory pressure?

Sure but it was not a huge memory system like yours.

> 
> In my test, jemalloc will map 61G vma, and use about 32G memory without
> MADV_FREE. If MADV_FREE is enabled, jemalloc will use whole 61G memory because
> madvise doesn't reclaim the unused memory. If I disable swap (tweak your patch

Yes, IIUC, jemalloc replaces MADV_DONTNEED with MADV_FREE completely.

> slightly to make it work without swap), I got oom. If swap is enabled, my

You mean you modified anon aging logic so it works although there is no swap?
If so, I have no idea why OOM happens. I guess it should free all of freeable
pages during the aging so although system stall happens more, I don't expect
OOM. Anyway, with MADV_FREE with no swap, we should consider more things
about anonymous aging.

> system is totally stalled because of swap activity. Without the MADV_FREE,
> everything is ok. Considering we definitely don't want to waste too much
> memory, a system with memory pressure is normal, so sounds MADV_FREE will
> introduce big trouble here.
> 
> Did you think about move the MADV_FREE pages to the head of inactive LRU, so
> they can be reclaimed easily?

I think it's desirable if the page lived in active LRU.
The reason I didn't that was caused by volatile ranges system call which
was motivaion for MADV_FREE in my mind.
In last LSF/MM, there was concern about data's hotness.
Some of users want to keep that as it is in LRU position, others want to
handle that as cold(tail of inactive list)/warm(head of inactive list)/
hot(head of active list), for example.
The vrange syscall was just about volatiltiy, not depends on page hotness
so the decision on my head was not to change LRU order and let's make new
hotness advise if we need it later.

However, MADV_FREE's main customer is allocators and afaik, they want
to replace MADV_DONTNEED with MADV_FREE so I think it is really cold,
but we couldn't make sure so head of inactive is good compromise.
Another concern about tail of inactive list is that there could be
plenty of pages in there, which was asynchromos write-backed in
previous reclaim path, not-yet reclaimed because of not being able
to free the in softirq context of writeback. It means we ends up
freeing more potential pages to become workingset in advance
than pages VM already decided to evict.

In summary, I like your suggestion.

Thanks.

> 
> Thanks,
> Shaohua
> 
> On Wed, Feb 04, 2015 at 08:47:22AM +0900, Minchan Kim wrote:
> > Hello, Michael
> > 
> > On Tue, Feb 03, 2015 at 05:39:24PM +0100, Michael Kerrisk (man-pages) wrote:
> > > Hello Minchan (and Michal)
> > > 
> > > I did not see this patch until just now when Michael explicitly
> > > mentioned it in another discussion because
> > > (a) it was buried in an LMKL thread that started a topic
> > >     that was not about a man-pages patch.
> > > (b) linux-man@ was not CCed.
> > 
> > Sorry about that.
> > 
> > > 
> > > When resubmitting this patch, could you please To:me and CC linux-man@
> > > and give the mail a suitable subject line indicating a man-pages patch.
> > 
> > Sure.
> > 
> > > 
> > > On 12/05/2014 09:32 AM, Michal Hocko wrote:
> > > > On Fri 05-12-14 16:08:16, Minchan Kim wrote:
> > > > [...]
> > > >> From cfa212d4fb307ae772b08cf564cab7e6adb8f4fc Mon Sep 17 00:00:00 2001
> > > >> From: Minchan Kim <minchan@kernel.org>
> > > >> Date: Mon, 1 Dec 2014 08:53:55 +0900
> > > >> Subject: [PATCH] madvise.2: Document MADV_FREE
> > > >>
> > > >> Signed-off-by: Minchan Kim <minchan@kernel.org>
> > > > 
> > > > Reviewed-by: Michal Hocko <mhocko@suse.cz>
> > > > 
> > > > Thanks!
> > > > 
> > > >> ---
> > > >>  man2/madvise.2 | 12 ++++++++++++
> > > >>  1 file changed, 12 insertions(+)
> > > >>
> > > >> diff --git a/man2/madvise.2 b/man2/madvise.2
> > > >> index 032ead7..fc1aaca 100644
> > > >> --- a/man2/madvise.2
> > > >> +++ b/man2/madvise.2
> > > >> @@ -265,6 +265,18 @@ file (see
> > > >>  .BR MADV_DODUMP " (since Linux 3.4)"
> > > >>  Undo the effect of an earlier
> > > >>  .BR MADV_DONTDUMP .
> > > >> +.TP
> > > >> +.BR MADV_FREE " (since Linux 3.19)"
> > > >> +Tell the kernel that contents in the specified address range are no
> > > >> +longer important and the range will be overwritten. When there is
> > > >> +demand for memory, the system will free pages associated with the
> > > >> +specified address range. In this instance, the next time a page in the
> > > >> +address range is referenced, it will contain all zeroes.  Otherwise,
> > > >> +it will contain the data that was there prior to the MADV_FREE call.
> > > >> +References made to the address range will not make the system read
> > > >> +from backing store (swap space) until the page is modified again.
> > > >> +It works only with private anonymous pages (see
> > > >> +.BR mmap (2)).
> > > >>  .SH RETURN VALUE
> > > >>  On success
> > > >>  .BR madvise ()
> > > 
> > > If I'm reading the conversation right, the initially proposed text 
> > > was from the BSD man page (which would be okay), but most of the 
> > > text above seems  to have come straight from the page here:
> > > http://www.lehman.cuny.edu/cgi-bin/man-cgi?madvise+3
> > > 
> > > Right?
> > 
> > True. Solaris man page was really straightforward/clear rather than BSD.
> > 
> > > 
> > > Unfortunately, I don't think we can use that text. It's from the 
> > > Solaris man page as far as I can tell, and I doubt that it's 
> > > under a license that we can use.
> > > 
> > > If that's the case, we need to go back and come up with an
> > > original text. It might draw inspiration from the Solaris page,
> > > and take actual text from the BSD page (which is under a free
> > > license), and it might also draw inspiration from Jon Corbet's 
> > > description at http://lwn.net/Articles/590991/. 
> > > 
> > > Could you take another shot this please!
> > 
> > No problem. I will test my essay writing skill.
> > Thanks. 
> > 
> > > 
> > > Thanks,
> > > 
> > > Michael
> > > 
> > > 
> > > 
> > > -- 
> > > Michael Kerrisk
> > > Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
> > > Linux/UNIX System Programming Training: http://man7.org/training/
> > 
> > -- 
> > Kind regards,
> > Minchan Kim
> > 
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
