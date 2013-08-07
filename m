Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 946776B008C
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 06:04:21 -0400 (EDT)
Received: by mail-oa0-f42.google.com with SMTP id i18so3018225oag.15
        for <linux-mm@kvack.org>; Wed, 07 Aug 2013 03:04:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130807055157.GA32278@redhat.com>
References: <20130807055157.GA32278@redhat.com>
Date: Wed, 7 Aug 2013 18:04:20 +0800
Message-ID: <CAJd=RBCJv7=Qj6dPW2Ha=nq6JctnK3r7wYCAZTm=REVOZUNowg@mail.gmail.com>
Subject: Re: unused swap offset / bad page map.
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, linux-mm@kvack.org, Linux Kernel <linux-kernel@vger.kernel.org>

Hello Dave

On Wed, Aug 7, 2013 at 1:51 PM, Dave Jones <davej@redhat.com> wrote:
> Seen while fuzzing with lots of child processes.
>
> swap_free: Unused swap offset entry 001263f5
> BUG: Bad page map in process trinity-child29  pte:24c7ea00 pmd:09fec067
> addr:00007f9db958d000 vm_flags:00100073 anon_vma:ffff88022c004ba0 mapping=
:          (null) index:f99
> Modules linked in: fuse ipt_ULOG snd_seq_dummy tun sctp scsi_transport_is=
csi can_raw can_bcm rfcomm bnep nfnetlink hidp appletalk bluetooth rose can=
 af_802154 phonet x25 af_rxrpc llc2 nfc rfkill af_key pppoe rds pppox ppp_g=
eneric slhc caif_socket caif irda crc_ccitt atm netrom ax25 ipx p8023 psnap=
 p8022 llc snd_hda_codec_realtek pcspkr usb_debug snd_seq snd_seq_device sn=
d_hda_intel snd_hda_codec snd_hwdep e1000e snd_pcm ptp pps_core snd_page_al=
loc snd_timer snd soundcore xfs libcrc32c
> CPU: 1 PID: 2624 Comm: trinity-child29 Not tainted 3.11.0-rc4+ #1
>  0000000000000000 ffff8801fd7ddc90 ffffffff81700f2c 00007f9db958d000
>  ffff8801fd7ddcd8 ffffffff8117cba7 0000000024c7ea00 0000000000000f99
>  00007f9db9600000 ffff880009fecc68 0000000024c7ea00 ffff8801fd7dde00
> Call Trace:
>  [<ffffffff81700f2c>] dump_stack+0x4e/0x82
>  [<ffffffff8117cba7>] print_bad_pte+0x187/0x220
>  [<ffffffff8117e415>] unmap_single_vma+0x535/0x890
>  [<ffffffff8117f719>] unmap_vmas+0x49/0x90
>  [<ffffffff81187ef1>] exit_mmap+0xc1/0x170
>  [<ffffffff810510ef>] mmput+0x6f/0x100
>  [<ffffffff81055818>] do_exit+0x288/0xcd0
>  [<ffffffff810c1da5>] ? trace_hardirqs_on_caller+0x115/0x1e0
>  [<ffffffff810c1e7d>] ? trace_hardirqs_on+0xd/0x10
>  [<ffffffff810575dc>] do_group_exit+0x4c/0xc0
>  [<ffffffff81057664>] SyS_exit_group+0x14/0x20
>  [<ffffffff81713dd4>] tracesys+0xdd/0xe2
>
> There were a slew of these. same trace, different addr/anon_vma/index.
> mapping always null.
>
Would you please run again with the debug info added?
---
--- a/mm/swapfile.c	Wed Aug  7 17:27:22 2013
+++ b/mm/swapfile.c	Wed Aug  7 17:57:20 2013
@@ -509,6 +509,7 @@ static struct swap_info_struct *swap_inf
 {
 	struct swap_info_struct *p;
 	unsigned long offset, type;
+	int race =3D 0;

 	if (!entry.val)
 		goto out;
@@ -524,10 +525,17 @@ static struct swap_info_struct *swap_inf
 	if (!p->swap_map[offset])
 		goto bad_free;
 	spin_lock(&p->lock);
+	if (!p->swap_map[offset]) {
+		race =3D 1;
+		spin_unlock(&p->lock);
+		goto bad_free;
+	}
 	return p;

 bad_free:
 	printk(KERN_ERR "swap_free: %s%08lx\n", Unused_offset, entry.val);
+	if (race)
+		printk(KERN_ERR "but due to race\n");
 	goto out;
 bad_offset:
 	printk(KERN_ERR "swap_free: %s%08lx\n", Bad_offset, entry.val);
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
