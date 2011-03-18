Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 464948D0039
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 03:17:00 -0400 (EDT)
Received: by iyf13 with SMTP id 13so5076838iyf.14
        for <linux-mm@kvack.org>; Fri, 18 Mar 2011 00:16:58 -0700 (PDT)
From: Nai Xia <nai.xia@gmail.com>
Reply-To: nai.xia@gmail.com
Subject: Re: [PATCH] ksm: add vm_stat and meminfo entry to reflect pte mapping to ksm pages
Date: Fri, 18 Mar 2011 15:16:37 +0800
References: <201102262256.31565.nai.xia@gmail.com> <20110301154100.212c4ff9.akpm@linux-foundation.org>
In-Reply-To: <20110301154100.212c4ff9.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <201103181516.37671.nai.xia@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrea Arcangeli <aarcange@redhat.com>, Chris Wright <chrisw@sous-sol.org>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-janitors@vger.kernel.org


>On Wednesday 02 March 2011, at 07:41:00, <Andrew Morton <akpm@linux-foundation.org>> wrote
> On Sat, 26 Feb 2011 22:56:31 +0800
> Nai Xia <nai.xia@gmail.com> wrote:
> 
> > ksm_pages_sharing is updated by ksmd periodically.  In some cases, it cannot 
> > reflect the actual savings and makes the benchmarks on volatile VMAs very 
> > inaccurate.
> > 
> > This patch add a vm_stat entry and let the /proc/meminfo show information 
> > about how much virutal address pte is being mapped to ksm pages.  With default 
> > ksm paramters (pages_to_scan==100 && sleep_millisecs==20), this can result in 
> > 50% more accurate averaged savings result for the following test program. 
> > Bigger sleep_millisecs values will increase this deviation. 
> 
> So I think you're saying that the existing ksm_pages_sharing sysfs file
> is no good.
> 
> You added a new entry to /proc/meminfo and left ksm_pages_sharing
> as-is.  Why not leave /proc/meminfo alone, and fix up the existing
> ksm_pages_sharing?


The ksm_pages_sharing is really a count for how many "rmap_item"s is currently
linked in stable_nodes. ksmd updates ksm_pages_sharing whenever it's waken up.
However, just during the time ksmd is sleeping, many shared KSM pages can be 
broken because of page writes. So ksm_pages_sharing means much more an internal
state for ksm than a real count for how much pages is being shared at some time
point. Since the state of the internal data structures of ksm is only updated 
by ksmd privately. I think it's hard to make it correctly reflect the real time
memory saving. So I just added another count and let ksm_pages_sharing still 
focus on it original role.

> 
> Also, the patch accumulates the NR_KSM_PAGES_SHARING counts on a
> per-zone basis as well as on a global basis, but only provides the
> global count to userspace.  The per-zone counts are potentially
> interesting?  If not, maintaining the per-zone counters is wasted
> overhead.

Yes, I will make it to the zoneinfo, soon. 

> 
> > 
> > --- test.c-----
> >
> 
> The "^---" token conventionally means "end of changelog".  Please avoid
> inserting it into the middle of the changelog.

OK, I understand now. :)

> 
> > +++ b/mm/ksm.c
> > @@ -897,6 +897,7 @@ static int try_to_merge_one_page(struct vm_area_struct 
> > *vma,
> 
> Your email client wordwraps the patches.

Oops, sorry for the crappy client it is also responsible for my late reply.
I will fix it soon.

Nai

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
