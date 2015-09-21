Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id BEC9D6B025D
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 10:06:19 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so117573951wic.0
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 07:06:19 -0700 (PDT)
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com. [209.85.212.173])
        by mx.google.com with ESMTPS id lk9si17401261wic.92.2015.09.21.07.06.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Sep 2015 07:06:18 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so113082228wic.0
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 07:06:18 -0700 (PDT)
Date: Mon, 21 Sep 2015 17:06:15 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] fs: fix data race on mnt.mnt_flags
Message-ID: <20150921140615.GA30755@node.dhcp.inet.fi>
References: <1442837807-70839-1-git-send-email-dvyukov@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1442837807-70839-1-git-send-email-dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, riel@redhat.com, mhocko@suse.cz, oleg@redhat.com, sasha.levin@oracle.com, gang.chen.5i5j@gmail.com, pfeiner@google.com, aarcange@redhat.com, vishnu.ps@samsung.com, linux-mm@kvack.org, glider@google.com, kcc@google.com, andreyknvl@google.com, ktsan@googlegroups.com, paulmck@linux.vnet.ibm.com

On Mon, Sep 21, 2015 at 02:16:47PM +0200, Dmitry Vyukov wrote:
> do_remount() does:
> 
> mnt_flags |= mnt->mnt.mnt_flags & ~MNT_USER_SETTABLE_MASK;
> mnt->mnt.mnt_flags = mnt_flags;
> 
> This can easily be compiled as:
> 
> mnt->mnt.mnt_flags &= ~MNT_USER_SETTABLE_MASK;
> mnt->mnt.mnt_flags |= mnt_flags;
> 
> (also 2 memory accesses, less register pressure)
> The flags are being concurrently read by e.g. do_mmap_pgoff()
> which does:
> 
> if (file->f_path.mnt->mnt_flags & MNT_NOEXEC)
> 
> As the result we can allow to mmap a MNT_NOEXEC mount
> as VM_EXEC.
> 
> Use WRITE_ONCE() to set new flags.
> 
> The data race was found with KernelThreadSanitizer (KTSAN).
> 
> Signed-off-by: Dmitry Vyukov <dvyukov@google.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
