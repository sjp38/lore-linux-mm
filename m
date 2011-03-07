Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 40B358D003B
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 14:47:07 -0500 (EST)
Received: from d01dlp02.pok.ibm.com (d01dlp02.pok.ibm.com [9.56.224.85])
	by e9.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p27JKgoM002812
	for <linux-mm@kvack.org>; Mon, 7 Mar 2011 14:20:42 -0500
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 3D8A96E8036
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 14:47:00 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p27Jl0Rq193316
	for <linux-mm@kvack.org>; Mon, 7 Mar 2011 14:47:00 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p27JkvlZ011267
	for <linux-mm@kvack.org>; Mon, 7 Mar 2011 16:46:59 -0300
Subject: Re: [PATCH] hugetlb: /proc/meminfo shows data for all sizes of
 hugepages
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <1299503155-6210-1-git-send-email-pholasek@redhat.com>
References: <1299503155-6210-1-git-send-email-pholasek@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Mon, 07 Mar 2011 11:46:54 -0800
Message-ID: <1299527214.8493.13263.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Holasek <pholasek@redhat.com>
Cc: linux-kernel@vger.kernel.org, emunson@mgebm.net, anton@redhat.com, Andi Kleen <ak@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org

On Mon, 2011-03-07 at 14:05 +0100, Petr Holasek wrote:
> +       for_each_hstate(h)
> +               seq_printf(m,
> +                               "HugePages_Total:   %5lu\n"
> +                               "HugePages_Free:    %5lu\n"
> +                               "HugePages_Rsvd:    %5lu\n"
> +                               "HugePages_Surp:    %5lu\n"
> +                               "Hugepagesize:   %8lu kB\n",
> +                               h->nr_huge_pages,
> +                               h->free_huge_pages,
> +                               h->resv_huge_pages,
> +                               h->surplus_huge_pages,
> +                               1UL << (huge_page_order(h) + PAGE_SHIFT - 10));
>  }

It sounds like now we'll get a meminfo that looks like:

...
AnonHugePages:    491520 kB
HugePages_Total:       5
HugePages_Free:        2
HugePages_Rsvd:        3
HugePages_Surp:        1
Hugepagesize:       2048 kB
HugePages_Total:       2
HugePages_Free:        1
HugePages_Rsvd:        1
HugePages_Surp:        1
Hugepagesize:    1048576 kB
DirectMap4k:       12160 kB
DirectMap2M:     2082816 kB
DirectMap1G:     2097152 kB

At best, that's a bit confusing.  There aren't any other entries in
meminfo that occur more than once.  Plus, this information is available
in the sysfs interface.  Why isn't that sufficient?

Could we do something where we keep the default hpage_size looking like
it does now, but append the size explicitly for the new entries?

HugePages_Total(1G):       2
HugePages_Free(1G):        1
HugePages_Rsvd(1G):        1
HugePages_Surp(1G):        1

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
