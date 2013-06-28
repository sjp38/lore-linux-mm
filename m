Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 2D1A96B0032
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 10:22:12 -0400 (EDT)
Date: Fri, 28 Jun 2013 17:22:02 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: re: list_lru: per-node list infrastructure
Message-ID: <20130628142202.GA16774@elgon.mountain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dchinner@redhat.com
Cc: linux-mm@kvack.org

Hi Dave,

The patch a8739514fa91: "list_lru: per-node list infrastructure" in -mm
has a signedness bug.

include/linux/list_lru.h
   116  static inline unsigned long
   117  list_lru_walk(struct list_lru *lru, list_lru_walk_cb isolate,
   118                void *cb_arg, unsigned long nr_to_walk)
   119  {
   120          long isolated = 0;
   121          int nid;
   122  
   123          for_each_node_mask(nid, lru->active_nodes) {
   124                  isolated += list_lru_walk_node(lru, nid, isolate,
   125                                                 cb_arg, &nr_to_walk);
   126                  if (nr_to_walk <= 0)
                            ^^^^^^^^^^^^^^^
nr_to_walk is unsigned so the timeout value from list_lru_walk_node() is
ULONG_MAX (it's not zero).

   127                          break;
   128          }
   129          return isolated;
   130  }

regards,
dan carpenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
