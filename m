Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8F6798E0002
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 12:10:47 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id n45so13101438qta.5
        for <linux-mm@kvack.org>; Fri, 18 Jan 2019 09:10:47 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g17sor50241815qki.31.2019.01.18.09.10.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 18 Jan 2019 09:10:46 -0800 (PST)
Subject: Re: [PATCH v2] rbtree: fix the red root
References: <20190111181600.GJ6310@bombadil.infradead.org>
 <864d6b85-3336-4040-7c95-7d9615873777@lechnology.com>
 <b1033d96-ebdd-e791-650a-c6564f030ce1@lca.pw>
 <8v11ZOLyufY7NLAHDFApGwXOO_wGjVHtsbw1eiZ__YvI9EZCDe_4FNmlp0E-39lnzGQHhHAczQ6Q6lQPzVU2V6krtkblM8IFwIXPHZCuqGE=@protonmail.ch>
 <c6265fc0-4089-9d1a-ba7c-b267b847747e@interlog.com>
 <UKsodHRZU8smIdO2MHHL4Yzde_YB4iWX43TaHI1uY2tMo4nii4ucbaw4XC31XIY-Pe4oEovjF62qbkeMsIMTrvT1TdCCP4Fs_fxciAzXYVc=@protonmail.ch>
 <ad591828-76e8-324b-6ab8-dc87e4390f64@interlog.com>
 <GBn2paWQ0Uy0COgTeJsgmC18Faw0x_yNIog8gpuC5TJ4kCn_IUH1EnHJW0mQeo3Qy5MMcpMzyw9Yer3lxyWYgtk5TJx8I3sJK4oVlIJh38s=@protonmail.ch>
 <dac115ca-d6ed-dfc0-161a-8e51a7f93e00@lca.pw>
 <V43yC74oVMPrFb5L6QvYmFx60e29_vCM12jAOjNpWyrsRbIkKjpDRS9uyMCAwOtLpoHKJkM1CVJ50oXG0n23vBvsAluprgSNas3aCeSP7rs=@protonmail.ch>
From: Qian Cai <cai@lca.pw>
Message-ID: <86889aee-2e9c-a686-cfe9-dde27249da53@lca.pw>
Date: Fri, 18 Jan 2019 12:10:43 -0500
MIME-Version: 1.0
In-Reply-To: <V43yC74oVMPrFb5L6QvYmFx60e29_vCM12jAOjNpWyrsRbIkKjpDRS9uyMCAwOtLpoHKJkM1CVJ50oXG0n23vBvsAluprgSNas3aCeSP7rs=@protonmail.ch>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Esme <esploit@protonmail.ch>
Cc: "dgilbert@interlog.com" <dgilbert@interlog.com>, David Lechner <david@lechnology.com>, Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>, "jejb@linux.ibm.com" <jejb@linux.ibm.com>, "martin.petersen@oracle.com" <martin.petersen@oracle.com>, "joeypabalinas@gmail.com" <joeypabalinas@gmail.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>



On 1/16/19 9:37 AM, Esme wrote:
> I have been off but back now, I had fetch'd current again and the diagnostics look a bit different, maybe I just got lucky.  Instead of fork'ng the test case (which is fairly aggressive in any case), interacting from the serial port with sig-int ^C tend's to trigger enough to hit something.  I'll get the page_owner sorted soon.
> 
> How I'm running;
> 
> qemu-system-x86_64 -kernel /home/files/dl/linux//arch/x86/boot/bzImage -append console=ttyS0 root=/dev/sda debug earlyprintk=serial slub_debug=QUZFP page_owner=on -hda stretch.img -net user,hostfwd=tcp::10021-:22 -net nic -enable-kvm -nographic -m 2G -smp 2
> 
> It's somewhat random I guess that in the last two CPU context dump's printed out, we see RAX and CR2 off by 4 from one another.
> 
> root@syzkaller:~# gcc -o test3 test3.c
> [  392.754148] ata1: lost interrupt (Status 0x50)
> [  392.754478] ata1.00: exception Emask 0x0 SAct 0x0 SErr 0x0 action 0x6 frozen
> [  392.759687] ata1.00: failed command: READ DMA
> [  392.761902] ata1.00: cmd c8/00:86:00:00:00/00:00:00:00:00/e0 tag 0 dma 68608 out
> [  392.761902]          res 40/00:01:00:00:00/00:00:00:00:00/a0 Emask 0x4 (timeout)
> [  392.768541] ata1.00: status: { DRDY }
> [  392.769532] ata1: soft resetting link
> [  392.937942] ata1.00: configured for MWDMA2
> [  392.945624] ata1: EH complete

While you are gathering page_owner (or kdump), it might be useful to use virtio
storage driver instead of legacy IDE here, as looks like this ATA was busted.
