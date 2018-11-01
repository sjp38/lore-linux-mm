Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 350606B0005
	for <linux-mm@kvack.org>; Thu,  1 Nov 2018 05:11:01 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id x8-v6so19918318qtc.15
        for <linux-mm@kvack.org>; Thu, 01 Nov 2018 02:11:01 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u79si2443113qki.223.2018.11.01.02.10.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Nov 2018 02:11:00 -0700 (PDT)
Date: Thu, 1 Nov 2018 17:10:55 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Memory hotplug failed to offline on bare metal system of multiple
 nodes
Message-ID: <20181101091055.GA15166@MiWiFi-R3L-srv>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,

A hot removal failure was met on one bare metal system with 8 nodes, and
node1~7 are all hotpluggable and 'movable_node' is set. When try to check
value of  /sys/devices/system/node/node1/memory*/removable, found some of
them are 0, namely un-removable. And a back trace will always be seen. After
bisecting, it points at criminal commit:

  15c30bc09085  ("mm, memory_hotplug: make has_unmovable_pages more robust")

Reverting it fix the failure, and node1~7 can be hot removed and hot
added again. From the log of commit 15c30bc09085, it's to fix a
movable_core setting issue which we allocated node_data firstly in
initmem_init(), then try to mark it as movable in mm_init(). We may need
think about it further to fix it, meanwhile not breaking bare metal
system.

I haven't figured out why the above commit caused those memmory
block in MOVABL zone being not removable. Still checking. Attach the
tested reverting patch in this mail.

Thanks
Baoquan
