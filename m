Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f41.google.com (mail-ee0-f41.google.com [74.125.83.41])
	by kanga.kvack.org (Postfix) with ESMTP id E3DC86B0036
	for <linux-mm@kvack.org>; Mon, 19 May 2014 04:23:36 -0400 (EDT)
Received: by mail-ee0-f41.google.com with SMTP id t10so3328356eei.14
        for <linux-mm@kvack.org>; Mon, 19 May 2014 01:23:36 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v7si1072793eef.166.2014.05.19.01.23.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 19 May 2014 01:23:35 -0700 (PDT)
Date: Mon, 19 May 2014 10:23:31 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: oops when swapping on latest kernel git 3.15-rc5
Message-ID: <20140519082331.GA3017@dhcp22.suse.cz>
References: <5378CD7C.9070004@gmail.com>
 <alpine.LSU.2.11.1405181123380.14447@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1405181123380.14447@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Branimir Maksimovic <branimir.maksimovic@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun 18-05-14 12:15:48, Hugh Dickins wrote:
> On Sun, 18 May 2014, Branimir Maksimovic wrote:
> 
> > Ia hev discovered this accidentaly when tried to see how oom killer
> > works. Program is this:
> > 
> > #include <unistd.h>
> > #include <cstring>
> > #include <exception>
> > #include <iostream>
> > 
> > int counter=0;
> > int main()
> > try
> > {
> >   for(;;++counter)
> >   {
> >     char* p = new char[1024*1024];
> >     memset(p,1,1024*1024);
> >     std::cout<<counter<<'\n';
> > //    if(counter > 24000)sleep(100);
> > 
> >   }
> > }catch(const std::exception& e)
> > {
> >   std::cout<<"exception:"<<e.what()<<" count:"<<counter<<std::endl;
> > }
> > 
> > After running this program system froze after some time. Programs could be
> > started but they will not finish.
> > Fortunatelly I could paste dmesg output:
> > 
> > [  388.522421] BUG: unable to handle kernel NULL pointer dereference at
> > 0000000000000340
> > [  388.522427] IP: [<ffffffff81185b0b>]
> > get_mem_cgroup_from_mm.isra.42+0x2b/0x60
> 
> Thank you very much for reporting.  That BUG is a 3.15-rc regression.
> 3.14's try_get_mem_cgroup_from_mm() had protection against NULL mm,
> as when exiting.  That was correctly removed as unnecessary by one
> 3.15 commit, but a new caller added in a later commit: which made
> it necessary again, as you have now found.

Good timing. I had a similar report on Friday from our internal testing
and was waiting for the over weekend testing results. Will post the
patch in a minute.

> Easily fixable, but opinions will differ on the right way to write it
> (and I'm rather out of touch with the current flux in css_tryget and
> root_mem_cgroup), so Cc'ing Hannes and Michal for the definitive fix.

Yes, I went with get_mem_cgroup_from_mm way. But Johannes is on vacation
AFAIK. So I would rather go with this more conservative approach and
make some additional cleanup later if necessary.
 
