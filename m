Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id D4C786B0169
	for <linux-mm@kvack.org>; Fri,  5 Aug 2011 04:42:45 -0400 (EDT)
Received: by qyk27 with SMTP id 27so215224qyk.14
        for <linux-mm@kvack.org>; Fri, 05 Aug 2011 01:42:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAJn8CcGGsdPdaJ7t_RcBmFOGgVLVjAP8Mr40Cv=FknLTNgBUsg@mail.gmail.com>
References: <CAJn8CcE20-co4xNOD8c+0jMeABrc1mjmGzju3xT34QwHHHFsUA@mail.gmail.com>
	<CAJn8CcG-pNbg88+HLB=tRr26_R+A0RxZEWsJQg4iGe4eY2noXA@mail.gmail.com>
	<20110802002226.3ff0b342.akpm@linux-foundation.org>
	<CAJn8CcGTwhAaqghqWOYN9mGvRZDzyd9UJbYARz7NGA-7NvFg9Q@mail.gmail.com>
	<20110803085437.GB19099@suse.de>
	<CAJn8CcGGsdPdaJ7t_RcBmFOGgVLVjAP8Mr40Cv=FknLTNgBUsg@mail.gmail.com>
Date: Fri, 5 Aug 2011 16:42:43 +0800
Message-ID: <CAJn8CcE2BRhHO6qiu2JigdYsjc-igedaA_wu8w70YBbisQTgcQ@mail.gmail.com>
Subject: Re: kernel BUG at mm/vmscan.c:1114
From: Xiaotian Feng <xtfeng@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>

On Thu, Aug 4, 2011 at 11:54 AM, Xiaotian Feng <xtfeng@gmail.com> wrote:
> On Wed, Aug 3, 2011 at 4:54 PM, Mel Gorman <mgorman@suse.de> wrote:
>> On Wed, Aug 03, 2011 at 02:44:20PM +0800, Xiaotian Feng wrote:
>>> On Tue, Aug 2, 2011 at 3:22 PM, Andrew Morton <akpm@linux-foundation.or=
g> wrote:
>>> > On Tue, 2 Aug 2011 15:09:57 +0800 Xiaotian Feng <xtfeng@gmail.com> wr=
ote:
>>> >
>>> >> __ __I'm hitting the kernel BUG at mm/vmscan.c:1114 twice, each time=
 I
