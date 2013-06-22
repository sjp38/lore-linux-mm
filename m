Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id C69946B0031
	for <linux-mm@kvack.org>; Sat, 22 Jun 2013 01:50:08 -0400 (EDT)
Received: from epcpsbgr3.samsung.com
 (u143.gpu120.samsung.co.kr [203.254.230.143])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MOS00GMG5J4JJ70@mailout1.samsung.com> for linux-mm@kvack.org;
 Sat, 22 Jun 2013 14:50:07 +0900 (KST)
From: Hyunhee Kim <hyunhee.kim@samsung.com>
References: 
 <CAOK=xRMz+qX=CQ+3oD6TsEiGckMAdGJ-GAUC8o6nQpx4SJtQPw@mail.gmail.com>
 <20130618110151.GI13677@dhcp22.suse.cz>
 <00fd01ce6ce0$82eac0a0$88c041e0$%kim@samsung.com>
 <20130619125329.GB16457@dhcp22.suse.cz>
 <000401ce6d5c$566ac620$03405260$%kim@samsung.com>
 <20130620121649.GB27196@dhcp22.suse.cz>
 <001e01ce6e15$3d183bd0$b748b370$%kim@samsung.com>
 <001f01ce6e15$b7109950$2531cbf0$%kim@samsung.com>
 <20130621012234.GF11659@bbox> <20130621091944.GC12424@dhcp22.suse.cz>
 <20130621162743.GA2837@gmail.com>
 <CAOK=xRMhwvWrao_ve8GFsk0JBHAcWh_SB_kM6fCujp8WThPimw@mail.gmail.com>
 <CAOK=xRNEMp3igfwQfrz0ffApmoAL19OM0EGLaBJ5RerZy9ddtw@mail.gmail.com>
In-reply-to: 
 <CAOK=xRNEMp3igfwQfrz0ffApmoAL19OM0EGLaBJ5RerZy9ddtw@mail.gmail.com>
Subject: [PATCH] memcg: consider "scanned < reclaimed" case when calculating
Date: Sat, 22 Jun 2013 14:50:06 +0900
Message-id: <005601ce6f0c$5948ff90$0bdafeb0$%kim@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
Content-language: ko
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Hyunhee Kim' <hyunhee.kim@samsung.com>, 'Minchan Kim' <minchan@kernel.org>, 'Michal Hocko' <mhocko@suse.cz>, 'Anton Vorontsov' <anton@enomsg.org>, linux-mm@kvack.org, akpm@linux-foundation.org, rob@landley.net, kamezawa.hiroyu@jp.fujitsu.com, hannes@cmpxchg.org, rientjes@google.com, kirill@shutemov.name, 'Kyungmin Park' <kyungmin.park@samsung.com>

In vmpressure, the pressure level is calculated based on the ratio
of how many pages were scanned vs. reclaimed in a given time window.
However, there is a possibility that "scanned < reclaimed" in such
a case, THP page is reclaimed or reclaiming is abandoned by fatal
signal in shrink_inactive_list, etc. So, with this patch, we just
return "low" level when "scanned < reclaimed" by assuming that
there are enough reclaimed pages.

Signed-off-by: Hyunhee Kim <hyunhee.kim@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 mm/vmpressure.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/vmpressure.c b/mm/vmpressure.c
index 736a601..c6560f3 100644
--- a/mm/vmpressure.c
+++ b/mm/vmpressure.c
@@ -118,6 +118,9 @@ static enum vmpressure_levels vmpressure_calc_level(unsigned long scanned,
 	unsigned long scale = scanned + reclaimed;
 	unsigned long pressure;
 
+	if (reclaimed > scanned)
+		return VMPRESSURE_LOW;
+
 	/*
 	 * We calculate the ratio (in percents) of how many pages were
 	 * scanned vs. reclaimed in a given time frame (window). Note that
-- 
1.7.9.5


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
