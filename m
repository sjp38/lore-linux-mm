Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id D63AD6B0005
	for <linux-mm@kvack.org>; Tue,  9 Feb 2016 13:46:05 -0500 (EST)
Received: by mail-pf0-f175.google.com with SMTP id e127so36193044pfe.3
        for <linux-mm@kvack.org>; Tue, 09 Feb 2016 10:46:05 -0800 (PST)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id g74si55577692pfg.144.2016.02.09.10.46.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Feb 2016 10:46:05 -0800 (PST)
Received: by mail-pa0-x229.google.com with SMTP id ho8so95343513pac.2
        for <linux-mm@kvack.org>; Tue, 09 Feb 2016 10:46:05 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160209172416.GB12245@quack.suse.cz>
References: <20160209172416.GB12245@quack.suse.cz>
Date: Tue, 9 Feb 2016 19:46:05 +0100
Message-ID: <CALXu0Udxe4W9XRaCu=TOa5HE9bHtNcHBeFT6iiXmgUDOJh7iZA@mail.gmail.com>
Subject: Re: Another proposal for DAX fault locking
From: Cedric Blancher <cedric.blancher@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Dave Chinner <david@fromorbit.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org, Dan Williams <dan.j.williams@intel.com>, linux-nvdimm@lists.01.org, mgorman@suse.de, Matthew Wilcox <willy@linux.intel.com>

On 9 February 2016 at 18:24, Jan Kara <jack@suse.cz> wrote:
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
> DAX will have an array of mutexes

One folly here: Arrays of mutexes NEVER work unless you manage to
align them to occupy one complete L2/L3 cache line each. Otherwise the
CPUS will fight over cache lines each time they touch (read or write)
a mutex, and it then becomes a O^n-like scalability problem if
multiple mutexes occupy one cache line. It becomes WORSE as more
mutexes fit into a single cache line and even more worse with the
number of CPUS accessing such contested lines.

Ced
-- 
Cedric Blancher <cedric.blancher@gmail.com>
Institute Pasteur

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
