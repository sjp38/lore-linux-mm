Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6A6346B0003
	for <linux-mm@kvack.org>; Thu,  9 Aug 2018 23:49:35 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id q2-v6so4971635plh.12
        for <linux-mm@kvack.org>; Thu, 09 Aug 2018 20:49:35 -0700 (PDT)
Received: from huawei.com (szxga02-in.huawei.com. [45.249.212.188])
        by mx.google.com with ESMTPS id l17-v6si7413848pgn.182.2018.08.09.20.49.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Aug 2018 20:49:33 -0700 (PDT)
From: "zhangsha (A)" <zhangsha.zhang@huawei.com>
Subject: [Problem] ndctl command hangs forever when reinitializing pmem
 device after vm destroyed
Date: Fri, 10 Aug 2018 03:49:23 +0000
Message-ID: <FC1AAE34B870124C835BDA1138D00F5C7C8BAD87@dggema521-mbs.china.huawei.com>
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_FC1AAE34B870124C835BDA1138D00F5C7C8BAD87dggema521mbschi_"
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "dan.j.williams@intel.com" <dan.j.williams@intel.com>
Cc: "Wanghui (John)" <john.wanghui@huawei.com>, "Zhangyanfei (UVP)" <yanfei.zhang@huawei.com>, guijianfeng <guijianfeng@huawei.com>, "Wencongyang (UVP)" <wencongyang2@huawei.com>

--_000_FC1AAE34B870124C835BDA1138D00F5C7C8BAD87dggema521mbschi_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Hi, all
I got a D status of the process ndctl command unfortunately,
when I try to reinitialize the dax device after vm destroyed.

The stack of the process ndctl command:
[<ffffffffa02c0029>] dax_pmem_percpu_kill+0x29/0x50 [dax_pmem]
[<ffffffff81454715>] devm_action_release+0x15/0x20
[<ffffffff814552cf>] release_nodes+0x1cf/0x220
[<ffffffff8145542c>] devres_release_all+0x3c/0x60
[<ffffffff81450bea>] __device_release_driver+0x8a/0xf0
[<ffffffff81450c73>] device_release_driver+0x23/0x30
[<ffffffff8144f647>] driver_unbind+0xf7/0x120
[<ffffffff8144ea87>] drv_attr_store+0x27/0x40
[<ffffffff81295ecb>] sysfs_write_file+0xcb/0x140
[<ffffffff812159e0>] vfs_write+0xc0/0x1f0
[<ffffffff8121650f>] SyS_write+0x7f/0xe0
[<ffffffff816c22ef>] system_call_fastpath+0x1c/0x21
[<ffffffffffffffff>] 0xffffffffffffffff

I can reproduce this problem reliably with the following steps:
1) initialize the device: "ndctl create-namespace --mode dax --map=3Dmem -e=
 namespace0.0 -f"
2) create the VM(command as follos), and wait the guestos starting up
   "/usr/bin/qemu-kvm -name guest=3Dsuse12sp2-wj,debug-threads=3Don -machin=
