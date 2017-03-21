Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 272466B0388
	for <linux-mm@kvack.org>; Tue, 21 Mar 2017 10:54:50 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id c23so314110990pfj.0
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 07:54:50 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id y21si21487887pgi.329.2017.03.21.07.54.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Mar 2017 07:54:49 -0700 (PDT)
Subject: Re: [PATCH v2 0/5] mm: support parallel free of memory
References: <1489568404-7817-1-git-send-email-aaron.lu@intel.com>
 <20170315141813.GB32626@dhcp22.suse.cz>
 <20170315154406.GF2442@aaronlu.sh.intel.com>
 <20170315162843.GA27197@dhcp22.suse.cz>
 <1489613914.2733.96.camel@linux.intel.com>
 <20170316090732.GF30501@dhcp22.suse.cz>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <ae4e3597-f664-e5c4-97fb-e07f230d5017@intel.com>
Date: Tue, 21 Mar 2017 07:54:37 -0700
MIME-Version: 1.0
In-Reply-To: <20170316090732.GF30501@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>
Cc: Aaron Lu <aaron.lu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tim Chen <tim.c.chen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Ying Huang <ying.huang@intel.com>

On 03/16/2017 02:07 AM, Michal Hocko wrote:
> On Wed 15-03-17 14:38:34, Tim Chen wrote:
>> max_active:   time
>> 1             8.9s   +-0.5%
>> 2             5.65s  +-5.5%
>> 4             4.84s  +-0.16%
>> 8             4.77s  +-0.97%
>> 16            4.85s  +-0.77%
>> 32            6.21s  +-0.46%
> 
> OK, but this will depend on the HW, right? Also now that I am looking at
> those numbers more closely. This was about unmapping 320GB area and
> using 4 times more CPUs you managed to half the run time. Is this really
> worth it? Sure if those CPUs were idle then this is a clear win but if
> the system is moderately busy then it doesn't look like a clear win to
> me.

This still suffers from zone lock contention.  It scales much better if
we are freeing memory from more than one zone.  We would expect any
other generic page allocator scalability improvements to really help
here, too.

Aaron, could you make sure to make sure that the memory being freed is
coming from multiple NUMA nodes?  It might also be interesting to boot
with a fake NUMA configuration with a *bunch* of nodes to see what the
best case looks like when zone lock contention isn't even in play where
one worker would be working on its own zone.

>>> Moreover, and this is a more generic question, is this functionality
>>> useful in general purpose workloads? 
>>
>> If we are running consecutive batch jobs, this optimization
>> should help start the next job sooner.
> 
> Is this sufficient justification to add a potentially hard to tune
> optimization that can influence other workloads on the machine?

The guys for whom a reboot is faster than a single exit() certainly
think so. :)

I have the feeling that we can find a pretty sane large process size to
be the floor where this feature gets activated.  I doubt the systems
that really care about noise from other workloads are often doing
multi-gigabyte mapping teardowns.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
