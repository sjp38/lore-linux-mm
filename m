Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4E9956B026B
	for <linux-mm@kvack.org>; Wed, 15 Nov 2017 17:46:05 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id m191so2680422itg.1
        for <linux-mm@kvack.org>; Wed, 15 Nov 2017 14:46:05 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id m203sor7997665itd.60.2017.11.15.14.46.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 15 Nov 2017 14:46:03 -0800 (PST)
Date: Wed, 15 Nov 2017 14:46:00 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: show total hugetlb memory consumption in
 /proc/meminfo
In-Reply-To: <20171115081818.ucnp26tho4qffdwx@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1711151443090.103372@chino.kir.corp.google.com>
References: <20171114125026.7055-1-guro@fb.com> <20171114131736.v2m6alrt5gelmh5c@dhcp22.suse.cz> <alpine.DEB.2.10.1711141425220.112995@chino.kir.corp.google.com> <20171115081818.ucnp26tho4qffdwx@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, kernel-team@fb.com, linux-kernel@vger.kernel.org

On Wed, 15 Nov 2017, Michal Hocko wrote:

> > > >  	if (!hugepages_supported())
> > > >  		return;
> > > >  	seq_printf(m,
> > > > @@ -2987,6 +2989,11 @@ void hugetlb_report_meminfo(struct seq_file *m)
> > > >  			h->resv_huge_pages,
> > > >  			h->surplus_huge_pages,
> > > >  			1UL << (huge_page_order(h) + PAGE_SHIFT - 10));
> > > > +
> > > > +	for_each_hstate(h)
> > > > +		total += (PAGE_SIZE << huge_page_order(h)) * h->nr_huge_pages;
> > > 
> > > Please keep the total calculation consistent with what we have there
> > > already.
> > > 
> > 
> > Yeah, and I'm not sure if your comment eludes to this being racy, but it 
> > would be better to store the default size for default_hstate during the 
> > iteration to total the size for all hstates.
> 
> I just meant to have the code consistent. I do not prefer one or other
> option.

It's always nice when HugePages_Total * Hugepagesize cannot become greater 
than Hugetlb.  Roman, could you factor something like this into your 
change accompanied with a documentation upodate as suggested by Dave?

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2975,20 +2975,33 @@ int hugetlb_overcommit_handler(struct ctl_table *table, int write,
 
 void hugetlb_report_meminfo(struct seq_file *m)
 {
-	struct hstate *h = &default_hstate;
+	struct hstate *h;
+	unsigned long total = 0;
+
 	if (!hugepages_supported())
 		return;
-	seq_printf(m,
-			"HugePages_Total:   %5lu\n"
-			"HugePages_Free:    %5lu\n"
-			"HugePages_Rsvd:    %5lu\n"
-			"HugePages_Surp:    %5lu\n"
-			"Hugepagesize:   %8lu kB\n",
-			h->nr_huge_pages,
-			h->free_huge_pages,
-			h->resv_huge_pages,
-			h->surplus_huge_pages,
-			1UL << (huge_page_order(h) + PAGE_SHIFT - 10));
+
+	for_each_hstate(h) {
+		unsigned long nr_huge_pages = h->nr_huge_pages;
+
+		total += nr_huge_pages <<
+			 (huge_page_order(h) + PAGE_SHIFT - 10);
+
+		if (h == &default_hstate) {
+			seq_printf(m,
+				"HugePages_Total:   %5lu\n"
+				"HugePages_Free:    %5lu\n"
+				"HugePages_Rsvd:    %5lu\n"
+				"HugePages_Surp:    %5lu\n"
+				"Hugepagesize:   %8lu kB\n",
+				nr_huge_pages,
+				h->free_huge_pages,
+				h->resv_huge_pages,
+				h->surplus_huge_pages,
+				1UL << (huge_page_order(h) + PAGE_SHIFT - 10));
+		}
+	}
+	seq_printf(m, "Hugetlb:            %5lu kB\n", total);
 }
 
 int hugetlb_report_node_meminfo(int nid, char *buf)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
