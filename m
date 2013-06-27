Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id EF6476B0034
	for <linux-mm@kvack.org>; Thu, 27 Jun 2013 02:12:13 -0400 (EDT)
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MP100B49FTPBAB0@mailout3.samsung.com> for linux-mm@kvack.org;
 Thu, 27 Jun 2013 15:12:11 +0900 (KST)
From: Hyunhee Kim <hyunhee.kim@samsung.com>
References: <000401ce6d5c$566ac620$03405260$%kim@samsung.com>
 <20130620121649.GB27196@dhcp22.suse.cz>
 <001e01ce6e15$3d183bd0$b748b370$%kim@samsung.com>
 <001f01ce6e15$b7109950$2531cbf0$%kim@samsung.com>
 <20130621012234.GF11659@bbox> <20130621091944.GC12424@dhcp22.suse.cz>
 <20130621162743.GA2837@gmail.com>
 <CAOK=xRMhwvWrao_ve8GFsk0JBHAcWh_SB_kM6fCujp8WThPimw@mail.gmail.com>
 <CAOK=xRNEMp3igfwQfrz0ffApmoAL19OM0EGLaBJ5RerZy9ddtw@mail.gmail.com>
 <005601ce6f0c$5948ff90$0bdafeb0$%kim@samsung.com> <20130626073557.GD29127@bbox>
In-reply-to: <20130626073557.GD29127@bbox>
Subject: [PATCH v2] vmpressure: consider "scanned < reclaimed" case when
 calculating  a pressure level.
Date: Thu, 27 Jun 2013 15:12:10 +0900
Message-id: <009601ce72fd$427eed70$c77cc850$%kim@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
Content-language: ko
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Michal Hocko' <mhocko@suse.cz>, 'Anton Vorontsov' <anton@enomsg.org>, linux-mm@kvack.org, akpm@linux-foundation.org, rob@landley.net, kamezawa.hiroyu@jp.fujitsu.com, hannes@cmpxchg.org, rientjes@google.com, kirill@shutemov.name, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Minchan Kim' <minchan@kernel.org>

In vmpressure, the pressure level is calculated based on the ratio
of how many pages were scanned vs. reclaimed in a given time window.
However, there is a possibility that "scanned < reclaimed" in such a
case, when reclaiming ends by fatal signal in shrink_inactive_list.
So, with this patch, we just return "low" level when "scanned < reclaimed"
happens not to have userland miss reclaim activity.

Signed-off-by: Hyunhee Kim <hyunhee.kim@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 mm/vmpressure.c |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/mm/vmpressure.c b/mm/vmpressure.c
index 736a601..8c60cad 100644
--- a/mm/vmpressure.c
+++ b/mm/vmpressure.c
@@ -119,6 +119,14 @@ static enum vmpressure_levels vmpressure_calc_level(unsigned long scanned,
 	unsigned long pressure;
 
 	/*
+	 * This could happen, in such a case, when reclaiming ends by fatal
+	 * signal in shrink_inactive_list(). In this case, return
+	 * VMPRESSURE_LOW not to have userland miss reclaim activity.
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
