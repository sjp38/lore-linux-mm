Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 28173828FD
	for <linux-mm@kvack.org>; Thu,  5 Feb 2015 19:33:22 -0500 (EST)
Received: by pdjz10 with SMTP id z10so10992226pdj.13
        for <linux-mm@kvack.org>; Thu, 05 Feb 2015 16:33:21 -0800 (PST)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com. [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id bd2si8267366pbc.44.2015.02.05.16.33.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Feb 2015 16:33:17 -0800 (PST)
Received: by mail-pa0-f48.google.com with SMTP id ey11so13368379pad.7
        for <linux-mm@kvack.org>; Thu, 05 Feb 2015 16:33:16 -0800 (PST)
Date: Thu, 5 Feb 2015 16:33:11 -0800
From: Shaohua Li <shli@kernel.org>
Subject: Re: [PATCH v17 1/7] mm: support madvise(MADV_FREE)
Message-ID: <20150206003311.GA2347@kernel.org>
References: <1413799924-17946-2-git-send-email-minchan@kernel.org>
 <20141127144725.GB19157@dhcp22.suse.cz>
 <20141130235652.GA10333@bbox>
 <20141202100125.GD27014@dhcp22.suse.cz>
 <20141203000026.GA30217@bbox>
 <20141203101329.GB23236@dhcp22.suse.cz>
 <20141205070816.GB3358@bbox>
 <20141205083249.GA2321@dhcp22.suse.cz>
 <54D0F9BC.4060306@gmail.com>
 <20150203234722.GB3583@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150203234722.GB3583@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Jason Evans <je@fb.com>, zhangyanfei@cn.fujitsu.com, "Kirill A. Shutemov" <kirill@shutemov.name>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>


Hi Minchan,

Sorry to jump in this thread so later, and if some issues are discussed before.
I'm interesting in this patch, so tried it here. I use a simple test with
jemalloc. Obviously this can improve performance when there is no memory
pressure. Did you try setup with memory pressure?

In my test, jemalloc will map 61G vma, and use about 32G memory without
MADV_FREE. If MADV_FREE is enabled, jemalloc will use whole 61G memory because
madvise doesn't reclaim the unused memory. If I disable swap (tweak your patch
slightly to make it work without swap), I got oom. If swap is enabled, my
system is totally stalled because of swap activity. Without the MADV_FREE,
everything is ok. Considering we definitely don't want to waste too much
memory, a system with memory pressure is normal, so sounds MADV_FREE will
introduce big trouble here.

Did you think about move the MADV_FREE pages to the head of inactive LRU, so
they can be reclaimed easily?

Thanks,
Shaohua

On Wed, Feb 04, 2015 at 08:47:22AM +0900, Minchan Kim wrote:
> Hello, Michael
> 
> On Tue, Feb 03, 2015 at 05:39:24PM +0100, Michael Kerrisk (man-pages) wrote:
> > Hello Minchan (and Michal)
> > 
> > I did not see this patch until just now when Michael explicitly
> > mentioned it in another discussion because
> > (a) it was buried in an LMKL thread that started a topic
> >     that was not about a man-pages patch.
> > (b) linux-man@ was not CCed.
> 
> Sorry about that.
> 
> > 
> > When resubmitting this patch, could you please To:me and CC linux-man@
> > and give the mail a suitable subject line indicating a man-pages patch.
> 
> Sure.
> 
> > 
> > On 12/05/2014 09:32 AM, Michal Hocko wrote:
> > > On Fri 05-12-14 16:08:16, Minchan Kim wrote:
> > > [...]
> > >> From cfa212d4fb307ae772b08cf564cab7e6adb8f4fc Mon Sep 17 00:00:00 2001
> > >> From: Minchan Kim <minchan@kernel.org>
> > >> Date: Mon, 1 Dec 2014 08:53:55 +0900
> > >> Subject: [PATCH] madvise.2: Document MADV_FREE
> > >>
> > >> Signed-off-by: Minchan Kim <minchan@kernel.org>
> > > 
> > > Reviewed-by: Michal Hocko <mhocko@suse.cz>
> > > 
> > > Thanks!
> > > 
> > >> ---
> > >>  man2/madvise.2 | 12 ++++++++++++
> > >>  1 file changed, 12 insertions(+)
> > >>
> > >> diff --git a/man2/madvise.2 b/man2/madvise.2
> > >> index 032ead7..fc1aaca 100644
> > >> --- a/man2/madvise.2
> > >> +++ b/man2/madvise.2
> > >> @@ -265,6 +265,18 @@ file (see
> > >>  .BR MADV_DODUMP " (since Linux 3.4)"
> > >>  Undo the effect of an earlier
> > >>  .BR MADV_DONTDUMP .
> > >> +.TP
> > >> +.BR MADV_FREE " (since Linux 3.19)"
> > >> +Tell the kernel that contents in the specified address range are no
> > >> +longer important and the range will be overwritten. When there is
> > >> +demand for memory, the system will free pages associated with the
> > >> +specified address range. In this instance, the next time a page in the
> > >> +address range is referenced, it will contain all zeroes.  Otherwise,
> > >> +it will contain the data that was there prior to the MADV_FREE call.
> > >> +References made to the address range will not make the system read
> > >> +from backing store (swap space) until the page is modified again.
> > >> +It works only with private anonymous pages (see
> > >> +.BR mmap (2)).
> > >>  .SH RETURN VALUE
> > >>  On success
> > >>  .BR madvise ()
> > 
> > If I'm reading the conversation right, the initially proposed text 
> > was from the BSD man page (which would be okay), but most of the 
> > text above seems  to have come straight from the page here:
> > http://www.lehman.cuny.edu/cgi-bin/man-cgi?madvise+3
> > 
> > Right?
> 
> True. Solaris man page was really straightforward/clear rather than BSD.
> 
> > 
> > Unfortunately, I don't think we can use that text. It's from the 
> > Solaris man page as far as I can tell, and I doubt that it's 
> > under a license that we can use.
> > 
> > If that's the case, we need to go back and come up with an
> > original text. It might draw inspiration from the Solaris page,
> > and take actual text from the BSD page (which is under a free
> > license), and it might also draw inspiration from Jon Corbet's 
> > description at http://lwn.net/Articles/590991/. 
> > 
> > Could you take another shot this please!
> 
> No problem. I will test my essay writing skill.
> Thanks. 
> 
> > 
> > Thanks,
> > 
> > Michael
> > 
> > 
> > 
> > -- 
> > Michael Kerrisk
> > Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
> > Linux/UNIX System Programming Training: http://man7.org/training/
> 
> -- 
> Kind regards,
> Minchan Kim
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
