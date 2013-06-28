Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id F3D2E6B0032
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 03:43:13 -0400 (EDT)
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MP300BU7ERZYX60@mailout3.samsung.com> for linux-mm@kvack.org;
 Fri, 28 Jun 2013 16:43:11 +0900 (KST)
From: Hyunhee Kim <hyunhee.kim@samsung.com>
References: <20130621091944.GC12424@dhcp22.suse.cz>
 <20130621162743.GA2837@gmail.com>
 <CAOK=xRMhwvWrao_ve8GFsk0JBHAcWh_SB_kM6fCujp8WThPimw@mail.gmail.com>
 <CAOK=xRNEMp3igfwQfrz0ffApmoAL19OM0EGLaBJ5RerZy9ddtw@mail.gmail.com>
 <005601ce6f0c$5948ff90$0bdafeb0$%kim@samsung.com>
 <20130626073557.GD29127@bbox>
 <009601ce72fd$427eed70$c77cc850$%kim@samsung.com>
 <20130627093721.GC17647@dhcp22.suse.cz> <20130627153528.GA5006@gmail.com>
 <20130627161103.GA25165@dhcp22.suse.cz> <20130627235435.GA15637@bbox>
In-reply-to: <20130627235435.GA15637@bbox>
Subject: [PATCH v3] vmpressure: consider "scanned < reclaimed" case when
 calculating  a pressure level.
Date: Fri, 28 Jun 2013 16:43:09 +0900
Message-id: <010801ce73d3$227f8800$677e9800$%kim@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
Content-language: ko
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Minchan Kim' <minchan@kernel.org>, 'Michal Hocko' <mhocko@suse.cz>, 'Anton Vorontsov' <anton@enomsg.org>, linux-mm@kvack.org, akpm@linux-foundation.org, rob@landley.net, kamezawa.hiroyu@jp.fujitsu.com, hannes@cmpxchg.org, rientjes@google.com, kirill@shutemov.name, 'Kyungmin Park' <kyungmin.park@samsung.com>

In vmpressure, the pressure level is calculated based on the ratio
of how many pages were scanned vs. reclaimed in a given time window.
However, there is a possibility that "scanned < reclaimed" for some
reasons, e.g., when reclaiming ends by fatal signal in shrink_inactive_list
or THP reclaiming, etc. When this happens, we cannot tell anything about the
current pressure level. So, with this patch, we just return "low" level
when "scanned < reclaimed" happens to inform that there is reclaiming activity.
Userland can have a chance to free some memory.

Signed-off-by: Hyunhee Kim <hyunhee.kim@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 mm/vmpressure.c |   10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/mm/vmpressure.c b/mm/vmpressure.c
index 736a601..915a608 100644
--- a/mm/vmpressure.c
+++ b/mm/vmpressure.c
@@ -119,6 +119,16 @@ static enum vmpressure_levels vmpressure_calc_level(unsigned long scanned,
 	unsigned long pressure;
 
 	/*
+	 * This could happen for some reasons. e.g., reclaiming ends by fatal
+	 * signal in shrink_inactive_list() or THP reclaiming, etc. In this case,
+	 * we cannot tell anything about the pressure level. So, the best way to
+	 * handle this is to notify LOW in order to inform that there is
+	 * reclaiming activity. This gives a chance to userland to free memory.
+	 */
+	if (reclaimed > scanned)
+		return VMPRESSURE_LOW;
+
+	/*
 	 * We calculate the ratio (in percents) of how many pages were
 	 * scanned vs. reclaimed in a given time frame (window). Note that
 	 * time is in VM reclaimer's "ticks", i.e. number of pages
-- 
1.7.9.5


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
