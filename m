Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 7F50B6B0031
	for <linux-mm@kvack.org>; Thu, 18 Jul 2013 20:51:27 -0400 (EDT)
Received: by mail-vc0-f174.google.com with SMTP id kw10so2788814vcb.5
        for <linux-mm@kvack.org>; Thu, 18 Jul 2013 17:51:26 -0700 (PDT)
MIME-Version: 1.0
From: Andy Lutomirski <luto@amacapital.net>
Date: Thu, 18 Jul 2013 17:51:06 -0700
Message-ID: <CALCETrVXzXLqvB+S6BMXuFbVGftg5Kwk+fGe1=w1G9S67S_ivA@mail.gmail.com>
Subject: MAP_HUGETLB and MPOL_PREFERRED = SIGBUS
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org

When I mmap anonymous hugepages with MAP_HUGETLB and there are
available (pre-reserved) hugepages available, but only on the wrong
node, things blow up.  The mmap succeeds, as it should (the accounting
here is wrong -- known issue AFAIK, but that's only relevant to
MPOL_BIND or cpusets).  But writing to the resulting page causes a
SIGBUS.

AFAICS the issue is that dequeue_huge_page_vma is calling
huge_zonelist, which returns a single-entry nodemask.  The loop over
allowable zones* will never try other numa zones, and the function
fails.

I'm not sure whether it would be better to try other nodes first or to
try get get a page from the buddy allocator on the preferred node
first, but currently the other nodes' reserved lists are never
checked.  The result is a crash.

Working around this in userspace is going to be a real PITA.  Grr.

* Why is this iterating zones instead of nodes?

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
