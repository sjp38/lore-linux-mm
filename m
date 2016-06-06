Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0ED9F828EA
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 15:52:40 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id d4so71001203iod.3
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 12:52:40 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id 35si21479431iom.109.2016.06.06.12.52.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jun 2016 12:52:39 -0700 (PDT)
Date: Mon, 6 Jun 2016 22:52:28 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: re: mm: reorganize SLAB freelist randomization
Message-ID: <20160606195228.GA27327@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: thgarnie@google.com
Cc: linux-mm@kvack.org

Hello Thomas Garnier,

The patch aded650eb82e: "mm: reorganize SLAB freelist randomization"
from Jun 5, 2016, leads to the following static checker warning:

	mm/slab_common.c:1160 freelist_randomize()
	warn: why is zero skipped 'i'

mm/slab_common.c
  1146  /* Randomize a generic freelist */
  1147  static void freelist_randomize(struct rnd_state *state, unsigned int *list,
  1148                          size_t count)
  1149  {
  1150          size_t i;
  1151          unsigned int rand;
  1152  
  1153          for (i = 0; i < count; i++)
  1154                  list[i] = i;
  1155  
  1156          /* Fisher-Yates shuffle */
  1157          for (i = count - 1; i > 0; i--) {

This looks like it should be i >= 0.

  1158                  rand = prandom_u32_state(state);
  1159                  rand %= (i + 1);
  1160                  swap(list[i], list[rand]);
  1161          }
  1162  }

regards,
dan carpenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