e pc-i440fx-2.8,accel=3Dkvm,usb=3Doff,dump-guest-core=3Doff,nvdimm=3Don -cp=
u host,hv_time,hv_relaxed,hv_vapic,hv_spinlocks=3D0x1fff -m size=3D16777216=
k,slots=3D4,maxmem=3D75497472k -realtime mlock=3Doff -smp 4,sockets=3D4,cor=
es=3D1,threads=3D1 -numa node,nodeid=3D0,cpus=3D0-3,mem=3D16384 -object mem=
ory-backend-file,id=3Dmemnvdimm0,prealloc=3Dyes,mem-path=3D/dev/dax0.0,shar=
e=3Dyes,size=3D8587837440,align=3D2097152 -device nvdimm,node=3D0,label-siz=
e=3D131072,memdev=3Dmemnvdimm0,id=3Dnvdimm0,slot=3D0 -uuid 39ce74f4-9cb6-49=
cf-8890-949864ee1a99 -no-user-config -nodefaults -rtc base=3Dutc -no-hpet -=
no-shutdown -boot menu=3Don,strict=3Don -device pci-bridge,chassis_nr=3D1,i=
d=3Dpci.1,bus=3Dpci.0,addr=3D0x7 -device pci-bridge,chassis_nr=3D1,id=3Dpci=
.2,bus=3Dpci.0,addr=3D0x8 -device pci-bridge,chassis_nr=3D1,id=3Dpci.3,bus=
=3Dpci.0,addr=3D0x9 -device piix3-usb-uhci,id=3Dusb,bus=3Dpci.0,addr=3D0x1.=
0x2 -device virtio-scsi-pci,id=3Dscsi0,bus=3Dpci.3,addr=3D0x1 -device virti=
o-serial-pci,id=3Dvirtio-serial0,bus=3Dpci.0,addr=3D0x19 -drive file=3D/Ima=
ges/zsha/images/EulerOS310.qcow2,format=3Dqcow2,if=3Dnone,id=3Ddrive-virtio=
-disk0,cache=3Dnone,aio=3Dthreads -device virtio-blk-pci,scsi=3Doff,bus=3Dp=
ci.2,addr=3D0x1,drive=3Ddrive-virtio-disk0,id=3Dvirtio-disk0,bootindex=3D1 =
-device usb-tablet,id=3Dinput0,bus=3Dusb.0,port=3D1 -vnc 0.0.0.0:0 -k en-us=
 -device cirrus-vga,id=3Dvideo0,vgamem_mb=3D16,bus=3Dpci.0,addr=3D0x2 -devi=
ce ivshmem,id=3Divshmem0,shm=3Di-00000006.kboxram,size=3D16m,role=3Dmaster,=
bus=3Dpci.0,addr=3D0x3 -device virtio-balloon-pci,id=3Dballoon0,bus=3Dpci.0=
,addr=3D0x1e -device pvpanic -msg timestamp=3Don -vnc :9"
3) destroy the VM: "kill -15 `pidof qemu-kvm`"
4) reinitialize the device, then the command hangs: "ndctl create-namespace=
 --mode dax --map=3Dmem -e namespace0.0 -f"

I've tested the problem with a CentOS 3.10.0-862 kernel, a Fedora 4.16.x ke=
rnel and a upstream 4.18.0-rc6; they all exhibit the same behavior.

By adding some logs, I find that the function gup_pte_range(get_page->get_z=
one_device_page)
increase the refcount of device dax0.0 to 161 when starting vm.
But function zap_pte_range() get a NULL page by vm_normal_page(),
so the OS can't decrease the refcount to zero when destroying vm.
And because of it, in function dax_pmem_percpu_kill(dax_pmem_percpu_exit),
the function percpu_ref_put() can't step in the brance releasing device,
the function wait_for_completion() will never be finished.

Stack of increasing the refcount of dax0.0:
[<ffffffff81072c90>] gup_pte_range+0x170/0x380
[<ffffffff8107312f>] gup_pud_range+0x12f/0x1e0
[<ffffffff8107339b>] __get_user_pages_fast+0xcb/0x140
[<ffffffffa057695b>] __gfn_to_pfn_memslot+0x46b/0x490 [kvm]
[<ffffffffa0593e2e>] try_async_pf+0x6e/0x2a0 [kvm]
[<ffffffffa0578dd8>] ? kvm_host_page_size+0x88/0x90 [kvm]
[<ffffffffa059b66a>] tdp_page_fault+0x13a/0x280 [kvm]
[<ffffffffa053c663>] ? vmx_vcpu_run+0x2f3/0xa40 [kvm_intel]
[<ffffffffa059570a>] kvm_mmu_page_fault+0x2a/0x140 [kvm]
[<ffffffffa0532346>] handle_ept_violation+0x96/0x170 [kvm_intel]
[<ffffffffa053ab7c>] vmx_handle_exit+0x2bc/0xc40 [kvm_intel]
[<ffffffffa053c66f>] ? vmx_vcpu_run+0x2ff/0xa40 [kvm_intel]
[<ffffffffa053c663>] ? vmx_vcpu_run+0x2f3/0xa40 [kvm_intel]
[<ffffffffa053c66f>] ? vmx_vcpu_run+0x2ff/0xa40 [kvm_intel]
[<ffffffffa053c663>] ? vmx_vcpu_run+0x2f3/0xa40 [kvm_intel]
[<ffffffffa0538ec8>] ? vmx_hwapic_irr_update+0xb8/0xc0 [kvm_intel]
[<ffffffffa0589b21>] vcpu_enter_guest+0x7d1/0x1300 [kvm]
[<ffffffffa05913b8>] kvm_arch_vcpu_ioctl_run+0x328/0x480 [kvm]
[<ffffffffa0577191>] kvm_vcpu_ioctl+0x2b1/0x660 [kvm]
[<ffffffff81229ec8>] do_vfs_ioctl+0x2e8/0x4d0
[<ffffffff8122a151>] SyS_ioctl+0xa1/0xc0
[<ffffffff816c22ef>] system_call_fastpath+0x1c/0x21

