Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 231346B0038
	for <linux-mm@kvack.org>; Sun, 14 Jul 2013 15:34:42 -0400 (EDT)
Received: by mail-oa0-f48.google.com with SMTP id f4so14680058oah.7
        for <linux-mm@kvack.org>; Sun, 14 Jul 2013 12:34:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130714141749.GB29815@redhat.com>
References: <1373596462-27115-1-git-send-email-ccross@android.com>
	<1373596462-27115-2-git-send-email-ccross@android.com>
	<20130714141749.GB29815@redhat.com>
Date: Sun, 14 Jul 2013 12:34:40 -0700
Message-ID: <CAMbhsRSofgisUUYTe-s6MRoknM1JBQZpcSy5nr4f02xS6L0yPA@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: add a field to store names for private anonymous memory
From: Colin Cross <ccross@android.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: lkml <linux-kernel@vger.kernel.org>, Kyungmin Park <kmpark@infradead.org>, Christoph Hellwig <hch@infradead.org>, John Stultz <john.stultz@linaro.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Pekka Enberg <penberg@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Cyrill Gorcunov <gorcunov@openvz.org>, David Rientjes <rientjes@google.com>, Davidlohr Bueso <dave@gnu.org>, Kees Cook <keescook@chromium.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, David Howells <dhowells@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Dave Jones <davej@redhat.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Shaohua Li <shli@fusionio.com>, Sasha Levin <sasha.levin@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ingo Molnar <mingo@kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Sun, Jul 14, 2013 at 7:17 AM, Oleg Nesterov <oleg@redhat.com> wrote:
> On 07/11, Colin Cross wrote:
>>
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
> Again, sorry if this was already discussed...
>
> But for what? This moves the policy into the kernel and afaics buys nothing.
> Can't it simply print the number?
>
> If an application reads its own /proc/pid/maps, surely it knows how it should
> interpret the numeric values.
>
> If another process reads this file, and if it assumes that this number is a
> pointer into that task's memory, it can do sys_process_vm_readv() ?

I think there is value in keeping /proc/pid/maps human readable.  A
userspace tool could certainly put together the same information, but
there would be no easy way to do it from the command line.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
