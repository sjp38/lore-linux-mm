Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 736106B000A
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 10:07:45 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id y35so4963273edb.5
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 07:07:45 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n14-v6si1587110edt.57.2018.11.14.07.07.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Nov 2018 07:07:44 -0800 (PST)
Date: Wed, 14 Nov 2018 16:07:42 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [mm PATCH v5 0/7] Deferred page init improvements
Message-ID: <20181114150742.GZ23419@dhcp22.suse.cz>
References: <154145268025.30046.11742652345962594283.stgit@ahduyck-desk1.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <154145268025.30046.11742652345962594283.stgit@ahduyck-desk1.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, davem@davemloft.net, pavel.tatashin@microsoft.com, mingo@kernel.org, kirill.shutemov@linux.intel.com, dan.j.williams@intel.com, dave.jiang@intel.com, rppt@linux.vnet.ibm.com, willy@infradead.org, vbabka@suse.cz, khalid.aziz@oracle.com, ldufour@linux.vnet.ibm.com, mgorman@techsingularity.net, yi.z.zhang@linux.intel.com

On Mon 05-11-18 13:19:25, Alexander Duyck wrote:
> This patchset is essentially a refactor of the page initialization logic
> that is meant to provide for better code reuse while providing a
> significant improvement in deferred page initialization performance.
> 
> In my testing on an x86_64 system with 384GB of RAM and 3TB of persistent
> memory per node I have seen the following. In the case of regular memory
> initialization the deferred init time was decreased from 3.75s to 1.06s on
> average. For the persistent memory the initialization time dropped from
> 24.17s to 19.12s on average. This amounts to a 253% improvement for the
> deferred memory initialization performance, and a 26% improvement in the
> persistent memory initialization performance.
> 
> I have called out the improvement observed with each patch.

I have only glanced through the code (there is a lot of the code to look
at here). And I do not like the code duplication and the way how you
make the hotplug special. There shouldn't be any real reason for that
IMHO (e.g. why do we init pfn-at-a-time in early init while we do
pageblock-at-a-time for hotplug). I might be wrong here and the code
reuse might be really hard to achieve though.

I am also not impressed by new iterators because this api is quite
complex already. But this is mostly a detail.

Thing I do not like is that you keep microptimizing PageReserved part
while there shouldn't be anything fundamental about it. We should just
remove it rather than make the code more complex. I fell more and more
guilty to add there actually.
-- 
Michal Hocko
SUSE Labs
