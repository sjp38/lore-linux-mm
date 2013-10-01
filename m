Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id CD2936B0031
	for <linux-mm@kvack.org>; Tue,  1 Oct 2013 17:59:12 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id kq14so105850pab.12
        for <linux-mm@kvack.org>; Tue, 01 Oct 2013 14:59:12 -0700 (PDT)
Received: by mail-vb0-f53.google.com with SMTP id i3so5356856vbh.12
        for <linux-mm@kvack.org>; Tue, 01 Oct 2013 14:59:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <524B3AC2.1090904@intel.com>
References: <1380658901-11666-1-git-send-email-ccross@android.com>
	<1380658901-11666-2-git-send-email-ccross@android.com>
	<524B3AC2.1090904@intel.com>
Date: Tue, 1 Oct 2013 14:59:08 -0700
Message-ID: <CAMbhsRRonWY4fTs07Cj8QTqn3z3qbvwqKiJcsH_Oty6EtiQsCw@mail.gmail.com>
Subject: Re: [PATCHv2 2/2] mm: add a field to store names for private
 anonymous memory
From: Colin Cross <ccross@android.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: lkml <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Oleg Nesterov <oleg@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Jan Glauber <jan.glauber@gmail.com>, Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Cyrill Gorcunov <gorcunov@openvz.org>, David Rientjes <rientjes@google.com>, Davidlohr Bueso <dave@gnu.org>, Kees Cook <keescook@chromium.org>, Pavel Emelyanov <xemul@parallels.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Jiang Liu <jiang.liu@huawei.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, David Howells <dhowells@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Dave Jones <davej@redhat.com>, Robin Holt <holt@sgi.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Shaohua Li <shli@fusionio.com>, Sasha Levin <sasha.levin@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "open list:DOCUMENTATION <linux-doc@vger.kernel.org>, open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

On Tue, Oct 1, 2013 at 2:12 PM, Dave Hansen <dave.hansen@intel.com> wrote:
> On 10/01/2013 01:21 PM, Colin Cross wrote:
>> +static void seq_print_vma_name(struct seq_file *m, struct vm_area_struct *vma)
>> +{
>> +     const char __user *name = vma_get_anon_name(vma);
>> +     struct mm_struct *mm = vma->vm_mm;
>> +
>> +     unsigned long page_start_vaddr;
>> +     unsigned long page_offset;
>> +     unsigned long num_pages;
>> +     unsigned long max_len = NAME_MAX;
>> +     int i;
>> +
>> +     page_start_vaddr = (unsigned long)name & PAGE_MASK;
>> +     page_offset = (unsigned long)name - page_start_vaddr;
>> +     num_pages = DIV_ROUND_UP(page_offset + max_len, PAGE_SIZE);
>> +
>> +     seq_puts(m, "[anon:");
>> +
>> +     for (i = 0; i < num_pages; i++) {
>> +             int len;
>> +             int write_len;
>> +             const char *kaddr;
>> +             long pages_pinned;
>> +             struct page *page;
>> +
>> +             pages_pinned = get_user_pages(current, mm, page_start_vaddr,
>> +                             1, 0, 0, &page, NULL);
>> +             if (pages_pinned < 1) {
>> +                     seq_puts(m, "<fault>]");
>> +                     return;
>> +             }
>> +
>> +             kaddr = (const char *)kmap(page);
>> +             len = min(max_len, PAGE_SIZE - page_offset);
>> +             write_len = strnlen(kaddr + page_offset, len);
>> +             seq_write(m, kaddr + page_offset, write_len);
>> +             kunmap(page);
>> +             put_page(page);
>> +
>> +             /* if strnlen hit a null terminator then we're done */
>> +             if (write_len != len)
>> +                     break;
>> +
>> +             max_len -= len;
>> +             page_offset = 0;
>> +             page_start_vaddr += PAGE_SIZE;
>> +     }
>> +
>> +     seq_putc(m, ']');
>> +}
>
> Is there a reason you can't use access_process_vm(), or share some code
> with proc_pid_cmdline()?  It seems to be doing a bunch of the same stuff
> that you are.  Also, considering that this roll-your-own code, and it's
> digging around in user-supplied addresses, it seems like the kind of
> thing that's prone to introducing security problems.  Could you share
> some of your logic around how misuse of this mechanism is prevented?

The key difference between access_process_vm/proc_pid_cmdline and this
is that I don't have a length here.  It reads up to NAME_MAX bytes
until it finds a null terminator.  There is also a secondary
optimization that avoids memcpy, it maps the page into the kernel and
then calls seq_write on it directly, but that is minor.

I could change this to access_process_vm, which would result in
copying 1024 bytes for every named mapping in /proc/pid/maps.

By passing a pointer to the kernel a process is allowing any other
process that can read /proc/pid/maps to see memory from the pointer to
either the first following null terminator, or 1024 bytes.  If the
memory were to get freed and reused without a null terminator the
process could leak up to 1024 bytes of its memory to other processes
that can read /proc/pid/maps.  I don't see this as a security issue
because /proc/pid/maps is protected by the same permissions as
/proc/pid/mem, so anything that could read the leaked data could
already read it directly.

> If the range this is going after spans two pages, and the second is
> bogus, you'll end up with :
>
>         [anon: foo<fault>]
>
> I guess that's OK, but I find it a wee bit funky.

Yeah, it is funky, but I don't expect it to happen in practice since
the string will likely be in the read-only .text section and won't get
unmapped.  It's a side-effect of avoiding the memcpy above.  If I
switched to access_process_vm it would go away.

>>  #ifdef CONFIG_NUMA
>>  /*
>>   * These functions are for numa_maps but called in generic **maps seq_file
>> @@ -336,6 +386,12 @@ show_map_vma(struct seq_file *m, struct vm_area_struct *vma, int is_pid)
>>                               pad_len_spaces(m, len);
>>                               seq_printf(m, "[stack:%d]", tid);
>>                       }
>> +                     goto done;
>> +             }
>> +
>> +             if (vma_get_anon_name(vma)) {
>> +                     pad_len_spaces(m, len);
>> +                     seq_print_vma_name(m, vma);
>>               }
>>       }
>>
>> @@ -635,6 +691,12 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
>>
>>       show_smap_vma_flags(m, vma);
>>
>> +     if (vma_get_anon_name(vma)) {
>> +             seq_puts(m, "Name:           ");
>> +             seq_print_vma_name(m, vma);
>> +             seq_putc(m, '\n');
>> +     }
>
> FWIW, I'm not a fan of using "get" in function names unless it's taking
> some kind of reference.  I'd probably call it "vma_user_anon_ptr()" or
> something.

Sure

> I dug through the implementation a bit, and don't see any showstoppers,
> but it does churn around the VMA merging code enough to make me a bit
> nervous.  I hope you tested it well. :)

Most of the churn is plumbing through the name of an existing vma from
all the callers to vma_merge.  I considered refactoring vma_merge to
take a struct describing the new vma, instead of a list of parameters
that describe the new vma, with a helper function to create the struct
from an existing vma.  So a vma_merge caller would have:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
