Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id D4D6C6B0006
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 12:18:46 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id w17so383738pfn.17
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 09:18:46 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ay8-v6si2841656plb.554.2018.04.10.09.18.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 Apr 2018 09:18:45 -0700 (PDT)
Date: Tue, 10 Apr 2018 09:05:21 -0700
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: Re: [PATCH] ipc/shm: fix use-after-free of shm file via
 remap_file_pages()
Message-ID: <20180410160521.ybi6g2r7b43eb2di@linux-n805>
References: <94eb2c06f65e5e2467055d036889@google.com>
 <20180409043039.28915-1-ebiggers3@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20180409043039.28915-1-ebiggers3@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Manfred Spraul <manfred@colorfullife.com>, "Eric W . Biederman" <ebiederm@xmission.com>, syzkaller-bugs@googlegroups.com

On Sun, 08 Apr 2018, Eric Biggers wrote:
>@@ -480,6 +487,7 @@ static int shm_release(struct inode *ino, struct file *file)
> 	struct shm_file_data *sfd = shm_file_data(file);
>
> 	put_ipc_ns(sfd->ns);
>+	fput(sfd->file);
> 	shm_file_data(file) = NULL;
> 	kfree(sfd);
> 	return 0;
>@@ -1432,7 +1440,7 @@ long do_shmat(int shmid, char __user *shmaddr, int shmflg,
> 	file->f_mapping = shp->shm_file->f_mapping;
> 	sfd->id = shp->shm_perm.id;
> 	sfd->ns = get_ipc_ns(ns);
>-	sfd->file = shp->shm_file;
>+	sfd->file = get_file(shp->shm_file);
> 	sfd->vm_ops = NULL;

This probably merits a comment as it is adhoc to remap_file_pages(),
but otherwise:

Acked-by: Davidlohr Bueso <dbueso@suse.de>