>>> >> was trying to build my kernel. The photo of crash screen and my conf=
ig
>>> >> is attached.
>>> >
>>> > hm, now why has that started happening?
>>> >
>>> > Perhaps you could apply this debug patch, see if we can narrow it dow=
n?
>>> >
>>>
>>> I will try it then, but it isn't very reproducible :(
>>> But my system hung after some list corruption warnings... I hit the
>>> corruption 4 times...
>>>
>>
>> That is very unexpected but if lists are being corrupted, it could
>> explain the previously reported bug as that bug looked like an active
>> page on an inactive list.
>>
>> What was the last working kernel? Can you bisect?
>>
>>> =C2=A0[ 1220.468089] ------------[ cut here ]------------
>>> =C2=A0[ 1220.468099] WARNING: at lib/list_debug.c:56 __list_del_entry+0=
x82/0xd0()
>>> =C2=A0[ 1220.468102] Hardware name: 42424XC
>>> =C2=A0[ 1220.468104] list_del corruption. next->prev should be
>>> ffffea0000e069a0, but was ffff880100216c78
>>> =C2=A0[ 1220.468106] Modules linked in: ip6table_filter ip6_tables
>>> ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4
>>> xt_state nf_conntrack ipt_REJECT xt_CHECKSUM iptable_mangle xt_tcpudp
>>> iptable_filter ip_tables x_tables binfmt_misc bridge stp parport_pc
>>> ppdev snd_hda_codec_conexant snd_hda_intel snd_hda_codec thinkpad_acpi
>>> snd_hwdep snd_pcm i915 snd_seq_midi snd_rawmidi arc4 cryptd
>>> snd_seq_midi_event aes_x86_64 snd_seq drm_kms_helper iwlagn snd_timer
>>> aes_generic drm snd_seq_device mac80211 psmouse uvcvideo videodev snd
>>> v4l2_compat_ioctl32 soundcore snd_page_alloc serio_raw i2c_algo_bit
>>> btusb tpm_tis tpm tpm_bios video cfg80211 bluetooth nvram lp joydev
>>> parport usbhid hid ahci libahci firewire_ohci firewire_core e1000e
>>> sdhci_pci sdhci crc_itu_t
>>> =C2=A0[ 1220.468185] Pid: 1168, comm: Xorg Tainted: G =C2=A0 =C2=A0 =C2=
=A0 =C2=A0W =C2=A0 3.0.0+ #23
>>> =C2=A0[ 1220.468188] Call Trace:
>>> =C2=A0[ 1220.468190] =C2=A0<IRQ> =C2=A0[<ffffffff8106db3f>] warn_slowpa=
th_common+0x7f/0xc0
>>> =C2=A0[ 1220.468201] =C2=A0[<ffffffff8106dc36>] warn_slowpath_fmt+0x46/=
0x50
>>> =C2=A0[ 1220.468206] =C2=A0[<ffffffff81332a52>] __list_del_entry+0x82/0=
xd0
>>> =C2=A0[ 1220.468210] =C2=A0[<ffffffff81332ab1>] list_del+0x11/0x40
>>> =C2=A0[ 1220.468216] =C2=A0[<ffffffff8117a212>] __slab_free+0x362/0x3d0
>>> =C2=A0[ 1220.468222] =C2=A0[<ffffffff811c6606>] ? bvec_free_bs+0x26/0x4=
0
>>> =C2=A0[ 1220.468226] =C2=A0[<ffffffff8117b767>] ? kmem_cache_free+0x97/=
0x220
>>> =C2=A0[ 1220.468230] =C2=A0[<ffffffff811c6606>] ? bvec_free_bs+0x26/0x4=
0
>>> =C2=A0[ 1220.468234] =C2=A0[<ffffffff811c6606>] ? bvec_free_bs+0x26/0x4=
0
>>> =C2=A0[ 1220.468239] =C2=A0[<ffffffff8117b8df>] kmem_cache_free+0x20f/0=
x220
>>> =C2=A0[ 1220.468243] =C2=A0[<ffffffff811c6606>] bvec_free_bs+0x26/0x40
>>> =C2=A0[ 1220.468247] =C2=A0[<ffffffff811c6654>] bio_free+0x34/0x70
>>> =C2=A0[ 1220.468250] =C2=A0[<ffffffff811c66a5>] bio_fs_de
>>>
>>
>
> I'm hitting this again today, when I'm trying to rebuild my kernel....
> Looking it a bit
>
> =C2=A0list_del corruption. next->prev should be ffffea0000e069a0, but was
> ffff880100216c78
>
> I find something interesting from my syslog:
>
> =C2=A0PERCPU: Embedded 28 pages/cpu @ffff880100200000 s83456 r8192 d23040=
 u262144
>
>> This warning and the page reclaim warning are on paths that are
>> commonly used and I would expect to see multiple reports. I wonder
>> what is happening on your machine that is so unusual.
>>
>> Have you run memtest on this machine for a few hours and badblocks
>> on the disk to ensure this is not hardware trouble?
>>
>>> So is it possible that my previous BUG is triggered by slab list corrup=
tion?
>>
>> Not directly, but clearly there is something very wrong.
>>
>> If slub corruption reports are very common and kernel 3.0 is fine, my
>> strongest candidate for the corruption would be the SLUB lockless
>> patches. Try
>>
>> git diff e4a46182e1bcc2ddacff5a35f6b52398b51f1b11..9e577e8b46ab0c38970c0=
f0cd7eae62e6dffddee | patch -p1 -R
>>
>

Here's a update for the results:

3.0.0-rc7: running for hours without a crash
upstream kernel: list corruption happened while building kernel within
10 mins (I'm running some app chrome/firefox/thunderbird/... as well)
upstream kernel with above revert: running for hours without a crash

Trying to bisect but rebuild is slow ....

> I will try it now, thanks.
>
>> They should revert cleanly with offsets.
>>
>> --
>> Mel Gorman
>> SUSE Labs
>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
