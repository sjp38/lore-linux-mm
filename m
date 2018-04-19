Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4A6516B0006
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 16:15:06 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id j186so4318251qkd.14
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 13:15:06 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id z14-v6si1944350qtg.89.2018.04.19.13.15.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Apr 2018 13:15:04 -0700 (PDT)
Date: Thu, 19 Apr 2018 16:15:02 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [LSF/MM] schedule suggestion
Message-ID: <20180419201502.GA11372@redhat.com>
References: <20180418211939.GD3476@redhat.com>
 <20180419015508.GJ27893@dastard>
 <20180419143825.GA3519@redhat.com>
 <20180419144356.GC25406@bombadil.infradead.org>
 <20180419163036.GC3519@redhat.com>
 <1524157119.2943.6.camel@kernel.org>
 <20180419172609.GD3519@redhat.com>
 <1524162667.2943.22.camel@kernel.org>
 <20180419193108.GA4981@redhat.com>
 <20180419195637.GA14024@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180419195637.GA14024@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Jeff Layton <jlayton@kernel.org>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-block@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>

On Thu, Apr 19, 2018 at 12:56:37PM -0700, Matthew Wilcox wrote:
> On Thu, Apr 19, 2018 at 03:31:08PM -0400, Jerome Glisse wrote:
> > > > Basicly i want a callback in __fd_install(), do_dup2(), dup_fd() and
> > > > add void * *private_data; to struct fdtable (also a default array to
> > > > struct files_struct). The callback would be part of struct file_operations.
> > > > and only call if it exist (os overhead is only for device driver that
> > > > care).
> > > > 
> > > > Did i miss something fundamental ? copy_files() call dup_fd() so i
> > > > should be all set here.
> > > > 
> > > > I will work on patches i was hoping this would not be too much work.
> > 
> > Well scratch that whole idea, i would need to add a new array to task
> > struct which make it a lot less appealing. Hence a better solution is
> > to instead have this as part of mm (well indirectly).
> 
> It shouldn't be too bad to add a struct radix_tree to the fdtable.
> 
> I'm sure we could just not support weird cases like sharing the fdtable
> without sharing the mm.  Does anyone actually do that?

Well like you pointed out what i really want is a 1:1 structure linking
a device struct an a mm_struct. Given that this need to be cleanup when
mm goes away hence tying this to mmu_notifier sounds like a better idea.

I am thinking of adding a hashtable to mmu_notifier_mm using file id for
hash as this should be a good hash value for common cases. I only expect
few drivers to need that (GPU drivers, RDMA). Today GPU drivers do have
a hashtable inside their driver and they has on the mm struct pointer,
i believe hash mmu_notifier_mm using file id will be better.

Jerome
