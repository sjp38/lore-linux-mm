Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 58EB96B0069
	for <linux-mm@kvack.org>; Thu, 27 Nov 2014 00:07:55 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id r10so4208186pdi.27
        for <linux-mm@kvack.org>; Wed, 26 Nov 2014 21:07:55 -0800 (PST)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id nv5si8639964pbc.85.2014.11.26.21.07.52
        for <linux-mm@kvack.org>;
        Wed, 26 Nov 2014 21:07:53 -0800 (PST)
Date: Thu, 27 Nov 2014 14:10:59 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v3 3/8] mm/debug-pagealloc: make debug-pagealloc boottime
 configurable
Message-ID: <20141127051059.GA6755@js1304-P5Q-DELUXE>
References: <1416816926-7756-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1416816926-7756-4-git-send-email-iamjoonsoo.kim@lge.com>
 <20141124145542.08b97076.akpm@linux-foundation.org>
 <20141124234237.GA7824@js1304-P5Q-DELUXE>
 <20141126124936.56cc901e13f27927d7b42aaf@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141126124936.56cc901e13f27927d7b42aaf@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave@sr71.net>, Michal Nazarewicz <mina86@mina86.com>, Jungsoo Son <jungsoo.son@lge.com>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Nov 26, 2014 at 12:49:36PM -0800, Andrew Morton wrote:
> On Tue, 25 Nov 2014 08:42:37 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> 
> > On Mon, Nov 24, 2014 at 02:55:42PM -0800, Andrew Morton wrote:
> > > On Mon, 24 Nov 2014 17:15:21 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> > > 
> > > > Now, we have prepared to avoid using debug-pagealloc in boottime. So
> > > > introduce new kernel-parameter to disable debug-pagealloc in boottime,
> > > > and makes related functions to be disabled in this case.
> > > > 
> > > > Only non-intuitive part is change of guard page functions. Because
> > > > guard page is effective only if debug-pagealloc is enabled, turning off
> > > > according to debug-pagealloc is reasonable thing to do.
> > > > 
> > > > ...
> > > >
> > > > --- a/Documentation/kernel-parameters.txt
> > > > +++ b/Documentation/kernel-parameters.txt
> > > > @@ -858,6 +858,14 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
> > > >  			causing system reset or hang due to sending
> > > >  			INIT from AP to BSP.
> > > >  
> > > > +	disable_debug_pagealloc
> > > > +			[KNL] When CONFIG_DEBUG_PAGEALLOC is set, this
> > > > +			parameter allows user to disable it at boot time.
> > > > +			With this parameter, we can avoid allocating huge
> > > > +			chunk of memory for debug pagealloc and then
> > > > +			the system will work mostly same with the kernel
> > > > +			built without CONFIG_DEBUG_PAGEALLOC.
> > > > +
> > > 
> > > Weren't we going to make this default to "off", require a boot option
> > > to turn debug_pagealloc on?
> > 
> > Hello, Andrew.
> > 
> > I'm afraid that changing default to "off" confuses some old users.
> > They would expect that it is default "on". But, it is just debug
> > feature, so, it may be no problem. If you prefer to change default, I
> > will rework this patch. Please let me know your decision.
> 
> I suspect the number of "old users" is one ;)
> 
> I think it would be better to default to off - that's the typical
> behaviour for debug features, for good reasons.

Okay.
Here goes the patch.

------------->8----------------
