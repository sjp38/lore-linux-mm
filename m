Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id A0D946B0038
	for <linux-mm@kvack.org>; Sat, 21 Mar 2015 11:11:30 -0400 (EDT)
Received: by igbqf9 with SMTP id qf9so9533010igb.1
        for <linux-mm@kvack.org>; Sat, 21 Mar 2015 08:11:30 -0700 (PDT)
Received: from mail-ig0-x22e.google.com (mail-ig0-x22e.google.com. [2607:f8b0:4001:c05::22e])
        by mx.google.com with ESMTPS id d65si6946122iod.11.2015.03.21.08.11.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 21 Mar 2015 08:11:29 -0700 (PDT)
Received: by ignm3 with SMTP id m3so8256247ign.0
        for <linux-mm@kvack.org>; Sat, 21 Mar 2015 08:11:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1421228561-16857-12-git-send-email-hch@lst.de>
References: <1421228561-16857-1-git-send-email-hch@lst.de> <1421228561-16857-12-git-send-email-hch@lst.de>
From: Mike Snitzer <snitzer@redhat.com>
Date: Sat, 21 Mar 2015 11:11:09 -0400
Message-ID: <CAMM=eLe6Tt+g7dLcnn5a1fQboDknkasazsMiOFBziWPZemnYtg@mail.gmail.com>
Subject: Re: [PATCH 11/12] fs: don't reassign dirty inodes to default_backing_dev_info
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Jens Axboe <axboe@fb.com>, David Howells <dhowells@redhat.com>, Tejun Heo <tj@kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org, linux-mtd@lists.infradead.org, linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org, device-mapper development <dm-devel@redhat.com>

On Wed, Jan 14, 2015 at 4:42 AM, Christoph Hellwig <hch@lst.de> wrote:
> If we have dirty inodes we need to call the filesystem for it, even if the
> device has been removed and the filesystem will error out early.  The
> current code does that by reassining all dirty inodes to the default
> backing_dev_info when a bdi is unlinked, but that's pretty pointless given
> that the bdi must always outlive the super block.
>
> Instead of stopping writeback at unregister time and moving inodes to the
> default bdi just keep the current bdi alive until it is destroyed.  The
> containing objects of the bdi ensure this doesn't happen until all
> writeback has finished by erroring out.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Reviewed-by: Tejun Heo <tj@kernel.org>
> ---
>  mm/backing-dev.c | 91 +++++++++++++++-----------------------------------------
>  1 file changed, 24 insertions(+), 67 deletions(-)

Hey Christoph,

Just a heads up: your commit c4db59d31e39ea067c32163ac961e9c80198fd37
is suspected as the first bad commit in a bisect performed to track
down the cause of DM crashes reported in this BZ:
https://bugzilla.redhat.com/show_bug.cgi?id=1202449

I've yet to look closely at _why_ this commit but figured I'd share
since this appears to be a 4.0-rcX regression.

Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
