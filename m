Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id D72B2280274
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 06:01:36 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id b130so78395843wmc.2
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 03:01:36 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k184si7814556wme.129.2016.09.26.03.01.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 26 Sep 2016 03:01:34 -0700 (PDT)
Subject: Re: [PATCH v2] fs/select: add vmalloc fallback for select(2)
References: <20160922164359.9035-1-vbabka@suse.cz>
 <1474562982.23058.140.camel@edumazet-glaptop3.roam.corp.google.com>
 <12efc491-a0e7-1012-5a8b-6d3533c720db@suse.cz>
 <1474564068.23058.144.camel@edumazet-glaptop3.roam.corp.google.com>
 <a212f313-1f34-7c83-3aab-b45374875493@suse.cz>
 <063D6719AE5E284EB5DD2968C1650D6DB0107DC8@AcuExch.aculab.com>
 <3bbcc269-ec8b-12dd-e0ae-190c18bc3f47@suse.cz>
 <063D6719AE5E284EB5DD2968C1650D6DB0107FEB@AcuExch.aculab.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5bb958c9-542e-e86b-779c-e3d93dc01632@suse.cz>
Date: Mon, 26 Sep 2016 12:01:32 +0200
MIME-Version: 1.0
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB0107FEB@AcuExch.aculab.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Laight <David.Laight@ACULAB.COM>, Eric Dumazet <eric.dumazet@gmail.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, "linux-man@vger.kernel.org" <linux-man@vger.kernel.org>

On 09/23/2016 03:35 PM, David Laight wrote:
> From: Vlastimil Babka
>> Sent: 23 September 2016 10:59
> ...
>> > I suspect that fdt->max_fds is an upper bound for the highest fd the
>> > process has open - not the RLIMIT_NOFILE value.
>>
>> I gathered that the highest fd effectively limits the number of files,
>> so it's the same. I might be wrong.
>
> An application can reduce RLIMIT_NOFILE below that of an open file.

OK, I did some more digging in the code, and my understanding is that:

- fdt->max_fds is the current size of the fdtable, which isn't allocated upfront 
to match the limit, but grows as needed. This means it's OK for 
core_sys_select() to silently cap nfds, as it knows there are no fd's with 
higher number in the fdtable, so it's a performance optimization. However, to 
match what the manpage says, there should be another check against RLIMIT_NOFILE 
to return -EINVAL, which there isn't, AFAICS.

- fdtable is expanded (and fdt->max_fds bumped) by 
expand_files()->expand_fdtable() which checks against fs.nr_open sysctl, which 
seems to be 1048576 where I checked.

- callers of expand_files(), such as dup(), check the rlimit(RLIMIT_NOFILE) to 
limit the expansion.

So yeah, application can reduce RLIMIT_NOFILE, but it has no effect on fdtable 
and fdt->max_fds that is already above the limit. Select syscall would have to 
check the rlimit to conform to the manpage. Or (rather?) we should fix the manpage.

As for the original vmalloc() flood concern, I still think we're safe, as 
ordinary users are limited by RLIMIT_NOFILE way below sizes that would need 
vmalloc(), and root has many other options to DOS the system (or worse).

Vlastimil

> 	David
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
