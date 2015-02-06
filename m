Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f171.google.com (mail-we0-f171.google.com [74.125.82.171])
	by kanga.kvack.org (Postfix) with ESMTP id 02CFE6B0075
	for <linux-mm@kvack.org>; Fri,  6 Feb 2015 15:45:42 -0500 (EST)
Received: by mail-we0-f171.google.com with SMTP id k11so16004568wes.2
        for <linux-mm@kvack.org>; Fri, 06 Feb 2015 12:45:41 -0800 (PST)
Received: from mail-wi0-x231.google.com (mail-wi0-x231.google.com. [2a00:1450:400c:c05::231])
        by mx.google.com with ESMTPS id l2si6075651wja.190.2015.02.06.12.45.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Feb 2015 12:45:39 -0800 (PST)
Received: by mail-wi0-f177.google.com with SMTP id r20so5206267wiv.4
        for <linux-mm@kvack.org>; Fri, 06 Feb 2015 12:45:38 -0800 (PST)
Date: Fri, 6 Feb 2015 21:45:36 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: MADV_DONTNEED semantics? Was: [RFC PATCH] mm: madvise: Ignore
 repeated MADV_DONTNEED hints
Message-ID: <20150206204536.GA24245@dhcp22.suse.cz>
References: <54D08483.40209@suse.cz>
 <20150203105301.GC14259@node.dhcp.inet.fi>
 <54D0B43D.8000209@suse.cz>
 <54D0F56A.9050003@gmail.com>
 <54D22298.3040504@suse.cz>
 <CAKgNAkgOOCuzJz9whoVfFjqhxM0zYsz94B1+oH58SthC5Ut9sg@mail.gmail.com>
 <54D2508A.9030804@suse.cz>
 <CAKgNAkhNbHQX7RukSsSe3bMqY11f493rYbDpTOA2jH7vsziNww@mail.gmail.com>
 <20150205154102.GA20607@dhcp22.suse.cz>
 <54D4E47E.4020509@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <54D4E47E.4020509@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, linux-man <linux-man@vger.kernel.org>, Hugh Dickins <hughd@google.com>

On Fri 06-02-15 16:57:50, Michael Kerrisk wrote:
[...]
> > Yes, this wording is better because many users are not aware of
> > MAP_ANON|MAP_SHARED being file backed in fact and mmap man page doesn't
> > mention that.
> 
> (Michal, would you have a text to propose to add to the mmap(2) page?
> Maybe it would be useful to add something there.)

I am half way on vacation, but I can cook a patch after I am back after
week.
 
> > I am just wondering whether it makes sense to mention that MADV_DONTNEED
> > for shared mappings might be surprising and not freeing the backing
> > pages thus not really freeing memory until there is a memory
> > pressure. But maybe this is too implementation specific for a man
> > page. What about the following wording on top of yours?
> > "
> > Please note that the MADV_DONTNEED hint on shared mappings might not
> > lead to immediate freeing of pages in the range. The kernel is free to
> > delay this until an appropriate moment. RSS of the calling process will
> > be reduced however.
> > "
> 
> Thanks! I added this, but dropped in the word "immediately" in the last 
> sentence, since I assume that was implied. So now we have:
> 
>               After  a  successful MADV_DONTNEED operation, the semana??
>               tics of  memory  access  in  the  specified  region  are
>               changed:  subsequent accesses of pages in the range will
>               succeed, but will result in either repopulating the mema??
>               ory  contents from the up-to-date contents of the undera??
>               lying mapped file  (for  shared  file  mappings,  shared
>               anonymous  mappings,  and shmem-based techniques such as
>               System V shared memory segments) or  zero-fill-on-demand
>               pages for anonymous private mappings.
> 
>               Note  that,  when applied to shared mappings, MADV_DONTa??
>               NEED might not lead to immediate freeing of the pages in
>               the  range.   The  kernel  is  free to delay freeing the
>               pages until an appropriate  moment.   The  resident  set
>               size  (RSS)  of  the calling process will be immediately
>               reduced however.

This sounds good to me and it is definitely much better than the current
state. Thanks!

> The current draft of the page can be found in a branch,
> http://git.kernel.org/cgit/docs/man-pages/man-pages.git/log/?h=draft_madvise
> 
> Thanks,
> 
> Michael
> 
> 
> 
> -- 
> Michael Kerrisk
> Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
> Linux/UNIX System Programming Training: http://man7.org/training/

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
