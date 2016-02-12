Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 60FF6828DF
	for <linux-mm@kvack.org>; Fri, 12 Feb 2016 17:15:40 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id g62so80039018wme.0
        for <linux-mm@kvack.org>; Fri, 12 Feb 2016 14:15:40 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id mc5si22173203wjb.99.2016.02.12.14.15.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Feb 2016 14:15:39 -0800 (PST)
Date: Fri, 12 Feb 2016 17:15:09 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: computing drop-able caches
Message-ID: <20160212221509.GA31407@cmpxchg.org>
References: <56AAC085.9060509@cisco.com>
 <20160129015534.GA6401@cmpxchg.org>
 <56ABEAA7.1020706@redhat.com>
 <D2DE3289.2B1F3%khalidm@cisco.com>
 <56BB7BC7.4040403@cisco.com>
 <56BB7DDE.8080206@intel.com>
 <56BB8B5E.0@cisco.com>
 <1455228719.15821.18.camel@redhat.com>
 <D2E35753.2BB9D%khalidm@cisco.com>
 <56BE52CE.5070403@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <56BE52CE.5070403@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Khalid Mughal (khalidm)" <khalidm@cisco.com>, Rik van Riel <riel@redhat.com>, "Daniel Walker (danielwa)" <danielwa@cisco.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "xe-kernel@external.cisco.com" <xe-kernel@external.cisco.com>

On Fri, Feb 12, 2016 at 01:46:54PM -0800, Dave Hansen wrote:
> On 02/12/2016 10:01 AM, Khalid Mughal (khalidm) wrote:
> > If you look at the attached pdf, you will notice that OOM messages start
> > to appear when memAvailable is showing 253MB (259228 KB) Free, memFree is
> > 13.5MB (14008 KB) Free, and dropcache based calculation 3Available memory2
> > is showing 21MB (21720 KB) Free.
> > 
> > So, it appears that memAvailable is not as accurate, especially if data is
> > used to warn user about system running low on memory.
> 
> Yep, that's true.
> 
> But, MemAvailable is calculated from some very cheap counters.  The
> "dropcache-based-calculation" requires iterating over every 4k page
> cache page in the system.

It's also completely off when the dominating cache consumer uses
mmap() instead of buffered IO.

> We track dirty and writebackw with counters, so we should theoretically
> be able to pull those out of MemAvailable fairly cheaply.

Yeah, that sounds like a good idea.

But the fact remains that this will never be fully accurate, and there
will always be scenarios where the system will thrash and trigger OOM
before this counter depletes, simply because maintaining uptodate heat
information of the page cache would be crazy expensive.

IMO, the best way to use the MemAvailable counter is to calculate a
utilization percentage against MemTotal, and then maintaining a
healthy number like 80-90% - depending on expected runtime variance
and an educated guess of how hot the page cache is.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
