Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 23BC58D0039
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 22:16:27 -0500 (EST)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <20110216185234.GA11636@tiehlicka.suse.cz>
	<20110216193700.GA6377@elte.hu>
	<AANLkTinDxxbVjrUViCs=UaMD9Wg9PR7b0ShNud5zKE3w@mail.gmail.com>
	<AANLkTi=xnbcs5BKj3cNE_aLtBO7W5m+2uaUacu7M8g_S@mail.gmail.com>
	<20110217090910.GA3781@tiehlicka.suse.cz>
	<AANLkTikPKpNHxDQAYBd3fiQsmVozLtCVDsNn=+eF_q2r@mail.gmail.com>
	<20110217163531.GF14168@elte.hu> <m1pqqqfpzh.fsf@fess.ebiederm.org>
	<AANLkTinB=EgDGNv-v-qD-MvHVAmstfP_CyyLNhhotkZx@mail.gmail.com>
Date: Thu, 17 Feb 2011 19:16:17 -0800
In-Reply-To: <AANLkTinB=EgDGNv-v-qD-MvHVAmstfP_CyyLNhhotkZx@mail.gmail.com>
	(Linus Torvalds's message of "Thu, 17 Feb 2011 11:11:51 -0800")
Message-ID: <m1sjvm822m.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Subject: Re: BUG: Bad page map in process udevd (anon_vma: (null)) in 2.6.38-rc4
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Linus Torvalds <torvalds@linux-foundation.org> writes:

> On Thu, Feb 17, 2011 at 10:57 AM, Eric W. Biederman
> <ebiederm@xmission.com> wrote:
>>
>> fedora 14
>> ext4 on all filesystems
>
> Your dmesg snippets had ext3 mentioned, though:
>
>   <6>EXT3-fs (sda1): recovery required on readonly filesystem
>   <6>EXT3-fs (sda1): write access will be enabled during recovery
>   <6>EXT3-fs: barriers not enabled
>   ..
>   <6>EXT3-fs (sda1): recovery complete
>   <6>EXT3-fs (sda1): mounted filesystem with ordered data mode
>   <6>dracut: Mounted root filesystem /dev/sda1
>
> not that I see that it should matter, but there's been some bigger
> ext3 changes too (like the batched discard).
>
> I don't really think ext3 is the issue, though.
>
>> I was about to say this happens with DEBUG_PAGEALLOC enabled but it
>> appears that options keeps eluding my fingers when I have a few minutes
>> to play with it. =C2=A0Perhaps this time will be the charm.
>
> Please do. You seem to be much better at triggering it than anybody
> else. And do the DEBUG_LIST and DEBUG_SLUB_ON things too (even if the
> DEBUG_LIST thing won't catch list_move())

Interesting.  I just got this with DEBUG_PAGEALLOC
It looks like something in DEBUG_PAGEALLOC is interfering with taking a
successful crashdump.

Given how many network namespaces I create and destroy this might be a
code path I exercise more than most people.

BUG: unable to handle kernel paging request at ffff8801adf8d760
IP: [<ffffffff8140c7ca>] unregister_netdevice_queue+0x3a/0xb0
Oops: 0002 [#1] SMP DEBUG_PAGEALLOC
last sysfs file: /sys/devices/system/cpu/cpu7/cache/index2/shared_cpu_map
Stack:
Call Trace:
Code: 24 08 48 89 fb 49 89 f4 e8 f4 c8 00 00 85 c0 74 6d 4d 85 e4 74 3b 48 =
8b 93 a0 00 00 00 48 8b 83 a8 00 00 00 48 8d bb a0 00 00 00 <48> 89 42 08 4=
8 89 10 4c 89 e2 49 8b 74 24 08 e8 32 75 e7 ff 48=20
RIP  [<ffffffff8140c7ca>] unregister_netdevice_queue+0x3a/0xb0
CR2: ffff8801adf8d760

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