Any reply will be appreciated, and thanks for all your help.

B.R.
Sha Zhang

--_000_FC1AAE34B870124C835BDA1138D00F5C7C8BAD87dggema521mbschi_
Content-Type: text/html; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<html xmlns:v=3D"urn:schemas-microsoft-com:vml" xmlns:o=3D"urn:schemas-micr=
osoft-com:office:office" xmlns:w=3D"urn:schemas-microsoft-com:office:word" =
xmlns:m=3D"http://schemas.microsoft.com/office/2004/12/omml" xmlns=3D"http:=
//www.w3.org/TR/REC-html40">
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Dus-ascii"=
>
<meta name=3D"Generator" content=3D"Microsoft Word 15 (filtered medium)">
<style><!--
/* Font Definitions */
@font-face
	{font-family:SimSun;
	panose-1:2 1 6 0 3 1 1 1 1 1;}
@font-face
	{font-family:"Cambria Math";
	panose-1:2 4 5 3 5 4 6 3 2 4;}
@font-face
	{font-family:Calibri;
	panose-1:2 15 5 2 2 2 4 3 2 4;}
@font-face
	{font-family:SimSun;
	panose-1:2 1 6 0 3 1 1 1 1 1;}
/* Style Definitions */
p.MsoNormal, li.MsoNormal, div.MsoNormal
	{margin:0cm;
	margin-bottom:.0001pt;
	font-size:11.0pt;
	font-family:"Calibri",sans-serif;}
a:link, span.MsoHyperlink
	{mso-style-priority:99;
	color:#0563C1;
	text-decoration:underline;}
a:visited, span.MsoHyperlinkFollowed
	{mso-style-priority:99;
	color:#954F72;
	text-decoration:underline;}
p.MsoListParagraph, li.MsoListParagraph, div.MsoListParagraph
	{mso-style-priority:34;
	margin-top:0cm;
	margin-right:0cm;
	margin-bottom:0cm;
	margin-left:36.0pt;
	margin-bottom:.0001pt;
	font-size:11.0pt;
	font-family:"Calibri",sans-serif;}
span.EmailStyle17
	{mso-style-type:personal-compose;
	font-family:"Calibri",sans-serif;
	color:windowtext;}
.MsoChpDefault
	{mso-style-type:export-only;
	font-family:"Calibri",sans-serif;}
@page WordSection1
	{size:612.0pt 792.0pt;
	margin:72.0pt 90.0pt 72.0pt 90.0pt;}
div.WordSection1
	{page:WordSection1;}
