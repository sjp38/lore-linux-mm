Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 7A8E76B006C
	for <linux-mm@kvack.org>; Fri,  6 Feb 2015 10:58:01 -0500 (EST)
Received: by mail-wi0-f169.google.com with SMTP id h11so3504139wiw.0
        for <linux-mm@kvack.org>; Fri, 06 Feb 2015 07:58:00 -0800 (PST)
Received: from mail-we0-x235.google.com (mail-we0-x235.google.com. [2a00:1450:400c:c03::235])
        by mx.google.com with ESMTPS id kq6si5076674wjc.34.2015.02.06.07.57.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Feb 2015 07:58:00 -0800 (PST)
Received: by mail-we0-f181.google.com with SMTP id k48so14522734wev.12
        for <linux-mm@kvack.org>; Fri, 06 Feb 2015 07:57:59 -0800 (PST)
Message-ID: <54D4E47E.4020509@gmail.com>
Date: Fri, 06 Feb 2015 16:57:50 +0100
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
MIME-Version: 1.0
Subject: Re: MADV_DONTNEED semantics? Was: [RFC PATCH] mm: madvise: Ignore
 repeated MADV_DONTNEED hints
References: <20150202165525.GM2395@suse.de> <54CFF8AC.6010102@intel.com> <54D08483.40209@suse.cz> <20150203105301.GC14259@node.dhcp.inet.fi> <54D0B43D.8000209@suse.cz> <54D0F56A.9050003@gmail.com> <54D22298.3040504@suse.cz> <CAKgNAkgOOCuzJz9whoVfFjqhxM0zYsz94B1+oH58SthC5Ut9sg@mail.gmail.com> <54D2508A.9030804@suse.cz> <CAKgNAkhNbHQX7RukSsSe3bMqY11f493rYbDpTOA2jH7vsziNww@mail.gmail.com> <20150205154102.GA20607@dhcp22.suse.cz>
In-Reply-To: <20150205154102.GA20607@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: mtk.manpages@gmail.com, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, linux-man <linux-man@vger.kernel.org>, Hugh Dickins <hughd@google.com>

Hi Michael

On 02/05/2015 04:41 PM, Michal Hocko wrote:
> On Wed 04-02-15 20:24:27, Michael Kerrisk wrote:
> [...]
>> So, how about this text:
>>
>>               After a successful MADV_DONTNEED operation, the semana??
>>               tics  of  memory  access  in  the specified region are
>>               changed: subsequent accesses of  pages  in  the  range
>>               will  succeed,  but will result in either reloading of
>>               the memory contents from the  underlying  mapped  file
> 
> "
> result in either providing the up-to-date contents of the underlying
> mapped file
> "

Thanks! I did something like that. See below.

> Would be more precise IMO because reload might be interpreted as a major
> fault which is not necessarily the case (see below).
> 
>>               (for  shared file mappings, shared anonymous mappings,
>>               and shmem-based techniques such  as  System  V  shared
>>               memory  segments)  or  zero-fill-on-demand  pages  for
>>               anonymous private mappings.
> 
> Yes, this wording is better because many users are not aware of
> MAP_ANON|MAP_SHARED being file backed in fact and mmap man page doesn't
> mention that.

(Michal, would you have a text to propose to add to the mmap(2) page?
Maybe it would be useful to add something there.)

> 
> I am just wondering whether it makes sense to mention that MADV_DONTNEED
> for shared mappings might be surprising and not freeing the backing
> pages thus not really freeing memory until there is a memory
> pressure. But maybe this is too implementation specific for a man
> page. What about the following wording on top of yours?
> "
> Please note that the MADV_DONTNEED hint on shared mappings might not
> lead to immediate freeing of pages in the range. The kernel is free to
> delay this until an appropriate moment. RSS of the calling process will
> be reduced however.
> "

Thanks! I added this, but dropped in the word "immediately" in the last 
sentence, since I assume that was implied. So now we have:

              After  a  successful MADV_DONTNEED operation, the semana??
              tics of  memory  access  in  the  specified  region  are
              changed:  subsequent accesses of pages in the range will
              succeed, but will result in either repopulating the mema??
              ory  contents from the up-to-date contents of the undera??
              lying mapped file  (for  shared  file  mappings,  shared
              anonymous  mappings,  and shmem-based techniques such as
              System V shared memory segments) or  zero-fill-on-demand
              pages for anonymous private mappings.

              Note  that,  when applied to shared mappings, MADV_DONTa??
              NEED might not lead to immediate freeing of the pages in
              the  range.   The  kernel  is  free to delay freeing the
              pages until an appropriate  moment.   The  resident  set
              size  (RSS)  of  the calling process will be immediately
              reduced however.

The current draft of the page can be found in a branch,
http://git.kernel.org/cgit/docs/man-pages/man-pages.git/log/?h=draft_madvise

Thanks,

Michael



-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
