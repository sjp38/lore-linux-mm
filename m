Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 344686B0253
	for <linux-mm@kvack.org>; Sun, 15 Nov 2015 21:12:39 -0500 (EST)
Received: by pacej9 with SMTP id ej9so51501077pac.2
        for <linux-mm@kvack.org>; Sun, 15 Nov 2015 18:12:39 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTPS id dm1si13770236pbc.117.2015.11.15.18.12.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 15 Nov 2015 18:12:38 -0800 (PST)
Date: Mon, 16 Nov 2015 11:13:21 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v3 01/17] mm: support madvise(MADV_FREE)
Message-ID: <20151116021320.GB7973@bbox>
References: <1447302793-5376-2-git-send-email-minchan@kernel.org>
 <CALCETrWA6aZC_3LPM3niN+2HFjGEm_65m9hiEdpBtEZMn0JhwQ@mail.gmail.com>
 <564421DA.9060809@gmail.com>
 <20151113061511.GB5235@bbox>
 <56458056.8020105@gmail.com>
 <20151113063802.GF5235@bbox>
 <56458720.4010400@gmail.com>
 <20151113070356.GG5235@bbox>
 <56459B9A.7080501@gmail.com>
 <CALCETrVx0JFchtJrrKVqEYvTwWvC+DwSLxzhD_A7EdNu2PiG7w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrVx0JFchtJrrKVqEYvTwWvC+DwSLxzhD_A7EdNu2PiG7w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Daniel Micay <danielmicay@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Michael Kerrisk <mtk.manpages@gmail.com>, Linux API <linux-api@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Shaohua Li <shli@kernel.org>, Michal Hocko <mhocko@suse.cz>, yalin wang <yalin.wang2010@gmail.com>

On Fri, Nov 13, 2015 at 11:46:07AM -0800, Andy Lutomirski wrote:
> On Fri, Nov 13, 2015 at 12:13 AM, Daniel Micay <danielmicay@gmail.com> wrote:
> > On 13/11/15 02:03 AM, Minchan Kim wrote:
> >> On Fri, Nov 13, 2015 at 01:45:52AM -0500, Daniel Micay wrote:
> >>>> And now I am thinking if we use access bit, we could implment MADV_FREE_UNDO
> >>>> easily when we need it. Maybe, that's what you want. Right?
> >>>
> >>> Yes, but why the access bit instead of the dirty bit for that? It could
> >>> always be made more strict (i.e. access bit) in the future, while going
> >>> the other way won't be possible. So I think the dirty bit is really the
> >>> more conservative choice since if it turns out to be a mistake it can be
> >>> fixed without a backwards incompatible change.
> >>
> >> Absolutely true. That's why I insist on dirty bit until now although
> >> I didn't tell the reason. But I thought you wanted to change for using
> >> access bit for the future, too. It seems MADV_FREE start to bloat
> >> over and over again before knowing real problems and usecases.
> >> It's almost same situation with volatile ranges so I really want to
> >> stop at proper point which maintainer should decide, I hope.
> >> Without it, we will make the feature a lot heavy by just brain storming
> >> and then causes lots of churn in MM code without real bebenfit
> >> It would be very painful for us.
> >
> > Well, I don't think you need more than a good API and an implementation
> > with no known bugs, kernel security concerns or backwards compatibility
> > issues. Configuration and API extensions are something for later (i.e.
> > land a baseline, then submit stuff like sysctl tunables). Just my take
> > on it though...
> >
> 
> As long as it's anonymous MAP_PRIVATE only, then the security aspects
> should be okay.  MADV_DONTNEED seems to work on pretty much any VMA,
> and there's been long history of interesting bugs there.
> 
> As for dirty vs accessed, an argument in favor of going straight to
> accessed is that it means that users can write code like this without
> worrying about whether they have a kernel that uses the dirty bit:
> 
> x = mmap(...);
> *x = 1;  /* mark it present */
> 
> /* i'm done with it */
> *x = 1;
> madvise(MADV_FREE, x, ...);
> 
> wait a while;
> 
> /* is it still there? */
> if (*x == 1) {
>   /* use whatever was cached there */
> } else {
>  /* reinitialize it */
>  *x = 1;
> }
> 
> With the dirty bit, this will look like it works, but on occasion
> users will lose the race where they probe *x to see if the data was
> lost and then the data gets lost before the next write comes in.
> 
> Sure, that load from *x could be changed to RMW or users could do a
> dummy write (e.g. x[1] = 1; if (*x == 1) ...), but people might forget
> to do that, and the caching implications are a little bit worse.

I think your example is the case what people abuse MADV_FREE.
What happens if the object(ie, x) spans multiple pages?
User should know object's memory align and investigate all of pages
which span the object. Hmm, I don't think it's good for API.

> 
> Note that switching to RMW is really really dangerous.  Doing:
> 
> *x &= 1;
> if (*x == 1) ...;
> 
> is safe on x86 if the compiler generates:
> 
> andl $1, (%[x]);
> cmpl $1, (%[x]);
> 
> but is unsafe if the compiler generates:
> 
> movl (%[x]), %eax;
> andl $1, %eax;
> movl %eax, (%[x]);
> cmpl $1, %eax;
> 
> and even worse if the write is omitted when "provably" unnecessary.
> 
> OTOH, if switching to the accessed bit is too much of a mess, then
> using the dirty bit at first isn't so bad.

Thanks! I want to use dirty bit first.

About access bit, I don't want to say it to mess but I guess it would
change a lot subtle thing for all architectures. Because we have used
access bit as just *hint* for aging while dirty bit is really
*critical marker* for system integrity. A example in x86, we don't
keep accuracy of access bit for reducing TLB flush IPI. I don't know
what technique other arches have used but they might have.

Thanks.


> 
> --Andy
> 
> -- 
> Andy Lutomirski
> AMA Capital Management, LLC

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
