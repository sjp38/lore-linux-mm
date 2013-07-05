Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id DCBC36B0033
	for <linux-mm@kvack.org>; Fri,  5 Jul 2013 15:40:51 -0400 (EDT)
Received: by mail-ve0-f169.google.com with SMTP id m1so2087084ves.28
        for <linux-mm@kvack.org>; Fri, 05 Jul 2013 12:40:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130704202232.GA19287@redhat.com>
References: <1372901537-31033-1-git-send-email-ccross@android.com>
	<20130704202232.GA19287@redhat.com>
Date: Fri, 5 Jul 2013 12:40:50 -0700
Message-ID: <CAMbhsRRjGjo_-zSigmdsDvY-kfBhmP49bDQzsgHfj5N-y+ZAdw@mail.gmail.com>
Subject: Re: [PATCH] mm: add sys_madvise2 and MADV_NAME to name vmas
From: Colin Cross <ccross@android.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: lkml <linux-kernel@vger.kernel.org>, Kyungmin Park <kmpark@infradead.org>, Christoph Hellwig <hch@infradead.org>, John Stultz <john.stultz@linaro.org>, Rob Landley <rob@landley.net>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Cyrill Gorcunov <gorcunov@openvz.org>, David Rientjes <rientjes@google.com>, Davidlohr Bueso <dave@gnu.org>, Kees Cook <keescook@chromium.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rusty Russell <rusty@rustcorp.com.au>, "Eric W. Biederman" <ebiederm@xmission.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Anton Vorontsov <anton.vorontsov@linaro.org>, Pekka Enberg <penberg@kernel.org>, Shaohua Li <shli@fusionio.com>, Sasha Levin <sasha.levin@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ingo Molnar <mingo@kernel.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, "open list:GENERIC INCLUDE/A..." <linux-arch@vger.kernel.org>

On Thu, Jul 4, 2013 at 1:22 PM, Oleg Nesterov <oleg@redhat.com> wrote:
> On 07/03, Colin Cross wrote:
>>
>> The names of named anonymous vmas are shown in /proc/pid/maps
>> as [anon:<name>].  The name of all named vmas are shown in
>> /proc/pid/smaps in a new "Name" field that is only present
>> for named vmas.
>
> And this is the only purpose, yes?

Yes

>>  static long madvise_behavior(struct vm_area_struct * vma,
>>                    struct vm_area_struct **prev,
>> -                  unsigned long start, unsigned long end, int behavior)
>> +                  unsigned long start, unsigned long end, int behavior,
>> +                  void *arg, size_t arg_len)
>>  {
>>       struct mm_struct * mm = vma->vm_mm;
>>       int error = 0;
>>       pgoff_t pgoff;
>>       unsigned long new_flags = vma->vm_flags;
>> +     struct vma_name *new_name = vma->vm_name;
>>
>>       switch (behavior) {
>>       case MADV_NORMAL:
>> @@ -93,16 +97,28 @@ static long madvise_behavior(struct vm_area_struct * vma,
>>               if (error)
>>                       goto out;
>>               break;
>> +     case MADV_NAME:
>> +             if (arg) {
>> +                     new_name = vma_name_get_from_str(arg, arg_len);
>> +                     if (!new_name) {
>> +                             error = -ENOMEM;
>> +                             goto out;
>> +                     }
>> +             } else {
>> +                     new_name = NULL;
>> +             }
>> +             break;
>>       }
>>
>> -     if (new_flags == vma->vm_flags) {
>> +     if (new_flags == vma->vm_flags && new_name == vma->vm_name) {
>>               *prev = vma;
>>               goto out;
>>       }
>>
>>       pgoff = vma->vm_pgoff + ((start - vma->vm_start) >> PAGE_SHIFT);
>>       *prev = vma_merge(mm, *prev, start, end, new_flags, vma->anon_vma,
>> -                             vma->vm_file, pgoff, vma_policy(vma));
>> +                             vma->vm_file, pgoff, vma_policy(vma),
>> +                             new_name);
>>       if (*prev) {
>>               vma = *prev;
>>               goto success;
>> @@ -127,8 +143,17 @@ success:
>>        * vm_flags is protected by the mmap_sem held in write mode.
>>        */
>>       vma->vm_flags = new_flags;
>> +     if (vma->vm_name != new_name) {
>> +             if (vma->vm_name)
>> +                     vma_name_put(vma->vm_name);
>> +             if (new_name)
>> +                     vma_name_get(new_name);
>> +             vma->vm_name = new_name;
>> +     }
>
> So we change vma->vm_name after vma_merge(). But given that is_mergeable_vma()
> checks vma->vm_name with this patch, this means that we can have 2 vma's with
> the same ->vm_name which should be merged?
>
> IOW. Suppose that we have vma with vm_start = START, end = START + 2 * PAGE_SIZE.
> Suppose that an application does
>
>         MADV_NAME(START, PAGE_SIZE, "MY_NAME");
>         MADV_NAME(START + PAGE_SIZE, PAGE_SIZE, "MY_NAME");
>
> The 1st MADV_NAME will split this vma, the 2nd won't merge. Not that I think
> this is buggy, just a bit inconsistent imho.

My intention is that any vmas that would be merged without names would
be merged if they have the same name.  I copied the logic used for
vm_flags, but I'll take another look.

> And I guess vma_name_get(new_name) is not needed, you can simply nullify it
> after changing ->vm_name to avoid vma_name_put() below.

Good point, I'll fix it in the next version.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
