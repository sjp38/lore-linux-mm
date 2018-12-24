Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id C3A7D8E0001
	for <linux-mm@kvack.org>; Mon, 24 Dec 2018 07:13:04 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id f69so12343727pff.5
        for <linux-mm@kvack.org>; Mon, 24 Dec 2018 04:13:04 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id j65si6193169pge.444.2018.12.24.04.13.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Dec 2018 04:13:02 -0800 (PST)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wBOC01YX110287
	for <linux-mm@kvack.org>; Mon, 24 Dec 2018 07:13:01 -0500
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2pjwwqu1pu-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 24 Dec 2018 07:13:01 -0500
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Mon, 24 Dec 2018 12:12:58 -0000
Date: Mon, 24 Dec 2018 14:12:51 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: Re: Bug with report THP eligibility for each vma
References: <CALouPAi8KEuPw_Ly5W=MkYi8Yw3J6vr8mVezYaxxVyKCxH1x_g@mail.gmail.com>
 <20181224074916.GB9063@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <20181224074916.GB9063@dhcp22.suse.cz>
Message-Id: <20181224121250.GA2070@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Paul Oppenheimer <bepvte@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon, Dec 24, 2018 at 08:49:16AM +0100, Michal Hocko wrote:
> [Cc-ing mailing list and people involved in the original patch]
>=20
> On Fri 21-12-18 13:42:24, Paul Oppenheimer wrote:
> > Hello! I've never reported a kernel bug before, and since its on the
> > "next" tree I was told to email the author of the relevant commit.
> > Please redirect me to the correct place if I've made a mistake.
> >=20
> > When opening firefox or chrome, and using it for a good 7 seconds, it
> > hangs in "uninterruptible sleep" and I recieve a "BUG" in dmesg. This
> > doesn't occur when reverting this commit:
> > https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/com=
mit/?id=3D48cf516f8c.
> > Ive attached the output of decode_stacktrace.sh and the relevant dmesg
> > log to this email.
> >=20
> > Thanks
>=20
> > BUG: unable to handle kernel NULL pointer dereference at 00000000000000=
e8
>=20
> Thanks for the bug report! This is offset 232 and that matches
> file->f_mapping as per pahole
> pahole -C file ./vmlinux | grep f_mapping
>         struct address_space *     f_mapping;            /*   232     8 */
>=20
> I thought that each file really has to have a mapping. But the following
> should heal the issue and add an extra care.
>=20
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index f64733c23067..fc9d70a9fbd1 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -66,6 +66,8 @@ bool transparent_hugepage_enabled(struct vm_area_struct=
 *vma)
