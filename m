Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id E02096B7596
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 12:55:18 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id m3so16437055pfj.14
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 09:55:18 -0800 (PST)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id n67si21079429pfk.34.2018.12.05.09.55.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Dec 2018 09:55:17 -0800 (PST)
Message-ID: <19c9f0fe83a857d5858c386a08ca2ddeba7cf27b.camel@linux.intel.com>
Subject: Re: [mm PATCH v6 6/7] mm: Add reserved flag setting to
 set_page_links
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Date: Wed, 05 Dec 2018 09:55:17 -0800
In-Reply-To: <20181205172225.GT1286@dhcp22.suse.cz>
References: 
	<154361452447.7497.1348692079883153517.stgit@ahduyck-desk1.amr.corp.intel.com>
	 <154361479877.7497.2824031260670152276.stgit@ahduyck-desk1.amr.corp.intel.com>
	 <20181205172225.GT1286@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, davem@davemloft.net, pavel.tatashin@microsoft.com, mingo@kernel.org, kirill.shutemov@linux.intel.com, dan.j.williams@intel.com, dave.jiang@intel.com, rppt@linux.vnet.ibm.com, willy@infradead.org, vbabka@suse.cz, khalid.aziz@oracle.com, ldufour@linux.vnet.ibm.com, mgorman@techsingularity.net, yi.z.zhang@linux.intel.com

On Wed, 2018-12-05 at 18:22 +0100, Michal Hocko wrote:
> On Fri 30-11-18 13:53:18, Alexander Duyck wrote:
> > Modify the set_page_links function to include the setting of the reserved
> > flag via a simple AND and OR operation. The motivation for this is the fact
> > that the existing __set_bit call still seems to have effects on performance
> > as replacing the call with the AND and OR can reduce initialization time.
> > 
> > Looking over the assembly code before and after the change the main
> > difference between the two is that the reserved bit is stored in a value
> > that is generated outside of the main initialization loop and is then
> > written with the other flags field values in one write to the page->flags
> > value. Previously the generated value was written and then then a btsq
> > instruction was issued.
> > 
> > On my x86_64 test system with 3TB of persistent memory per node I saw the
> > persistent memory initialization time on average drop from 23.49s to
> > 19.12s per node.
> 
> I have tried to explain why the whole reserved bit doesn't make much
> sense in this code several times already. You keep ignoring that and
> that is highly annoying. Especially when you add a tricky code to
> optimize something that is not really needed.
> 
> Based on that I am not going to waste my time on other patches in this
> series to review and give feedback which might be ignored again.

I got your explanation. However Andrew had already applied the patches
and I had some outstanding issues in them that needed to be addressed.
So I thought it best to send out this set of patches with those fixes
before the code in mm became too stale. I am still working on what to
do about the Reserved bit, and plan to submit it as a follow-up set.
