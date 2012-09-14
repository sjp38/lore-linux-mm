Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id EDBA56B0069
	for <linux-mm@kvack.org>; Fri, 14 Sep 2012 16:14:29 -0400 (EDT)
Date: Fri, 14 Sep 2012 13:14:28 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH RESEND] memory hotplug: fix a double register section
 info bug
Message-Id: <20120914131428.1f530681.akpm@linux-foundation.org>
In-Reply-To: <50530E39.5020100@jp.fujitsu.com>
References: <5052A7DF.4050301@gmail.com>
	<50530E39.5020100@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: qiuxishi <qiuxishi@gmail.com>, mgorman@suse.de, tony.luck@intel.com, Jiang Liu <jiang.liu@huawei.com>, qiuxishi@huawei.com, bessel.wang@huawei.com, wujianguo@huawei.com, paul.gortmaker@windriver.com, kamezawa.hiroyu@jp.fujitsu.com, kosaki.motohiro@jp.fujitsu.com, rientjes@google.com, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wen Congyang <wency@cn.fujitsu.com>

On Fri, 14 Sep 2012 20:00:09 +0900
Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com> wrote:

> > @@ -187,9 +184,10 @@ void register_page_bootmem_info_node(struct pglist_data *pgdat)
> >   	end_pfn = pfn + pgdat->node_spanned_pages;
> >
> >   	/* register_section info */
> > -	for (; pfn < end_pfn; pfn += PAGES_PER_SECTION)
> > -		register_page_bootmem_info_section(pfn);
> > -
> > +	for (; pfn < end_pfn; pfn += PAGES_PER_SECTION) {
> > +		if (pfn_valid(pfn) && (pfn_to_nid(pfn) == node))
> 
> I cannot judge whether your configuration is correct or not.
> Thus if it is correct, I want a comment of why the node check is
> needed. In usual configuration, a node does not span the other one.
> So it is natural that "pfn_to_nid(pfn) is same as "pgdat->node_id".
> Thus we may remove the node check in the future.

yup.  How does this look?

--- a/mm/memory_hotplug.c~memory-hotplug-fix-a-double-register-section-info-bug-fix
+++ a/mm/memory_hotplug.c
@@ -185,6 +185,12 @@ void register_page_bootmem_info_node(str
 
 	/* register_section info */
 	for (; pfn < end_pfn; pfn += PAGES_PER_SECTION) {
+		/*
+		 * Some platforms can assign the same pfn to multiple nodes - on
+		 * node0 as well as nodeN.  To avoid registering a pfn against
+		 * multiple nodes we check that this pfn does not already
+		 * reside in some other node.
+		 */
 		if (pfn_valid(pfn) && (pfn_to_nid(pfn) == node))
 			register_page_bootmem_info_section(pfn);
 	}
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
