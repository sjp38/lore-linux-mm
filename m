Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id B51DA6B0005
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 13:29:51 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id o128so11571892pfg.6
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 10:29:51 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n12-v6si68563plk.425.2018.01.30.10.29.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 30 Jan 2018 10:29:50 -0800 (PST)
Date: Tue, 30 Jan 2018 19:29:47 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Memory hotplug not increasing the total RAM
Message-ID: <20180130182947.GK21609@dhcp22.suse.cz>
References: <20180130083006.GB1245@in.ibm.com>
 <20180130091600.GA26445@dhcp22.suse.cz>
 <20180130092815.GR21609@dhcp22.suse.cz>
 <20180130095345.GC1245@in.ibm.com>
 <20180130101141.GW21609@dhcp22.suse.cz>
 <CAOAebxvAwuQfAErNJa2fwdWCe+yToCLn-vr0+SuyUcdb5corAw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOAebxvAwuQfAErNJa2fwdWCe+yToCLn-vr0+SuyUcdb5corAw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Bharata B Rao <bharata@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On Tue 30-01-18 13:11:06, Pavel Tatashin wrote:
> Hi Michal,
> 
> Thank you for taking care of the problem. The patch may introduce a
> small performance regression during normal boot, as we add a branch
> into a hot initialization path. But, it fixes a current problem, so:
> 
> Reviewed-by: Pavel Tatashin <pasha.tatashin@oracle.com>

Thanks!

> However, I think we should change the hotplug code to also not to
> touch the map area until struct pages are initialized.
> 
> Currently, we loop through "struct page"s several times during memory hotplug:
> 
> 1. memset(0) in sparse_add_one_section()
> 2. loop in __add_section() to set do: set_page_node(page, nid); and
> SetPageReserved(page);
> 3. loop in pages_correctly_reserved() to check that SetPageReserved is set.
> 4. loop in memmap_init_zone() to call __init_single_pfn()

You might be very well correct but the hotplug code is quite subtle and
we do depend on PageReserved at some unexpected places so it is not that
easy I am afraid. My TODO list in the hotplug is quite long. If you feel
like you want to work on that I would be more than happy.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
