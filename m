Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 940186B004F
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 14:56:59 -0400 (EDT)
Message-ID: <4A539B11.5020803@redhat.com>
Date: Tue, 07 Jul 2009 14:59:29 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 1/2] vmscan don't isolate too many pages
References: <20090707182947.0C6D.A69D9226@jp.fujitsu.com> <20090707184034.0C70.A69D9226@jp.fujitsu.com>
In-Reply-To: <20090707184034.0C70.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:

> FAQ
> -------
> Q: Why do you compared zone accumulate pages, not individual zone pages?
> A: If we check individual zone, #-of-reclaimer is restricted by smallest zone.
>    it mean decreasing the performance of the system having small dma zone.

That is a clever solution!  I was playing around a bit with
doing it on a per-zone basis.  Your idea is much nicer.

However, I can see one potential problem with your patch:

+		nr_inactive += zone_page_state(zone, NR_INACTIVE_ANON);
+		nr_inactive += zone_page_state(zone, NR_INACTIVE_FILE);
+		nr_isolated += zone_page_state(zone, NR_ISOLATED_ANON);
+		nr_isolated += zone_page_state(zone, NR_ISOLATED_FILE);
+	}
+
+	return nr_isolated > nr_inactive;

What if we ran out of swap space, or are not scanning the
anon list at all for some reason?

It is possible that there are no inactive_file pages left,
with all file pages already isolated, and your function
still letting reclaimers through.

This means you could still get a spurious OOM.

I guess I should mail out my (ugly) approach, so we can
compare the two :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
