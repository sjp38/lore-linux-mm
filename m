Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 049418E0161
	for <linux-mm@kvack.org>; Thu, 13 Dec 2018 10:56:07 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id n50so2192008qtb.9
        for <linux-mm@kvack.org>; Thu, 13 Dec 2018 07:56:06 -0800 (PST)
Received: from a9-114.smtp-out.amazonses.com (a9-114.smtp-out.amazonses.com. [54.240.9.114])
        by mx.google.com with ESMTPS id t62si1252232qki.223.2018.12.13.07.56.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 13 Dec 2018 07:56:06 -0800 (PST)
Date: Thu, 13 Dec 2018 15:56:05 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder
 versions
In-Reply-To: <20181213020229.GN5037@redhat.com>
Message-ID: <01000167a8483bd2-16ae0d3e-d217-4993-a80a-25d221c677e4-000000@email.amazonses.com>
References: <59ca5c4b-fd5b-1fc6-f891-c7986d91908e@nvidia.com> <7b4733be-13d3-c790-ff1b-ac51b505e9a6@nvidia.com> <20181207191620.GD3293@redhat.com> <3c4d46c0-aced-f96f-1bf3-725d02f11b60@nvidia.com> <20181208022445.GA7024@redhat.com> <20181210102846.GC29289@quack2.suse.cz>
 <20181212150319.GA3432@redhat.com> <20181212214641.GB29416@dastard> <20181212215931.GG5037@redhat.com> <20181213005119.GD29416@dastard> <20181213020229.GN5037@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, Dan Williams <dan.j.williams@intel.com>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, mike.marciniszyn@intel.com, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Wed, 12 Dec 2018, Jerome Glisse wrote:

> On Thu, Dec 13, 2018 at 11:51:19AM +1100, Dave Chinner wrote:
> > > > >     [O1] Avoid write back from a page still being written by either a
> > > > >          device or some direct I/O or any other existing user of GUP.
> >
> > IOWs, you need to mark pages being written to by a GUP as
> > PageWriteback, so all attempts to write the page will block on
> > wait_on_page_writeback() before trying to write the dirty page.
>
> No you don't and you can't for the simple reasons is that the GUP
> of some device driver can last days, weeks, months, years ... so
> it is not something you want to do. Here is what happens today:

I think it would be better to use the established way to block access that
Dave suggests. Maybe deal with the issue of threads being blocked for
a long time instead? Introduce a way to abort these attempts in a
controlled fashion that also allows easy debugging of these conflicts?
