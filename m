Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B3C698D003A
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 10:19:46 -0400 (EDT)
Received: (from localhost user: 'dkiper' uid#4000 fake: STDIN
	(dkiper@router-fw.net-space.pl)) by router-fw-old.local.net-space.pl
	id S1577168Ab1COOSh (ORCPT <rfc822;linux-mm@kvack.org>);
	Tue, 15 Mar 2011 15:18:37 +0100
Date: Tue, 15 Mar 2011 15:18:37 +0100
From: Daniel Kiper <dkiper@net-space.pl>
Subject: Re: [PATCH R4 2/7] xen/balloon: HVM mode support
Message-ID: <20110315141837.GA12730@router-fw-old.local.net-space.pl>
References: <20110308214636.GC27331@router-fw-old.local.net-space.pl> <alpine.DEB.2.00.1103091356370.2968@kaball-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1103091356370.2968@kaball-desktop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefano Stabellini <stefano.stabellini@eu.citrix.com>
Cc: Daniel Kiper <dkiper@net-space.pl>, Ian Campbell <Ian.Campbell@eu.citrix.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "andi.kleen@intel.com" <andi.kleen@intel.com>, "haicheng.li@linux.intel.com" <haicheng.li@linux.intel.com>, "fengguang.wu@intel.com" <fengguang.wu@intel.com>, "jeremy@goop.org" <jeremy@goop.org>, "konrad.wilk@oracle.com" <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, "v.tolstov@selfip.ru" <v.tolstov@selfip.ru>, "pasik@iki.fi" <pasik@iki.fi>, "dave@linux.vnet.ibm.com" <dave@linux.vnet.ibm.com>, "wdauchy@gmail.com" <wdauchy@gmail.com>, "rientjes@google.com" <rientjes@google.com>, "xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, Mar 09, 2011 at 01:58:30PM +0000, Stefano Stabellini wrote:
> On Tue, 8 Mar 2011, Daniel Kiper wrote:
> > HVM mode support.
>
> I have already a patch in linux-next to do this, please give a look at
> "xen: make the ballon driver work for hvm domains":
>
> git://xenbits.xen.org/people/sstabellini/linux-pvhvm.git linux-next

OK, I will remove this patch from memory hotplug patchset, however:

@@ -232,7 +232,7 @@ static int increase_reservation(unsigned long nr_pages)
 		set_phys_to_machine(pfn, frame_list[i]);
 
 		/* Link back into the page tables if not highmem. */
-		if (pfn < max_low_pfn) {
+		if (!xen_hvm_domain() && pfn < max_low_pfn) {

Why do not write it as:

if (xen_pv_domain() && !PageHighMem(page)) ...

For me it is simpler to read (xen_pv_domain()) and make it similar
to relevant part in decrease_reservation() (!PageHighMem(page)).

@@ -280,7 +280,7 @@ static int decrease_reservation(unsigned long nr_pages)
 
 		scrub_page(page);
 
-		if (!PageHighMem(page)) {
+		if (!xen_hvm_domain() && !PageHighMem(page)) {

As above.

@@ -392,15 +392,19 @@ static struct notifier_block xenstore_notifier;
 
 static int __init balloon_init(void)
 {
-	unsigned long pfn, extra_pfn_end;
+ 	unsigned long pfn, nr_pages, extra_pfn_end;
 	struct page *page;
 
-	if (!xen_pv_domain())
+	if (!xen_domain())
 		return -ENODEV;
 
 	pr_info("xen_balloon: Initialising balloon driver.\n");
 
-	balloon_stats.current_pages = min(xen_start_info->nr_pages, max_pfn);
+ 	if (xen_pv_domain())
+ 		nr_pages = xen_start_info->nr_pages;
+ 	else
+ 		nr_pages = max_pfn;
+ 	balloon_stats.current_pages = min(nr_pages, max_pfn);

It could be simplified:

balloon_stats.current_pages = xen_pv_domain() ? min(xen_start_info->nr_pages, max_pfn) : max_pfn;

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
