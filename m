Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 6F3348D0039
	for <linux-mm@kvack.org>; Tue,  1 Mar 2011 18:41:05 -0500 (EST)
Date: Tue, 1 Mar 2011 15:41:00 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] ksm: add vm_stat and meminfo entry to reflect pte
 mapping to ksm pages
Message-Id: <20110301154100.212c4ff9.akpm@linux-foundation.org>
In-Reply-To: <201102262256.31565.nai.xia@gmail.com>
References: <201102262256.31565.nai.xia@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: nai.xia@gmail.com
Cc: Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrea Arcangeli <aarcange@redhat.com>, Chris Wright <chrisw@sous-sol.org>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-janitors@vger.kernel.org

On Sat, 26 Feb 2011 22:56:31 +0800
Nai Xia <nai.xia@gmail.com> wrote:

> ksm_pages_sharing is updated by ksmd periodically.  In some cases, it cannot 
> reflect the actual savings and makes the benchmarks on volatile VMAs very 
> inaccurate.
> 
> This patch add a vm_stat entry and let the /proc/meminfo show information 
> about how much virutal address pte is being mapped to ksm pages.  With default 
> ksm paramters (pages_to_scan==100 && sleep_millisecs==20), this can result in 
> 50% more accurate averaged savings result for the following test program. 
> Bigger sleep_millisecs values will increase this deviation. 

So I think you're saying that the existing ksm_pages_sharing sysfs file
is no good.

You added a new entry to /proc/meminfo and left ksm_pages_sharing
as-is.  Why not leave /proc/meminfo alone, and fix up the existing
ksm_pages_sharing?

Also, the patch accumulates the NR_KSM_PAGES_SHARING counts on a
per-zone basis as well as on a global basis, but only provides the
global count to userspace.  The per-zone counts are potentially
interesting?  If not, maintaining the per-zone counters is wasted
overhead.

> 
> --- test.c-----
>

The "^---" token conventionally means "end of changelog".  Please avoid
inserting it into the middle of the changelog.

> +++ b/mm/ksm.c
> @@ -897,6 +897,7 @@ static int try_to_merge_one_page(struct vm_area_struct 
> *vma,

Your email client wordwraps the patches.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
