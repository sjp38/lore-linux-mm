Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id EDB866B006E
	for <linux-mm@kvack.org>; Tue, 23 Oct 2012 21:33:50 -0400 (EDT)
Received: by mail-ia0-f169.google.com with SMTP id h37so2943iak.14
        for <linux-mm@kvack.org>; Tue, 23 Oct 2012 18:33:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <50873E1F.2050009@gmail.com>
References: <1350996411-5425-1-git-send-email-casualfisher@gmail.com>
	<508699D3.9040509@gmail.com>
	<CAA9v8mGMa3SDD1OLTG_wdhCGx7K-0kvSV1+MRi9uCGTz6zZaLg@mail.gmail.com>
	<CAA9v8mGGE2sPW1hv-zSaFEq4PD2DZES=zYTJ=aeY1CVe8sXwyw@mail.gmail.com>
	<50873E1F.2050009@gmail.com>
Date: Wed, 24 Oct 2012 09:33:50 +0800
Message-ID: <CAA9v8mFpqVyUhTdnJbdnooTAuZSmT3i2nbsbxgywX0pz3HMQ8Q@mail.gmail.com>
Subject: Re: [PATCH] mm: readahead: remove redundant ra_pages in file_ra_state
From: YingHang Zhu <casualfisher@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ni zhan Chen <nizhan.chen@gmail.com>
Cc: akpm@linux-foundation.org, Fengguang Wu <fengguang.wu@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Chen,

On Wed, Oct 24, 2012 at 9:02 AM, Ni zhan Chen <nizhan.chen@gmail.com> wrote:
> On 10/23/2012 09:41 PM, YingHang Zhu wrote:
>>
>> Sorry for the annoying, I forgot ccs in the previous mail.
>> Thanks,
>>           Ying Zhu
>> Hi Chen,
>>
>> On Tue, Oct 23, 2012 at 9:21 PM, Ni zhan Chen <nizhan.chen@gmail.com>
>> wrote:
>>>
>>> On 10/23/2012 08:46 PM, Ying Zhu wrote:
>>>>
>>>> Hi,
>>>>     Recently we ran into the bug that an opened file's ra_pages does not
>>>> synchronize with it's backing device's when the latter is changed
>>>> with blockdev --setra, the application needs to reopen the file
>>>> to know the change, which is inappropriate under our circumstances.
>>>
>>>
>>> Could you tell me in which function do this synchronize stuff?
>>
>> With this patch we use bdi.ra_pages directly, so change bdi.ra_pages also
>> change an opened file's ra_pages.
>>>
>>>
>>>> This bug is also mentioned in scst (generic SCSI target subsystem for
>>>> Linux)'s
>>>> README file.
>>>>     This patch tries to unify the ra_pages in struct file_ra_state
>>>> and struct backing_dev_info. Basically current readahead algorithm
>>>> will ramp file_ra_state.ra_pages up to bdi.ra_pages once it detects the
>>>
>>>
>>> You mean ondemand readahead algorithm will do this? I don't think so.
>>> file_ra_state_init only called in btrfs path, correct?
>>
>> No, it's also called in do_dentry_open.
>>>
>>>
>>>> read mode is sequential. Then all files sharing the same backing device
>>>> have the same max value bdi.ra_pages set in file_ra_state.
>>>
>>>
>>> why remove file_ra_state? If one file is read sequential and another file
>>> is
>>> read ramdom, how can use the global bdi.ra_pages to indicate the max
>>> readahead window of each file?
>>
>> This patch does not remove file_ra_state, an file's readahead window
>> is determined
>> by it's backing device.
>
>
> As Dave said, backing device readahead window doesn't tend to change
> dynamically, but file readahead window does, it will change when sequential
> read, random read, thrash, interleaved read and so on occur.
>
    I agree about what you and Dave said totally and the point here is
not about how readahead
algorithm does. It's about those file systems using a abstract bdi
instead of the actual
devices, thus the bdi.ra_pages does not really reflect the backing
storage's read IO bandwidth.
    AFAIK btrfs also has a abstract bdi to manage the many backing
