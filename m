Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 07A136B0657
	for <linux-mm@kvack.org>; Fri, 11 May 2018 02:20:52 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id e15-v6so279651wmh.6
        for <linux-mm@kvack.org>; Thu, 10 May 2018 23:20:51 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id v1-v6si2122817wrm.195.2018.05.10.23.20.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 May 2018 23:20:50 -0700 (PDT)
Date: Fri, 11 May 2018 08:24:35 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 01/33] block: add a lower-level bio_add_page interface
Message-ID: <20180511062435.GD7962@lst.de>
References: <20180509074830.16196-1-hch@lst.de> <20180509074830.16196-2-hch@lst.de> <CACVXFVMPwQV8M0raTcLUtqDix-kEkYV3E3fJSVOVw8m=iiv5Uw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACVXFVMPwQV8M0raTcLUtqDix-kEkYV3E3fJSVOVw8m=iiv5Uw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <tom.leiming@gmail.com>
Cc: Christoph Hellwig <hch@lst.de>, "open list:XFS FILESYSTEM" <linux-xfs@vger.kernel.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, linux-block <linux-block@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Thu, May 10, 2018 at 04:52:00PM +0800, Ming Lei wrote:
> On Wed, May 9, 2018 at 3:47 PM, Christoph Hellwig <hch@lst.de> wrote:
> > For the upcoming removal of buffer heads in XFS we need to keep track of
> > the number of outstanding writeback requests per page.  For this we need
> > to know if bio_add_page merged a region with the previous bvec or not.
> > Instead of adding additional arguments this refactors bio_add_page to
> > be implemented using three lower level helpers which users like XFS can
> > use directly if they care about the merge decisions.
> 
> The merge policy may be transparent to fs, such as multipage bvec.

The whole point of this series it to make it explicit.  That will have to
be carried over into a multipage bvec world.  That means the current
__bio_try_merge_page will have to remain as-is in that new world order,
but we'd also add a new __bio_try_merge_segment which merges beyond th
e page.  For the iomap and xfs code we'd first call __bio_try_merge_page,
if that fails increment the read/write count, and only after that
call __bio_try_merge_segment.
