Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 929906B002B
	for <linux-mm@kvack.org>; Sat, 15 Dec 2012 22:09:26 -0500 (EST)
Date: Sun, 16 Dec 2012 03:09:25 +0000
From: Eric Wong <normalperson@yhbt.net>
Subject: Re: [PATCH] fadvise: perform WILLNEED readahead in a workqueue
Message-ID: <20121216030925.GB28172@dcvr.yhbt.net>
References: <20121215005448.GA7698@dcvr.yhbt.net>
 <20121216024520.GH9806@dastard>
 <20121216030442.GA28172@dcvr.yhbt.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121216030442.GA28172@dcvr.yhbt.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Eric Wong <normalperson@yhbt.net> wrote:
> Perhaps squashing something like the following will work?

Last hunk should've had a return before skip_ra:

--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -264,6 +266,10 @@ void wq_page_cache_readahead(struct address_space *mapping, struct file *filp,
 	req->nr_to_read = nr_to_read;
 
 	queue_work(readahead_wq, &req->work);
+
+	return;
+skip_ra:
+	fput(filp);
 }
 
 /*
-- 
Eric Wong

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