devices, so I think btrfs also
has this problem. As for a further comment, btrfs may spread a file's
contents across the managed
backing devices, so maybe offset (0, x) and (x+1, y) land on different
disks and have different readahead
abilities, in this case the file's max readahead pages should change
accordingly.
Perhaps in reality we seldom meet this heterogenous stroage architecture.

Thanks,
       Ying Zhu
>>>
>>>>     Applying this means the flags POSIX_FADV_NORMAL and
>>>> POSIX_FADV_SEQUENTIAL
>>>> in fadivse will only set file reading mode without signifying the
>>>> max readahead size of the file. The current apporach adds no additional
>>>> overhead in read IO path, IMHO is the simplest solution.
>>>> Any comments are welcome, thanks in advance.
>>>
>>>
>>> Could you show me how you test this patch?
>>
>> This patch brings no perfmance gain, just fixs some functional bugs.
>> By reading a 500MB file, the default max readahead size of the
>> backing device was 128KB, after applying this patch, the read file's
>> max ra_pages
>> changed when I tuned the device's read ahead size with blockdev.
>>>
>>>
>>>> Thanks,
>>>>          Ying Zhu
>>>>
>>>> Signed-off-by: Ying Zhu <casualfisher@gmail.com>
>>>> ---
>>>>    include/linux/fs.h |    1 -
>>>>    mm/fadvise.c       |    2 --
>>>>    mm/filemap.c       |   17 +++++++++++------
>>>>    mm/readahead.c     |    8 ++++----
>>>>    4 files changed, 15 insertions(+), 13 deletions(-)
>>>>
>>>> diff --git a/include/linux/fs.h b/include/linux/fs.h
>>>> index 17fd887..36303a5 100644
>>>> --- a/include/linux/fs.h
>>>> +++ b/include/linux/fs.h
>>>> @@ -991,7 +991,6 @@ struct file_ra_state {
>>>>          unsigned int async_size;        /* do asynchronous readahead
>>>> when
>>>>                                             there are only # of pages
>>>> ahead
>>>> */
>>>>    -     unsigned int ra_pages;          /* Maximum readahead window */
>>>>          unsigned int mmap_miss;         /* Cache miss stat for mmap
>>>> accesses */
>>>>          loff_t prev_pos;                /* Cache last read() position
>>>> */
>>>>    };
>>>> diff --git a/mm/fadvise.c b/mm/fadvise.c
>>>> index 469491e..75e2378 100644
>>>> --- a/mm/fadvise.c
>>>> +++ b/mm/fadvise.c
>>>> @@ -76,7 +76,6 @@ SYSCALL_DEFINE(fadvise64_64)(int fd, loff_t offset,
>>>> loff_t len, int advice)
>>>>          switch (advice) {
>>>>          case POSIX_FADV_NORMAL:
>>>> -               file->f_ra.ra_pages = bdi->ra_pages;
>>>>                  spin_lock(&file->f_lock);
>>>>                  file->f_mode &= ~FMODE_RANDOM;
>>>>                  spin_unlock(&file->f_lock);
>>>> @@ -87,7 +86,6 @@ SYSCALL_DEFINE(fadvise64_64)(int fd, loff_t offset,
>>>> loff_t len, int advice)
>>>>                  spin_unlock(&file->f_lock);
>>>>                  break;
>>>>          case POSIX_FADV_SEQUENTIAL:
>>>> -               file->f_ra.ra_pages = bdi->ra_pages * 2;
>>>>                  spin_lock(&file->f_lock);
>>>>                  file->f_mode &= ~FMODE_RANDOM;
>>>>                  spin_unlock(&file->f_lock);
>>>> diff --git a/mm/filemap.c b/mm/filemap.c
>>>> index a4a5260..e7e4409 100644
>>>> --- a/mm/filemap.c
>>>> +++ b/mm/filemap.c
>>>> @@ -1058,11 +1058,15 @@ EXPORT_SYMBOL(grab_cache_page_nowait);
>>>>     * readahead(R+4...B+3) => bang => read(R+4) => read(R+5) => ......
>>>>     *
>>>>     * It is going insane. Fix it by quickly scaling down the readahead
>>>> size.
>>>> + * It's hard to estimate how the bad sectors lay out, so to be
>>>> conservative,
>>>> + * set the read mode in random.
>>>>     */
>>>>    static void shrink_readahead_size_eio(struct file *filp,
>>>>                                          struct file_ra_state *ra)
>>>>    {
>>>> -       ra->ra_pages /= 4;
>>>> +       spin_lock(&filp->f_lock);
>>>> +       filp->f_mode |= FMODE_RANDOM;
>>>> +       spin_unlock(&filp->f_lock);
>>>>    }
>>>>      /**
>>>> @@ -1527,12 +1531,12 @@ static void do_sync_mmap_readahead(struct
>>>> vm_area_struct *vma,
>>>>          /* If we don't want any read-ahead, don't bother */
>>>>          if (VM_RandomReadHint(vma))
>>>>                  return;
>>>> -       if (!ra->ra_pages)
>>>> +       if (!mapping->backing_dev_info->ra_pages)
>>>>                  return;
>>>>          if (VM_SequentialReadHint(vma)) {
>>>> -               page_cache_sync_readahead(mapping, ra, file, offset,
>>>> -                                         ra->ra_pages);
>>>> +               page_cache_sync_readahead(mapping, ra, file, offset,
>>>> +
>>>> mapping->backing_dev_info->ra_pages);
>>>>                  return;
>>>>          }
>>>>    @@ -1550,7 +1554,7 @@ static void do_sync_mmap_readahead(struct
>>>> vm_area_struct *vma,
>>>>          /*
>>>>           * mmap read-around
>>>>           */
>>>> -       ra_pages = max_sane_readahead(ra->ra_pages);
>>>> +       ra_pages =
>>>> max_sane_readahead(mapping->backing_dev_info->ra_pages);
>>>>          ra->start = max_t(long, 0, offset - ra_pages / 2);
>>>>          ra->size = ra_pages;
>>>>          ra->async_size = ra_pages / 4;
>>>> @@ -1576,7 +1580,8 @@ static void do_async_mmap_readahead(struct
>>>> vm_area_struct *vma,
>>>>                  ra->mmap_miss--;
>>>>          if (PageReadahead(page))
>>>>                  page_cache_async_readahead(mapping, ra, file,
>>>> -                                          page, offset, ra->ra_pages);
>>>> +                                          page, offset,
>>>> +
>>>> mapping->backing_dev_info->ra_pages);
>>>>    }
>>>>      /**
>>>> diff --git a/mm/readahead.c b/mm/readahead.c
>>>> index ea8f8fa..6ea5999 100644
>>>> --- a/mm/readahead.c
>>>> +++ b/mm/readahead.c
>>>> @@ -27,7 +27,6 @@
>>>>    void
>>>>    file_ra_state_init(struct file_ra_state *ra, struct address_space
>>>> *mapping)
>>>>    {
>>>> -       ra->ra_pages = mapping->backing_dev_info->ra_pages;
>>>>          ra->prev_pos = -1;
>>>>    }
>>>>    EXPORT_SYMBOL_GPL(file_ra_state_init);
>>>> @@ -400,7 +399,8 @@ ondemand_readahead(struct address_space *mapping,
>>>>                     bool hit_readahead_marker, pgoff_t offset,
>>>>                     unsigned long req_size)
>>>>    {
>>>> -       unsigned long max = max_sane_readahead(ra->ra_pages);
>>>> +       struct backing_dev_info *bdi = mapping->backing_dev_info;
>>>> +       unsigned long max = max_sane_readahead(bdi->ra_pages);
>>>>          /*
>>>>           * start of file
>>>> @@ -507,7 +507,7 @@ void page_cache_sync_readahead(struct address_space
>>>> *mapping,
>>>>                                 pgoff_t offset, unsigned long req_size)
>>>>    {
>>>>          /* no read-ahead */
>>>> -       if (!ra->ra_pages)
>>>> +       if (!mapping->backing_dev_info->ra_pages)
>>>>                  return;
>>>>          /* be dumb */
>>>> @@ -543,7 +543,7 @@ page_cache_async_readahead(struct address_space
>>>> *mapping,
>>>>                             unsigned long req_size)
>>>>    {
>>>>          /* no read-ahead */
>>>> -       if (!ra->ra_pages)
>>>> +       if (!mapping->backing_dev_info->ra_pages)
>>>>                  return;
>>>>          /*
>>>
>>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
