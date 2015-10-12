Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id DE9776B0253
	for <linux-mm@kvack.org>; Mon, 12 Oct 2015 14:55:50 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so160359966wic.1
        for <linux-mm@kvack.org>; Mon, 12 Oct 2015 11:55:50 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fx2si5668893wic.38.2015.10.12.11.55.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 12 Oct 2015 11:55:49 -0700 (PDT)
Date: Mon, 12 Oct 2015 11:55:33 -0700
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: Re: GPF in shm_lock ipc
Message-ID: <20151012185533.GD3170@linux-uzut.site>
References: <CACT4Y+aqaR8QYk2nyN1n1iaSZWofBEkWuffvsfcqpvmGGQyMAw@mail.gmail.com>
 <20151012122702.GC2544@node>
 <20151012174945.GC3170@linux-uzut.site>
 <20151012181040.GC6447@node>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20151012181040.GC6447@node>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, dave.hansen@linux.intel.com, Hugh Dickins <hughd@google.com>, Joe Perches <joe@perches.com>, sds@tycho.nsa.gov, Oleg Nesterov <oleg@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, mhocko@suse.cz, gang.chen.5i5j@gmail.com, Peter Feiner <pfeiner@google.com>, aarcange@redhat.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, syzkaller@googlegroups.com, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>, Andrey Konovalov <andreyknvl@google.com>, Sasha Levin <sasha.levin@oracle.com>

On Mon, 12 Oct 2015, Kirill A. Shutemov wrote:

>On Mon, Oct 12, 2015 at 10:49:45AM -0700, Davidlohr Bueso wrote:
>> diff --git a/ipc/shm.c b/ipc/shm.c
>> index 4178727..9615f19 100644
>> --- a/ipc/shm.c
>> +++ b/ipc/shm.c
>> @@ -385,9 +385,25 @@ static struct mempolicy *shm_get_policy(struct vm_area_struct *vma,
>>  static int shm_mmap(struct file *file, struct vm_area_struct *vma)
>>  {
>> -	struct shm_file_data *sfd = shm_file_data(file);
>> +	struct file *vma_file = vma->vm_file;
>> +	struct shm_file_data *sfd = shm_file_data(vma_file);
>> +	struct ipc_ids *ids = &shm_ids(sfd->ns);
>> +	struct kern_ipc_perm *shp;
>>  	int ret;
>> +	rcu_read_lock();
>> +	shp = ipc_obtain_object_check(ids, sfd->id);
>> +	if (IS_ERR(shp)) {
>> +		ret = -EINVAL;
>> +		goto err;
>> +	}
>> +
>> +	if (!ipc_valid_object(shp)) {
>> +		ret = -EIDRM;
>> +		goto err;
>> +	}
>> +	rcu_read_unlock();
>> +
>
>Hm. Isn't it racy? What prevents IPC_RMID from happening after this point?

Nothing, but that is later caught by shm_open() doing similar checks. We
basically end up doing a check between ->mmap() calls, which is fair imho.
Note that this can occur anywhere in ipc as IPC_RMID is a user request/cmd,
and we try to respect it -- thus you can argue this race anywhere, which is
why we have EIDRM/EINVL. Ultimately the user should not be doing such hacks
_anyway_. So I'm not really concerned about it.

Another similar alternative would be perhaps to make shm_lock() return an
error, and thus propagate that error to mmap return. That way we would have
a silent way out of the warning scenario (afterward we cannot race as we
hold the ipc object lock). However, the users would now have to take this
into account...

      [validity check lockless]
      ->mmap()
      [validity check lock]

>Shouldn't we bump shm_nattch here? Or some other refcount?

At least not shm_nattach, as that would acknowledge a new attachment after
a valid IPC_RMID. But the problem is also with how we check for marked for
deletion segments -- ipc_valid_object() checking the deleted flag. As such,
we always rely on explicitly checking against the deleted flag.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
