Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id 5A2556B0038
	for <linux-mm@kvack.org>; Mon, 23 Mar 2015 18:40:16 -0400 (EDT)
Received: by qgez102 with SMTP id z102so80118098qge.3
        for <linux-mm@kvack.org>; Mon, 23 Mar 2015 15:40:16 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b2si2215161qkb.29.2015.03.23.15.40.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Mar 2015 15:40:15 -0700 (PDT)
Date: Mon, 23 Mar 2015 18:40:13 -0400
From: Mike Snitzer <snitzer@redhat.com>
Subject: Re: [PATCH 11/12] fs: don't reassign dirty inodes to
 default_backing_dev_info
Message-ID: <20150323224012.GA29505@redhat.com>
References: <1421228561-16857-1-git-send-email-hch@lst.de>
 <1421228561-16857-12-git-send-email-hch@lst.de>
 <CAMM=eLe6Tt+g7dLcnn5a1fQboDknkasazsMiOFBziWPZemnYtg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAMM=eLe6Tt+g7dLcnn5a1fQboDknkasazsMiOFBziWPZemnYtg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: David Howells <dhowells@redhat.com>, linux-nfs@vger.kernel.org, linux-mm@kvack.org, Jens Axboe <axboe@fb.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, device-mapper development <dm-devel@redhat.com>, linux-mtd@lists.infradead.org, Tejun Heo <tj@kernel.org>, ceph-devel@vger.kernel.org, Jeff Moyer <jmoyer@redhat.com>

On Sat, Mar 21 2015 at 11:11am -0400,
Mike Snitzer <snitzer@redhat.com> wrote:

> On Wed, Jan 14, 2015 at 4:42 AM, Christoph Hellwig <hch@lst.de> wrote:
> > If we have dirty inodes we need to call the filesystem for it, even if the
> > device has been removed and the filesystem will error out early.  The
> > current code does that by reassining all dirty inodes to the default
> > backing_dev_info when a bdi is unlinked, but that's pretty pointless given
> > that the bdi must always outlive the super block.
> >
> > Instead of stopping writeback at unregister time and moving inodes to the
> > default bdi just keep the current bdi alive until it is destroyed.  The
> > containing objects of the bdi ensure this doesn't happen until all
> > writeback has finished by erroring out.
> >
> > Signed-off-by: Christoph Hellwig <hch@lst.de>
> > Reviewed-by: Tejun Heo <tj@kernel.org>
> > ---
> >  mm/backing-dev.c | 91 +++++++++++++++-----------------------------------------
> >  1 file changed, 24 insertions(+), 67 deletions(-)
> 
> Hey Christoph,
> 
> Just a heads up: your commit c4db59d31e39ea067c32163ac961e9c80198fd37
> is suspected as the first bad commit in a bisect performed to track
> down the cause of DM crashes reported in this BZ:
> https://bugzilla.redhat.com/show_bug.cgi?id=1202449
> 
> I've yet to look closely at _why_ this commit but figured I'd share
> since this appears to be a 4.0-rcX regression.

FYI, here is the DM fix I've staged for 4.0-rc6.  I'll continue testing
the various DM targets before requesting Linus to pull.
