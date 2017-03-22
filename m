Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2571E6B0333
	for <linux-mm@kvack.org>; Wed, 22 Mar 2017 04:02:02 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e126so94509760pfg.3
        for <linux-mm@kvack.org>; Wed, 22 Mar 2017 01:02:02 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id y2si835432pgy.46.2017.03.22.01.01.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Mar 2017 01:02:00 -0700 (PDT)
Date: Wed, 22 Mar 2017 16:02:06 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: Re: [PATCH v2 0/5] mm: support parallel free of memory
Message-ID: <20170322080206.GB2360@aaronlu.sh.intel.com>
References: <1489568404-7817-1-git-send-email-aaron.lu@intel.com>
 <20170315141813.GB32626@dhcp22.suse.cz>
 <20170315154406.GF2442@aaronlu.sh.intel.com>
 <20170315162843.GA27197@dhcp22.suse.cz>
 <1489613914.2733.96.camel@linux.intel.com>
 <20170316090732.GF30501@dhcp22.suse.cz>
 <ae4e3597-f664-e5c4-97fb-e07f230d5017@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <ae4e3597-f664-e5c4-97fb-e07f230d5017@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Michal Hocko <mhocko@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tim Chen <tim.c.chen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Ying Huang <ying.huang@intel.com>

On Tue, Mar 21, 2017 at 07:54:37AM -0700, Dave Hansen wrote:
> On 03/16/2017 02:07 AM, Michal Hocko wrote:
> > On Wed 15-03-17 14:38:34, Tim Chen wrote:
> >> max_active:   time
> >> 1             8.9s   +-0.5%
> >> 2             5.65s  +-5.5%
> >> 4             4.84s  +-0.16%
> >> 8             4.77s  +-0.97%
> >> 16            4.85s  +-0.77%
> >> 32            6.21s  +-0.46%
> > 
> > OK, but this will depend on the HW, right? Also now that I am looking at
> > those numbers more closely. This was about unmapping 320GB area and
> > using 4 times more CPUs you managed to half the run time. Is this really
> > worth it? Sure if those CPUs were idle then this is a clear win but if
> > the system is moderately busy then it doesn't look like a clear win to
> > me.
> 
> This still suffers from zone lock contention.  It scales much better if
> we are freeing memory from more than one zone.  We would expect any
> other generic page allocator scalability improvements to really help
> here, too.
> 
> Aaron, could you make sure to make sure that the memory being freed is
> coming from multiple NUMA nodes?  It might also be interesting to boot

The test machine has 4 nodes and each has 128G memory.
With the test size of 320G, at least 3 nodes are involved.

But since the test is done on an idle system, I *guess* the allocated
memory is physically continuous. Then when they are freed in virtually
continuous order, it's likely that one after another physically continous
1G chunk are sent to the free kworkers. So roughly for the first
128 1G chunks, those workers will all be contending on the same zone.
(well, it shouldn't be 128 kworkers all runnable contending for the same
lock since early launched kworkers will have exited after finishing its
job before some later launched kworkers start).

> with a fake NUMA configuration with a *bunch* of nodes to see what the
> best case looks like when zone lock contention isn't even in play where
> one worker would be working on its own zone.

Good idea, will post results here once I finished the test.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
