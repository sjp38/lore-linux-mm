Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id EE95B6B0005
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 04:53:54 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id a1so6634686qkb.17
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 01:53:54 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id h20si807596qta.418.2018.01.30.01.53.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jan 2018 01:53:54 -0800 (PST)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w0U9nxtv097116
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 04:53:53 -0500
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2ftkb6gc9d-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 04:53:53 -0500
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bharata@linux.vnet.ibm.com>;
	Tue, 30 Jan 2018 09:53:51 -0000
Date: Tue, 30 Jan 2018 15:23:45 +0530
From: Bharata B Rao <bharata@linux.vnet.ibm.com>
Subject: Re: Memory hotplug not increasing the total RAM
Reply-To: bharata@linux.vnet.ibm.com
References: <20180130083006.GB1245@in.ibm.com>
 <20180130091600.GA26445@dhcp22.suse.cz>
 <20180130092815.GR21609@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180130092815.GR21609@dhcp22.suse.cz>
Message-Id: <20180130095345.GC1245@in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, pasha.tatashin@oracle.com

On Tue, Jan 30, 2018 at 10:28:15AM +0100, Michal Hocko wrote:
> On Tue 30-01-18 10:16:00, Michal Hocko wrote:
> > On Tue 30-01-18 14:00:06, Bharata B Rao wrote:
> > > Hi,
> > > 
> > > With the latest upstream, I see that memory hotplug is not working
> > > as expected. The hotplugged memory isn't seen to increase the total
> > > RAM pages. This has been observed with both x86 and Power guests.
> > > 
> > > 1. Memory hotplug code intially marks pages as PageReserved via
> > > __add_section().
> > > 2. Later the struct page gets cleared in __init_single_page().
> > > 3. Next online_pages_range() increments totalram_pages only when
> > >    PageReserved is set.
> > 
> > You are right. I have completely forgot about this late struct page
> > initialization during onlining. memory hotplug really doesn't want
> > zeroying. Let me think about a fix.
> 
> Could you test with the following please? Not an act of beauty but
> we are initializing memmap in sparse_add_one_section for memory
> hotplug. I hate how this is different from the initialization case
> but there is quite a long route to unify those two... So a quick
> fix should be as follows.

Tested on Power guest, fixes the issue. I can now see the total memory
size increasing after hotplug.

Regards,
Bharata.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
