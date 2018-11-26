Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5ADAA6B446D
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 18:29:29 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id c3so10104091eda.3
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 15:29:29 -0800 (PST)
Received: from outbound-smtp16.blacknight.com (outbound-smtp16.blacknight.com. [46.22.139.233])
        by mx.google.com with ESMTPS id y33si1215475eda.109.2018.11.26.15.29.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 15:29:27 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp16.blacknight.com (Postfix) with ESMTPS id 919F51C2A16
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 23:29:27 +0000 (GMT)
Date: Mon, 26 Nov 2018 23:29:26 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: Hackbench pipes regression bisected to PSI
Message-ID: <20181126232926.GS23260@techsingularity.net>
References: <20181126133420.GN23260@techsingularity.net>
 <20181126160724.GA21268@cmpxchg.org>
 <20181126165446.GQ23260@techsingularity.net>
 <20181126173218.GA22640@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20181126173218.GA22640@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tejun Heo <tj@kernel.org>, Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org

On Mon, Nov 26, 2018 at 12:32:18PM -0500, Johannes Weiner wrote:
> > 
> > Bit late to notice but this switch should be in
> > Documentation/admin-guide/kernel-parameters.txt. If you really want to
> > match the automatic numa balancing switch then it also should be
> > psi=[enable|disable] instead of psi_enable=[1|0]
> 
> Done and done, thanks. Updated patch:
> 

The following is a comparision using CONFIG_PSI=n as a baseline against
your patch and a vanilla kernel

                         4.20.0-rc4             4.20.0-rc4             4.20.0-rc4
                kconfigdisable-v1r1                vanilla        psidisable-v1r1
Amean     1       1.3100 (   0.00%)      1.3923 (  -6.28%)      1.3427 (  -2.49%)
Amean     3       3.8860 (   0.00%)      4.1230 *  -6.10%*      3.8860 (  -0.00%)
Amean     5       6.8847 (   0.00%)      8.0390 * -16.77%*      6.7727 (   1.63%)
Amean     7       9.9310 (   0.00%)     10.8367 *  -9.12%*      9.9910 (  -0.60%)
Amean     12     16.6577 (   0.00%)     18.2363 *  -9.48%*     17.1083 (  -2.71%)
Amean     18     26.5133 (   0.00%)     27.8833 *  -5.17%*     25.7663 (   2.82%)
Amean     24     34.3003 (   0.00%)     34.6830 (  -1.12%)     32.0450 (   6.58%)
Amean     30     40.0063 (   0.00%)     40.5800 (  -1.43%)     41.5087 (  -3.76%)
Amean     32     40.1407 (   0.00%)     41.2273 (  -2.71%)     39.9417 (   0.50%)

It's showing that the vanilla kernel takes a hit (as the bisection
indicated it would) and that disabling PSI by default is reasonably
close in terms of performance for this particular workload on this
particular machine so;

Tested-by: Mel Gorman <mgorman@techsingularity.net>

Thanks!

-- 
Mel Gorman
SUSE Labs
