Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id B61366B0038
	for <linux-mm@kvack.org>; Thu,  4 May 2017 16:55:00 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id o85so9353868qkh.15
        for <linux-mm@kvack.org>; Thu, 04 May 2017 13:55:00 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id 71si3019308qkq.5.2017.05.04.13.54.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 May 2017 13:54:14 -0700 (PDT)
Subject: Re: [PATCH] swap: add block io poll in swapin path
References: <7dd0349ba5d321af557d7a09e08610f2486ea29e.1493930299.git.shli@fb.com>
From: Jens Axboe <axboe@fb.com>
Message-ID: <b1fec49f-5e22-3d0c-1725-09625b3047b0@fb.com>
Date: Thu, 4 May 2017 14:53:59 -0600
MIME-Version: 1.0
In-Reply-To: <7dd0349ba5d321af557d7a09e08610f2486ea29e.1493930299.git.shli@fb.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Kernel-team@fb.com, Tim Chen <tim.c.chen@intel.com>, Huang Ying <ying.huang@intel.com>

On 05/04/2017 02:42 PM, Shaohua Li wrote:
> For fast flash disk, async IO could introduce overhead because of
> context switch. block-mq now supports IO poll, which improves
> performance and latency a lot. swapin is a good place to use this
> technique, because the task is waitting for the swapin page to continue
> execution.

Nitfy!

> In my virtual machine, directly read 4k data from a NVMe with iopoll is
> about 60% better than that without poll. With iopoll support in swapin
> patch, my microbenchmark (a task does random memory write) is about 10%
> ~ 25% faster. CPU utilization increases a lot though, 2x and even 3x CPU
> utilization. This will depend on disk speed though. While iopoll in
> swapin isn't intended for all usage cases, it's a win for latency
> sensistive workloads with high speed swap disk. block layer has knob to
> control poll in runtime. If poll isn't enabled in block layer, there
> should be no noticeable change in swapin.

Did you try with hybrid polling enabled? We should be able to achieve
most of the latency win at much less CPU cost with that.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