>  {
>  	if (vma_is_anonymous(vma))
>  		return __transparent_hugepage_enabled(vma);
> +	if (!vma->vm_file || !vma->vm_file->f_mapping)
> +		return false;
>  	if (shmem_mapping(vma->vm_file->f_mapping) && shmem_huge_enabled(vma))
>  		return __transparent_hugepage_enabled(vma);

We have vma_is_shmem(), it can be used to replace shmem_mapping() without
adding the check for !vma->vm_file

> =20
> Andrew, could you fold it to the original patch please?
>=20
> Keeping the rest for the reference.
>=20
> > #PF error: [normal kernel read fault]
> > PGD 0 P4D 0
> > Oops: 0000 [#1] PREEMPT SMP PTI
> > CPU: 7 PID: 2687 Comm: StreamTrans #56 Tainted: G     U            4.20=
=2E0-rc7-next-20181221-beppy+ #15
> > Hardware name: Dell Inc. XPS 13 9360/0TPN17, BIOS 2.10.0 09/27/2018
> > RIP: 0010:transparent_hugepage_enabled (??:?)=20
> > Code: 17 fd 00 e9 20 ff ff ff 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 53=
 48 89 fb 48 83 bf 90 00 00 00 00 74 27 48 8b 87 a0 00 00 00 <48> 8b b8 e8 =
00 00 00 e8 7a cc fa ff 84 c0 75 04 31 c0 5b c3 48 89
> > All code
> > =3D=3D=3D=3D=3D=3D=3D=3D
> >    0:	17                   	(bad) =20
> >    1:	fd                   	std   =20
> >    2:	00 e9                	add    %ch,%cl
> >    4:	20 ff                	and    %bh,%bh
> >    6:	ff                   	(bad) =20
> >    7:	ff 0f                	decl   (%rdi)
> >    9:	1f                   	(bad) =20
> >    a:	84 00                	test   %al,(%rax)
> >    c:	00 00                	add    %al,(%rax)
> >    e:	00 00                	add    %al,(%rax)
> >   10:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
> >   15:	53                   	push   %rbx
> >   16:	48 89 fb             	mov    %rdi,%rbx
> >   19:	48 83 bf 90 00 00 00 	cmpq   $0x0,0x90(%rdi)
> >   20:	00=20
> >   21:	74 27                	je     0x4a
> >   23:	48 8b 87 a0 00 00 00 	mov    0xa0(%rdi),%rax
> >   2a:*	48 8b b8 e8 00 00 00 	mov    0xe8(%rax),%rdi		<-- trapping instr=
uction
> >   31:	e8 7a cc fa ff       	callq  0xfffffffffffaccb0
> >   36:	84 c0                	test   %al,%al
> >   38:	75 04                	jne    0x3e
> >   3a:	31 c0                	xor    %eax,%eax
> >   3c:	5b                   	pop    %rbx
> >   3d:	c3                   	retq  =20
> >   3e:	48                   	rex.W
> >   3f:	89                   	.byte 0x89
> >=20
> > Code starting with the faulting instruction
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> >    0:	48 8b b8 e8 00 00 00 	mov    0xe8(%rax),%rdi
> >    7:	e8 7a cc fa ff       	callq  0xfffffffffffacc86
> >    c:	84 c0                	test   %al,%al
> >    e:	75 04                	jne    0x14
> >   10:	31 c0                	xor    %eax,%eax
> >   12:	5b                   	pop    %rbx
> >   13:	c3                   	retq  =20
> >   14:	48                   	rex.W
> >   15:	89                   	.byte 0x89
> > RSP: 0018:ffffb79744f17d28 EFLAGS: 00010282
> > RAX: 0000000000000000 RBX: ffff8948c17aff00 RCX: 0000000000000000
> > RDX: 0000000000000004 RSI: ffffffffab1165ba RDI: ffff8948c17aff00
> > RBP: ffff8948c17aff00 R08: 0000000000000007 R09: ffff894927e547b2
> > R10: 0000000000000000 R11: ffff894927e549da R12: ffffb79744f17d38
> > R13: ffff8948c17aff00 R14: ffff89489bef9400 R15: ffff89488b775a80
> > FS:  00007fa54ad43700(0000) GS:ffff8949363c0000(0000) knlGS:00000000000=
00000
> > CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > CR2: 00000000000000e8 CR3: 000000025c0ee003 CR4: 00000000003606e0
> > Call Trace:
> > show_smap (/home/bep/.opt/kernel/linux-e/fs/proc/task_mmu.c:805)=20
> > seq_read (/home/bep/.opt/kernel/linux-e/fs/seq_file.c:269)=20
> > __vfs_read (/home/bep/.opt/kernel/linux-e/fs/read_write.c:421)=20
> > vfs_read (/home/bep/.opt/kernel/linux-e/fs/read_write.c:452 /home/bep/.=
opt/kernel/linux-e/fs/read_write.c:437)=20
> > ksys_read (/home/bep/.opt/kernel/linux-e/fs/read_write.c:579)=20
> > do_syscall_64 (/home/bep/.opt/kernel/linux-e/arch/x86/entry/common.c:29=
0)=20
> > entry_SYSCALL_64_after_hwframe (/home/bep/.opt/kernel/linux/arch/x86/en=
try/entry_64.S:184)=20
> > RIP: 0033:0x7fa585fb3184
> > Code: c3 0f 1f 44 00 00 41 54 49 89 d4 55 48 89 f5 53 89 fb 48 83 ec 10=
 e8 5b fc ff ff 4c 89 e2 48 89 ee 89 df 41 89 c0 31 c0 0f 05 <48> 3d 00 f0 =
ff ff 77 38 44 89 c7 48 89 44 24 08 e8 97 fc ff ff 48
> > All code
> > =3D=3D=3D=3D=3D=3D=3D=3D
> >    0:	c3                   	retq  =20
> >    1:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
> >    6:	41 54                	push   %r12
> >    8:	49 89 d4             	mov    %rdx,%r12
> >    b:	55                   	push   %rbp
> >    c:	48 89 f5             	mov    %rsi,%rbp
> >    f:	53                   	push   %rbx
> >   10:	89 fb                	mov    %edi,%ebx
> >   12:	48 83 ec 10          	sub    $0x10,%rsp
> >   16:	e8 5b fc ff ff       	callq  0xfffffffffffffc76
> >   1b:	4c 89 e2             	mov    %r12,%rdx
> >   1e:	48 89 ee             	mov    %rbp,%rsi
> >   21:	89 df                	mov    %ebx,%edi
> >   23:	41 89 c0             	mov    %eax,%r8d
> >   26:	31 c0                	xor    %eax,%eax
> >   28:	0f 05                	syscall=20
> >   2a:*	48 3d 00 f0 ff ff    	cmp    $0xfffffffffffff000,%rax		<-- trapp=
ing instruction
> >   30:	77 38                	ja     0x6a
> >   32:	44 89 c7             	mov    %r8d,%edi
> >   35:	48 89 44 24 08       	mov    %rax,0x8(%rsp)
> >   3a:	e8 97 fc ff ff       	callq  0xfffffffffffffcd6
> >   3f:	48                   	rex.W
> >=20
> > Code starting with the faulting instruction
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> >    0:	48 3d 00 f0 ff ff    	cmp    $0xfffffffffffff000,%rax
> >    6:	77 38                	ja     0x40
> >    8:	44 89 c7             	mov    %r8d,%edi
> >    b:	48 89 44 24 08       	mov    %rax,0x8(%rsp)
> >   10:	e8 97 fc ff ff       	callq  0xfffffffffffffcac
> >   15:	48                   	rex.W
> > RSP: 002b:00007fa54ad42060 EFLAGS: 00000246 ORIG_RAX: 0000000000000000
> > RAX: ffffffffffffffda RBX: 000000000000002c RCX: 00007fa585fb3184
> > RDX: 0000000000001fff RSI: 00007fa54ffb2000 RDI: 000000000000002c
> > RBP: 00007fa54ffb2000 R08: 0000000000000000 R09: 000000000000001e
> > R10: 00007fa585c0dae0 R11: 0000000000000246 R12: 0000000000001fff
> > R13: 00007fa54ad42510 R14: 00007fa54ffb2fc5 R15: 00007fa54ad42498
> > Modules linked in: thunderbolt sch_cake rfcomm fuse arc4 iwlmvm mac8021=
1 btusb btrtl btbcm btintel bnep bluetooth iwlwifi snd_hda_codec_hdmi ecdh_=
generic snd_hda_codec_realtek snd_hda_codec_generic snd_hda_intel cfg80211 =
snd_hda_codec nf_log_ipv6 ip6t_REJECT nf_reject_ipv6 snd_hwdep xt_hl snd_hd=
a_core ip6t_rt nf_log_ipv4 nf_log_common joydev snd_pcm mousedev ipt_REJECT=
 nf_reject_ipv4 hid_multitouch intel_rapl xt_LOG xt_comment nls_iso8859_1 i=
ntel_pmc_core nls_cp437 intel_powerclamp xt_limit kvm_intel xt_addrtype xt_=
tcpudp dell_laptop snd_timer xt_conntrack ledtrig_audio snd dell_wmi nf_con=
ntrack efi_pstore dell_smbios mei_me dcdbas input_leds idma64 mei wmi_bmof =
intel_wmi_thunderbolt dell_wmi_descriptor efivars rfkill intel_pch_thermal =
intel_lpss_pci processor_thermal_device i2c_i801 soundcore intel_lpss intel=
_soc_dts_iosf i2c_hid evdev int3403_thermal int3400_thermal intel_vbtn rtc_=
cmos int340x_thermal_zone acpi_thermal_rel intel_hid mac_hid nf_defrag_ipv6=
 nf_defrag_ipv4
> > ip6table_filter ip6_tables iptable_filter bpfilter coretemp msr dell_sm=
m_hwmon crypto_user ip_tables x_tables algif_skcipher af_alg rtsx_pci_sdmmc=
 mmc_core crct10dif_pclmul crc32_pclmul xhci_pci ghash_clmulni_intel serio_=
raw rtsx_pci xhci_hcd i915 kvmgt vfio_mdev mdev vfio_iommu_type1 vfio kvm i=
rqbypass intel_gtt
> > CR2: 00000000000000e8
> > ---[ end trace 77d24d35c4e5213f ]---
> > RIP: 0010:transparent_hugepage_enabled (??:?)=20
> > Code: 17 fd 00 e9 20 ff ff ff 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 53=
 48 89 fb 48 83 bf 90 00 00 00 00 74 27 48 8b 87 a0 00 00 00 <48> 8b b8 e8 =
00 00 00 e8 7a cc fa ff 84 c0 75 04 31 c0 5b c3 48 89
> > All code
> > =3D=3D=3D=3D=3D=3D=3D=3D
> >    0:	17                   	(bad) =20
> >    1:	fd                   	std   =20
> >    2:	00 e9                	add    %ch,%cl
> >    4:	20 ff                	and    %bh,%bh
> >    6:	ff                   	(bad) =20
> >    7:	ff 0f                	decl   (%rdi)
> >    9:	1f                   	(bad) =20
> >    a:	84 00                	test   %al,(%rax)
> >    c:	00 00                	add    %al,(%rax)
> >    e:	00 00                	add    %al,(%rax)
> >   10:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
> >   15:	53                   	push   %rbx
> >   16:	48 89 fb             	mov    %rdi,%rbx
> >   19:	48 83 bf 90 00 00 00 	cmpq   $0x0,0x90(%rdi)
> >   20:	00=20
> >   21:	74 27                	je     0x4a
> >   23:	48 8b 87 a0 00 00 00 	mov    0xa0(%rdi),%rax
> >   2a:*	48 8b b8 e8 00 00 00 	mov    0xe8(%rax),%rdi		<-- trapping instr=
uction
> >   31:	e8 7a cc fa ff       	callq  0xfffffffffffaccb0
> >   36:	84 c0                	test   %al,%al
> >   38:	75 04                	jne    0x3e
> >   3a:	31 c0                	xor    %eax,%eax
> >   3c:	5b                   	pop    %rbx
> >   3d:	c3                   	retq  =20
> >   3e:	48                   	rex.W
> >   3f:	89                   	.byte 0x89
> >=20
> > Code starting with the faulting instruction
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> >    0:	48 8b b8 e8 00 00 00 	mov    0xe8(%rax),%rdi
> >    7:	e8 7a cc fa ff       	callq  0xfffffffffffacc86
> >    c:	84 c0                	test   %al,%al
> >    e:	75 04                	jne    0x14
> >   10:	31 c0                	xor    %eax,%eax
> >   12:	5b                   	pop    %rbx
> >   13:	c3                   	retq  =20
> >   14:	48                   	rex.W
> >   15:	89                   	.byte 0x89
> > RSP: 0018:ffffb79744f17d28 EFLAGS: 00010282
> > RAX: 0000000000000000 RBX: ffff8948c17aff00 RCX: 0000000000000000
> > RDX: 0000000000000004 RSI: ffffffffab1165ba RDI: ffff8948c17aff00
> > RBP: ffff8948c17aff00 R08: 0000000000000007 R09: ffff894927e547b2
> > R10: 0000000000000000 R11: ffff894927e549da R12: ffffb79744f17d38
> > R13: ffff8948c17aff00 R14: ffff89489bef9400 R15: ffff89488b775a80
> > FS:  00007fa54ad43700(0000) GS:ffff8949363c0000(0000) knlGS:00000000000=
00000
> > CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > BUG: unable to handle kernel NULL pointer dereference at 00000000000000=
e8
> > #PF error: [normal kernel read fault]
> > PGD 0 P4D 0
> > Oops: 0000 [#1] PREEMPT SMP PTI
> > CPU: 7 PID: 2687 Comm: StreamTrans #56 Tainted: G     U            4.20=
=2E0-rc7-next-20181221-beppy+ #15
> > Hardware name: Dell Inc. XPS 13 9360/0TPN17, BIOS 2.10.0 09/27/2018
> > RIP: 0010:transparent_hugepage_enabled+0x1a/0xa0
> > Code: 17 fd 00 e9 20 ff ff ff 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 53=
 48 89 fb 48 83 bf 90 00 00 00 00 74 27 48 8b 87 a0 00 00 00 <48> 8b b8 e8 =
00 00 00 e8 7a cc fa ff 84 c0 75 04 31 c0 5b c3 48 89
> > RSP: 0018:ffffb79744f17d28 EFLAGS: 00010282
> > RAX: 0000000000000000 RBX: ffff8948c17aff00 RCX: 0000000000000000
> > RDX: 0000000000000004 RSI: ffffffffab1165ba RDI: ffff8948c17aff00
> > RBP: ffff8948c17aff00 R08: 0000000000000007 R09: ffff894927e547b2
> > R10: 0000000000000000 R11: ffff894927e549da R12: ffffb79744f17d38
> > R13: ffff8948c17aff00 R14: ffff89489bef9400 R15: ffff89488b775a80
> > FS:  00007fa54ad43700(0000) GS:ffff8949363c0000(0000) knlGS:00000000000=
00000
> > CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > CR2: 00000000000000e8 CR3: 000000025c0ee003 CR4: 00000000003606e0
> > Call Trace:
> >  show_smap+0xd7/0x200
> >  seq_read+0x2e8/0x410
> >  __vfs_read+0x36/0x1a0
> >  vfs_read+0x8a/0x140
> >  ksys_read+0x52/0xc0
> >  do_syscall_64+0x48/0xf0
> >  entry_SYSCALL_64_after_hwframe+0x44/0xa9
> > RIP: 0033:0x7fa585fb3184
> > Code: c3 0f 1f 44 00 00 41 54 49 89 d4 55 48 89 f5 53 89 fb 48 83 ec 10=
 e8 5b fc ff ff 4c 89 e2 48 89 ee 89 df 41 89 c0 31 c0 0f 05 <48> 3d 00 f0 =
ff ff 77 38 44 89 c7 48 89 44 24 08 e8 97 fc ff ff 48
> > RSP: 002b:00007fa54ad42060 EFLAGS: 00000246 ORIG_RAX: 0000000000000000
> > RAX: ffffffffffffffda RBX: 000000000000002c RCX: 00007fa585fb3184
> > RDX: 0000000000001fff RSI: 00007fa54ffb2000 RDI: 000000000000002c
> > RBP: 00007fa54ffb2000 R08: 0000000000000000 R09: 000000000000001e
> > R10: 00007fa585c0dae0 R11: 0000000000000246 R12: 0000000000001fff
> > R13: 00007fa54ad42510 R14: 00007fa54ffb2fc5 R15: 00007fa54ad42498
> > Modules linked in: thunderbolt sch_cake rfcomm fuse arc4 iwlmvm mac8021=
1 btusb btrtl btbcm btintel bnep bluetooth iwlwifi snd_hda_codec_hdmi ecdh_=
generic snd_hda_codec_realtek snd_hda_codec_generic snd_hda_intel cfg80211 =
snd_hda_codec nf_log_ipv6 ip6t_REJECT nf_reject_ipv6 snd_hwdep xt_hl snd_hd=
a_core ip6t_rt nf_log_ipv4 nf_log_common joydev snd_pcm mousedev ipt_REJECT=
 nf_reject_ipv4 hid_multitouch intel_rapl xt_LOG xt_comment nls_iso8859_1 i=
ntel_pmc_core nls_cp437 intel_powerclamp xt_limit kvm_intel xt_addrtype xt_=
tcpudp dell_laptop snd_timer xt_conntrack ledtrig_audio snd dell_wmi nf_con=
ntrack efi_pstore dell_smbios mei_me dcdbas input_leds idma64 mei wmi_bmof =
intel_wmi_thunderbolt dell_wmi_descriptor efivars rfkill intel_pch_thermal =
intel_lpss_pci processor_thermal_device i2c_i801 soundcore intel_lpss intel=
_soc_dts_iosf i2c_hid evdev int3403_thermal int3400_thermal intel_vbtn rtc_=
cmos int340x_thermal_zone acpi_thermal_rel intel_hid mac_hid nf_defrag_ipv6=
 nf_defrag_ipv4
> >  ip6table_filter ip6_tables iptable_filter bpfilter coretemp msr dell_s=
mm_hwmon crypto_user ip_tables x_tables algif_skcipher af_alg rtsx_pci_sdmm=
c mmc_core crct10dif_pclmul crc32_pclmul xhci_pci ghash_clmulni_intel serio=
_raw rtsx_pci xhci_hcd i915 kvmgt vfio_mdev mdev vfio_iommu_type1 vfio kvm =
irqbypass intel_gtt
> > CR2: 00000000000000e8
> > ---[ end trace 77d24d35c4e5213f ]---
> > RIP: 0010:transparent_hugepage_enabled+0x1a/0xa0
> > Code: 17 fd 00 e9 20 ff ff ff 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 53=
 48 89 fb 48 83 bf 90 00 00 00 00 74 27 48 8b 87 a0 00 00 00 <48> 8b b8 e8 =
00 00 00 e8 7a cc fa ff 84 c0 75 04 31 c0 5b c3 48 89
> > RSP: 0018:ffffb79744f17d28 EFLAGS: 00010282
> > RAX: 0000000000000000 RBX: ffff8948c17aff00 RCX: 0000000000000000
> > RDX: 0000000000000004 RSI: ffffffffab1165ba RDI: ffff8948c17aff00
> > RBP: ffff8948c17aff00 R08: 0000000000000007 R09: ffff894927e547b2
> > R10: 0000000000000000 R11: ffff894927e549da R12: ffffb79744f17d38
> > R13: ffff8948c17aff00 R14: ffff89489bef9400 R15: ffff89488b775a80
> > FS:  00007fa54ad43700(0000) GS:ffff8949363c0000(0000) knlGS:00000000000=
00000
> > CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > CR2: 00000000000000e8 CR3: 000000025c0ee003 CR4: 00000000003606e0
>=20
>=20
> --=20
> Michal Hocko
> SUSE Labs
>=20

--=20
Sincerely yours,
Mike.
