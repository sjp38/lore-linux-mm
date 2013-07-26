Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id BC59D6B0036
	for <linux-mm@kvack.org>; Fri, 26 Jul 2013 10:27:48 -0400 (EDT)
From: Davidlohr Bueso <davidlohr.bueso@hp.com>
Subject: [PATCH 0/2] hugepage: optimize page fault path locking
Date: Fri, 26 Jul 2013 07:27:23 -0700
Message-Id: <1374848845-1429-1-git-send-email-davidlohr.bueso@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "AneeshKumarK.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Gibson <david@gibson.dropbear.id.au>, Eric B Munson <emunson@mgebm.net>, Anton Blanchard <anton@samba.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <davidlohr.bueso@hp.com>

This patchset attempts to reduce the amount of contention we impose
on the hugetlb_instantiation_mutex by replacing the global mutex with
a table of mutexes, selected based on a hash. The original discussion can 
be found here: http://lkml.org/lkml/2013/7/12/428

Patch 1: Allows the file region tracking list to be serialized by its own rwsem.
This is necessary because the next patch allows concurrent hugepage fault paths,
getting rid of the hugetlb_instantiation_mutex - which protects chains of struct 
file_regionin inode->i_mapping->private_list (VM_MAYSHARE) or vma_resv_map(vma)->regions 
(!VM_MAYSHARE).

Patch 2: From David Gibson, for some reason never made it into the kernel. 
Further cleanups and enhancements from Anton Blanchard and myself.
Details of how the hash key is selected is in the patch.

Davidlohr Bueso (2):
  hugepage: protect file regions with rwsem
  hugepage: allow parallelization of the hugepage fault path

 mm/hugetlb.c | 134 ++++++++++++++++++++++++++++++++++++++++++++++-------------
 1 file changed, 106 insertions(+), 28 deletions(-)

-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
