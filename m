Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4172E6B0033
	for <linux-mm@kvack.org>; Fri, 24 Nov 2017 08:13:12 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id s28so19574627pfg.6
        for <linux-mm@kvack.org>; Fri, 24 Nov 2017 05:13:12 -0800 (PST)
Received: from JPTOSEGREL01.sonyericsson.com (jptosegrel01.sonyericsson.com. [124.215.201.71])
        by mx.google.com with ESMTPS id h71si17945368pgc.321.2017.11.24.05.13.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Nov 2017 05:13:11 -0800 (PST)
Subject: Re: [PATCH] mm:Add watermark slope for high mark
References: <20171124100707.24190-1-peter.enderborg@sony.com>
 <20171124101457.by7eoblmk357jwnz@dhcp22.suse.cz>
From: peter enderborg <peter.enderborg@sony.com>
Message-ID: <3ff0a870-4a0e-3b8a-ecfd-3db4c6bbd695@sony.com>
Date: Fri, 24 Nov 2017 14:12:56 +0100
MIME-Version: 1.0
In-Reply-To: <20171124101457.by7eoblmk357jwnz@dhcp22.suse.cz>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Language: en-GB
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, "Luis R . Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Alex Deucher <alexander.deucher@amd.com>, "David S .
 Miller" <davem@davemloft.net>, Harry Wentland <Harry.Wentland@amd.com>, Greg
 Kroah-Hartman <gregkh@linuxfoundation.org>, Tony Cheng <Tony.Cheng@amd.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Dave Jiang <dave.jiang@intel.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Hugh
 Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, Vlastimil Babka <vbabka@suse.cz>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Nikolay Borisov <nborisov@suse.com>, Mel Gorman <mgorman@suse.de>, Pavel Tatashin <pasha.tatashin@oracle.com>, Linux API <linux-api@vger.kernel.org>

On 11/24/2017 11:14 AM, Michal Hocko wrote:
> On Fri 24-11-17 11:07:07, Peter Enderborg wrote:
>> When tuning the watermark_scale_factor to reduce stalls and compactions
>> the high mark is also changed, it changed a bit too much. So this
>> patch introduces a slope that can reduce this overhead a bit, or
>> increase it if needed.
> This doesn't explain what is the problem, why it is a problem and why we
> need yet another tuning to address it. Users shouldn't really care about
> internal stuff like watermark tuning for each watermark independently.
> This looks like a gross hack. Please start over with the problem
> description and then we can move on to an approapriate fix. Piling up
> tuning knobs to workaround problems is simply not acceptable.
>  

In the original patch - https://lkml.org/lkml/2016/2/18/498 - had a

discussion about small systems with 8GB RAM. In the handheld world, that's
a lot of RAM. However, the magic number 2 used in the present algorithm
is out of the blue. Compaction problems are the same for both small and
big. So small devices also need to increase watermark to
get compaction to work and reduce direct reclaims. Changing the low watermark
makes direct reclaim rate drop a lot. But it will cause kswap to work more,
and that has a negative impact. Lowering the gap will smooth out the kswap
workload to suite embedded devices a lot better. This can be addressed by
reducing the high watermark using the slope patch herein. Im sort of understand
your opinion on user knobs, but hard-coded magic numbers are even worse.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
