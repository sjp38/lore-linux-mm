Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id BD97B6B0286
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 05:59:02 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id l138so12316807wmg.3
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 02:59:02 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a185si2533858wmc.55.2016.09.23.02.59.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 23 Sep 2016 02:59:01 -0700 (PDT)
Subject: Re: [PATCH v2] fs/select: add vmalloc fallback for select(2)
References: <20160922164359.9035-1-vbabka@suse.cz>
 <1474562982.23058.140.camel@edumazet-glaptop3.roam.corp.google.com>
 <12efc491-a0e7-1012-5a8b-6d3533c720db@suse.cz>
 <1474564068.23058.144.camel@edumazet-glaptop3.roam.corp.google.com>
 <a212f313-1f34-7c83-3aab-b45374875493@suse.cz>
 <063D6719AE5E284EB5DD2968C1650D6DB0107DC8@AcuExch.aculab.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <3bbcc269-ec8b-12dd-e0ae-190c18bc3f47@suse.cz>
Date: Fri, 23 Sep 2016 11:58:34 +0200
MIME-Version: 1.0
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB0107DC8@AcuExch.aculab.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Laight <David.Laight@ACULAB.COM>, Eric Dumazet <eric.dumazet@gmail.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, "linux-man@vger.kernel.org" <linux-man@vger.kernel.org>

On 09/23/2016 11:42 AM, David Laight wrote:
> From: Vlastimil Babka
>> Sent: 22 September 2016 18:55
> ...
>> So in the case of select() it seems like the memory we need 6 bits per file
>> descriptor, multiplied by the highest possible file descriptor (nfds) as passed
>> to the syscall. According to the man page of select:
>>
>>         EINVAL nfds is negative or exceeds the RLIMIT_NOFILE resource limit (see
>> getrlimit(2)).
> 
> That second clause is relatively recent.

Interesting... so it was added without actually being true in the kernel
code?

>> The code actually seems to silently cap the value instead of returning EINVAL
>> though? (IIUC):
>>
>>         /* max_fds can increase, so grab it once to avoid race */
>>          rcu_read_lock();
>>          fdt = files_fdtable(current->files);
>>          max_fds = fdt->max_fds;
>>          rcu_read_unlock();
>>          if (n > max_fds)
>>                  n = max_fds;
>>
>> The default for this cap seems to be 1024 where I checked (again, IIUC, it's
>> what ulimit -n returns?). I wasn't able to change it to more than 2048, which
>> makes the bitmaps still below PAGE_SIZE.
>>
>> So if I get that right, the system admin would have to allow really large
>> RLIMIT_NOFILE to even make vmalloc() possible here. So I don't see it as a large
>> concern?
> 
> 4k open files isn't that many.
> Especially for programs that are using pipes to emulate windows events.

Sure but IIUC we need 6 bits per file. That means up to almost 42k
files, we should fit into order-3 allocation, which effectively cannot
fail right now.

> I suspect that fdt->max_fds is an upper bound for the highest fd the
> process has open - not the RLIMIT_NOFILE value.

I gathered that the highest fd effectively limits the number of files,
so it's the same. I might be wrong.

> select() shouldn't be silently ignoring large values of 'n' unless
> the fd_set bits are zero.

Yeah that doesn't seem to conform to the manpage.

> Of course, select does scale well for high numbered fds
> and neither poll nor select scale well for large numbers of fds.

True.

> 	David
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
