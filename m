Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id CE0446B004A
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 09:37:13 -0400 (EDT)
Message-ID: <4F9AA102.8060103@parallels.com>
Date: Fri, 27 Apr 2012 17:37:06 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] proc: report page->index instead of pfn for non-linear
 mappings in /proc/pid/pagemap
References: <4F91BC8A.9020503@parallels.com> <20120427123910.2132.7022.stgit@zurg>
In-Reply-To: <20120427123910.2132.7022.stgit@zurg>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>

On 04/27/2012 04:39 PM, Konstantin Khlebnikov wrote:
> Currently there is no way to find out current layout of non-linear mapping.
> Also there is no way to distinguish ordinary file mapping from non-linear mapping.
> 
> Now in pagemap non-linear pte can be recognized as present swapped file-backed,
> or as non-present non-swapped file-backed for non-present non-linear file-pte:
> 
>     present swapped file    data        description
>     0       0       0       null        non-present
>     0       0       1       page-index  non-linear file-pte
>     0       1       0       swap-entry  anon-page in swap, migration or hwpoison
>     0       1       1       swap-entry  file-page in migration or hwpoison
>     1       0       0       page-pfn    present private-anon or special page
>     1       0       1       page-pfn    present file or shared-anon page
>     1       1       0       none        impossible combination
>     1       1       1       page-index  non-linear file-page
> 
> [ the last unused combination 1-1-0 can be used for special pages, if anyone want this ]

This means that

a) Any application doing if (pme & PAGE_IS_XXX) checks will get ... broken
b) In order to determine that a mapping is non-linear we'll have to scan it
   ALL and check. Currently in CRIU we just don't read the pagemap for shared
   file maps but will have to. This is not very optimal. I'd prefer having
   this linear/nonlinear info in /proc/pid/smaps or smth like this.

> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
> Cc: Pavel Emelyanov <xemul@parallels.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
