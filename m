Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id B03926B0038
	for <linux-mm@kvack.org>; Fri,  5 May 2017 09:47:39 -0400 (EDT)
Received: by mail-yb0-f200.google.com with SMTP id f37so3298041ybj.8
        for <linux-mm@kvack.org>; Fri, 05 May 2017 06:47:39 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id k1si2510747ybj.283.2017.05.05.06.47.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 May 2017 06:47:38 -0700 (PDT)
Subject: Re: [PATCH] swap: add block io poll in swapin path
References: <7dd0349ba5d321af557d7a09e08610f2486ea29e.1493930299.git.shli@fb.com>
 <87shkk0zn9.fsf@yhuang-dev.intel.com>
 <20170505051218.GA50755@dhcp-172-20-191-107.dhcp.thefacebook.com>
 <878tmb265d.fsf@yhuang-dev.intel.com>
From: Jens Axboe <axboe@fb.com>
Message-ID: <a260882d-3247-8410-b4fe-bc5f19c90beb@fb.com>
Date: Fri, 5 May 2017 07:47:27 -0600
MIME-Version: 1.0
In-Reply-To: <878tmb265d.fsf@yhuang-dev.intel.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>, Shaohua Li <shli@fb.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Kernel-team@fb.com, Tim Chen <tim.c.chen@intel.com>

On 05/05/2017 12:02 AM, Huang, Ying wrote:
>> The hybrid polling could help. The default hybrid polling poll half
>> the average IO latency. But it will not work very well if the latency
>> becomes very big. The hybrid polling has an interface to allow
>> userspace to configure the poll threshold, but since the latency
>> varies from time to time, it would be very hard to set a single
>> threshold for all workloads.
> 
> If my understanding were correct, the hybrid polling will insert some
> sleep before the polling, but will not restrict the duration of the
> polling itself.  This helps CPU usage, but may not help much for very
> long latency.  How about add another threshold to restrict the max
> polling time?  For example, the sleep time + max polling time could be
> 1.5 * mean latency.  So that most IO requests could be serviced by
> polling, and for very long latency, polling could be restricted to
> reduce CPU usage.

I don't think that's a bad idea at all, there's definitely room for
improvement on how long to sleep and when to completely stop. The stats
track min/avg/max for a given window of time, so it would not be too
hard to implement an appropriate backoff as well.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
