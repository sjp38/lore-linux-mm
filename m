Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f45.google.com (mail-la0-f45.google.com [209.85.215.45])
	by kanga.kvack.org (Postfix) with ESMTP id A9392800CA
	for <linux-mm@kvack.org>; Fri,  7 Nov 2014 11:28:18 -0500 (EST)
Received: by mail-la0-f45.google.com with SMTP id pn19so4751071lab.18
        for <linux-mm@kvack.org>; Fri, 07 Nov 2014 08:28:18 -0800 (PST)
Received: from mail-lb0-f178.google.com (mail-lb0-f178.google.com. [209.85.217.178])
        by mx.google.com with ESMTPS id ob1si15529331lbb.113.2014.11.07.08.28.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 07 Nov 2014 08:28:17 -0800 (PST)
Received: by mail-lb0-f178.google.com with SMTP id f15so3240745lbj.37
        for <linux-mm@kvack.org>; Fri, 07 Nov 2014 08:28:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <x49y4rn29oh.fsf@segfault.boston.devel.redhat.com>
References: <cover.1415220890.git.milosz@adfin.com>
	<dcc7d998033bbd999bbd92ef9c2041bce0255a3e.1415220890.git.milosz@adfin.com>
	<x49y4rn29oh.fsf@segfault.boston.devel.redhat.com>
Date: Fri, 7 Nov 2014 11:28:17 -0500
Message-ID: <CANP1eJG=nTB_jbOUY9nQfmsxbyAfO6KhmHm0jRVTyp09dseCxg@mail.gmail.com>
Subject: Re: [PATCH v5 2/7] vfs: Define new syscalls preadv2,pwritev2
From: Milosz Tanski <milosz@adfin.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Christoph Hellwig <hch@infradead.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-aio@kvack.org" <linux-aio@kvack.org>, Mel Gorman <mgorman@suse.de>, Volker Lendecke <Volker.Lendecke@sernet.de>, Tejun Heo <tj@kernel.org>, Theodore Ts'o <tytso@mit.edu>, Al Viro <viro@zeniv.linux.org.uk>, Linux API <linux-api@vger.kernel.org>, Michael Kerrisk <mtk.manpages@gmail.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org

On Thu, Nov 6, 2014 at 6:25 PM, Jeff Moyer <jmoyer@redhat.com> wrote:
> Milosz Tanski <milosz@adfin.com> writes:
>
>> New syscalls that take an flag argument. This change does not add any specific
>> flags.
>>
>> Signed-off-by: Milosz Tanski <milosz@adfin.com>
>> Reviewed-by: Christoph Hellwig <hch@lst.de>
>> ---
>>  fs/read_write.c                   | 176 ++++++++++++++++++++++++++++++--------
>>  include/linux/compat.h            |   6 ++
>>  include/linux/syscalls.h          |   6 ++
>>  include/uapi/asm-generic/unistd.h |   6 +-
>>  mm/filemap.c                      |   5 +-
>>  5 files changed, 158 insertions(+), 41 deletions(-)
>>
>> diff --git a/fs/read_write.c b/fs/read_write.c
>> index 94b2d34..907735c 100644
>> --- a/fs/read_write.c
>> +++ b/fs/read_write.c
>> @@ -866,6 +866,8 @@ ssize_t vfs_readv(struct file *file, const struct iovec __user *vec,
>>               return -EBADF;
>>       if (!(file->f_mode & FMODE_CAN_READ))
>>               return -EINVAL;
>> +     if (flags & ~0)
>> +             return -EINVAL;
>>
>>       return do_readv_writev(READ, file, vec, vlen, pos, flags);
>>  }
>> @@ -879,21 +881,23 @@ ssize_t vfs_writev(struct file *file, const struct iovec __user *vec,
>>               return -EBADF;
>>       if (!(file->f_mode & FMODE_CAN_WRITE))
>>               return -EINVAL;
>> +     if (flags & ~0)
>> +             return -EINVAL;
>>
>>       return do_readv_writev(WRITE, file, vec, vlen, pos, flags);
>>  }
>
> Hi, Milosz,
>
> You've checked for invalid flags for the normal system calls, but not
> for the compat variants.  Can you add that in, please?
>
> Thanks!
> Jeff

That's a good catch Jeff I'll fix this and it'll be in the next
version of the patch series.

- M



-- 
Milosz Tanski
CTO
16 East 34th Street, 15th floor
New York, NY 10016

p: 646-253-9055
e: milosz@adfin.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
