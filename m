Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 2A8B06B0047
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 14:59:04 -0500 (EST)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: unable to handle kernel paging request on resume with 2.6.33-00001-gbaac35c
Date: Tue, 2 Mar 2010 21:01:21 +0100
References: <20100301175256.GA4034@tiehlicka.suse.cz> <20100302082543.GA4241@tiehlicka.suse.cz> <20100302154553.GB4241@tiehlicka.suse.cz>
In-Reply-To: <20100302154553.GB4241@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201003022101.21521.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
To: Michal Hocko <mstsxfx@gmail.com>
Cc: linux-kernel@vger.kernel.org, pm list <linux-pm@lists.linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tuesday 02 March 2010, Michal Hocko wrote:
> On Tue, Mar 02, 2010 at 09:25:43AM +0100, Michal Hocko wrote:
> > On Tue, Mar 02, 2010 at 01:06:06AM +0100, Rafael J. Wysocki wrote:
> > > On Monday 01 March 2010, Michal Hocko wrote:
> > > > [Let's CC mm guys]
> > > 
> > > I guess it's rather architecture-related than a genering mm issue.
s/genering/generic/  (why did I write that?)
... 
> > > > Yes, it really looks strange. dup_mm+0x1c7 matches to:
> > > > c102fc0e:       81 60 14 ff df ff ff    andl   $0xffffdfff,0x14(%eax)
> > > > c102fc15:       8b 45 ec                mov    -0x14(%ebp),%eax
> > > > c102fc18:       c7 43 0c 00 00 00 00    movl   $0x0,0xc(%ebx)
> > > > c102fc1f:       89 03                   mov    %eax,(%ebx)
> > > > c102fc21:       89 d8                   mov    %ebx,%eax
> > > > c102fc23:       e8 38 e6 06 00          call   c109e260 <anon_vma_link>
> > > > c102fc28:       8b 43 48                mov    0x48(%ebx),%eax  <<< BANG
> > > > 
> > > > which corresponds to:
> > > > kernel/fork.c:336
> > > > 		tmp->vm_flags &= ~VM_LOCKED;
> > > >                 tmp->vm_mm = mm;
> > > >                 tmp->vm_next = NULL;
> > > >                 anon_vma_link(tmp);
> > > >                 file = tmp->vm_file; <<< BANG
> > > > 
> > > > ebx is tmp which somehow got deallocated. I cannot see how this could happened.
> > > 
> > > Through a page tables corruption or a TLB issue, for example.
> > 
> > I thought so. Is there any other possibility? Like a race with vma
> > unlinking?

I don't think that particular instruction would trigger the NULL poiter
dereference in that case.

In theory, it may be a result of a stack corruption if EBX was saved on the
stack by anon_vma_link().  I'm not sure if that happens, though.

> It really looks like some memory corruption. Now I got the following:
>
> BUG: unable to handle kernel NULL pointer dereference at (null)
> IP: [<c026db57>] strcmp+0xe/0x22
> *pde = 00000000
> Oops: 0000 [#1] PREEMPT SMP
> last sysfs file: /sys/devices/pci0000:00/0000:00:1e.0/0000:08:03.4/fw-host0/00000e1003d248c6/uevent
> Modules linked in: fbcon font bitblit softcursor i915 drm_kms_helper drm fb i2c_algo_bit cfbcopyarea i2c
> on snd_hda_codec_realtek arc4 ecb snd_hda_intel snd_hda_codec snd_pcm_oss snd_mixer_oss snd_pcm iwl3945
> d_timer snd_seq_device mac80211 snd fujitsu_laptop rtc_cmos cfg80211 rtc_core rtc_lib led_class snd_page
> i_wait_scan]
> 
> Pid: 16719, comm: udev-acl.ck Not tainted 2.6.33-00001-gbaac35c #11 FJNB1B5/LIFEBOOK S7110
> EIP: 0060:[<c026db57>] EFLAGS: 00010286 CPU: 0
> EIP is at strcmp+0xe/0x22
> EAX: 00000000 EBX: f71c0600 ECX: f70d0f00 EDX: f5a1d49c
> ESI: 00000000 EDI: f5a1d49c EBP: f70d0dec ESP: f70d0de4
>  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
> Process udev-acl.ck (pid: 16719, ti=f70d0000 task=f6a65710 task.ti=f70d0000)
> Stack:
>  f5a1d49c fffffffe f70d0dfc c01ea0c0 f5a1d440 f71c05a0 f70d0e14 c01ea267
> <0> f5a1d330 c044cfac f70d0f00 f6f44968 f70d0e3c c01b3a14 f70fcc80 f70d0e7c
> <0> f6f449e0 f5a1d330 f5a1d440 f70d0f00 f6f44968 087bed70 f70d0e90 c01b508a
> Call Trace:
>  [<c01ea0c0>] ? sysfs_find_dirent+0x1b/0x2c
>  [<c01ea267>] ? sysfs_lookup+0x2f/0xa6
>  [<c01b3a14>] ? do_lookup+0xca/0x174
>  [<c01b508a>] ? link_path_walk+0x691/0xa22
>  [<c01bf3e8>] ? mntput_no_expire+0x1e/0xb2
>  [<c01b552c>] ? path_walk+0x3f/0x89
>  [<c01b3dd1>] ? path_init+0x73/0x114
>  [<c01b5601>] ? do_path_lookup+0x26/0x47
>  [<c01b6072>] ? do_filp_open+0xdc/0x79e
>  [<c01899d0>] ? free_hot_page+0x55/0x59
>  [<c01eaad0>] ? sysfs_put_link+0x0/0x1f
>  [<c0189a6b>] ? free_pages+0x22/0x24
>  [<c01b3d54>] ? generic_readlink+0x69/0x73
>  [<c04371c9>] ? add_preempt_count+0x8/0x75
>  [<c0437155>] ? sub_preempt_count+0x8/0x74
>  [<c0434547>] ? _raw_spin_unlock+0x14/0x28
>  [<c01aae0a>] ? do_sys_open+0x4d/0xe9
>  [<c01aad0e>] ? filp_close+0x56/0x60
>  [<c01aaef2>] ? sys_open+0x23/0x2b
>  [<c0102850>] ? sysenter_do_call+0x12/0x26
> Code: 31 c0 83 c9 ff f2 ae 4f 89 d1 49 78 06 ac aa 84 c0 75 f7 31 c0 aa 89 d8 5b 5e 5f 5d c3 55 89 e5 57 56 0f 1f 44 00 00 89 c6 89 d7 <ac> ae 75 08 84 c0 75 f8 31 c0 eb 04 19 c0 0c 01 5e 5f 5d c3 55
> EIP: [<c026db57>] strcmp+0xe/0x22 SS:ESP 0068:f70d0de4
> CR2: 0000000000000000
> ---[ end trace 877af85bb64785ae ]---

The question is whether hibernation is the reason of this or it's only a
messenger.

> > > > > What's the HEAD commit in this kernel tree?
> > > > 
> > > > $ git describe
> > > > v2.6.33-1-gbaac35c
> > > 
> > > I can't find gbaac35c anywhere post 2.6.33.  
> > 
> > you should look at baac35c. Git describe displays gHASH

Ah.

> > > Can you just send the output
> > > of "git show | head -1", please?
> > 
> > The whole commit ID is baac35c4155a8aa826c70acee6553368ca5243a2

So this is just plain 2.6.33 plus one commit.

Hmm.  There are only a few changes directly related to hibernation in that
kernel and none of them can possibly introduce a problem like that.

Do you use s2disk or the in-kernel thing?

Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
