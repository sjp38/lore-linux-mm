Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 169A46B025F
	for <linux-mm@kvack.org>; Fri, 30 Mar 2018 17:42:14 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id o9so1692144pgv.8
        for <linux-mm@kvack.org>; Fri, 30 Mar 2018 14:42:14 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id x7-v6si4189302pln.175.2018.03.30.14.42.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Mar 2018 14:42:12 -0700 (PDT)
Date: Fri, 30 Mar 2018 17:42:09 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v1] kernel/trace:check the val against the available mem
Message-ID: <20180330174209.4cb77003@gandalf.local.home>
In-Reply-To: <20180330173031.257a491a@gandalf.local.home>
References: <1522320104-6573-1-git-send-email-zhaoyang.huang@spreadtrum.com>
	<20180330102038.2378925b@gandalf.local.home>
	<20180330205356.GA13332@bombadil.infradead.org>
	<20180330173031.257a491a@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Zhaoyang Huang <huangzhaoyang@gmail.com>, Ingo Molnar <mingo@kernel.org>, linux-kernel@vger.kernel.org, kernel-patch-test@lists.linaro.org, Andrew Morton <akpm@linux-foundation.org>, Joel Fernandes <joelaf@google.com>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>

On Fri, 30 Mar 2018 17:30:31 -0400
Steven Rostedt <rostedt@goodmis.org> wrote:

> I'll take a look at si_mem_available() that Joel suggested and see if
> we can make that work.

Wow, this appears to work great! Joel and Zhaoyang, can you test this?

-- Steve

diff --git a/kernel/trace/ring_buffer.c b/kernel/trace/ring_buffer.c
index a2fd3893cc02..32a803626ee2 100644
--- a/kernel/trace/ring_buffer.c
+++ b/kernel/trace/ring_buffer.c
@@ -1164,6 +1164,11 @@ static int __rb_allocate_pages(long nr_pages, struct list_head *pages, int cpu)
 	struct buffer_page *bpage, *tmp;
 	long i;
 
+	/* Check if the available memory is there first */
+	i = si_mem_available();
+	if (i < nr_pages)
+		return -ENOMEM;
+
 	for (i = 0; i < nr_pages; i++) {
 		struct page *page;
 		/*
