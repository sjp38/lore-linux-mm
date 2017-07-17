Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 21C4C6B0292
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 12:02:38 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id c12so169347242pfj.12
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 09:02:38 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id p18si2242324pgc.484.2017.07.17.09.02.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jul 2017 09:02:36 -0700 (PDT)
Subject: Re: [RFC PATCH v1 5/6] mm: parallelize clear_gigantic_page
References: <1500070573-3948-1-git-send-email-daniel.m.jordan@oracle.com>
 <1500070573-3948-6-git-send-email-daniel.m.jordan@oracle.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <398e9887-6d6e-e1d3-abcf-43a6d7496bc8@intel.com>
Date: Mon, 17 Jul 2017 09:02:36 -0700
MIME-Version: 1.0
In-Reply-To: <1500070573-3948-6-git-send-email-daniel.m.jordan@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: daniel.m.jordan@oracle.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 07/14/2017 03:16 PM, daniel.m.jordan@oracle.com wrote:
> Machine:  Intel(R) Xeon(R) CPU E7-8895 v3 @ 2.60GHz, 288 cpus, 1T memory
> Test:    Clear a range of gigantic pages
> nthread   speedup   size (GiB)   min time (s)   stdev
>       1                    100          41.13    0.03
>       2     2.03x          100          20.26    0.14
>       4     4.28x          100           9.62    0.09
>       8     8.39x          100           4.90    0.05
>      16    10.44x          100           3.94    0.03
...
>       1                    800         434.91    1.81
>       2     2.54x          800         170.97    1.46
>       4     4.98x          800          87.38    1.91
>       8    10.15x          800          42.86    2.59
>      16    12.99x          800          33.48    0.83

What was the actual test here?  Did you just use sysfs to allocate 800GB
of 1GB huge pages?

This test should be entirely memory-bandwidth-limited, right?  Are you
contending here that a single core can only use 1/10th of the memory
bandwidth when clearing a page?

Or, does all the gain here come because we are round-robin-allocating
the pages across all 8 NUMA nodes' memory controllers and the speedup
here is because we're not doing the clearing across the interconnect?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
