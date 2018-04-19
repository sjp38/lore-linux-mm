Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id C1B136B0005
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 16:33:14 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id y16-v6so6356214wrh.22
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 13:33:14 -0700 (PDT)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id s44-v6si3545272wrc.426.2018.04.19.13.33.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Apr 2018 13:33:13 -0700 (PDT)
Date: Thu, 19 Apr 2018 21:33:07 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [LSF/MM] schedule suggestion
Message-ID: <20180419203307.GJ30522@ZenIV.linux.org.uk>
References: <20180418211939.GD3476@redhat.com>
 <20180419015508.GJ27893@dastard>
 <20180419143825.GA3519@redhat.com>
 <20180419144356.GC25406@bombadil.infradead.org>
 <20180419163036.GC3519@redhat.com>
 <1524157119.2943.6.camel@kernel.org>
 <20180419172609.GD3519@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180419172609.GD3519@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Jeff Layton <jlayton@kernel.org>, Matthew Wilcox <willy@infradead.org>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-block@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>

On Thu, Apr 19, 2018 at 01:26:10PM -0400, Jerome Glisse wrote:

> Basicly i want a callback in __fd_install(), do_dup2(), dup_fd() and
> add void * *private_data; to struct fdtable (also a default array to
> struct files_struct). The callback would be part of struct file_operations.
> and only call if it exist (os overhead is only for device driver that
> care).

Hell, *NO*.  This is insane - you would need to maintain extra counts
("how many descriptors refer to this struct file... for this descriptor
table").

Besides, _what_ private_data?  What would own and maintain it?  A specific
driver?  What if more than one of them wants that thing?
 
> Did i miss something fundamental ? copy_files() call dup_fd() so i
> should be all set here.

That looks like an extremely misguided kludge for hell knows what purpose,
almost certainly architecturally insane.  What are you actually trying to
achieve?
