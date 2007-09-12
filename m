Date: Wed, 12 Sep 2007 11:43:22 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH] overwride page->mapping [0/3] intro
Message-Id: <20070912114322.e4d8a86e.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>, Christoph Lameter <clameter@sgi.com>, "Lee.Schermerhorn@hp.com" <Lee.Schermerhorn@hp.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

In general, we cannot inclease size of 'struct page'. So, overriding and
adding prural meanings to page struct's member is done in many situation.

But to do some kind of precise VM mamangement, page struct itself seems to be
too small. This patchset overrides page->mapping and add on-demand page
information.

like this:

==
page->mapping points to address_space or anon_vma or mapping_info

mapping_info is strucutured as 

struct mapping_info {
	union {
		anon_vma;
		address_space;
	};
	/* Additional Information to this page */
};

==
This works based on "adding page->mapping interface" patch set, I posted.

My main target is move page_container information to this mapping_info.
By this, we can avoid increasing size of struct page when container is used.

Maybe other men may have other information they want to remember.
This patch set implements mlock_counter on mapping_info as *exmaple*.
(About mlock_counter, overriding page->lru may be able to be used.)


This approach will consume some amount of memory. But I believe this *additional
information* can be tunred off easily if the user doesn't want this.

I'm glad if I can get some comments.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
