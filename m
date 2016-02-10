Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 19B206B0254
	for <linux-mm@kvack.org>; Wed, 10 Feb 2016 05:18:43 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id 128so20087183wmz.1
        for <linux-mm@kvack.org>; Wed, 10 Feb 2016 02:18:43 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o69si4450912wmg.74.2016.02.10.02.18.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 10 Feb 2016 02:18:42 -0800 (PST)
Date: Wed, 10 Feb 2016 11:18:57 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: Another proposal for DAX fault locking
Message-ID: <20160210101857.GC12245@quack.suse.cz>
References: <20160209172416.GB12245@quack.suse.cz>
 <CALXu0Udxe4W9XRaCu=TOa5HE9bHtNcHBeFT6iiXmgUDOJh7iZA@mail.gmail.com>
 <20160210081922.GC4763@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160210081922.GC4763@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Cedric Blancher <cedric.blancher@gmail.com>, Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Dave Chinner <david@fromorbit.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org, Dan Williams <dan.j.williams@intel.com>, linux-nvdimm@lists.01.org, Matthew Wilcox <willy@linux.intel.com>

On Wed 10-02-16 08:19:22, Mel Gorman wrote:
> On Tue, Feb 09, 2016 at 07:46:05PM +0100, Cedric Blancher wrote:
> > On 9 February 2016 at 18:24, Jan Kara <jack@suse.cz> wrote:
> > > Hello,
> > >
> > > I was thinking about current issues with DAX fault locking [1] (data
> > > corruption due to racing faults allocating blocks) and also races which
> > > currently don't allow us to clear dirty tags in the radix tree due to races
> > > between faults and cache flushing [2]. Both of these exist because we don't
> > > have an equivalent of page lock available for DAX. While we have a
> > > reasonable solution available for problem [1], so far I'm not aware of a
> > > decent solution for [2]. After briefly discussing the issue with Mel he had
> > > a bright idea that we could used hashed locks to deal with [2] (and I think
> > > we can solve [1] with them as well). So my proposal looks as follows:
> > >
> > > DAX will have an array of mutexes
> > 
> > One folly here: Arrays of mutexes NEVER work unless you manage to
> > align them to occupy one complete L2/L3 cache line each. Otherwise the
> > CPUS will fight over cache lines each time they touch (read or write)
> > a mutex, and it then becomes a O^n-like scalability problem if
> > multiple mutexes occupy one cache line. It becomes WORSE as more
> > mutexes fit into a single cache line and even more worse with the
> > number of CPUS accessing such contested lines.
> > 
> 
> That is a *potential* performance concern although I agree with you in that
> mutex's false sharing a cache line would be a problem. However, it is a
> performance concern that potentially is alleviated by alternative hashing
> where as AFAIK the issues being faced currently are data corruption and
> functional issues. I'd take a performance issue over a data corruption
> issue any day of the week.

Exactly. We have to add *some* locking to fix the data corruption. Cache
aliasing of hashed mutexes may be an issue but I believe the result will be
still better than a single mutex.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
