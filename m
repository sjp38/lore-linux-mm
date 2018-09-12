Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 925CC8E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 09:39:35 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id h10-v6so899459eda.9
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 06:39:35 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t24-v6si214015edq.93.2018.09.12.06.39.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Sep 2018 06:39:34 -0700 (PDT)
Date: Wed, 12 Sep 2018 15:39:33 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] memory_hotplug: fix the panic when memory end is not on
 the section boundary
Message-ID: <20180912133933.GI10951@dhcp22.suse.cz>
References: <20180910123527.71209-1-zaslonko@linux.ibm.com>
 <20180910131754.GG10951@dhcp22.suse.cz>
 <20180912150356.642c1dab@thinkpad>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180912150356.642c1dab@thinkpad>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: Mikhail Zaslonko <zaslonko@linux.ibm.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pavel.Tatashin@microsoft.com, osalvador@suse.de

On Wed 12-09-18 15:03:56, Gerald Schaefer wrote:
[...]
> BTW, those sysfs attributes are world-readable, so anyone can trigger
> the panic by simply reading them, or just run lsmem (also available for
> x86 since util-linux 2.32). OK, you need a special not-memory-block-aligned
> mem= parameter and DEBUG_VM for poison check, but w/o DEBUG_VM you would
> still access uninitialized struct pages. This sounds very wrong, and I
> think it really should be fixed.

Ohh, absolutely. Nobody is questioning that. The thing is that the
code has been likely always broken. We just haven't noticed because
those unitialized parts where zeroed previously. Now that the implicit
zeroying is gone it is just visible.

All that I am arguing is that there are many places which assume
pageblocks to be fully initialized and plugging one place that blows up
at the time is just whack a mole. We need to address this much earlier.
E.g. by allowing only full pageblocks when adding a memory range.
-- 
Michal Hocko
SUSE Labs
