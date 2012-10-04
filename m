Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 33FD26B010E
	for <linux-mm@kvack.org>; Thu,  4 Oct 2012 09:01:22 -0400 (EDT)
Date: Thu, 4 Oct 2012 15:01:19 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: Repeatable ext4 oops with 3.6.0 (regression)
Message-ID: <20121004130119.GH4641@quack.suse.cz>
References: <pan.2012.10.02.11.19.55.793436@googlemail.com>
 <20121002133642.GD22777@quack.suse.cz>
 <pan.2012.10.02.14.31.57.530230@googlemail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <pan.2012.10.02.14.31.57.530230@googlemail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Holger Hoffstaette <holger.hoffstaette@googlemail.com>
Cc: linux-ext4@vger.kernel.org, linux-mm@kvack.org

On Tue 02-10-12 16:31:57, Holger Hoffstaette wrote:
> On Tue, 02 Oct 2012 15:36:42 +0200, Jan Kara wrote:
> 
> >   Thanks for report! Can you please attach here full dmesg after the oops
> > happens - the output from syslog seems to be partially filtered which
> > makes things unnecessarily hard... Thanks!
  Please use reply-to-all next time. It makes me less likely to miss the
email in the list traffic. Thanks.

> The output was cut from /var/log/messages since the machine hung and that file
> was intact.
  I see.

> Following are dmesg from the reboot after the crash and after
> that is the full messages file from the crash I just reproduced; this time
> gthumb "properly" segfaulted (15:49:32), but the kernel still started to
> tumble and hung a few seconds later. Produced even more fireworks this
> time. :)
> 
> (..after several posting attempts..)
> 
> I'm reading this through gmane and the files are apparently too big for
> posting, so I put them here: http://hoho.dyndns.org/~holger/ext4-oops-3.6.0/
  dmesg after boot doesn't help us. It is a dump of a kernel internal
buffer of messages so it is cleared after reboot. I had hoped the machine
is usable after a crash but apparently it's not. Could you reconfigure your
syslog to put all messages in one file (because now part of the oops
message apparently ends in /var/log/warn or something like that)? Or setup
something like netconsole (see Documentation/networking/netconsole.txt) to
grab the oops. Thanks!

Looking into your messages file, the oops now is:

segfault at 138 ip b7033ee0 sp ad6fee2c error 4 in libgio-2.0.so.0.3200.4[b7010000+156000]
*pde = 00000000 
Oops: 0000 [#1] SMP 
Modules linked in: nfsv4 auth_rpcgss radeon
drm_kms_helper ttm drm i2c_algo_bit nfs lockd sunrpc dm_mod 
snd_hda_codec_analog coretemp kvm_intel kvm ehci_hcd i2c_i801 i2c_core
uhci_hcd sr_mod snd_hda_intel cdrom usbcore e1000e snd_hda_codec 
usb_common snd_pcm snd_page_alloc snd_timer thinkpad_acpi snd video
Pid: 2934, comm: nscd Not tainted 3.6.0 #1 LENOVO 20087JG/20087JG
EIP: 0060:[<c01bfcfd>] EFLAGS: 00010206 CPU: 0
EIP is at kmem_cache_alloc+0x4d/0xd0
EAX: 00000000 EBX: 09000000 ECX: 0000e6bd EDX: 0000e6bc
ESI: f5802380 EDI: 09000000 EBP: f1599ecc ESP: f1599ea0
 DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
CR0: 8005003b CR2: 09000000 CR3: 358fe000 CR4: 000007d0
DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
DR6: ffff0ff0 DR7: 00000400
 c02c5d91 09000000 0000e6bc f1599ec8 0000e6bd bfc24000 c01440b9 000000d0
 01200011 00000000 00000000 f1599f08 c01440b9 f14c4038 c05c2d20 f4acf64c
 f4acf650 f4acf630 f4acf63c f14c4380 00000022 01200011 f158fff8 01200011
 [<c02c5d91>] ? cpumask_any_but+0x21/0x40
 [<c01440b9>] ? alloc_pid+0x19/0x350
 [<c01440b9>] alloc_pid+0x19/0x350
 [<c012b983>] copy_process+0xa93/0x10a0
 [<c012c04c>] do_fork+0x9c/0x2a0
 [<c013c86e>] ? __set_current_blocked+0x2e/0x50
 [<c01094ef>] sys_clone+0x2f/0x40
 [<c04a8c9d>] ptregs_clone+0x15/0x38
 [<c04a8bd0>] ? sysenter_do_call+0x12/0x26
CR2: 0000000009000000
---[ end trace 8447e05159f57aa8 ]---

So this time there's nothing about filesystems in the trace. Maybe this is
a generic mm bug - adding mm list to CC.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
