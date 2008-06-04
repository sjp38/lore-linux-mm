Date: Wed, 4 Jun 2008 13:58:15 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 0/2] memcg: hierarchy support (v3)
Message-Id: <20080604135815.498eaf82.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "menage@google.com" <menage@google.com>, "xemul@openvz.org" <xemul@openvz.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

Hi, this is third version.

While small changes in codes, the whole _tone_ of code is changed.
I'm not in hurry, any comments are welcome.

based on 2.6.26-rc2-mm1 + memcg patches in -mm queue.

Changes from v2:
 - Named as HardWall policy.
 - rewrote the code to be read easily. changed the name of functions.
 - Added text.
 - supported hierarchy_model parameter.
   Now, no_hierarchy and hardwall_hierarchy is implemented.

HardWall Policy:
  - designed for strict resource isolation under hierarchy.
    Usually, automatic load balancing between cgroup can break the
    users assumption even if it's implemented very well.
  - parent overcommits all children
     parent->usage = resource used by itself + resource moved to children.
     Of course, parent->limit > parent->usage. 
  - when child's limit is set, the resouce moves.
  - no automatic resource moving between parent <-> child

Example)
  1) Assume a cgroup with 1GB limits. (and no tasks belongs to this, now)
     - group_A limit=1G,usage=0M.

  2) create group B, C under A.
     - group A limit=1G, usage=0M
          - group B limit=0M, usage=0M.
          - group C limit=0M, usage=0M.

  3) increase group B's limit to 300M.
     - group A limit=1G, usage=300M.
          - group B limit=300M, usage=0M.
          - group C limit=0M, usage=0M.

  4) increase group C's limit to 500M
     - group A limit=1G, usage=800M.
          - group B limit=300M, usage=0M.
          - group C limit=500M, usage=0M.

  5) reduce group B's limit to 100M
     - group A limit=1G, usage=600M.
          - group B limit=100M, usage=0M.
          - group C limit=500M, usage=0M.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
