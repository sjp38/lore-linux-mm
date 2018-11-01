Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4A5BF6B0007
	for <linux-mm@kvack.org>; Thu,  1 Nov 2018 05:22:15 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id y5-v6so9463727edp.7
        for <linux-mm@kvack.org>; Thu, 01 Nov 2018 02:22:15 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p88-v6si2001174edb.93.2018.11.01.02.22.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Nov 2018 02:22:14 -0700 (PDT)
Date: Thu, 1 Nov 2018 10:22:12 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Memory hotplug failed to offline on bare metal system of
 multiple nodes
Message-ID: <20181101092212.GB23921@dhcp22.suse.cz>
References: <20181101091055.GA15166@MiWiFi-R3L-srv>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181101091055.GA15166@MiWiFi-R3L-srv>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baoquan He <bhe@redhat.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 01-11-18 17:10:55, Baoquan He wrote:
> Hi,
> 
> A hot removal failure was met on one bare metal system with 8 nodes, and
> node1~7 are all hotpluggable and 'movable_node' is set. When try to check
> value of  /sys/devices/system/node/node1/memory*/removable, found some of
> them are 0, namely un-removable. And a back trace will always be seen. After
> bisecting, it points at criminal commit:
> 
>   15c30bc09085  ("mm, memory_hotplug: make has_unmovable_pages more robust")
> 
> Reverting it fix the failure, and node1~7 can be hot removed and hot
> added again. From the log of commit 15c30bc09085, it's to fix a
> movable_core setting issue which we allocated node_data firstly in
> initmem_init(), then try to mark it as movable in mm_init(). We may need
> think about it further to fix it, meanwhile not breaking bare metal
> system.
> 
> I haven't figured out why the above commit caused those memmory
> block in MOVABL zone being not removable. Still checking. Attach the
> tested reverting patch in this mail.

Could you check which of the test inside has_unmovable_pages claimed the
failure? Going back to marking movable_zone as guaranteed to offline is
just too fragile.
-- 
Michal Hocko
SUSE Labs
