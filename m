Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3ACC46B0033
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 16:27:13 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id e6so1605971otd.17
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 13:27:13 -0800 (PST)
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id 80si4459639otg.425.2017.12.18.13.27.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 13:27:12 -0800 (PST)
Subject: Re: [PATCH v5] mmap.2: MAP_FIXED updated documentation
References: <20171212002331.6838-1-jhubbard@nvidia.com>
 <3a07ef4d-7435-7b8d-d5c7-3bce80042577@gmail.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <fb49f293-2048-e64f-51da-ff039929c7ac@nvidia.com>
Date: Mon, 18 Dec 2017 13:27:10 -0800
MIME-Version: 1.0
In-Reply-To: <3a07ef4d-7435-7b8d-d5c7-3bce80042577@gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: linux-man <linux-man@vger.kernel.org>, linux-api@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org, Jann Horn <jannh@google.com>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Cyril Hrubis <chrubis@suse.cz>, Michal Hocko <mhocko@suse.com>, Pavel Machek <pavel@ucw.cz>

On 12/18/2017 11:15 AM, Michael Kerrisk (man-pages) wrote:
> On 12/12/2017 01:23 AM, john.hubbard@gmail.com wrote:
>> From: John Hubbard <jhubbard@nvidia.com>
>>
>>     -- Expand the documentation to discuss the hazards in
>>        enough detail to allow avoiding them.
>>
>>     -- Mention the upcoming MAP_FIXED_SAFE flag.
>>
>>     -- Enhance the alignment requirement slightly.
>>
>> CC: Michael Ellerman <mpe@ellerman.id.au>
>> CC: Jann Horn <jannh@google.com>
>> CC: Matthew Wilcox <willy@infradead.org>
>> CC: Michal Hocko <mhocko@kernel.org>
>> CC: Mike Rapoport <rppt@linux.vnet.ibm.com>
>> CC: Cyril Hrubis <chrubis@suse.cz>
>> CC: Michal Hocko <mhocko@suse.com>
>> CC: Pavel Machek <pavel@ucw.cz>
>> Signed-off-by: John Hubbard <jhubbard@nvidia.com>
> 
> John,
> 
> Thanks for the patch. I think you win the prize for the 
> most iterations ever on a man-pages patch! (And Michal,
> thanks for helping out.) I've applied your patch, made 
> some minor tweaks, and removed the mention of 
> MAP_FIXED_SAFE, since I don't like to document stuff
> that hasn't yet been merged. (I only later noticed the
> fuss about the naming...)
> 

Hi Michael,

The final result looks nice, thanks for all the editing fixes.

One last thing: reading through this, I think it might need a wording
fix (this is my fault), in order to avoid implying that brk() or
malloc() use dlopen().

Something approximately like this:

diff --git a/man2/mmap.2 b/man2/mmap.2
index 79681b31e..1c0bd80de 100644
--- a/man2/mmap.2
+++ b/man2/mmap.2
@@ -250,8 +250,9 @@ suffice.
 The
 .BR dlopen (3)
 call will map the library into the process's address space.
-Furthermore, almost any library call may be implemented using this technique.
-Examples include
+Furthermore, almost any library call may be implemented in a way that
+adds memory mappings to the address space, either with this technique,
+or by simply allocating memory. Examples include
 .BR brk (2),
 .BR malloc (3),
 .BR pthread_create (3),


...or does the current version seem OK to other people?

thanks,
-- 
John Hubbard
NVIDIA

> Cheers,
> 
> Michael
> 
>> ---
>>
>> Changes since v4:
>>
>>     -- v2 ("mmap.2: MAP_FIXED is no longer discouraged") was applied already,
>>        so v5 is a merge, including rewording of the paragraph transitions.
>>
>>     -- We seem to have consensus about what to say about alignment
>>        now, and this includes that new wording.
>>
>> Changes since v3:
>>
>>     -- Removed the "how to use this safely" part, and
>>        the SHMLBA part, both as a result of Michal Hocko's
>>        review.
>>
>>     -- A few tiny wording fixes, at the not-quite-typo level.
>>
>> Changes since v2:
>>
>>     -- Fixed up the "how to use safely" example, in response
>>        to Mike Rapoport's review.
>>
>>     -- Changed the alignment requirement from system page
>>        size, to SHMLBA. This was inspired by (but not yet
>>        recommended by) Cyril Hrubis' review.
>>
>>     -- Formatting: underlined /proc/<pid>/maps
>>
>> Changes since v1:
>>
>>     -- Covered topics recommended by Matthew Wilcox
>>        and Jann Horn, in their recent review: the hazards
>>        of overwriting pre-exising mappings, and some notes
>>        about how to use MAP_FIXED safely.
>>
>>     -- Rewrote the commit description accordingly.
>>
>>  man2/mmap.2 | 32 ++++++++++++++++++++++++++++++--
>>  1 file changed, 30 insertions(+), 2 deletions(-)
>>
>> diff --git a/man2/mmap.2 b/man2/mmap.2
>> index a5a8eb47a..400cfda2d 100644
>> --- a/man2/mmap.2
>> +++ b/man2/mmap.2
>> @@ -212,8 +212,9 @@ Don't interpret
>>  .I addr
>>  as a hint: place the mapping at exactly that address.
>>  .I addr
>> -must be a multiple of the page size.
>> -If the memory region specified by
>> +must be suitably aligned: for most architectures a multiple of page
>> +size is sufficient; however, some architectures may impose additional
>> +restrictions. If the memory region specified by
>>  .I addr
>>  and
>>  .I len
>> @@ -226,6 +227,33 @@ Software that aspires to be portable should use this option with care, keeping
>>  in mind that the exact layout of a process' memory map is allowed to change
>>  significantly between kernel versions, C library versions, and operating system
>>  releases.
>> +.IP
>> +Furthermore, this option is extremely hazardous (when used on its own), because
>> +it forcibly removes pre-existing mappings, making it easy for a multi-threaded
>> +process to corrupt its own address space.
>> +.IP
>> +For example, thread A looks through
>> +.I /proc/<pid>/maps
>> +and locates an available
>> +address range, while thread B simultaneously acquires part or all of that same
>> +address range. Thread A then calls mmap(MAP_FIXED), effectively overwriting
>> +the mapping that thread B created.
>> +.IP
>> +Thread B need not create a mapping directly; simply making a library call
>> +that, internally, uses
>> +.I dlopen(3)
>> +to load some other shared library, will
>> +suffice. The dlopen(3) call will map the library into the process's address
>> +space. Furthermore, almost any library call may be implemented using this
>> +technique.
>> +Examples include brk(2), malloc(3), pthread_create(3), and the PAM libraries
>> +(http://www.linux-pam.org).
>> +.IP
>> +Newer kernels
>> +(Linux 4.16 and later) have a
>> +.B MAP_FIXED_SAFE
>> +option that avoids the corruption problem; if available, MAP_FIXED_SAFE
>> +should be preferred over MAP_FIXED.
>>  .TP
>>  .B MAP_GROWSDOWN
>>  This flag is used for stacks.
>>
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
