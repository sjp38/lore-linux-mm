Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id AE1046B0032
	for <linux-mm@kvack.org>; Fri, 12 Jul 2013 02:42:57 -0400 (EDT)
Received: by mail-ve0-f182.google.com with SMTP id ox1so8018386veb.13
        for <linux-mm@kvack.org>; Thu, 11 Jul 2013 23:42:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <51DFA3FD.2020201@intel.com>
References: <1373596462-27115-1-git-send-email-ccross@android.com>
	<1373596462-27115-2-git-send-email-ccross@android.com>
	<51DFA3FD.2020201@intel.com>
Date: Thu, 11 Jul 2013 23:42:56 -0700
Message-ID: <CAMbhsRQNMtJL40es0ta9iePdm07yt2GwXkaDBgLOonH1mA2G+Q@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: add a field to store names for private anonymous memory
From: Colin Cross <ccross@android.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: lkml <linux-kernel@vger.kernel.org>, Kyungmin Park <kmpark@infradead.org>, Christoph Hellwig <hch@infradead.org>, John Stultz <john.stultz@linaro.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Pekka Enberg <penberg@kernel.org>, Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Cyrill Gorcunov <gorcunov@openvz.org>, David Rientjes <rientjes@google.com>, Davidlohr Bueso <dave@gnu.org>, Kees Cook <keescook@chromium.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, David Howells <dhowells@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Dave Jones <davej@redhat.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Oleg Nesterov <oleg@redhat.com>, Shaohua Li <shli@fusionio.com>, Sasha Levin <sasha.levin@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ingo Molnar <mingo@kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Thu, Jul 11, 2013 at 11:36 PM, Dave Hansen <dave.hansen@intel.com> wrote:
> On 07/11/2013 07:34 PM, Colin Cross wrote:
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
>
> This looks a bit like access_process_vm()?  Can you perhaps use it here?

It's a lot like __access_remote_vm, and this pattern is repeated in
many other places in the kernel.  I didn't try to reuse any of them
because I wanted to stop reading at a null byte and __access_remote_vm
would read the full NAME_MAX every time.  I was also avoiding having
to allocate a NAME_MAX sized buffer to copy into, instead passing the
mapped user page directly to seq_write.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
