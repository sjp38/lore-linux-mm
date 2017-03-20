Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2CE0B6B0388
	for <linux-mm@kvack.org>; Mon, 20 Mar 2017 15:29:45 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id w37so28677535wrc.2
        for <linux-mm@kvack.org>; Mon, 20 Mar 2017 12:29:45 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 63si10343866wmv.111.2017.03.20.12.29.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 20 Mar 2017 12:29:43 -0700 (PDT)
Date: Mon, 20 Mar 2017 15:29:39 -0400
From: Michal Hocko <mhocko@kernel.org>
Subject: memory hotplug and force_remove
Message-ID: <20170320192938.GA11363@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Toshi Kani <toshi.kani@hp.com>, Jiri Kosina <jkosina@suse.cz>, joeyli <jlee@suse.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-api@vger.kernel.org

Hi Rafael,
we have been chasing the following BUG() triggering during the memory
hotremove (remove_memory):
	ret = walk_memory_range(PFN_DOWN(start), PFN_UP(start + size - 1), NULL,
				check_memblock_offlined_cb);
	if (ret)
		BUG();

and it took a while to learn that the issue is caused by
/sys/firmware/acpi/hotplug/force_remove being enabled. I was really
surprised to see such an option because at least for the memory hotplug
it cannot work at all. Memory hotplug fails when the memory is still
in use. Even if we do not BUG() here enforcing the hotplug operation
will lead to problematic behavior later like crash or a silent memory
corruption if the memory gets onlined back and reused by somebody else.

I am wondering what was the motivation for introducing this behavior and
whether there is a way to disallow it for memory hotplug. Or maybe drop
it completely. What would break in such a case?

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
