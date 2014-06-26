Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f172.google.com (mail-ie0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id 6D36C6B005A
	for <linux-mm@kvack.org>; Thu, 26 Jun 2014 07:27:46 -0400 (EDT)
Received: by mail-ie0-f172.google.com with SMTP id lx4so2906818iec.3
        for <linux-mm@kvack.org>; Thu, 26 Jun 2014 04:27:46 -0700 (PDT)
Received: from mail-ie0-x22d.google.com (mail-ie0-x22d.google.com [2607:f8b0:4001:c03::22d])
        by mx.google.com with ESMTPS id gh14si10680196icb.1.2014.06.26.04.27.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 26 Jun 2014 04:27:45 -0700 (PDT)
Received: by mail-ie0-f173.google.com with SMTP id y20so2903785ier.32
        for <linux-mm@kvack.org>; Thu, 26 Jun 2014 04:27:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1406252044420.30620@eggly.anvils>
References: <20140624201606.18273.44270.stgit@zurg>
	<20140624201610.18273.93645.stgit@zurg>
	<alpine.LSU.2.11.1406252044420.30620@eggly.anvils>
Date: Thu, 26 Jun 2014 15:27:45 +0400
Message-ID: <CALYGNiNq-J_WHfonOt6YSO3p2zw-Y1U2_O_MkDVqvpN01aT_RA@mail.gmail.com>
Subject: Re: [PATCH 2/3] shmem: update memory reservation on truncate
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Jun 26, 2014 at 7:53 AM, Hugh Dickins <hughd@google.com> wrote:
> On Wed, 25 Jun 2014, Konstantin Khlebnikov wrote:
>
>> Shared anonymous mapping created without MAP_NORESERVE holds memory
>> reservation for whole range of shmem segment. Usually there is no way to
>> change its size, but /proc/<pid>/map_files/...
>> (available if CONFIG_CHECKPOINT_RESTORE=y) allows to do that.
>>
>> This patch adjust memory reservation in shmem_setattr().
>>
>> Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
>
> Acked-by: Hugh Dickins <hughd@google.com>
>
> Thank you, I knew nothing about this backdoor to shmem objects.  Scary.
> Was this really the only problem map_files access leads to?  If you
> did not do so already, please try to think through other possibilities.

Ouch, it's still broken. I've fixed only truncate.
write_begin/write_end and fallocate might change i_size too.

>
> I haven't begun, but perhaps it's not so bad.  I guess the interaction
> with mremap extension is benign - it's annoyed people in the past that
> the underlying shmem object is not extended, but now here's a way that
> it can be.
>
> (I'll leave it to others comment on 3/3 if they wish.)
>
>>
>> ---
>>
>> exploit:
>>
>> #include <sys/mman.h>
>> #include <unistd.h>
>> #include <stdio.h>
>>
>> int main(int argc, char **argv)
>> {
>>       unsigned long addr;
>>       char path[100];
>>
>>       /* charge 4KiB */
>>       addr = (unsigned long)mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_SHARED|MAP_ANONYMOUS, -1, 0);
>>       sprintf(path, "/proc/self/map_files/%lx-%lx", addr, addr + 4096);
>>       truncate(path, 1 << 30);
>>       /* uncharge 1GiB */
>> }
>> ---
>>  mm/shmem.c |   17 +++++++++++++++++
>>  1 file changed, 17 insertions(+)
>>
>> diff --git a/mm/shmem.c b/mm/shmem.c
>> index 0aabcbd..a3c49d6 100644
>> --- a/mm/shmem.c
>> +++ b/mm/shmem.c
>> @@ -149,6 +149,19 @@ static inline void shmem_unacct_size(unsigned long flags, loff_t size)
>>               vm_unacct_memory(VM_ACCT(size));
>>  }
>>
>> +static inline int shmem_reacct_size(unsigned long flags,
>> +             loff_t oldsize, loff_t newsize)
>> +{
>> +     if (!(flags & VM_NORESERVE)) {
>> +             if (VM_ACCT(newsize) > VM_ACCT(oldsize))
>> +                     return security_vm_enough_memory_mm(current->mm,
>> +                                     VM_ACCT(newsize) - VM_ACCT(oldsize));
>> +             else if (VM_ACCT(newsize) < VM_ACCT(oldsize))
>> +                     vm_unacct_memory(VM_ACCT(oldsize) - VM_ACCT(newsize));
>> +     }
>> +     return 0;
>> +}
>> +
>>  /*
>>   * ... whereas tmpfs objects are accounted incrementally as
>>   * pages are allocated, in order to allow huge sparse files.
>> @@ -543,6 +556,10 @@ static int shmem_setattr(struct dentry *dentry, struct iattr *attr)
>>               loff_t newsize = attr->ia_size;
>>
>>               if (newsize != oldsize) {
>> +                     error = shmem_reacct_size(SHMEM_I(inode)->flags,
>> +                                     oldsize, newsize);
>> +                     if (error)
>> +                             return error;
>>                       i_size_write(inode, newsize);
>>                       inode->i_ctime = inode->i_mtime = CURRENT_TIME;
>>               }
>>
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
