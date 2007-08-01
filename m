Received: by rv-out-0910.google.com with SMTP id f1so39905rvb
        for <linux-mm@kvack.org>; Tue, 31 Jul 2007 19:17:26 -0700 (PDT)
Message-ID: <e28f90730707311917l1803dac3r6322359f58def574@mail.gmail.com>
Date: Tue, 31 Jul 2007 23:17:26 -0300
From: "Luiz Fernando N. Capitulino" <lcapitulino@gmail.com>
Subject: Re: [patch][rfc] remove ZERO_PAGE?
In-Reply-To: <20070801014739.GA30549@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070727021943.GD13939@wotan.suse.de>
	 <e28f90730707300652g4a0d0f4ah10bd3c06564d624b@mail.gmail.com>
	 <20070730115751.a2aaa28f.akpm@linux-foundation.org>
	 <20070730223912.GM2386@fieldses.org>
	 <20070801014739.GA30549@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Andrea Arcangeli <andrea@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, lcapitulino@mandriva.com.br, Neil Brown <neilb@suse.de>
List-ID: <linux-mm.kvack.org>

On 7/31/07, Nick Piggin <npiggin@suse.de> wrote:
> On Mon, Jul 30, 2007 at 06:39:12PM -0400, J. Bruce Fields wrote:
> > On Mon, Jul 30, 2007 at 11:57:51AM -0700, Andrew Morton wrote:
> > > On Mon, 30 Jul 2007 10:52:27 -0300
> > > "Luiz Fernando N. Capitulino" <lcapitulino@gmail.com> wrote:
> > >
> > > > Hi Nick,
> > > >
> > > > On 7/26/07, Nick Piggin <npiggin@suse.de> wrote:
> > > >
> > > > > I'd like to see if we can get the ball rolling on this again, and try to
> > > > > get it in 2.6.24 maybe. Any comments?
> > > >
> > > >  I'm trying this patch and got this during the weekend (gmail will
> > > > probably break lines automatically, grrr):
> > > >
> > > > """
> > > > [29711.081281] BUG: unable to handle kernel NULL pointer dereference
> > > > at virtual address 00000004
> > > > [29711.081300]  printing eip:
> > > > [29711.081305] dcb5aa49
> > > > [29711.081308] *pde = 00000000
> > > > [29711.081315] Oops: 0000 [#1]
> > > > [29711.081319] SMP
> > > > [29711.081325] Modules linked in: nfsd exportfs auth_rpcgss nfs lockd
> > > > nfs_acl sunrpc capability commoncap af_packet ipv6 ide_cd ide_core
> > > > binfmt_misc loop dm_mod floppy pcspkr snd_pcm_oss snd_mixer_oss
> > > > snd_via82xx gameport snd_ac97_codec i2c_viapro amd64_agp snd_pcm
> > > > snd_timer ac97_bus snd_page_alloc snd_mpu401_uart snd_rawmidi
> > > > snd_seq_device snd agpgart ehci_hcd uhci_hcd i2c_core via_rhine k8temp
> > > > mii usbcore evdev tsdev soundcore sr_mod sg ext3 jbd sd_mod pata_via
> > > > sata_via libata scsi_mod
> > > > [29711.081445] CPU:    0
> > > > [29711.081446] EIP:    0060:[<dcb5aa49>]    Not tainted VLI
> > > > [29711.081447] EFLAGS: 00010246   (2.6.23-rc1-zpage #1)
> > > > [29711.081511] EIP is at encode_fsid+0x89/0xb0 [nfsd]
> > > > [29711.081529] eax: d99f4000   ebx: d80af064   ecx: 00000000   edx: 00000002
> > > > [29711.081549] esi: d809204c   edi: d80af14c   ebp: d8788f04   esp: d8788efc
> > > > [29711.081569] ds: 007b   es: 007b   fs: 00d8  gs: 0000  ss: 0068
> > > > [29711.081589] Process nfsd (pid: 3474, ti=d8788000 task=dac07740
> > > > task.ti=d8788000)
> > > > [29711.081609] Stack: 00000000 d809203c d8788f28 dcb5ab25 d80af064
> > > > c0945160 dcb59202 00000000
> > > > [29711.081644]        d80b0000 dcb5bf90 dcb77404 d8788f38 dcb5bfb3
> > > > d80af14c d80b0000 d8788f68
> > > > [29711.081679]        dcb4d32c d87b4c44 d87b4a80 d8788f60 00000003
> > > > d8092018 d8092000 0000001c
> > > > [29711.081714] Call Trace:
> > > > [29711.081738]  [<c01053fa>] show_trace_log_lvl+0x1a/0x30
> > > > [29711.081760]  [<c01054bb>] show_stack_log_lvl+0xab/0xd0
> > > > [29711.081779]  [<c01056b1>] show_registers+0x1d1/0x2d0
> > > > [29711.081798]  [<c01058c6>] die+0x116/0x250
> > > > [29711.081815]  [<c011bb2b>] do_page_fault+0x28b/0x690
> > > > [29711.081836]  [<c02e95ba>] error_code+0x72/0x78
> > > > [29711.081856]  [<dcb5ab25>] encode_fattr3+0xb5/0x140 [nfsd]
> > > > [29711.081888]  [<dcb5bfb3>] nfs3svc_encode_attrstat+0x23/0x50 [nfsd]
> > > > [29711.081921]  [<dcb4d32c>] nfsd_dispatch+0x18c/0x220 [nfsd]
> > > > [29711.081950]  [<dcaf41fa>] svc_process+0x42a/0x7b0 [sunrpc]
> > > > [29711.081985]  [<dcb4d909>] nfsd+0x169/0x290 [nfsd]
> > > > [29711.082013]  [<c0104f9f>] kernel_thread_helper+0x7/0x18
> > > > [29711.082032]  =======================
> > > > [29711.082047] Code: 48 30 89 cb c1 fb 1f 89 d8 0f c8 89 06 89 c8 0f
> > > > c8 89 46 04 8d 46 08 5b 5e 5d c3 8d b4 26 00 00 00 00 8b 83 88 00 00
> > > > 00 8b 48 34 <8b> 51 04 33 51 0c 8b 01 33 41 08 89 d1 0f c8 0f c9 89 46
> > > > 04 8d
> > > > [29711.082150] EIP: [<dcb5aa49>] encode_fsid+0x89/0xb0 [nfsd] SS:ESP
> > > > 0068:d8788efc
> > > > """
> > > >
> > > >  Now I'm not sure if this was caused by your patch, or is a bug
> > > > somewhere else.
> > >
> > > It's a little hard to see how Nick's patch could have caused that to
> > > happen.
> > >
> > > Neil, Bruce: does this look at all familiar?
> >
> > Not to me.
> >
> > > We don't appear to have changed anything in there for months...
> >
> > Well, I've fooled around with the exports in 2.6.23-rc1, and Neil added
> > the uuid stuff some time around 2.6.21.
> >
> > It looks to me like it's oopsing at the deference of
> > fhp->fh_export->ex_uuid in encode_fsid(), which is exactly the case
> > commit b41eeef14d claims to fix.  Looks like that's been in since
> > v2.6.22-rc1; what kernel is this?
>
> Any progress with this? I'm fairly sure ZERO_PAGE removal wouldn't
> have triggered it. Luiz, is it reproducable? Without the zero page
> removal patch?

 I've tried to reproduce it a few times w/o success, the OOPS has happened
during the weekend at the office, so I can't tell when/how it happened.

 The only important info I have for NFS people is that my machine does
export some NFS volumes with three chroots and some kernel packages.

 I know that there're people at the office who mounts that volumes, but it's
probably impossible to say what was the usage pattern at the weekend.

 But it's there, running the kernel since yesterday w/o problems so far.

-- 
Luiz Fernando N. Capitulino

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