--></style><!--[if gte mso 9]><xml>
<o:shapedefaults v:ext=3D"edit" spidmax=3D"1026" />
</xml><![endif]--><!--[if gte mso 9]><xml>
<o:shapelayout v:ext=3D"edit">
<o:idmap v:ext=3D"edit" data=3D"1" />
</o:shapelayout></xml><![endif]-->
</head>
<body lang=3D"EN-US" link=3D"#0563C1" vlink=3D"#954F72">
<div class=3D"WordSection1">
<p class=3D"MsoNormal">Hi, all<o:p></o:p></p>
<p class=3D"MsoNormal">I got a D status of the process ndctl command unfort=
unately,
<o:p></o:p></p>
<p class=3D"MsoNormal">when I try to reinitialize the dax device after vm d=
estroyed.<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">The stack of the process ndctl command:<o:p></o:p></=
p>
<p class=3D"MsoNormal">[&lt;ffffffffa02c0029&gt;] dax_pmem_percpu_kill&#43;=
0x29/0x50 [dax_pmem]<o:p></o:p></p>
<p class=3D"MsoNormal">[&lt;ffffffff81454715&gt;] devm_action_release&#43;0=
x15/0x20<o:p></o:p></p>
<p class=3D"MsoNormal">[&lt;ffffffff814552cf&gt;] release_nodes&#43;0x1cf/0=
x220<o:p></o:p></p>
<p class=3D"MsoNormal">[&lt;ffffffff8145542c&gt;] devres_release_all&#43;0x=
3c/0x60<o:p></o:p></p>
<p class=3D"MsoNormal">[&lt;ffffffff81450bea&gt;] __device_release_driver&#=
43;0x8a/0xf0<o:p></o:p></p>
<p class=3D"MsoNormal">[&lt;ffffffff81450c73&gt;] device_release_driver&#43=
;0x23/0x30<o:p></o:p></p>
<p class=3D"MsoNormal">[&lt;ffffffff8144f647&gt;] driver_unbind&#43;0xf7/0x=
120<o:p></o:p></p>
<p class=3D"MsoNormal">[&lt;ffffffff8144ea87&gt;] drv_attr_store&#43;0x27/0=
x40<o:p></o:p></p>
<p class=3D"MsoNormal">[&lt;ffffffff81295ecb&gt;] sysfs_write_file&#43;0xcb=
/0x140<o:p></o:p></p>
<p class=3D"MsoNormal">[&lt;ffffffff812159e0&gt;] vfs_write&#43;0xc0/0x1f0<=
o:p></o:p></p>
<p class=3D"MsoNormal">[&lt;ffffffff8121650f&gt;] SyS_write&#43;0x7f/0xe0<o=
:p></o:p></p>
<p class=3D"MsoNormal">[&lt;ffffffff816c22ef&gt;] system_call_fastpath&#43;=
0x1c/0x21<o:p></o:p></p>
<p class=3D"MsoNormal">[&lt;ffffffffffffffff&gt;] 0xffffffffffffffff<o:p></=
o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">I can reproduce this problem reliably with the follo=
wing steps:<o:p></o:p></p>
<p class=3D"MsoNormal">1) initialize the device: &#8220;ndctl create-namesp=
ace --mode dax --map=3Dmem -e namespace0.0 &#8211;f&#8221;<o:p></o:p></p>
<p class=3D"MsoNormal">2) create the VM(command as follos), and wait the gu=
estos starting up<o:p></o:p></p>
<p class=3D"MsoNormal">&nbsp;&nbsp; &#8220;/usr/bin/qemu-kvm -name guest=3D=
suse12sp2-wj,debug-threads=3Don -machine pc-i440fx-2.8,accel=3Dkvm,usb=3Dof=
f,dump-guest-core=3Doff,nvdimm=3Don -cpu host,hv_time,hv_relaxed,hv_vapic,h=
v_spinlocks=3D0x1fff -m size=3D16777216k,slots=3D4,maxmem=3D75497472k
 -realtime mlock=3Doff -smp 4,sockets=3D4,cores=3D1,threads=3D1 -numa node,=
nodeid=3D0,cpus=3D0-3,mem=3D16384 -object memory-backend-file,id=3Dmemnvdim=
m0,prealloc=3Dyes,mem-path=3D/dev/dax0.0,share=3Dyes,size=3D8587837440,alig=
n=3D2097152 -device nvdimm,node=3D0,label-size=3D131072,memdev=3Dmemnvdimm0=
,id=3Dnvdimm0,slot=3D0
 -uuid 39ce74f4-9cb6-49cf-8890-949864ee1a99 -no-user-config -nodefaults -rt=
