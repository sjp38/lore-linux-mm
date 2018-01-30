Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7A1B06B0005
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 14:17:45 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id z6so12264217iob.3
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 11:17:45 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id t101si8749054ioi.45.2018.01.30.11.17.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jan 2018 11:17:44 -0800 (PST)
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w0UJGqTC075671
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 19:17:43 GMT
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by aserp2130.oracle.com with ESMTP id 2ftw5d0m4v-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 19:17:43 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w0UJCgSp025390
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 19:12:42 GMT
Received: from abhmp0004.oracle.com (abhmp0004.oracle.com [141.146.116.10])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w0UJCfKu025029
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 19:12:42 GMT
Received: by mail-ot0-f181.google.com with SMTP id 73so1853785oti.12
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 11:12:41 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180130182947.GK21609@dhcp22.suse.cz>
References: <20180130083006.GB1245@in.ibm.com> <20180130091600.GA26445@dhcp22.suse.cz>
 <20180130092815.GR21609@dhcp22.suse.cz> <20180130095345.GC1245@in.ibm.com>
 <20180130101141.GW21609@dhcp22.suse.cz> <CAOAebxvAwuQfAErNJa2fwdWCe+yToCLn-vr0+SuyUcdb5corAw@mail.gmail.com>
 <20180130182947.GK21609@dhcp22.suse.cz>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Tue, 30 Jan 2018 14:12:41 -0500
Message-ID: <CAOAebxuf_GWZFPzQZs0r5Mgoq-kcDiqd0kpX6yYqC_XqLG+0PA@mail.gmail.com>
Subject: Re: Memory hotplug not increasing the total RAM
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Bharata B Rao <bharata@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

> You might be very well correct but the hotplug code is quite subtle and
> we do depend on PageReserved at some unexpected places so it is not that
> easy I am afraid. My TODO list in the hotplug is quite long. If you feel
> like you want to work on that I would be more than happy.

You are correct, PageReserved might be tested in offlined memory, if
we go with the proposed solution, we might even need to add "struct
page" poisoning instead of memset(0) in  sparse_add_one_section when
debugging is enabled. Similar to what we do during boot in
memblock_virt_alloc_raw()

The fix would imply to ensure that PageReserved is never tested and
page_to_nid is never executed for offlined memory. I will study for
possible solutions.

Thank you,
Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
