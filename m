Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 1B4526B0032
	for <linux-mm@kvack.org>; Fri, 23 Jan 2015 11:03:42 -0500 (EST)
Received: by mail-wg0-f49.google.com with SMTP id k14so3893707wgh.8
        for <linux-mm@kvack.org>; Fri, 23 Jan 2015 08:03:41 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id hh5si3270948wib.88.2015.01.23.08.03.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Jan 2015 08:03:40 -0800 (PST)
Date: Fri, 23 Jan 2015 11:03:35 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: mmotm 2015-01-22-15-04: qemu failure due to 'mm: memcontrol:
 remove unnecessary soft limit tree node test'
Message-ID: <20150123160335.GB32592@phnom.home.cmpxchg.org>
References: <54c1822d.RtdGfWPekQVAw8Ly%akpm@linux-foundation.org>
 <20150123050802.GB22751@roeck-us.net>
 <20150123141817.GA22926@phnom.home.cmpxchg.org>
 <54C26CE3.2060001@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54C26CE3.2060001@roeck-us.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Guenter Roeck <linux@roeck-us.net>
Cc: akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, cl@linux.com

On Fri, Jan 23, 2015 at 07:46:43AM -0800, Guenter Roeck wrote:
> I added some debugging. First, the problem is only seen with SMP disabled.
> Second, there is only one online node.
> 
> Without your patch:
> 
> Node 0 online 1 high 1 memory 1 cpu 0 normal 1 tmp 0 rtpn c00000003d240600
> Node 1 online 0 high 0 memory 0 cpu 0 normal 0 tmp -1 rtpn c00000003d240640
> Node 2 online 0 high 0 memory 0 cpu 0 normal 0 tmp -1 rtpn c00000003d240680
> 
> [ and so on up to node 255 ]
> 
> With your patch:
> 
> Node 0 online 1 high 1 memory 1 cpu 0 normal 1 rtpn c00000003d240600
> Unable to handle kernel paging request for data at address 0x0000af50
> Faulting instruction address: 0xc000000000895a3c
> Oops: Kernel access of bad area, sig: 11 [#1]
> 
> The log message is after the call to kzalloc_node.
> 
> So it doesn't look like the fallback is working, at least not with ppc64
> in non-SMP mode.

Yep, and Christoph confirmed that it's not meant to work like that.
The patch is flawed.

Thanks for testing and sorry for breaking your setup.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
