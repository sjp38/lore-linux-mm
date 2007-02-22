Message-ID: <45DDD55F.4060106@redhat.com>
Date: Thu, 22 Feb 2007 12:39:43 -0500
From: Peter Staubach <staubach@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] update ctime and mtime for mmaped write
References: <E1HJvdA-0003Nj-00@dorka.pomaz.szeredi.hu> <20070221202615.a0a167f4.akpm@linux-foundation.org> <E1HK8hU-0005Mq-00@dorka.pomaz.szeredi.hu>
In-Reply-To: <E1HK8hU-0005Mq-00@dorka.pomaz.szeredi.hu>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: akpm@linux-foundation.org, hugh@veritas.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Miklos Szeredi wrote:
>> On Wed, 21 Feb 2007 18:51:52 +0100 Miklos Szeredi <miklos@szeredi.hu> wrote:
>>
>>     
>>> This patch makes writing to shared memory mappings update st_ctime and
>>> st_mtime as defined by SUSv3:
>>>
>>>    The st_ctime and st_mtime fields of a file that is mapped with
>>>    MAP_SHARED and PROT_WRITE shall be marked for update at some point
>>>    in the interval between a write reference to the mapped region and
>>>    the next call to msync() with MS_ASYNC or MS_SYNC for that portion
>>>    of the file by any process. If there is no such call and if the
>>>    underlying file is modified as a result of a write reference, then
>>>    these fields shall be marked for update at some time after the
>>>    write reference.
>>>
>>> A new address_space flag is introduced: AS_CMTIME.  This is set each
>>> time a page is dirtied through a userspace memory mapping.  This
>>> includes write accesses via get_user_pages().
>>>
>>> Note, the flag is set unconditionally, even if the page is already
>>> dirty.  This is important, because the page might have been dirtied
>>> earlier by a non-mmap write.
>>>
>>> This flag is checked in msync() and __fput(), and if set, the file
>>> times are updated and the flag is cleared
>>>
>>> The flag is also cleared, if the time update is triggered by a normal
>>> write.  This is not mandated by the standard, but seems to be a sane
>>> thing to do.
>>>       
>> Why is the flag checked in __fput()?
>>     
>
> It's because of this bit in the standard:
>
>     If there is no such call and if the underlying file is modified
>     as a result of a write reference, then these fields shall be
>     marked for update at some time after the write reference.
>
> It could be done in munmap/mremap, but it seemed more difficult to
> track down all the places where the vma is removed.  But yes, that may
> be a nicer solution.

It seems to me that, with this support, a file, which is mmap'd,
modified, but never msync'd or munmap'd, will never get its mtime
updated.  Or did I miss that?

I also don't see how an mmap'd block device will get its mtime
updated either.

    Thanx...

       ps

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
