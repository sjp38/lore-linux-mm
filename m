Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 903A76B0253
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 10:12:41 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id z29so2260434qkg.5
        for <linux-mm@kvack.org>; Tue, 17 Oct 2017 07:12:41 -0700 (PDT)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id 123si1686427ybv.228.2017.10.17.07.12.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 17 Oct 2017 07:12:40 -0700 (PDT)
Date: Tue, 17 Oct 2017 10:12:33 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: kernel BUG at fs/xfs/xfs_aops.c:853! in kernel 4.13 rc6
Message-ID: <20171017141233.l3avshagrv7fr7xt@thunk.org>
References: <CABXGCsOeex62Y4qQJwvMJ+fJ+MnKyKGDj9eRbKemeMVWo5huKw@mail.gmail.com>
 <20171009000529.GY3666@dastard>
 <20171009183129.GE11645@wotan.suse.de>
 <87wp442lgm.fsf@xmission.com>
 <8729041d-05e5-6bea-98db-7f265edde193@suse.de>
 <20171015130625.o5k6tk5uflm3rx65@thunk.org>
 <87efq4qcry.fsf@xmission.com>
 <20171016011301.dcam44qylno7rm6a@thunk.org>
 <c5bb6c1b-90c9-f50e-7283-af7e0de67caa@suse.de>
 <20171017092017.GN9762@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171017092017.GN9762@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Aleksa Sarai <asarai@suse.de>, "Eric W. Biederman" <ebiederm@xmission.com>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Dave Chinner <david@fromorbit.com>, =?utf-8?B?0JzQuNGF0LDQuNC7INCT0LDQstGA0LjQu9C+0LI=?= <mikhail.v.gavrilov@gmail.com>, Christoph Hellwig <hch@infradead.org>, Jan Blunck <jblunck@infradead.org>, linux-mm@kvack.org, Oscar Salvador <osalvador@suse.com>, Hannes Reinecke <hare@suse.de>, linux-xfs@vger.kernel.org

On Tue, Oct 17, 2017 at 11:20:17AM +0200, Jan Kara wrote:
> The operation we are speaking about here is different. It is more along the
> lines of "release this device".  And in the current world of containers,
> mount namespaces, etc. it is not trivial for userspace to implement this
> using umount(2) as Ted points out. I believe we could do that by walking
> through all mount points of a superblock and unmounting them (and I don't
> want to get into a discussion how to efficiently implement that now but in
> principle the kernel has all the necessary information).

Yes, this is what I want.  And regardless of how efficiently or not
the kernel can implement such an operatoin, by definition it will be
more efficient than if we ahve to do it in userspace.  (And I don't
think it has to be super-efficient, since this is not a hot-path.  So
for the record, I wouldn't want to add any extra linked list
references, etc.)

> What I'm a bit concerned about is the "release device reference" part - for
> a block device to stop looking busy we have to do that however then the
> block device can go away and the filesystem isn't prepared to that - we
> reference sb->s_bdev in lots of places, we have buffer heads which are part
> of bdev page cache, and probably other indirect assumptions I forgot about
> now. One solution to this is to not just stop accessing the device but
> truly cleanup the filesystem up to a point where it is practically
> unmounted. I like this solution more but we have to be careful to block
> any access attemps high enough in VFS ideally before ever entering fs code.

Right, so first step would be to block access attempts high up in the
VFS.  The second would be to point any file descriptors at a revoked
NULL struct file, also redirect any task struct's CWD so it is as if
the directory had gotten rmdir'ed, and also munmap any mapped regions.
At that point, all of the file descriptors will be closed.  The third
step would be to do a syncfs(), which will force out any dirty pages.
And then finally, to call umount() in all of the namespaces, which
will naturally take care of any buffer or page cache references once
the ref count of the struct super goes to zero.

This all doesn't have to be a single system call.  Perhaps it would
make sense for first and second step to be one system call --- call it
revokefs(2), perhaps.  And then the last step could be another system
call --- maybe umountall(2).

> Another option would be to do something similar to what we do when the
> device just gets unplugged under our hands - we detach bdev from gendisk,
> leave it dangling and invisible. But we would still somehow have to
> convince DM that the bdev practically went away by calling
> disk->fops->release() and it all just seems fragile to me. But I wanted to
> mention this option in case the above solution proves to be too difficult.

Yeah, that's similarly as fragile as using the ext4/xfs/f2fs
shutdown/goingdown ioctl.  In order to do this right I really think we
need to get the VFS involved, so it can be a real, clean unmount, as
opposed to something where we just rip the file system away from the
bdev.

						- Ted
						

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
