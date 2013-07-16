Return-Path: <owner-linux-mm@kvack.org>
Message-ID: <51E518B8.9030801@cn.fujitsu.com>
Date: Tue, 16 Jul 2013 17:56:08 +0800
From: Gu Zheng <guz.fnst@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH RESEND 0/2] Add support to aio ring pages migration
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Benjamin LaHaise <bcrl@kvack.org>, Al Viro <viro@zeniv.linux.org.uk>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, tangchen <tangchen@cn.fujitsu.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

Currently aio ring pages use get_user_pages() to allocate pages from movable
zone,as discussed in thread https://lkml.org/lkml/2012/11/29/69, it is easy to
pin user pages for a long time, which is fatal for memory hotplug/remove framework.

As Mel Gorman suggested, "Implement a callback for migration to unpin pages,
barrier operations until migration completes and pin the new pfns" can soloved
this issue. And the best palce to hold the callbacks is address space operations
which can be found via page->mapping.

But the current aio ring pages are anonymous pages, they don't have
address_space_operations, so we use an anon inode file as the aio ring file to
manage the aio ring pages, so that we can implement the callback and register it
to page->mmapping->a_ops->migratepage.

But there's a ploblem that all files created by anon_inode_getfile() share the
same inode, so mutil aio context will share the same aio ring pages, it'll lead
to io events chaos. In order to solve this issus, we introduce a new fucntion
anon_inode_getfile_private() which is samilar to anon_inode_getfile(), but each
new file has its own anon inode.

This work is based on Benjamin's patch,
http://www.spinics.net/lists/linux-fsdevel/msg66014.html

Gu Zheng (2):
  fs/anon_inode: Introduce a new lib function anon_inode_getfile_private()
  fs/aio: Add support to aio ring pages migration

 fs/aio.c                    |  120 +++++++++++++++++++++++++++++++++++++++----
 fs/anon_inodes.c            |   66 +++++++++++++++++++++++
 include/linux/anon_inodes.h |    3 +
 include/linux/migrate.h     |    3 +
 mm/migrate.c                |    2 +-
 5 files changed, 182 insertions(+), 12 deletions(-)

-- 
1.7.7


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
