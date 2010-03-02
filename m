Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 90B936B0047
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 03:25:48 -0500 (EST)
Date: Tue, 2 Mar 2010 09:25:43 +0100
From: Michal Hocko <mstsxfx@gmail.com>
Subject: Re: unable to handle kernel paging request on resume with
 2.6.33-00001-gbaac35c
Message-ID: <20100302082543.GA4241@tiehlicka.suse.cz>
References: <20100301175256.GA4034@tiehlicka.suse.cz>
 <201003012207.37582.rjw@sisk.pl>
 <20100301223457.GB4034@tiehlicka.suse.cz>
 <201003020106.06867.rjw@sisk.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201003020106.06867.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: linux-kernel@vger.kernel.org, pm list <linux-pm@lists.linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 02, 2010 at 01:06:06AM +0100, Rafael J. Wysocki wrote:
> On Monday 01 March 2010, Michal Hocko wrote:
> > [Let's CC mm guys]
> 
> I guess it's rather architecture-related than a genering mm issue.
> 
> > On Mon, Mar 01, 2010 at 10:07:37PM +0100, Rafael J. Wysocki wrote:
> > > On Monday 01 March 2010, Michal Hocko wrote:
> > > > Hi,
> > > > 
> > > > I have experienced the following kernel BUG on resume from suspend from
> > > > disk (the whole log from  hibarnation to suspend along with kernel
> > > > config are attached):
> > > > 
> > > > BUG: unable to handle kernel paging request at 00aaaaaa
> > > > IP: [<c019e28c>] anon_vma_link+0x2c/0x39
> > > > *pde = 00000000
> > > > Oops: 0002 [#1] PREEMPT SMP
> > > > last sysfs file: /sys/devices/LNXSYSTM:00/LNXSYBUS:00/ACPI0003:00/power_supply/AC/type
> > > > Modules linked in: aes_i586 aes_generic iwl3945 iwlcore mac80211 cfg80211 fbcon font bitblit softcursor i915 drm_kms_helper drm fb i2c_algo_bit cfbcopyarea i2c_core cfbimgblt cfbfillrect fuse tun coretemp hwmon snd_hda_codec_realtek snd_hda_intel snd_hda_codec arc4 ecb snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_oss snd_seq_midi_event snd_seq snd_timer fujitsu_laptop snd_seq_device rtc_cmos rtc_core led_class rtc_lib snd snd_page_alloc video backlight output [last unloaded: cfg80211]
> > > > 
> > > > Pid: 3942, comm: kxkb Not tainted 2.6.33-00001-gbaac35c #11 FJNB1B5/LIFEBOOK S7110
> > > > EIP: 0060:[<c019e28c>] EFLAGS: 00010246 CPU: 1
> > > > EIP is at anon_vma_link+0x2c/0x39
> > > > EAX: 00aaaaaa EBX: f69c6410 ECX: f69c6414 EDX: f63e4df4
> > > > ESI: f63e4dc0 EDI: f63e4e14 EBP: f6901ec0 ESP: f6901eb8
> > > >  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
> > > > Process kxkb (pid: 3942, ti=f6901000 task=f6aa6ff0 task.ti=f6901000)
> > > > Stack:
> > > >  f63e4dc0 f23fc7e4 f6901efc c012fc28 f6aa6ff0 f63e4e30 f63e4e34 f63e4e24
> > > > <0> ca4656f4 f6ace734 f6aa6ff0 f6ace700 ca4656c0 f23fc790 ca560000 fffffff4
> > > > <0> f659ef94 f6901f38 c0130821 f6aa6ff0 f6901fb4 bff441f0 ca560208 00000000
> > > > Call Trace:
> > > >  [<c012fc28>] ? dup_mm+0x1c7/0x3d3
> > > >  [<c0130821>] ? copy_process+0x98e/0xf26
> > > >  [<c0130ed6>] ? do_fork+0x11d/0x2a1
> > > >  [<c0434547>] ? _raw_spin_unlock+0x14/0x28
> > > >  [<c01b6795>] ? set_close_on_exec+0x45/0x4b
> > > >  [<c01b6e98>] ? do_fcntl+0x15f/0x3f1
> > > >  [<c0108678>] ? sys_clone+0x20/0x25
> > > >  [<c010291d>] ? ptregs_clone+0x15/0x38
> > > >  [<c0102850>] ? sysenter_do_call+0x12/0x26
> > > > Code: 89 e5 56 53 0f 1f 44 00 00 8b 58 3c 89 c6 85 db 74 22 89 d8 e8 54 65 29 00 8b 43 08 8d 56 34 8d 4b 04 89 53 08 89 4e 34 89 46 38 <89> 10 89 d8 e8 9e 62 29 00 5b 5e 5d c3 55 89 e5 0f 1f 44 00 00
> > > > EIP: [<c019e28c>] anon_vma_link+0x2c/0x39 SS:ESP 0068:f6901eb8
> > > > CR2: 0000000000aaaaaa
> > > > ---[ end trace b7f008b0e5aa7c65 ]---
> > > 
> > > This looks like a low-level memory management issue of some sort.
> > 
> > Yes, it really looks strange. dup_mm+0x1c7 matches to:
> > c102fc0e:       81 60 14 ff df ff ff    andl   $0xffffdfff,0x14(%eax)
> > c102fc15:       8b 45 ec                mov    -0x14(%ebp),%eax
> > c102fc18:       c7 43 0c 00 00 00 00    movl   $0x0,0xc(%ebx)
> > c102fc1f:       89 03                   mov    %eax,(%ebx)
> > c102fc21:       89 d8                   mov    %ebx,%eax
> > c102fc23:       e8 38 e6 06 00          call   c109e260 <anon_vma_link>
> > c102fc28:       8b 43 48                mov    0x48(%ebx),%eax  <<< BANG
> > 
> > which corresponds to:
> > kernel/fork.c:336
> > 		tmp->vm_flags &= ~VM_LOCKED;
> >                 tmp->vm_mm = mm;
> >                 tmp->vm_next = NULL;
> >                 anon_vma_link(tmp);
> >                 file = tmp->vm_file; <<< BANG
> > 
> > ebx is tmp which somehow got deallocated. I cannot see how this could happened.
> 
> Through a page tables corruption or a TLB issue, for example.

I thought so. Is there any other possibility? Like a race with vma
unlinking?

> 
> > > What's the HEAD commit in this kernel tree?
> > 
> > $ git describe
> > v2.6.33-1-gbaac35c
> 
> I can't find gbaac35c anywhere post 2.6.33.  

you should look at baac35c. Git describe displays gHASH

> Can you just send the output
> of "git show | head -1", please?

The whole commit ID is baac35c4155a8aa826c70acee6553368ca5243a2

> 
> > > Also, is the problem reproducible?
> > 
> > As I've already mentioned. This is the first time I have seen this problem.
> > I am using suspend to disk and wake up quite often (several times a day). I
> > haven't tried suspend/resume loop test yet.
> 
> OK
> 
> Given the apparent nature of the problem it will be extremely difficult to
> track down without a reliable way to reproduce it.

Yes, I am aware of that but maybe someone will face the same problem.
Let's see whether I am able to reproduce.

> 
> Rafael

-- 
Michal Hocko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
