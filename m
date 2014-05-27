Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id B9BFA6B0098
	for <linux-mm@kvack.org>; Tue, 27 May 2014 10:21:39 -0400 (EDT)
Received: by mail-qg0-f44.google.com with SMTP id i50so13791804qgf.17
        for <linux-mm@kvack.org>; Tue, 27 May 2014 07:21:39 -0700 (PDT)
Received: from qmta03.emeryville.ca.mail.comcast.net (qmta03.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:32])
        by mx.google.com with ESMTP id q16si17491229qay.123.2014.05.27.07.21.38
        for <linux-mm@kvack.org>;
        Tue, 27 May 2014 07:21:39 -0700 (PDT)
Date: Tue, 27 May 2014 09:21:32 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH] page_alloc: skip cpuset enforcement for lower zone
 allocations
In-Reply-To: <20140523193706.GA22854@amt.cnet>
Message-ID: <alpine.DEB.2.10.1405270917510.13999@gentwo.org>
References: <20140523193706.GA22854@amt.cnet>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marcelo Tosatti <mtosatti@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Lai Jiangshan <laijs@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>

On Fri, 23 May 2014, Marcelo Tosatti wrote:

> Zone specific allocations, such as GFP_DMA32, should not be restricted
> to cpusets allowed node list: the zones which such allocations demand
> might be contained in particular nodes outside the cpuset node list.
>
> The alternative would be to not perform such allocations from
> applications which are cpuset restricted, which is unrealistic.
>
> Fixes KVM's alloc_page(gfp_mask=GFP_DMA32) with cpuset as explained.

Memory policies are only applied to a specific zone so this is not
unprecedented. However, if a user wants to limit allocation to a specific
node and there is no DMA memory there then may be that is a operator
error? After all the application will be using memory from a node that the
operator explicitly wanted not to be used.

There is also the hardwall flag. I think its ok to allocate outside of the
cpuset if that flag is not set. However, if it is set then any attempt to
alloc outside of the cpuset should fail.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
