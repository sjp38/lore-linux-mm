Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6F2B78D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 18:47:32 -0500 (EST)
Received: from hpaq5.eem.corp.google.com (hpaq5.eem.corp.google.com [172.25.149.5])
	by smtp-out.google.com with ESMTP id p27NlU1H025360
	for <linux-mm@kvack.org>; Mon, 7 Mar 2011 15:47:30 -0800
Received: from pzk37 (pzk37.prod.google.com [10.243.19.165])
	by hpaq5.eem.corp.google.com with ESMTP id p27NlRw7001407
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 7 Mar 2011 15:47:28 -0800
Received: by pzk37 with SMTP id 37so1219859pzk.26
        for <linux-mm@kvack.org>; Mon, 07 Mar 2011 15:47:26 -0800 (PST)
Date: Mon, 7 Mar 2011 15:47:23 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] hugetlb: /proc/meminfo shows data for all sizes of
 hugepages
In-Reply-To: <20110307152516.fee931bb.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1103071543460.22274@chino.kir.corp.google.com>
References: <1299503155-6210-1-git-send-email-pholasek@redhat.com> <1299527214.8493.13263.camel@nimitz> <20110307145149.97e6676e.akpm@linux-foundation.org> <20110307231448.GA2946@spritzera.linux.bs1.fc.nec.co.jp>
 <20110307152516.fee931bb.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Petr Holasek <pholasek@redhat.com>, linux-kernel@vger.kernel.org, emunson@mgebm.net, anton@redhat.com, Andi Kleen <ak@linux.intel.com>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Nishanth Aravamudan <nacc@us.ibm.com>, linux-mm@kvack.org

On Mon, 7 Mar 2011, Andrew Morton wrote:

> > > > On Mon, 2011-03-07 at 14:05 +0100, Petr Holasek wrote:
> > > > > +       for_each_hstate(h)
> > > > > +               seq_printf(m,
> > > > > +                               "HugePages_Total:   %5lu\n"
> > > > > +                               "HugePages_Free:    %5lu\n"
> > > > > +                               "HugePages_Rsvd:    %5lu\n"
> > > > > +                               "HugePages_Surp:    %5lu\n"
> > > > > +                               "Hugepagesize:   %8lu kB\n",
> > > > > +                               h->nr_huge_pages,
> > > > > +                               h->free_huge_pages,
> > > > > +                               h->resv_huge_pages,
> > > > > +                               h->surplus_huge_pages,
> > > > > +                               1UL << (huge_page_order(h) + PAGE_SHIFT - 10));
> > > > >  }
> > > >
> > > > It sounds like now we'll get a meminfo that looks like:
> > > >
> > > > ...
> > > > AnonHugePages:    491520 kB
> > > > HugePages_Total:       5
> > > > HugePages_Free:        2
> > > > HugePages_Rsvd:        3
> > > > HugePages_Surp:        1
> > > > Hugepagesize:       2048 kB
> > > > HugePages_Total:       2
> > > > HugePages_Free:        1
> > > > HugePages_Rsvd:        1
> > > > HugePages_Surp:        1
> > > > Hugepagesize:    1048576 kB
> > > > DirectMap4k:       12160 kB
> > > > DirectMap2M:     2082816 kB
> > > > DirectMap1G:     2097152 kB
> > > >
> > > > At best, that's a bit confusing.  There aren't any other entries in
> > > > meminfo that occur more than once.  Plus, this information is available
> > > > in the sysfs interface.  Why isn't that sufficient?
> > > >
> > > > Could we do something where we keep the default hpage_size looking like
> > > > it does now, but append the size explicitly for the new entries?
> > > >
> > > > HugePages_Total(1G):       2
> > > > HugePages_Free(1G):        1
> > > > HugePages_Rsvd(1G):        1
> > > > HugePages_Surp(1G):        1
> > > >
> > >
> > > Let's not change the existing interface, please.
> > >
> > > Adding new fields: OK.
> > > Changing the way in whcih existing fields are calculated: OKish.
> > > Renaming existing fields: not OK.
> > 
> > How about lining up multiple values in each field like this?
> > 
> >   HugePages_Total:       5 2
> >   HugePages_Free:        2 1
> >   HugePages_Rsvd:        3 1
> >   HugePages_Surp:        1 1
> >   Hugepagesize:       2048 1048576 kB
> >   ...
> > 
> > This doesn't change the field names and the impact for user space
> > is still small?
> 
> It might break some existing parsers, dunno.
> 
> It was a mistake to assume that all hugepages will have the same size
> for all time, and we just have to live with that mistake.
> 

I'm not sure it was a mistake: the kernel has a default hugepage size and 
that's what the global /proc/sys/vm/nr_hugepages tunable uses, so it seems 
appropriate that its statistics are exported in the global /proc/meminfo.

> I'd suggest that we leave meminfo alone, just ensuring that its output
> makes some sense.  Instead create a new interface which presents all
> the required info in a sensible fashion and migrate usersapce reporting
> tools over to that interface.  Just let the meminfo field die a slow
> death.
> 

(Adding Nishanth to the cc)

It's already there, all this data is available for all the configured 
hugepage sizes via /sys/kernel/mm/hugepages/hugepages-<size>kB/ as 
described by Documentation/ABI/testing/sysfs-kernel-mm-hugepages.

It looks like Nishanth and others put quite a bit of effort into making as 
stable of an API as possible for this information.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
