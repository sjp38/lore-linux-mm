Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id DDFD16B004D
	for <linux-mm@kvack.org>; Tue,  4 Dec 2012 03:36:01 -0500 (EST)
Message-ID: <50BDB5E0.7030906@oracle.com>
Date: Tue, 04 Dec 2012 16:35:44 +0800
From: Jeff Liu <jeff.liu@oracle.com>
MIME-Version: 1.0
Subject: [RFC PATCH 0/3] Disable swap cgroup allocation at system boot stage
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: cgroups@vger.kernel.org, Glauber Costa <glommer@parallels.com>

Hello,

Currently, we allocate pages for swap cgroup when the system is booting up.
Which means that a particular size of pre-allocated memory(depending on the total
size of the enabled swap files/partitions) would be wasted if there is no child memcg
being alive.

This patch set is intended to defer the memory allocation for swap cgroup until the first
children of memcg was created. Actually, it was totally inspired by Glabuer's previous
proposed patch set, which can be found at:  
"memcg: do not call page_cgroup_init at system_boot".
http://lwn.net/Articles/517562/

These patches works to me with some sanity check up.  There must have some issues I am not
aware of for now, at least, performing swapon/swapoff when there have child memcg alives
can run into some potential race conditions that would end up go into bad_page() path...
but I'd like to post it early to seek any directions if possible, so that I can continue to
improve it.

Any comments are appreciated, Thanks in advance!
-Jeff

[PATCH 1/3]memcg: refactor pages allocation/free for swap_cgroup
[PATCH 2/3]memcg: disable pages allocation for swap cgroup on system booting up
[PATCH 3/3]memcg: allocate pages for swap cgroup until the first child memcg is alive

 include/linux/page_cgroup.h |   12 ++++
 mm/memcontrol.c             |    3 +
 mm/page_cgroup.c            |  160 +++++++++++++++++++++++++++++++++++++------
 3 files changed, 153 insertions(+), 22 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
