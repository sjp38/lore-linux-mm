Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E90816B025E
	for <linux-mm@kvack.org>; Sun,  4 Sep 2016 22:18:55 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id v67so179190059pfv.1
        for <linux-mm@kvack.org>; Sun, 04 Sep 2016 19:18:55 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id w27si26516940pfi.135.2016.09.04.19.18.54
        for <linux-mm@kvack.org>;
        Sun, 04 Sep 2016 19:18:55 -0700 (PDT)
Date: Mon, 5 Sep 2016 11:18:52 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC 0/4] ZRAM: make it just store the high compression rate page
Message-ID: <20160905021852.GB22701@bbox>
References: <1471854309-30414-1-git-send-email-zhuhui@xiaomi.com>
 <20160825060957.GA568@swordfish>
 <CANFwon3aXLz=EOdsArS5Ou4pMTr6nFuHfW1UKV6WGnCYNWk1kg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANFwon3aXLz=EOdsArS5Ou4pMTr6nFuHfW1UKV6WGnCYNWk1kg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hui Zhu <teawater@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, ngupta@vflare.org, Hugh Dickins <hughd@google.com>, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, acme@kernel.org, alexander.shishkin@linux.intel.com, Andrew Morton <akpm@linux-foundation.org>, mhocko@suse.com, hannes@cmpxchg.org, mgorman@techsingularity.net, vbabka@suse.cz, redkoi@virtuozzo.com, luto@kernel.org, kirill.shutemov@linux.intel.com, geliangtang@163.com, baiyaowei@cmss.chinamobile.com, dan.j.williams@intel.com, vdavydov@virtuozzo.com, aarcange@redhat.com, dvlasenk@redhat.com, jmarchan@redhat.com, koct9i@gmail.com, yang.shi@linaro.org, dave.hansen@linux.intel.com, vkuznets@redhat.com, vitalywool@gmail.com, ross.zwisler@linux.intel.com, Thomas Gleixner <tglx@linutronix.de>, kwapulinski.piotr@gmail.com, axboe@fb.com, mchristi@redhat.com, Joe Perches <joe@perches.com>, namit@vmware.com, Rik van Riel <riel@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Thu, Aug 25, 2016 at 04:25:30PM +0800, Hui Zhu wrote:
> On Thu, Aug 25, 2016 at 2:09 PM, Sergey Senozhatsky
> <sergey.senozhatsky.work@gmail.com> wrote:
> > Hello,
> >
> > On (08/22/16 16:25), Hui Zhu wrote:
> >>
> >> Current ZRAM just can store all pages even if the compression rate
> >> of a page is really low.  So the compression rate of ZRAM is out of
> >> control when it is running.
> >> In my part, I did some test and record with ZRAM.  The compression rate
> >> is about 40%.
> >>
> >> This series of patches make ZRAM can just store the page that the
> >> compressed size is smaller than a value.
> >> With these patches, I set the value to 2048 and did the same test with
> >> before.  The compression rate is about 20%.  The times of lowmemorykiller
> >> also decreased.
> >
> > I haven't looked at the patches in details yet. can you educate me a bit?
> > is your test stable? why the number of lowmemorykill-s has decreased?
> > ... or am reading "The times of lowmemorykiller also decreased" wrong?
> >
> > suppose you have X pages that result in bad compression size (from zram
> > point of view). zram stores such pages uncompressed, IOW we have no memory
> > savings - swapped out page lands in zsmalloc PAGE_SIZE class. now you
> > don't try to store those pages in zsmalloc, but keep them as unevictable.
> > so the page still occupies PAGE_SIZE; no memory saving again. why did it
> > improve LMK?
> 
> No, zram will not save this page uncompressed with these patches.  It
> will set it as non-swap and kick back to shrink_page_list.
> Shrink_page_list will remove this page from swapcache and kick it to
> unevictable list.
> Then this page will not be swaped before it get write.
> That is why most of code are around vmscan.c.

If I understand Sergey's point right, he means there is no gain
to save memory between before and after.

With your approach, you can prevent unnecessary pageout(i.e.,
uncompressible page swap out) but it doesn't mean you save the
memory compared to old so why does your patch decrease the number of
lowmemory killing?

A thing I can imagine is without this feature, zram could be full of
uncompressible pages so good-compressible page cannot be swapped out.
Hui, is this scenario right for your case?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