c base=3Dutc -no-hpet -no-shutdown -boot menu=3Don,strict=3Don -device pci-=
bridge,chassis_nr=3D1,id=3Dpci.1,bus=3Dpci.0,addr=3D0x7 -device pci-bridge,=
chassis_nr=3D1,id=3Dpci.2,bus=3Dpci.0,addr=3D0x8 -device
 pci-bridge,chassis_nr=3D1,id=3Dpci.3,bus=3Dpci.0,addr=3D0x9 -device piix3-=
usb-uhci,id=3Dusb,bus=3Dpci.0,addr=3D0x1.0x2 -device virtio-scsi-pci,id=3Ds=
csi0,bus=3Dpci.3,addr=3D0x1 -device virtio-serial-pci,id=3Dvirtio-serial0,b=
us=3Dpci.0,addr=3D0x19 -drive file=3D/Images/zsha/images/EulerOS310.qcow2,f=
ormat=3Dqcow2,if=3Dnone,id=3Ddrive-virtio-disk0,cache=3Dnone,aio=3Dthreads
 -device virtio-blk-pci,scsi=3Doff,bus=3Dpci.2,addr=3D0x1,drive=3Ddrive-vir=
tio-disk0,id=3Dvirtio-disk0,bootindex=3D1 -device usb-tablet,id=3Dinput0,bu=
s=3Dusb.0,port=3D1 -vnc 0.0.0.0:0 -k en-us -device cirrus-vga,id=3Dvideo0,v=
gamem_mb=3D16,bus=3Dpci.0,addr=3D0x2 -device ivshmem,id=3Divshmem0,shm=3Di-=
00000006.kboxram,size=3D16m,role=3Dmaster,bus=3Dpci.0,addr=3D0x3
 -device virtio-balloon-pci,id=3Dballoon0,bus=3Dpci.0,addr=3D0x1e -device p=
vpanic -msg timestamp=3Don -vnc :9&#8221;<o:p></o:p></p>
<p class=3D"MsoNormal">3) destroy the VM: &#8220;kill -15 `pidof qemu-kvm`&=
#8221;<o:p></o:p></p>
<p class=3D"MsoNormal">4) reinitialize the device, then the command hangs: =
&#8220;ndctl create-namespace --mode dax --map=3Dmem -e namespace0.0 &#8211=
;f&#8221;<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">I've tested the problem with a CentOS 3.10.0-862 ker=
nel, a Fedora 4.16.x kernel and a upstream 4.18.0-rc6; they all exhibit the=
 same behavior.<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">By adding some logs, I find that the function gup_pt=
