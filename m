Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 552F58E0001
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 03:49:12 -0500 (EST)
Received: by mail-yw1-f72.google.com with SMTP id m200so806683ywd.14
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 00:49:12 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id o127sor2408903ywf.31.2019.01.23.00.49.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 23 Jan 2019 00:49:10 -0800 (PST)
MIME-Version: 1.0
From: Amir Goldstein <amir73il@gmail.com>
Date: Wed, 23 Jan 2019 10:48:58 +0200
Message-ID: <CAOQ4uxj4DiU=vFqHCuaHQ=4XVkTeJrXci0Y6YUX=22dE+iygqA@mail.gmail.com>
Subject: [LSF/MM TOPIC] Sharing file backed pages
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: Al Viro <viro@zeniv.linux.org.uk>, "Darrick J. Wong" <darrick.wong@oracle.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>, Chris Mason <clm@fb.com>, Miklos Szeredi <miklos@szeredi.hu>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

Hi,

In his session about "reflink" in LSF/MM 2016 [1], Darrick Wong brought
up the subject of sharing pages between cloned files and the general vibe
in room was that it could be done.

In his talk about XFS subvolumes and snapshots [2], Dave Chinner said
that Matthew Willcox was "working on that problem".

I have started working on a new overlayfs address space implementation
that could also benefit from being able to share pages even for filesystems
that do not support clones (for copy up anticipation state).

To simplify the problem, we can start with sharing only uptodate clean
pages that map the same offset in respected files. While the same offset
requirement somewhat limits the use cases that benefit from shared
file pages, there is still a vast majority of use cases (i.e. clone full image),
where sharing pages of similar offset will bring a lot of benefit.

At first glance, this requires dropping the assumption that a for an uptodate
clean page, vmf->vma->vm_file->f_inode == page->mapping->host.
Is there really such an assumption in common vfs/mm code?
and what will it take to drop it?

I would like to discuss where do we stand on this effort and what are the
steps we need to take to move this forward, as well as to collaborate the
efforts between the interested parties (e.g. xfs, btrfs, overlayfs, anyone?).

Thanks,
Amir.

[1] https://lwn.net/Articles/684826/
[2] https://lwn.net/Articles/747633/
