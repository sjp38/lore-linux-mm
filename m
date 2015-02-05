Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 18F64828FD
	for <linux-mm@kvack.org>; Thu,  5 Feb 2015 10:41:08 -0500 (EST)
Received: by mail-wg0-f52.google.com with SMTP id y19so8245956wgg.11
        for <linux-mm@kvack.org>; Thu, 05 Feb 2015 07:41:07 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f4si9855777wje.8.2015.02.05.07.41.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 05 Feb 2015 07:41:06 -0800 (PST)
Date: Thu, 5 Feb 2015 16:41:02 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: MADV_DONTNEED semantics? Was: [RFC PATCH] mm: madvise: Ignore
 repeated MADV_DONTNEED hints
Message-ID: <20150205154102.GA20607@dhcp22.suse.cz>
References: <20150202165525.GM2395@suse.de>
 <54CFF8AC.6010102@intel.com>
 <54D08483.40209@suse.cz>
 <20150203105301.GC14259@node.dhcp.inet.fi>
 <54D0B43D.8000209@suse.cz>
 <54D0F56A.9050003@gmail.com>
 <54D22298.3040504@suse.cz>
 <CAKgNAkgOOCuzJz9whoVfFjqhxM0zYsz94B1+oH58SthC5Ut9sg@mail.gmail.com>
 <54D2508A.9030804@suse.cz>
 <CAKgNAkhNbHQX7RukSsSe3bMqY11f493rYbDpTOA2jH7vsziNww@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAKgNAkhNbHQX7RukSsSe3bMqY11f493rYbDpTOA2jH7vsziNww@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, linux-man <linux-man@vger.kernel.org>, Hugh Dickins <hughd@google.com>

On Wed 04-02-15 20:24:27, Michael Kerrisk wrote:
[...]
> So, how about this text:
> 
>               After a successful MADV_DONTNEED operation, the semana??
>               tics  of  memory  access  in  the specified region are
>               changed: subsequent accesses of  pages  in  the  range
>               will  succeed,  but will result in either reloading of
>               the memory contents from the  underlying  mapped  file

"
result in either providing the up-to-date contents of the underlying
mapped file
"

Would be more precise IMO because reload might be interpreted as a major
fault which is not necessarily the case (see below).

>               (for  shared file mappings, shared anonymous mappings,
>               and shmem-based techniques such  as  System  V  shared
>               memory  segments)  or  zero-fill-on-demand  pages  for
>               anonymous private mappings.

Yes, this wording is better because many users are not aware of
MAP_ANON|MAP_SHARED being file backed in fact and mmap man page doesn't
mention that.

I am just wondering whether it makes sense to mention that MADV_DONTNEED
for shared mappings might be surprising and not freeing the backing
pages thus not really freeing memory until there is a memory
pressure. But maybe this is too implementation specific for a man
page. What about the following wording on top of yours?
"
Please note that the MADV_DONTNEED hint on shared mappings might not
lead to immediate freeing of pages in the range. The kernel is free to
delay this until an appropriate moment. RSS of the calling process will
be reduced however.
"
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
