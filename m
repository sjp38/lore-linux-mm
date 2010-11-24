Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 31E176B0071
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 07:17:41 -0500 (EST)
Received: by iwn35 with SMTP id 35so750800iwn.14
        for <linux-mm@kvack.org>; Wed, 24 Nov 2010 04:17:39 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101124094736.3c4ba760.kamezawa.hiroyu@jp.fujitsu.com>
References: <AANLkTingzd3Pqrip1izfkLm+HCE9jRQL777nu9s3RnLv@mail.gmail.com>
	<20101124094736.3c4ba760.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 24 Nov 2010 15:17:38 +0300
Message-ID: <AANLkTimSRJ6GC3=bddNMfnVE3LmMx-9xSY2GX_XNvzCA@mail.gmail.com>
Subject: Re: Question about cgroup hierarchy and reducing memory limit
From: Evgeniy Ivanov <lolkaantimat@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Nov 24, 2010 at 3:47 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Mon, 22 Nov 2010 19:59:41 +0300
> Evgeniy Ivanov <lolkaantimat@gmail.com> wrote:
>
>> Hello,
>>
> Hi,
>
>> I have following cgroup hierarchy:
>>
>> =A0 Root
>> =A0 / =A0 |
>> A =A0 B
>>
>> A and B have memory limits set so that it's 100% of limit set in Root.
>> I want to add C to root:
>>
>> =A0 Root
>> =A0 / =A0 | =A0\
>> A =A0 B =A0C
>>
>> What is correct way to shrink limits for A and B? When they use all
>> allowed memory and I try to write to their limit files I get error.
>
> What kinds of error ? Do you have swap ? What is the kerenel version ?

Kernel is 2.6.31-5 from SLES-SP1 (my build, but without extra patches).
I have 2 Gb swap and just 40 Mb used. Machine has 3 Gb RAM and no load
(neither mem or CPU).

Error is "-bash: echo: write error: Device or resource busy", when I
write to memory.limit_in_bytes.

> It's designed to allow "shrink at once" but that means release memory
> and do forced-writeback. To release memory, it may have to write back
> to swap. If tasks in "A" and "B" are too busy and tocuhes tons of memory
> while shrinking, it may fail.

Well, in test I have a process which uses 30M of memory and in loop
dirties all pages (just single byte) then sleeps 5 seconds before next
iteration.

> It may be a regression. Kernel version is important.
>
> Could you show memory.stat file when you shrink "A" and "B" ?
> And what happnes
> # sync
> # sync
> # sync
> # reduce memory A
> # reduce memory B

Sync doesn't help. Here is log just for memory.stat for group I tried to sh=
rink:

ivanoe:/cgroups/root# cat C/memory.stat
cache 0
rss 90222592
mapped_file 0
pgpgin 1212770
pgpgout 1190743
inactive_anon 45338624
active_anon 44883968
inactive_file 0
active_file 0
unevictable 0
hierarchical_memory_limit 94371840
hierarchical_memsw_limit 9223372036854775807
total_cache 0
total_rss 90222592
total_mapped_file 0
total_pgpgin 1212770
total_pgpgout 1190743
total_inactive_anon 45338624
total_active_anon 44883968
total_inactive_file 0
total_active_file 0
total_unevictable 0
ivanoe:/cgroups/root# echo 30M > C/memory.limit_in_bytes
-bash: echo: write error: Device or resource busy
ivanoe:/cgroups/root# echo 30M > C/memory.limit_in_bytes
-bash: echo: write error: Device or resource busy
ivanoe:/cgroups/root# echo 30M > C/memory.limit_in_bytes
-bash: echo: write error: Device or resource busy
ivanoe:/cgroups/root# echo 30M > C/memory.limit_in_bytes
ivanoe:/cgroups/root# cat memory.limit_in_bytes
125829120
ivanoe:/cgroups/root# cat B/memory.limit_in_bytes
62914560
ivanoe:/cgroups/root# cat A/memory.limit_in_bytes
20971520



--=20
Evgeniy Ivanov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