> > [  388.522435] PGD 3f233c067 PUD 3f20f7067 PMD 0
> > [  388.522439] Oops: 0000 [#1] SMP
> > [  388.522441] Modules linked in: snd_hrtimer pci_stub vboxpci(OE)
> > vboxnetadp(OE) vboxnetflt(OE) vboxdrv(OE) cuse rfcomm bnep bluetooth
> > binfmt_misc intel_rapl x86_pkg_temp_thermal intel_powerclamp crct10dif_pclmul
> > crc32_pclmul ghash_clmulni_intel aesni_intel snd_hda_codec_hdmi aes_x86_64
> > lrw gf128mul glue_helper snd_hda_codec_realtek snd_hda_codec_generic
> > ablk_helper cryptd gspca_spca561 gspca_main videodev mxm_wmi snd_hda_intel
> > snd_hda_controller snd_hda_codec microcode snd_hwdep joydev snd_pcm
> > snd_seq_midi snd_seq_midi_event snd_rawmidi snd_seq dm_multipath scsi_dh
> > snd_seq_device snd_timer mei_me snd mei lpc_ich wmi soundcore video mac_hid
> > serio_raw parport_pc ppdev nct6775 hwmon_vid coretemp nvidia(POE) drm lp
> > parport btrfs xor raid6_pq hid_generic usbhid hid psmouse e1000e ahci libahci
> > ptp pps_core
> > [  388.522494] CPU: 1 PID: 160 Comm: kworker/u8:5 Tainted: P           OE
> > 3.15.0-rc5-core2-custom #159
> > [  388.522496] Hardware name: System manufacturer System Product Name/MAXIMUS
> > V GENE, BIOS 1903 08/19/2013
> > [  388.522498] task: ffff880404e349b0 ti: ffff88040486a000 task.ti:
> > ffff88040486a000
> > [  388.522500] RIP: 0010:[<ffffffff81185b0b>] [<ffffffff81185b0b>]
> > get_mem_cgroup_from_mm.isra.42+0x2b/0x60
> > [  388.522504] RSP: 0000:ffff88040486bab8  EFLAGS: 00010246
> > [  388.522506] RAX: 0000000000000000 RBX: ffffea000a416340 RCX:
> > 0000000000000a40
> > [  388.522508] RDX: ffff88041efe8a40 RSI: ffffea000a416340 RDI:
> > 0000000000000340
> > [  388.522509] RBP: ffff88040486bab8 R08: 000000000001cb56 R09:
> > 0000000000072d5a
> > [  388.522511] R10: 0000000000000000 R11: 0000000000000005 R12:
> > ffff88040486bb00
> > [  388.522512] R13: 00000000000000d0 R14: 0000000000000000 R15:
> > ffff8803f3fe82f8
> > [  388.522515] FS:  0000000000000000(0000) GS:ffff88041ec80000(0000)
> > knlGS:0000000000000000
> > [  388.522517] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > [  388.522518] CR2: 0000000000000340 CR3: 00000003ee44d000 CR4:
> > 00000000001407e0
> > [  388.522520] Stack:
> > [  388.522521]  ffff88040486baf0 ffffffff8118abf5 ffffffff8112ce1a
> > 0000000000000000
> > [  388.522524]  ffffea000a416340 0000000000000003 00000000ffffffef
> > ffff88040486bb18
> > [  388.522527]  ffffffff8118b1cc ffff88040486baf8 000000000001cb56
> > 0000000000000000
> > [  388.522530] Call Trace:
> > [  388.522536]  [<ffffffff8118abf5>] __mem_cgroup_try_charge_swapin+0x45/0xf0
> > [  388.522539]  [<ffffffff8112ce1a>] ? __lock_page+0x6a/0x70
> > [  388.522543]  [<ffffffff8118b1cc>] mem_cgroup_charge_file+0x9c/0xe0
> > [  388.522548]  [<ffffffff8114599c>] shmem_getpage_gfp+0x62c/0x770
> > [  388.522552]  [<ffffffff81145b18>] shmem_write_begin+0x38/0x40
> > [  388.522555]  [<ffffffff8112d1c5>] generic_perform_write+0xc5/0x1c0
> > [  388.522559]  [<ffffffff811ad53a>] ? file_update_time+0x8a/0xd0
> > [  388.522563]  [<ffffffff8112f211>] __generic_file_aio_write+0x1d1/0x3f0
> > [  388.522567]  [<ffffffff81084fc1>] ? enqueue_entity+0x291/0xb90
> > [  388.522570]  [<ffffffff8112f47f>] generic_file_aio_write+0x4f/0xc0
> > [  388.522574]  [<ffffffff81192eaa>] do_sync_write+0x5a/0x90
> > [  388.522578]  [<ffffffff810c53c1>] do_acct_process+0x4b1/0x550
> > [  388.522582]  [<ffffffff810c5acd>] acct_process+0x6d/0xa0
> > [  388.522587]  [<ffffffff810667d0>] ? manage_workers.isra.25+0x2a0/0x2a0
> > [  388.522590]  [<ffffffff8104d937>] do_exit+0x827/0xa70
> > [  388.522594]  [<ffffffff8106699e>] ? worker_thread+0x1ce/0x3a0
> > [  388.522597]  [<ffffffff810667d0>] ? manage_workers.isra.25+0x2a0/0x2a0
> > [  388.522600]  [<ffffffff8106cad3>] kthread+0xc3/0xf0
> > [  388.522604]  [<ffffffff8106ca10>] ? kthread_create_on_node+0x180/0x180
> > [  388.522608]  [<ffffffff816bfe6c>] ret_from_fork+0x7c/0xb0
> > [  388.522611]  [<ffffffff8106ca10>] ? kthread_create_on_node+0x180/0x180

Hmm, this is slightly different from what I saw. The kernel thread is
common as well as swapcache mem_cgroup_charge_file path. We just got
there from a different path (shmem_file_splice_read). This looks like
accounting is done on tmpfs?
 
> Or does that backtrace say that it's a kernel thread that was exiting
> (and being accounted)?  A kernel thread would not have had an mm in the
> first place.
> 
> I know very little about accounting (acct_process etc).  You said above
> "Programs could be started but they will not finish": I'll assume that
> hitting such a BUG inside acct_process() led to that.

That sounds possible.
 
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
