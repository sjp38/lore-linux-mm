Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 740B46B0038
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 23:13:18 -0500 (EST)
Received: by igcph11 with SMTP id ph11so3324285igc.1
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 20:13:18 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTPS id cj4si10351360igb.40.2015.12.02.20.13.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 02 Dec 2015 20:13:17 -0800 (PST)
Date: Thu, 3 Dec 2015 13:14:11 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] mm/vmstat: retrieve more accurate vmstat value
Message-ID: <20151203041410.GA1495@js1304-P5Q-DELUXE>
References: <1448346123-2699-1-git-send-email-iamjoonsoo.kim@lge.com>
 <alpine.DEB.2.20.1511240934130.20512@east.gentwo.org>
 <20151125025735.GC9563@js1304-P5Q-DELUXE>
 <alpine.DEB.2.20.1511251002380.31590@east.gentwo.org>
 <20151126015252.GA13138@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151126015252.GA13138@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Nov 26, 2015 at 10:52:52AM +0900, Joonsoo Kim wrote:
> On Wed, Nov 25, 2015 at 10:04:44AM -0600, Christoph Lameter wrote:
> > > Although vmstat values aren't designed for accuracy, these are already
> > > used by some sensitive places so it is better to be more accurate.
> > 
> > The design is to sacrifice accuracy and the time the updates occur for
> > performance reasons. This is not the purpose the counters were designed
> > for. If you put these demands on the vmstat then you will get complex
> > convoluted code and compromise performance.
> 
> I understand design decision, but, it is better to get value as much
> as accurate if there is no performance problem. My patch would not
> cause much performance degradation because it is just adding one
> this_cpu_read().
> 
> Consider about following example. Current implementation returns
> interesting output if someone do following things.
> 
> v1 = zone_page_state(XXX);
> mod_zone_page_state(XXX, 1);
> v2 = zone_page_state(XXX);
> 
> v2 would be same with v1 in most of cases even if we already update
> it.
> 
> This situation could occurs in page allocation path and others. If
> some task try to allocate many pages, then watermark check returns
> same values until updating vmstat even if some freepage are allocated.
> There are some adjustments for this imprecision but why not do it become
> accurate? I think that this change is reasonable trade-off.
> 
Christoph, any comment?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
