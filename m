Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id C145C440441
	for <linux-mm@kvack.org>; Sat,  6 Feb 2016 08:32:09 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id 128so103275521wmz.1
        for <linux-mm@kvack.org>; Sat, 06 Feb 2016 05:32:09 -0800 (PST)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id k10si30539482wjy.108.2016.02.06.05.32.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 06 Feb 2016 05:32:08 -0800 (PST)
Received: by mail-wm0-x243.google.com with SMTP id g62so7450576wme.2
        for <linux-mm@kvack.org>; Sat, 06 Feb 2016 05:32:08 -0800 (PST)
Subject: Re: [PATCH v5 00/12] MADV_FREE support
References: <20160205021557.GA11598@bbox>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Message-ID: <56B5F5D2.70309@gmail.com>
Date: Sat, 6 Feb 2016 14:32:02 +0100
MIME-Version: 1.0
In-Reply-To: <20160205021557.GA11598@bbox>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: mtk.manpages@gmail.com, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, Daniel Micay <danielmicay@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Shaohua Li <shli@kernel.org>, Michal Hocko <mhocko@suse.cz>, yalin.wang2010@gmail.com, Andy Lutomirski <luto@amacapital.net>

Hello Minchan,

On 02/05/2016 03:15 AM, Minchan Kim wrote:
> On Thu, Jan 28, 2016 at 08:16:25AM +0100, Michael Kerrisk (man-pages) wrote:
>> Hello Minchan,
>>
>> On 11/30/2015 07:39 AM, Minchan Kim wrote:
>>> In v4, Andrew wanted to settle in old basic MADV_FREE and introduces
>>> new stuffs(ie, lazyfree LRU, swapless support and lazyfreeness) later
>>> so this version doesn't include them.
>>>
>>> I have been tested it on mmotm-2015-11-25-17-08 with additional
>>> patch[1] from Kirill to prevent BUG_ON which he didn't send to
>>> linux-mm yet as formal patch. With it, I couldn't find any
>>> problem so far.
>>>
>>> Note that this version is based on THP refcount redesign so
>>> I needed some modification on MADV_FREE because split_huge_pmd
>>> doesn't split a THP page any more and pmd_trans_huge(pmd) is not
>>> enough to guarantee the page is not THP page.
>>> As well, for MAVD_FREE lazy-split, THP split should respect
>>> pmd's dirtiness rather than marking ptes of all subpages dirty
>>> unconditionally. Please, review last patch in this patchset.
>>
>> Now that MADV_FREE has been merged, would you be willing to write
>> patch to the madvise(2) man page that describes the semantics, 
>> noes limitations and restrictions, and (ideally) has some sentences
>> describing use cases?
>>
> 
> Hello Michael,
> 
> Could you review this patch?
> 
> Thanks.
> 
>>From 203372f901f574e991215fdff6907608ba53f932 Mon Sep 17 00:00:00 2001
> From: Minchan Kim <minchan@kernel.org>
> Date: Fri, 5 Feb 2016 11:09:54 +0900
> Subject: [PATCH] madvise.2: Add MADV_FREE
> 
> Document the MADV_FREE flags added to madvise() in Linux 4.5
> 
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  man2/madvise.2 | 19 +++++++++++++++++++
>  1 file changed, 19 insertions(+)
> 
> diff --git a/man2/madvise.2 b/man2/madvise.2
> index c1df67c..4704304 100644
> --- a/man2/madvise.2
> +++ b/man2/madvise.2
> @@ -143,6 +143,25 @@ flag are special memory areas that are not managed
>  by the virtual memory subsystem.
>  Such pages are typically created by device drivers that
>  map the pages into user space.)
> +.TP
> +.B MADV_FREE " (since Linux 4.5)"
> +Application is finished with the given range, so kernel can free
> +resources associated with it but the freeing could be delayed until
> +memory pressure happens or canceld by write operation by user.
> +
> +After a successful MADV_FREE operation, user shouldn't expect kernel
> +keeps stale data on the page. However, subsequent write of pages
> +in the range will succeed and then kernel cannot free those dirtied pages
> +so user can always see just written data. If there was no subsequent
> +write, kernel can free those clean pages any time. In such case,
> +user can see zero-fill-on-demand pages.
> +
> +Note that, it works only with private anonymous pages (see
> +.BR mmap (2)).
> +On swapless system, freeing pages in given range happens instantly
> +regardless of memory pressure.
> +
> +
>  .\"
>  .\" ======================================================================
>  .\"
> 

Thanks for the nice text! I reworked somewhat, trying to fill out a
few details about how I understand things work, but I may have introduced
errors, so I would be happy if you would check the following text:

       MADV_FREE (since Linux 4.5)
              The  application  no  longer  requires  the pages in the
              range specified by addr and len.  The  kernel  can  thus
              free these pages, but the freeing could be delayed until
              memory pressure occurs.  For each of the pages that  has
              been  marked to be freed but has not yet been freed, the
              free operation will be canceled  if  the  caller  writes
              into  the page.  After a successful MADV_FREE operation,
              any stale data (i.e., dirty, unwritten  pages)  will  be
              lost  when  the kernel frees the pages.  However, subsea??
              quent writes to pages in the range will succeed and then
              kernel  cannot  free  those  dirtied  pages, so that the
              caller can always see just written data.  If there is no
              subsequent  write,  the kernel can free the pages at any
              time.  Once pages in the  range  have  been  freed,  the
              caller  will  see  zero-fill-on-demand pages upon subsea??
              quent page references.

              The MADV_FREE operation can be applied only  to  private
              anonymous  pages  (see  mmap(2)).  On a swapless system,
              freeing  pages  in  a  given  range  happens  instantly,
              regardless of memory pressure.

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
