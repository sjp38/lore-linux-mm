Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 3484B6B004D
	for <linux-mm@kvack.org>; Wed,  4 Jan 2012 19:37:21 -0500 (EST)
Message-ID: <4F04F0B9.5040401@fb.com>
Date: Wed, 4 Jan 2012 16:37:13 -0800
From: Arun Sharma <asharma@fb.com>
MIME-Version: 1.0
Subject: MAP_NOZERO revisited
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Davide Libenzi <davidel@xmailserver.org>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <balbir@linux.vnet.ibm.com>


A few years ago, Davide posted patches to address clear_page() showing 
up high in the kernel profiles.

http://thread.gmane.org/gmane.linux.kernel/548928

With malloc implementations that try to conserve the RSS by madvising 
away unused pages that are dirty (i.e. faulted in), we pay a high cost 
in clear_page() if that page is needed later by the same process.

Now that we have memcgs with their own LRU lists, I was thinking of a 
MAP_NOZERO implementation that tries to avoid zero'ing the page if it's 
coming from the same memcg.

This will probably need an extra PCG_* flag maintaining state about 
whether the page was moved between memcgs since last use.

Security implications: this is not as good as the UID based checks in 
Davide's implementation, so should probably be an opt-in instead of 
being enabled by default.

Comments?

  -Arun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
