Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f169.google.com (mail-yw0-f169.google.com [209.85.161.169])
	by kanga.kvack.org (Postfix) with ESMTP id 503546B0005
	for <linux-mm@kvack.org>; Tue,  9 Feb 2016 13:18:54 -0500 (EST)
Received: by mail-yw0-f169.google.com with SMTP id g127so132913914ywf.2
        for <linux-mm@kvack.org>; Tue, 09 Feb 2016 10:18:54 -0800 (PST)
Received: from mail-yw0-x230.google.com (mail-yw0-x230.google.com. [2607:f8b0:4002:c05::230])
        by mx.google.com with ESMTPS id o203si15819230ybo.40.2016.02.09.10.18.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Feb 2016 10:18:53 -0800 (PST)
Received: by mail-yw0-x230.google.com with SMTP id u200so54463450ywf.0
        for <linux-mm@kvack.org>; Tue, 09 Feb 2016 10:18:53 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160209172416.GB12245@quack.suse.cz>
References: <20160209172416.GB12245@quack.suse.cz>
Date: Tue, 9 Feb 2016 10:18:53 -0800
Message-ID: <CAPcyv4g1Z-2BzOfF7KAsSviMeNz+rFS1e1KR-VeE1SJxLYhNBg@mail.gmail.com>
Subject: Re: Another proposal for DAX fault locking
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dave Chinner <david@fromorbit.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Mel Gorman <mgorman@suse.de>, Matthew Wilcox <willy@linux.intel.com>

I l

On Tue, Feb 9, 2016 at 9:24 AM, Jan Kara <jack@suse.cz> wrote:
> Hello,
>
> I was thinking about current issues with DAX fault locking [1] (data
> corruption due to racing faults allocating blocks) and also races which
> currently don't allow us to clear dirty tags in the radix tree due to races
> between faults and cache flushing [2]. Both of these exist because we don't
> have an equivalent of page lock available for DAX. While we have a
> reasonable solution available for problem [1], so far I'm not aware of a
> decent solution for [2]. After briefly discussing the issue with Mel he had
> a bright idea that we could used hashed locks to deal with [2] (and I think
> we can solve [1] with them as well). So my proposal looks as follows:
>
> DAX will have an array of mutexes (the array can be made per device but
> initially a global one should be OK). We will use mutexes in the array as a
> replacement for page lock - we will use hashfn(mapping, index) to get
> particular mutex protecting our offset in the mapping. On fault / page
> mkwrite, we'll grab the mutex similarly to page lock and release it once we
> are done updating page tables. This deals with races in [1]. When flushing
> caches we grab the mutex before clearing writeable bit in page tables
> and clearing dirty bit in the radix tree and drop it after we have flushed
> caches for the pfn. This deals with races in [2].
>
> Thoughts?
>

I like the fact that this makes the locking explicit and
straightforward rather than something more tricky.  Can we make the
hashfn pfn based?  I'm thinking we could later reuse this as part of
the solution for eliminating the need to allocate struct page, and we
don't have the 'mapping' available in all paths...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
