Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id CC8276B00E7
	for <linux-mm@kvack.org>; Wed, 12 Jan 2011 02:03:38 -0500 (EST)
Received: by gwj22 with SMTP id 22so113679gwj.14
        for <linux-mm@kvack.org>; Tue, 11 Jan 2011 23:03:35 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110111130959.GA19003@merz.inka.de>
References: <20110110223154.GA9739@merz.inka.de>
	<AANLkTi=hnWtpHgv-j0u3n5sG4T-GU0KG_vAMe4vevY05@mail.gmail.com>
	<20110111130959.GA19003@merz.inka.de>
Date: Wed, 12 Jan 2011 09:03:32 +0200
Message-ID: <AANLkTimViOqKP9aw28PVt0_2LcH_OuruS736fickb_jp@mail.gmail.com>
Subject: Re: Regression in linux 2.6.37: failure on remount / (ext4) rw (was:
 Re: Regression in linux 2.6.37: failure to boot, caused by commit 37d57443d5 (mm/slub.c))
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Matthias Merz <linux@merz-ka.de>
Cc: Christoph Lameter <cl@linux.com>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, Tero Roponen <tero.roponen@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 11, 2011 at 3:09 PM, Matthias Merz <linux@merz-ka.de> wrote:
> Hello,
>
> Am Di, 11.01.2011 09:50 schrieb Pekka Enberg
>> On Tue, Jan 11, 2011 at 12:31 AM, Matthias Merz <linux@merz-ka.de> wrote=
:
>> > This morning I tried vanilla 2.6.37 on my Desktop system, which failed
>> > to boot but continued displaying Debug-Messages too fast to read. Usin=
g
>> > netconsole I was then able to capture them (see attached file). I was
>> > able to trigger this bug even with init=3D/bin/bash by a simple call o=
f
>> > "mount -o remount,rw /" with my / being an ext4 filesystem.
>> >
>> > Using git bisect I could identify commit 37d57443d5 as "the culprit" -
>> > once I reverted that bugfix locally, my system booted happily.
>
> Sorry; this morning the version which I was able to boot yesterday
> failed. I assume some "hardware state" influeces triggering of this bug
> and my whole bisect-session yesterday was useless because I did mostly
> warm restarts and no cold boot when trying :-(

Would it be possible for you to try to bisect it again? The oops you
report looks slightly obscure (at least to me) so it might be
difficult to find someone to fix it.

>> Now here's an interesting bug! Commit 37d57443d5 shouldn't change
>> anything unless you actually access the affected sysfs files. I'm but
>> lost with your oops as well so lets CC some scheduler people to see if
>> they can help us out:
>
> You're proven to be right; sorry for complicating things by wrong
> conclusions - next time I'll hopefully remember to cut the AC-power for
> 10 seconds when testing revisions...
>
> As I just noticed I don't use slub at all, but slab; I'll attach my
> .config for reference.
>
>
> Keeping the citation of the debug log for inline reference:
>
>> BUG: scheduling while atomic: swapper/0/0x10010000
>> Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc
>> snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev
>> snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi
>> snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371
>> snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer
>> snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda
>> crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev
>> ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg
>> videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common
>> ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog
>> gameport uhci_hcd ehci_hcd e100
>> Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc
>> snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev
>> snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi
>> snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371
>> snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer
>> snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda
>> crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev
>> ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg
>> videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common
>> ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog
>> gameport uhci_hcd ehci_hcd e100
>>
>> Pid: 0, comm: swapper Not tainted 2.6.37-matthias #28 A7V8X/System Name
>> EIP: 0060:[<c10088ba>] EFLAGS: 00000246 CPU: 0
>> EIP is at default_idle+0x2a/0x40
>> EAX: 00000000 EBX: c1596140 ECX: 00000000 EDX: 00000000
>> ESI: 0008d800 EDI: c153d000 EBP: c153bfbc ESP: c153bfbc
>> =A0DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
>> Process swapper (pid: 0, ti=3Df6004000 task=3Dc1541300 task.ti=3Dc153a00=
0)
>> Stack:
>> =A0c153bfc4 c1001c7c c153bfcc c13e72a2 c153bfe4 c15706cd 000000a0 c15702=
b9
>> =A0c1596140 00000000 c153bff8 c157006b 01606d60 00000000 c14b0e88 018270=
03
>> =A000000000
>> Call Trace:
>> =A0[<c1001c7c>] ? cpu_idle+0x2c/0x50
>> =A0[<c13e72a2>] ? rest_init+0x52/0x60
>> =A0[<c15706cd>] ? start_kernel+0x242/0x248
>> =A0[<c15702b9>] ? unknown_bootoption+0x0/0x19c
>> =A0[<c157006b>] ? i386_start_kernel+0x6b/0x6d
>> Code: 00 55 8b 0d 18 67 5c c1 89 e5 85 c9 75 2b 80 3d 05 d5 56 c1 00
>> 74 22 89 e0 25 00 e0 ff ff 83 60 0c fb 8b 40 08 a8 08 75 15 fb f4 <89>
>> e0 25 00 e0 ff ff 83 48 0c 04 c9 c3 90 fb f3 90 c9 c3 fb eb
>>
>> Full log available here:
>>
>> http://www.spinics.net/lists/linux-mm/msg13451.html
>
> Thanks for your effort,
> Yours
> Matthias Merz
>
> --
> In einem geschlossenen System (Kinderzimmer) w=E4chst die Entropie
> (=3DUnordnung) so lange, bis jemand (=3DEltern) dem System Energie zuf=FC=
hrt
> (=3Ddie T=FCre =F6ffnet und reinruft: "Jetzt r=E4umt Ihr aber auf!")
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 "Walter P. Zaehl" in <gervns$m90$1@deacx010.e=
ed.ericsson.se>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
