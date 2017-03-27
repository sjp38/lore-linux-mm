Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9EAC16B0390
	for <linux-mm@kvack.org>; Mon, 27 Mar 2017 17:21:32 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id u18so31537843wrc.10
        for <linux-mm@kvack.org>; Mon, 27 Mar 2017 14:21:32 -0700 (PDT)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id b73si870495wmf.0.2017.03.27.14.21.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Mar 2017 14:21:31 -0700 (PDT)
Date: Mon, 27 Mar 2017 22:21:27 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH] shmem: fix __shmem_file_setup error path leaks
Message-ID: <20170327212127.GF29622@ZenIV.linux.org.uk>
References: <20170327170534.GA16903@shells.gnugeneration.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170327170534.GA16903@shells.gnugeneration.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vito Caputo <vcaputo@pengaru.com>
Cc: hughd@google.com, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Mon, Mar 27, 2017 at 10:05:34AM -0700, Vito Caputo wrote:
> The existing path and memory cleanups appear to be in reverse order, and
> there's no iput() potentially leaking the inode in the last two error gotos.
> 
> Also make put_memory shmem_unacct_size() conditional on !inode since if we
> entered cleanup at put_inode, shmem_evict_inode() occurs via
> iput()->iput_final(), which performs the shmem_unacct_size() for us.
> 
> Signed-off-by: Vito Caputo <vcaputo@pengaru.com>
> ---
> 
> This caught my eye while looking through the memfd_create() implementation.
> Included patch was compile tested only...

Obviously so, since you've just introduced a double iput() there.  After
        d_instantiate(path.dentry, inode);
dropping the reference to path.dentry (done by path_put(&path)) will drop
the reference to inode transferred into that dentry by d_instantiate().
NAK.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
