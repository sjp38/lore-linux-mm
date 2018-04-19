Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5DEC26B0005
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 15:56:41 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id x5-v6so3545872pln.21
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 12:56:41 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id k14si3840919pfg.321.2018.04.19.12.56.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 19 Apr 2018 12:56:40 -0700 (PDT)
Date: Thu, 19 Apr 2018 12:56:37 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [LSF/MM] schedule suggestion
Message-ID: <20180419195637.GA14024@bombadil.infradead.org>
References: <20180418211939.GD3476@redhat.com>
 <20180419015508.GJ27893@dastard>
 <20180419143825.GA3519@redhat.com>
 <20180419144356.GC25406@bombadil.infradead.org>
 <20180419163036.GC3519@redhat.com>
 <1524157119.2943.6.camel@kernel.org>
 <20180419172609.GD3519@redhat.com>
 <1524162667.2943.22.camel@kernel.org>
 <20180419193108.GA4981@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180419193108.GA4981@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Jeff Layton <jlayton@kernel.org>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-block@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>

On Thu, Apr 19, 2018 at 03:31:08PM -0400, Jerome Glisse wrote:
> > > Basicly i want a callback in __fd_install(), do_dup2(), dup_fd() and
> > > add void * *private_data; to struct fdtable (also a default array to
> > > struct files_struct). The callback would be part of struct file_operations.
> > > and only call if it exist (os overhead is only for device driver that
> > > care).
> > > 
> > > Did i miss something fundamental ? copy_files() call dup_fd() so i
> > > should be all set here.
> > > 
> > > I will work on patches i was hoping this would not be too much work.
> 
> Well scratch that whole idea, i would need to add a new array to task
> struct which make it a lot less appealing. Hence a better solution is
> to instead have this as part of mm (well indirectly).

It shouldn't be too bad to add a struct radix_tree to the fdtable.

I'm sure we could just not support weird cases like sharing the fdtable
without sharing the mm.  Does anyone actually do that?
