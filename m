Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id D43AC6B0257
	for <linux-mm@kvack.org>; Mon, 22 Feb 2016 06:05:13 -0500 (EST)
Received: by mail-wm0-f48.google.com with SMTP id g62so166549511wme.1
        for <linux-mm@kvack.org>; Mon, 22 Feb 2016 03:05:13 -0800 (PST)
Received: from mail-wm0-x230.google.com (mail-wm0-x230.google.com. [2a00:1450:400c:c09::230])
        by mx.google.com with ESMTPS id q7si37218916wje.36.2016.02.22.03.05.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Feb 2016 03:05:12 -0800 (PST)
Received: by mail-wm0-x230.google.com with SMTP id b205so150254995wmb.1
        for <linux-mm@kvack.org>; Mon, 22 Feb 2016 03:05:12 -0800 (PST)
Message-ID: <56CAEB65.3080807@plexistor.com>
Date: Mon, 22 Feb 2016 13:05:09 +0200
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: Re: [RFC 0/2] New MAP_PMEM_AWARE mmap flag
References: <56C9EDCF.8010007@plexistor.com>	<CAPcyv4iqAXryz0-WAtvnYf6_Q=ha8F5b-fCUt7DDhYasX=YRUA@mail.gmail.com>	<56CA1CE7.6050309@plexistor.com>	<CAPcyv4hpxab=c1g83ARJvrnk_5HFkqS-t3sXpwaRBiXzehFwWQ@mail.gmail.com>	<56CA2AC9.7030905@plexistor.com> <CAPcyv4gQV9Oh9OpHTGuGfTJ_s1C_L7J-VGyto3JMdAcgqyVeAw@mail.gmail.com>
In-Reply-To: <CAPcyv4gQV9Oh9OpHTGuGfTJ_s1C_L7J-VGyto3JMdAcgqyVeAw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dave Chinner <david@fromorbit.com>, Oleg Nesterov <oleg@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, Arnd Bergmann <arnd@arndb.de>

On 02/22/2016 12:03 AM, Dan Williams wrote:
> On Sun, Feb 21, 2016 at 1:23 PM, Boaz Harrosh <boaz@plexistor.com> wrote:
<>
>> I have manually tested all this and it seems to work. Can you see
>> a theoretical scenario where it would not?
> 
> I'm worried about the scenario where the pmem aware app assumes that
> none of the cachelines in its mapping are dirty when it goes to issue
> pcommit.  We'll have two applications with different perceptions of
> when writes are durable.  

Warning rant: Rrrr the theoretical pcommit. We have built mountains
on a none existing CPU. Show me a pcomit already.

But yes pcommit changes nothing.

> Maybe it's not a problem in practice, at
> least current generation x86 cpus flush existing dirty cachelines when
> performing non-temporal stores.  However, it bothers me that there are
> cpus where a pmem-unaware app could prevent a pmem-aware app from
> making writes durable.  It seems if one app has established a
> MAP_PMEM_AWARE mapping it needs guarantees that all apps participating
> in that shared mapping have the same awareness.
> 

But we are not breaking any current POSIX guaranties. You are thinking
memory, but this is POSIX filesystem semantics. This is all up to the
application.

Consider a regular page-cached FS, and your above two applications,
(Which BTW do not exist exactly because). Both are doing a write not
to a cacheline to a page even:

App 1			app2
- write block X		...
- sync			write block X

- 		POWER OFF

There is no guaranty that app 1 version is what will be read
after mount. Any random amount of app2 changes can be seen.
In fact even while the pages are in DMA they can change.

All that is guarantied is that the page will be marked dirty
because app 2 dirty it even though app 1 submitted it to be
cleaned.
And is what we have. If app 2 is pmem-unaware the page is added
to the radix tree, come sync time it will cl_flush.

In Any which case after the write storms end, and a final
sync is preformed we should have an image of the very last
writes. This is POSIX. And this is kept here.

So no no need for "shared mapping have the same awareness"

[BTW: coming from the NFS world all this is one big lough
 because there we don't even have a read concurrent write
 guaranty let alone a write vs write guaranty.]

> Another potential issue is that MAP_PMEM_AWARE is not enough on its
> own.  If the filesystem or inode does not support DAX the application
> needs to assume page cache semantics.  At a minimum MAP_PMEM_AWARE
> requests would need to fail if DAX is not available.
> 

Yes good idea, will do.

Shalom
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
