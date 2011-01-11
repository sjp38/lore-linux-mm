Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id AFB756B00E7
	for <linux-mm@kvack.org>; Tue, 11 Jan 2011 02:50:54 -0500 (EST)
Received: by gyd10 with SMTP id 10so5222524gyd.14
        for <linux-mm@kvack.org>; Mon, 10 Jan 2011 23:50:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110110223154.GA9739@merz.inka.de>
References: <20110110223154.GA9739@merz.inka.de>
Date: Tue, 11 Jan 2011 09:50:42 +0200
Message-ID: <AANLkTi=hnWtpHgv-j0u3n5sG4T-GU0KG_vAMe4vevY05@mail.gmail.com>
Subject: Re: Regression in linux 2.6.37: failure to boot, caused by commit
 37d57443d5 (mm/slub.c)
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Matthias Merz <linux@merz-ka.de>
Cc: Christoph Lameter <cl@linux.com>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, Tero Roponen <tero.roponen@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 11, 2011 at 12:31 AM, Matthias Merz <linux@merz-ka.de> wrote:
> Hello together,
>
> I hope, I've got the right list of people from scripts/get_maintainer.pl
> and the commit-log, just omitting LKML as Rcpt.
>
> This morning I tried vanilla 2.6.37 on my Desktop system, which failed
> to boot but continued displaying Debug-Messages too fast to read. Using
> netconsole I was then able to capture them (see attached file). I was
> able to trigger this bug even with init=/bin/bash by a simple call of
> "mount -o remount,rw /" with my / being an ext4 filesystem.
>
> Using git bisect I could identify commit 37d57443d5 as "the culprit" -
> once I reverted that bugfix locally, my system booted happily. This ist
> surely not a fix, but a local workaround for me - I would appreciate, if
> someone with knowledge of the code could find a real fix.
>
> The attached dmesg-output was "anonymized" wrt. MAC-Addresses, but is
> complete otherwise.

Now here's an interesting bug! Commit 37d57443d5 shouldn't change
anything unless you actually access the affected sysfs files. I'm but
lost with your oops as well so lets CC some scheduler people to see if
they can help us out:

BUG: scheduling while atomic: swapper/0/0x10010000
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc
snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev
snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi
snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371
snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer
snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda
crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev
ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg
videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common
ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog
gameport uhci_hcd ehci_hcd e100
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc
snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev
snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi
snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371
snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer
snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda
crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev
ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg
videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common
ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog
gameport uhci_hcd ehci_hcd e100

Pid: 0, comm: swapper Not tainted 2.6.37-matthias #28 A7V8X/System Name
EIP: 0060:[<c10088ba>] EFLAGS: 00000246 CPU: 0
EIP is at default_idle+0x2a/0x40
EAX: 00000000 EBX: c1596140 ECX: 00000000 EDX: 00000000
ESI: 0008d800 EDI: c153d000 EBP: c153bfbc ESP: c153bfbc
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process swapper (pid: 0, ti=f6004000 task=c1541300 task.ti=c153a000)
Stack:
 c153bfc4 c1001c7c c153bfcc c13e72a2 c153bfe4 c15706cd 000000a0 c15702b9
 c1596140 00000000 c153bff8 c157006b 01606d60 00000000 c14b0e88 01827003
 00000000
Call Trace:
 [<c1001c7c>] ? cpu_idle+0x2c/0x50
 [<c13e72a2>] ? rest_init+0x52/0x60
 [<c15706cd>] ? start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] ? i386_start_kernel+0x6b/0x6d
Code: 00 55 8b 0d 18 67 5c c1 89 e5 85 c9 75 2b 80 3d 05 d5 56 c1 00
74 22 89 e0 25 00 e0 ff ff 83 60 0c fb 8b 40 08 a8 08 75 15 fb f4 <89>
e0 25 00 e0 ff ff 83 48 0c 04 c9 c3 90 fb f3 90 c9 c3 fb eb

Full log available here:

http://www.spinics.net/lists/linux-mm/msg13451.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
