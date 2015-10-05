Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 7F03A440313
	for <linux-mm@kvack.org>; Sun,  4 Oct 2015 23:38:25 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so100369375wic.1
        for <linux-mm@kvack.org>; Sun, 04 Oct 2015 20:38:24 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u9si28418166wjx.196.2015.10.04.20.38.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 04 Oct 2015 20:38:24 -0700 (PDT)
Date: Sun, 4 Oct 2015 20:37:08 -0700
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: Re: [PATCH 3/3] mm/nommu: drop unlikely behind BUG_ON()
Message-ID: <20151005033708.GC8831@linux-uzut.site>
References: <a89c7bef0699c3d3f5e592c58ff3f0a4db482b69.1443937856.git.geliangtang@163.com>
 <cf38aa69e23adb31ebb4c9d80384dabe9b91b75e.1443937856.git.geliangtang@163.com>
 <45bf632d263280847a2a894017c62b7f2a71eda1.1443937856.git.geliangtang@163.com>
 <20151005015055.GA8831@linux-uzut.site>
 <20151005023000.GA1607@bogon>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20151005023000.GA1607@bogon>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geliang Tang <geliangtang@163.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, "Peter Zij    lstra (Intel)" <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Joonsoo Kim <js1304@gmail.com>, Arnd Bergmann <arnd@arndb.de>, Paul Gortmaker <paul.gortmaker@windriver.com>, Leon Romanovsky <leon@leon.nu>, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 05 Oct 2015, Geliang Tang wrote:

>On Sun, Oct 04, 2015 at 06:50:55PM -0700, Davidlohr Bueso wrote:
>> On Sun, 04 Oct 2015, Geliang Tang wrote:
>>
>> >BUG_ON() already contain an unlikely compiler flag. Drop it.
>> >
>> >Signed-off-by: Geliang Tang <geliangtang@163.com>
>>
>> Acked-by: Davidlohr Bueso <dave@stgolabs.net>
>>
>> ... but I believe you do have some left:
>>
>> drivers/scsi/scsi_lib.c:                BUG_ON(unlikely(count > ivecs));
>> drivers/scsi/scsi_lib.c:                BUG_ON(unlikely(count > queue_max_integrity_segments(rq->q)));
>> kernel/sched/core.c:    BUG_ON(unlikely(task_stack_end_corrupted(prev)));
>
>Thanks for your review, the left have been sended out already in two other patches.

So given that the 'unlikely' is based on CONFIG_BUG/HAVE_ARCH_BUG_ON, the
changelog needs to be rewritten. Ie mentioning at least why it should be
ok to drop the redundant predictions: (1) For !CONFIG_BUG cases, the bug call
is a no-op, so we couldn't care less and the change is ok. (2) ppc and
mips, which HAVE_ARCH_BUG_ON, do not rely on branch predictions as it seems
to be pointless[1] and thus callers should not be trying to push an optimization
in the first place.

Also, I think that all the changes should be in the same patch. Logically,
this is a tree wide change, and trivial enough. But I don't really have a
preference.

Thanks,
Davidlohr

[1] http://lkml.iu.edu/hypermail/linux/kernel/1101.3/02289.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