e_range(get_page-&gt;get_zone_device_page)
<o:p></o:p></p>
<p class=3D"MsoNormal">increase the refcount of device dax0.0 to 161 when s=
tarting vm.<o:p></o:p></p>
<p class=3D"MsoNormal">But function zap_pte_range() get a NULL page by vm_n=
ormal_page(),
<o:p></o:p></p>
<p class=3D"MsoNormal">so the OS can't decrease the refcount to zero when d=
estroying vm.<o:p></o:p></p>
<p class=3D"MsoNormal">And because of it, in function dax_pmem_percpu_kill(=
dax_pmem_percpu_exit),
<o:p></o:p></p>
<p class=3D"MsoNormal">the function percpu_ref_put() can't step in the bran=
ce releasing device,<o:p></o:p></p>
<p class=3D"MsoNormal">the function wait_for_completion() will never be fin=
ished.<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">Stack of increasing the refcount of dax0.0:<o:p></o:=
p></p>
<p class=3D"MsoNormal">[&lt;ffffffff81072c90&gt;] gup_pte_range&#43;0x170/0=
x380<o:p></o:p></p>
<p class=3D"MsoNormal">[&lt;ffffffff8107312f&gt;] gup_pud_range&#43;0x12f/0=
x1e0<o:p></o:p></p>
<p class=3D"MsoNormal">[&lt;ffffffff8107339b&gt;] __get_user_pages_fast&#43=
;0xcb/0x140<o:p></o:p></p>
<p class=3D"MsoNormal">[&lt;ffffffffa057695b&gt;] __gfn_to_pfn_memslot&#43;=
0x46b/0x490 [kvm]<o:p></o:p></p>
<p class=3D"MsoNormal">[&lt;ffffffffa0593e2e&gt;] try_async_pf&#43;0x6e/0x2=
a0 [kvm]<o:p></o:p></p>
<p class=3D"MsoNormal">[&lt;ffffffffa0578dd8&gt;] ? kvm_host_page_size&#43;=
0x88/0x90 [kvm]<o:p></o:p></p>
<p class=3D"MsoNormal">[&lt;ffffffffa059b66a&gt;] tdp_page_fault&#43;0x13a/=
0x280 [kvm]<o:p></o:p></p>
<p class=3D"MsoNormal">[&lt;ffffffffa053c663&gt;] ? vmx_vcpu_run&#43;0x2f3/=
0xa40 [kvm_intel]<o:p></o:p></p>
<p class=3D"MsoNormal">[&lt;ffffffffa059570a&gt;] kvm_mmu_page_fault&#43;0x=
2a/0x140 [kvm]<o:p></o:p></p>
<p class=3D"MsoNormal">[&lt;ffffffffa0532346&gt;] handle_ept_violation&#43;=
0x96/0x170 [kvm_intel]<o:p></o:p></p>
<p class=3D"MsoNormal">[&lt;ffffffffa053ab7c&gt;] vmx_handle_exit&#43;0x2bc=
/0xc40 [kvm_intel]<o:p></o:p></p>
<p class=3D"MsoNormal">[&lt;ffffffffa053c66f&gt;] ? vmx_vcpu_run&#43;0x2ff/=
0xa40 [kvm_intel]<o:p></o:p></p>
<p class=3D"MsoNormal">[&lt;ffffffffa053c663&gt;] ? vmx_vcpu_run&#43;0x2f3/=
0xa40 [kvm_intel]<o:p></o:p></p>
<p class=3D"MsoNormal">[&lt;ffffffffa053c66f&gt;] ? vmx_vcpu_run&#43;0x2ff/=
0xa40 [kvm_intel]<o:p></o:p></p>
<p class=3D"MsoNormal">[&lt;ffffffffa053c663&gt;] ? vmx_vcpu_run&#43;0x2f3/=
0xa40 [kvm_intel]<o:p></o:p></p>
<p class=3D"MsoNormal">[&lt;ffffffffa0538ec8&gt;] ? vmx_hwapic_irr_update&#=
43;0xb8/0xc0 [kvm_intel]<o:p></o:p></p>
<p class=3D"MsoNormal">[&lt;ffffffffa0589b21&gt;] vcpu_enter_guest&#43;0x7d=
1/0x1300 [kvm]<o:p></o:p></p>
<p class=3D"MsoNormal">[&lt;ffffffffa05913b8&gt;] kvm_arch_vcpu_ioctl_run&#=
43;0x328/0x480 [kvm]<o:p></o:p></p>
<p class=3D"MsoNormal">[&lt;ffffffffa0577191&gt;] kvm_vcpu_ioctl&#43;0x2b1/=
0x660 [kvm]<o:p></o:p></p>
<p class=3D"MsoNormal">[&lt;ffffffff81229ec8&gt;] do_vfs_ioctl&#43;0x2e8/0x=
4d0<o:p></o:p></p>
<p class=3D"MsoNormal">[&lt;ffffffff8122a151&gt;] SyS_ioctl&#43;0xa1/0xc0<o=
:p></o:p></p>
<p class=3D"MsoNormal">[&lt;ffffffff816c22ef&gt;] system_call_fastpath&#43;=
0x1c/0x21<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">Any reply will be appreciated, and thanks for all yo=
ur help.<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">B.R.<o:p></o:p></p>
<p class=3D"MsoNormal">Sha Zhang<o:p></o:p></p>
</div>
</body>
</html>

--_000_FC1AAE34B870124C835BDA1138D00F5C7C8BAD87dggema521mbschi_--
