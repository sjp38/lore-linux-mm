Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 4832C82BEF
	for <linux-mm@kvack.org>; Sun,  9 Nov 2014 22:23:22 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id bj1so7359150pad.29
        for <linux-mm@kvack.org>; Sun, 09 Nov 2014 19:23:22 -0800 (PST)
Received: from out4133-66.mail.aliyun.com (out4133-66.mail.aliyun.com. [42.120.133.66])
        by mx.google.com with ESMTP id ny1si6580100pdb.14.2014.11.09.19.23.19
        for <linux-mm@kvack.org>;
        Sun, 09 Nov 2014 19:23:21 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <00a801cffbd8$434189b0$c9c49d10$@alibaba-inc.com> <1433036.WjB5pb09Zh@xorhgos3.pefnos> <545F3556.5000802@suse.cz>
In-Reply-To: <545F3556.5000802@suse.cz>
Subject: Re: Early test: hangs in mm/compact.c w. Linus's 12d7aacab56e9ef185c
Date: Mon, 10 Nov 2014 11:23:15 +0800
Message-ID: <00f301cffc95$ab4adad0$01e09070$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Vlastimil Babka' <vbabka@suse.cz>, "'P. Christeas'" <xrg@linux.gr>, 'linux-kernel' <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org

> >
> > I guess this one would mitigate against Vlastmil's migration scanner issue,
> > wouldn't it?
> 
Nope, I wanted to see  if free pages are low enough.

> Please no, that's a wrong fix. The purpose of compaction is to make the
> high-order watermark meet, not give up.
> 
Yupe, have to spin.

--- a/mm/compaction.c	Sun Nov  9 12:02:59 2014
+++ b/mm/compaction.c	Mon Nov 10 11:12:07 2014
@@ -1074,6 +1074,8 @@ static int compact_finished(struct zone 
 	watermark = low_wmark_pages(zone);
 	watermark += (1 << cc->order);
 
+	if (!zone_watermark_ok(zone, 0, watermark, 0, 0))
+		return COMPACT_SKIPPED;
 	if (!zone_watermark_ok(zone, cc->order, watermark, 0, 0))
 		return COMPACT_CONTINUE;
 
--


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
