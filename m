Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id AD0FE6B0389
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 17:09:02 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id w185so87481757ita.5
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 14:09:02 -0800 (PST)
Received: from mail-io0-x230.google.com (mail-io0-x230.google.com. [2607:f8b0:4001:c06::230])
        by mx.google.com with ESMTPS id r188si12184002itd.105.2017.03.06.14.09.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Mar 2017 14:09:01 -0800 (PST)
Received: by mail-io0-x230.google.com with SMTP id g6so4437566ioj.1
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 14:09:01 -0800 (PST)
From: "Blake Caldwell" <caldweba@colorado.edu>
Subject: RE: userfaultfd UFFDIO_REMAP
Date: Mon, 6 Mar 2017 15:09:00 -0700
Message-ID: <013601d296c6$4286fec0$c794fc40$@colorado.edu>
MIME-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_NextPart_000_0137_01D2968B.96289BF0"
Content-Language: en-us
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: louis.krigovski@emc.com, aarcange@redhat.com

This is a multipart message in MIME format.

------=_NextPart_000_0137_01D2968B.96289BF0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

I wanted to chime in here following an individual exchange with Andrea, =
because I have been using the userfaultfd remap functionality downstream =
for a research project at the University of Colorado. I've included =
links below to 4.3 and 4.10_rc6 kernels patched to enable userfaultfd =
remap. However, I would hit a kernel bug with 4.3-4.9 or experience =
application failure with invalid page messages with 4.10_rc6. I'm hoping =
the cause might be more obvious to someone on this list. These errors =
occur when concurrent threads are reading and writing to the userfaultfd =
region, while a separate process is performing UFFDIO_REMAP operations =
on the same region. Our use case requires this ability to remove memory =
from the region. The error is not observed if only a single thread is =
reading and writing to the userfaultfd region.

There are 2 attachments.
  - 4.10_dmesg.txt (from the 4.10 kernel, where the application will =
hang after these messages)
  - 4.3-vmcore-dmesg.txt (from the 4.3 kernel BUG. I also have vmcore =
from this crash)=20

The 4.10_rc6 kernel with patches:
https://github.com/blakecaldwell/userfault-kernel/tree/userfault_4.10_rc6=


The 4.3 kernel with patches:
https://github.com/blakecaldwell/userfault-kernel/commits/4.3_userfault

note that my patch for 4.3 here:
https://github.com/blakecaldwell/userfault-kernel/commit/8bbcbed8d61dcb85=
33af67bb00f41a0df66e0535

...is no longer part of the above 4.10 kernel in lieu of:
https://github.com/blakecaldwell/userfault-kernel/commit/15a77c6fe494f4b1=
757d30cd137fe66ab06a38c3

I'm hopeful for 3 things out of this:
1. to add that remap functionality within userfaultfd is critical for =
use case, and we hope that it can make it into mainline in the future.
2. to get more eyes on the patches that might provide some into site =
into why we see failures with concurrent operation on a =
userfault-registered region
3. that the code above with patches will be useful to others interested =
in using the remap functionality

Thanks,
Blake

> -----Original Message-----
> From:
> Sent: None
> Subject:
>=20
> CC'ed linux-mm with your ACK as this may be of general interest, plus =
CC'ed
> others that expressed interest in UFFDIO_REMAP use cases.
>=20
> On Sun, Feb 19, 2017 at 04:35:54PM +0000, krigovski, louis wrote:
> > Hi,
> > I am looking at your slides from LinuxCon Toronto 2016.
> >
> > You mention functionality
> >
> >   1.  "Removing the memory atomically... after adding it with =
UFFDIO_COPY"
> >
> > Is this possible? I don=C3=A2=E2=82=AC=E2=84=A2t see how you can =
unmap page and give copy of it
> to the caller.
>=20
> Originally removing the memory atomically was the only way and there =
was
> not UFFDIO_COPY.
>=20
> The non linear relocation had some constraint (the source page had to =
be not-
> shared so rmap re-linearization was possible).
>=20
> The main complexity in UFFDIO_REMAP is about the re-linearization of =
rmap
> for the pages moved post remap, copying atomically doesn't require any =
rmap
> change instead so it's simpler.
>=20
> As long as the page is not shared solving the rmap is possible as the =
page will
> not become non-linear post-UFFDIO_REMAP and I solved that already for =
anon
> pages already in the old userfault19 branch (last branch where I =
included
> UFFDIO_REMAP, until it can be re-introduced later).
>=20
> The last UFFDIO_REMAP implementation is below, but it's only =
worthwhile to
> remove memory, postcopy doesn't require it, but it would benefit =
distributed
> shared memory implementations or similar usages requiring full memory
> externalization. Others already asked for it.
>=20
> =
https://git.kernel.org/cgit/linux/kernel/git/andrea/aa.git/log/?h=3Duserf=
ault19
> =
https://git.kernel.org/cgit/linux/kernel/git/andrea/aa.git/commit/?h=3Dus=
erfault
> 19&id=3D7a84c6b2af19bd2f989be849b4b8d1096e44d5ea
>=20
> The primary reason why UFFDIO_REMAP was deferred is that UFFDIO_COPY =
is
> not only simpler but it's faster too, for the postcopy live migration =
case (we
> verified it with benchmarks just in case).
>=20
> The reason remap is slower is because of the IPIs that need to be =
delivered to
> all CPUs that mapped the address space of the source virtual range to
> flush/invalidate the TLB.
>=20
> I think IPI deferral and batching would be possible to skip IPIs for =
every single
> page UFFDIO_REMAPped (using a virtual range ring whose TLB flush is =
only
> done at ring-overflow), but it's tricky and it'd have more complext =
semantics
> than mremap. The above implementation in the link retains the same =
strict
> semantics as mremap() but it's slower than UFFDIO_COPY as result. When
> UFFDIO_REMAP is used to remove memory from the final destination =
however
> the IPI cannot be deferred so if only used to remove memory the =
current
> implementation would be already optimal.
>=20
> About the WP support it kind of works but I've (non-kernel-crashing)
> bugreports pending for KVM get_user_pages access that we need to solve
> before it's fully workable for things like postcopy live snapshotting =
too. So it's
> not finished. We focused on completing the hugetlbfs shmem and non
> cooperative features in time for 4.11 merge window and so now we can
> concentrate on finishing the WP support.
>=20
> I've more patches pending than what's currently in the aa.git =
userfault main
> branch: the main objective of the pending work is to have a user (non =
hw
> interpreted) flag on pagetables and swap entries that can =
differentiate when a
> page is wrprotected by other means or through UFFDIO_WRITEPROTECT. =
Just
> like the soft dirty pte/swapentry flag. So that there will be no risk =
of false
> positive WP faults post
> fork() or anything that wrprotect the pagetables by other means. Then =
even
> soft dirty users can be converted to use userfaultfd WP support that =
has a
> computational complexity lower than O(N), and just like PML hw VT =
feature,
> won't require to scan all pagetables to find which pages have been =
re-dirtied.
>=20
> The WP feature isn't just good for distributed shared memory combined =
with
> UFFDIO_REMAP to remove memory, but it'll be useful for postcopy live
> snapshotting and for regular databases that may be using fork() =
instead. fork()
> is not ideal because databases run into trouble with THP WP faults =
that turn
> out to be less efficient than PAGE_SIZEd WP faults for that specific
> snapshotting use case. Furthermore spawning a userfaul thread will be =
more
> efficient than forking off a new process and there will be no TLB =
trashing during
> the snapshotting. With user page faults it's always userland to =
decides the
> granularity of the fault resolution and THP in-kernel will cope with =
whatever
> granularity the userfault handler thread decides. In the snapshotting =
case the
> lower page size the kernel supports is always more efficient and =
creates less
> memory footprint too. Last but not the least, userfaultfd WP will =
allow the
> snapshotting to decide if to throttle on I/O if too much memory is =
getting
> allocated despite using smallest page size granularity available =
(fork() instead
> doesn't allow I/O throttling, so no matter if THP is on or off, the =
max memory
> usage can reach twice the size of the db cache, which may trigger OOM =
in
> containers or similar).
>=20
> Thanks,
> Andrea
>=20
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in the body =
to
> majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>

------=_NextPart_000_0137_01D2968B.96289BF0
Content-Type: text/plain;
	name="4.10_dmesg.txt"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="4.10_dmesg.txt"

[14989.724066] page:ffffdfc6c5320740 count:0 mapcount:0 mapping:         =
 (null) index:0x1=0A=
[14989.732105] flags: 0x2ffff0000000014(referenced|dirty)=0A=
[14989.737638] page:ffffdfc6c5375140 count:0 mapcount:0 mapping:         =
 (null) index:0x1=0A=
[14989.745675] flags: 0x2ffff0000000014(referenced|dirty)=0A=
[14989.750934] page:ffffdfc6c5334c00 count:0 mapcount:0 mapping:         =
 (null) index:0x1=0A=
[14989.758941] flags: 0x2ffff0000000014(referenced|dirty)=0A=
[14989.764358] page:ffffdfc6c5320a80 count:0 mapcount:0 mapping:         =
 (null) index:0x1=0A=
[14989.764361] flags: 0x2ffff0000000014(referenced|dirty)=0A=
[14989.777675] page:ffffdfc6c53754c0 count:0 mapcount:0 mapping:         =
 (null) index:0x1=0A=
[14989.785713] flags: 0x2ffff0000000014(referenced|dirty)=0A=
[14989.791216] page:ffffdfc6c533f2c0 count:0 mapcount:0 mapping:         =
 (null) index:0x1=0A=
[14989.791219] flags: 0x2ffff0000000014(referenced|dirty)=0A=
[14989.791292] page:ffffdfc6c5447c40 count:0 mapcount:0 mapping:         =
 (null) index:0x1=0A=
[14989.791293] flags: 0x2ffff0000000014(referenced|dirty)=0A=
[14989.791364] page:ffffdfc6c5440140 count:0 mapcount:0 mapping:         =
 (null) index:0x1=0A=
[14989.791365] flags: 0x2ffff0000000014(referenced|dirty)=0A=
[14989.791436] page:ffffdfc6c548fa40 count:0 mapcount:0 mapping:         =
 (null) index:0x1=0A=
[14989.791436] flags: 0x2ffff0000000010(dirty)=0A=
[14989.792430] page:ffffdfc6c421d040 count:0 mapcount:0 mapping:         =
 (null) index:0x1=0A=
[14989.792430] flags: 0x2ffff0000000014(referenced|dirty)=0A=
[14989.792507] page:ffffdfc6c4495840 count:0 mapcount:0 mapping:         =
 (null) index:0x1=0A=
[14989.792508] flags: 0x2ffff0000000014(referenced|dirty)=0A=
[14989.792604] page:ffffdfc6c44cbb40 count:0 mapcount:0 mapping:         =
 (null) index:0x1=0A=
[14989.792605] flags: 0x2ffff0000000014(referenced|dirty)=0A=
[14989.792675] page:ffffdfc6c4485140 count:0 mapcount:0 mapping:         =
 (null) index:0x1=0A=
[14989.792676] flags: 0x2ffff0000000014(referenced|dirty)=0A=
[14989.792746] page:ffffdfc6c44e2200 count:0 mapcount:0 mapping:         =
 (null) index:0x1=0A=
[14989.792747] flags: 0x2ffff0000000014(referenced|dirty)=0A=
[14989.792818] page:ffffdfc6c44eb0c0 count:0 mapcount:0 mapping:         =
 (null) index:0x1=0A=
[14989.792818] flags: 0x2ffff0000000014(referenced|dirty)=0A=
[14989.792889] page:ffffdfc6c44f5b80 count:0 mapcount:0 mapping:         =
 (null) index:0x1=0A=
[14989.792889] flags: 0x2ffff0000000014(referenced|dirty)=0A=
[14989.792960] page:ffffdfc6c44e5f40 count:0 mapcount:0 mapping:         =
 (null) index:0x1=0A=
[14989.792961] flags: 0x2ffff0000000014(referenced|dirty)=0A=
[14989.793031] page:ffffdfc6c44d5480 count:0 mapcount:0 mapping:         =
 (null) index:0x1=0A=
[14989.793032] flags: 0x2ffff0000000014(referenced|dirty)=0A=
[14989.793102] page:ffffdfc6c6bdfd80 count:0 mapcount:0 mapping:         =
 (null) index:0x1=0A=
[14989.793103] flags: 0x2ffff0000000014(referenced|dirty)=0A=
[14989.793173] page:ffffdfc6c4509000 count:0 mapcount:0 mapping:         =
 (null) index:0x1=0A=
[14989.793174] flags: 0x2ffff0000000010(dirty)=0A=
[14989.793245] page:ffffdfc6c4507240 count:0 mapcount:0 mapping:         =
 (null) index:0x1=0A=
[14989.793245] flags: 0x2ffff0000000010(dirty)=0A=
[14989.793315] page:ffffdfc6c4500180 count:0 mapcount:0 mapping:         =
 (null) index:0x1=0A=
[14989.793316] flags: 0x2ffff0000000014(referenced|dirty)=0A=
[14989.793387] page:ffffdfc6c4224440 count:0 mapcount:0 mapping:         =
 (null) index:0x1=0A=
[14989.793387] flags: 0x2ffff0000000014(referenced|dirty)=0A=
[14989.793458] page:ffffdfc6c422df40 count:0 mapcount:0 mapping:         =
 (null) index:0x1=0A=
[14989.793458] flags: 0x2ffff0000000014(referenced|dirty)=0A=
[14989.793529] page:ffffdfc6c42cb340 count:0 mapcount:0 mapping:         =
 (null) index:0x1=0A=
[14989.793530] flags: 0x2ffff0000000010(dirty)=0A=
[14989.793600] page:ffffdfc6c4322940 count:0 mapcount:0 mapping:         =
 (null) index:0x1=0A=
[14989.793601] flags: 0x2ffff0000000014(referenced|dirty)=0A=
[14990.036966] page:ffffdfc6c45018c0 count:0 mapcount:0 mapping:         =
 (null) index:0x1=0A=
[14990.036968] flags: 0x2ffff0000000014(referenced|dirty)=0A=
[14990.037224] page:ffffdfc6c454e400 count:0 mapcount:0 mapping:         =
 (null) index:0x1=0A=
[14990.037225] flags: 0x2ffff0000000014(referenced|dirty)=0A=
[14990.037599] page:ffffdfc6c433a500 count:0 mapcount:0 mapping:         =
 (null) index:0x1=0A=
[14990.037600] flags: 0x2ffff0000000014(referenced|dirty)=0A=
[14990.037775] page:ffffdfc6c433a540 count:0 mapcount:0 mapping:         =
 (null) index:0x1=0A=
[14990.037776] flags: 0x2ffff0000000010(dirty)=0A=
[14990.037948] page:ffffdfc6c4322980 count:0 mapcount:0 mapping:         =
 (null) index:0x1=0A=
[14990.037949] flags: 0x2ffff0000000014(referenced|dirty)=0A=
[14990.038115] page:ffffdfc6c43229c0 count:0 mapcount:0 mapping:         =
 (null) index:0x1=0A=
[14990.038116] flags: 0x2ffff0000000014(referenced|dirty)=0A=
[14990.038282] page:ffffdfc6c42d2f00 count:0 mapcount:0 mapping:         =
 (null) index:0x1=0A=
[14990.038283] flags: 0x2ffff0000000014(referenced|dirty)=0A=
[14990.038447] page:ffffdfc6c42d2f40 count:0 mapcount:0 mapping:         =
 (null) index:0x1=0A=
[14990.038448] flags: 0x2ffff0000000014(referenced|dirty)=0A=
[14990.038612] page:ffffdfc6c42a3600 count:0 mapcount:0 mapping:         =
 (null) index:0x1=0A=
[14990.038613] flags: 0x2ffff0000000014(referenced|dirty)=0A=
[14990.038779] page:ffffdfc6c42a3640 count:0 mapcount:0 mapping:         =
 (null) index:0x1=0A=
[14990.038780] flags: 0x2ffff0000000014(referenced|dirty)=0A=
[14990.038943] page:ffffdfc6c42c2f00 count:0 mapcount:0 mapping:         =
 (null) index:0x1=0A=
[14990.038944] flags: 0x2ffff0000000014(referenced|dirty)=0A=
[14990.039107] page:ffffdfc6c42c2f40 count:0 mapcount:0 mapping:         =
 (null) index:0x1=0A=

------=_NextPart_000_0137_01D2968B.96289BF0
Content-Type: text/plain;
	name="4.3-vmcore-dmesg.txt"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="4.3-vmcore-dmesg.txt"

hhim[    0.000000] Initializing cgroup subsys cpuset=0A=
[    0.000000] Initializing cgroup subsys cpu=0A=
[    0.000000] Initializing cgroup subsys cpuacct=0A=
[    0.000000] Linux version 4.3.0-scaleos+ (root@33dffebccf37) (gcc =
version 4.8.5 20150623 (Red Hat 4.8.5-11) (GCC) ) #1 SMP PREEMPT Sun Mar =
5 21:35:16 UTC 2017=0A=
[    0.000000] Command line: =
BOOT_IMAGE=3D/tftpboot/master_images/vmlinuz-4.3.0-scaleos+ =
initrd=3D/tftpboot/master_images/initramfs-4.3.0-scaleos+.img =
bootdev=3Dbr1 bridge=3Dbr1:eno1 console=3DttyS1,115200 enforcing=3D0 =
ip=3Dbr1:dhcp nofb nomodeset =
root=3Dnfs:10.0.1.1:/data/images/centos-scaleos-4.4:vers=3D3 selinux=3D0 =
vga=3Dnormal crashkernel=3D384M audit=3D0=0A=
[    0.000000] KERNEL supported cpus:=0A=
[    0.000000]   Intel GenuineIntel=0A=
[    0.000000]   AMD AuthenticAMD=0A=
[    0.000000] x86/fpu: xstate_offset[2]: 0240, xstate_sizes[2]: 0100=0A=
[    0.000000] x86/fpu: Supporting XSAVE feature 0x01: 'x87 floating =
point registers'=0A=
[    0.000000] x86/fpu: Supporting XSAVE feature 0x02: 'SSE registers'=0A=
[    0.000000] x86/fpu: Supporting XSAVE feature 0x04: 'AVX registers'=0A=
[    0.000000] x86/fpu: Enabled xstate features 0x7, context size is =
0x340 bytes, using 'standard' format.=0A=
[    0.000000] x86/fpu: Using 'eager' FPU context switches.=0A=
[    0.000000] e820: BIOS-provided physical RAM map:=0A=
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009abff] =
usable=0A=
[    0.000000] BIOS-e820: [mem 0x000000000009ac00-0x000000000009ffff] =
reserved=0A=
[    0.000000] BIOS-e820: [mem 0x00000000000e0000-0x00000000000fffff] =
reserved=0A=
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x0000000078f3efff] =
usable=0A=
[    0.000000] BIOS-e820: [mem 0x0000000078f3f000-0x000000007985ffff] =
reserved=0A=
[    0.000000] BIOS-e820: [mem 0x0000000079860000-0x0000000079d4ffff] =
ACPI NVS=0A=
[    0.000000] BIOS-e820: [mem 0x0000000079d50000-0x000000008fffffff] =
reserved=0A=
[    0.000000] BIOS-e820: [mem 0x00000000fed1c000-0x00000000fed44fff] =
reserved=0A=
[    0.000000] BIOS-e820: [mem 0x00000000ff000000-0x00000000ffffffff] =
reserved=0A=
[    0.000000] BIOS-e820: [mem 0x0000000100000000-0x000000107fffffff] =
usable=0A=
[    0.000000] NX (Execute Disable) protection: active=0A=
[    0.000000] SMBIOS 3.0 present.=0A=
[    0.000000] DMI: Supermicro SYS-1028TR-TF/X10DRT-LIBF, BIOS 2.0 =
12/17/2015=0A=
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> =
reserved=0A=
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable=0A=
[    0.000000] e820: last_pfn =3D 0x1080000 max_arch_pfn =3D 0x400000000=0A=
[    0.000000] MTRR default type: write-back=0A=
[    0.000000] MTRR fixed ranges enabled:=0A=
[    0.000000]   00000-9FFFF write-back=0A=
[    0.000000]   A0000-BFFFF uncachable=0A=
[    0.000000]   C0000-FFFFF write-protect=0A=
[    0.000000] MTRR variable ranges enabled:=0A=
[    0.000000]   0 base 000080000000 mask 3FFF80000000 uncachable=0A=
[    0.000000]   1 base 380000000000 mask 3F8000000000 uncachable=0A=
[    0.000000]   2 base 0000C5800000 mask 3FFFFF800000 write-through=0A=
[    0.000000]   3 disabled=0A=
[    0.000000]   4 disabled=0A=
[    0.000000]   5 disabled=0A=
[    0.000000]   6 disabled=0A=
[    0.000000]   7 disabled=0A=
[    0.000000]   8 disabled=0A=
[    0.000000]   9 disabled=0A=
[    0.000000] x86/PAT: Configuration [0-7]: WB  WC  UC- UC  WB  WC  UC- =
WT=0A=
[    0.000000] e820: last_pfn =3D 0x78f3f max_arch_pfn =3D 0x400000000=0A=
[    0.000000] found SMP MP-table at [mem 0x000fdb20-0x000fdb2f] mapped =
at [ffff8800000fdb20]=0A=
[    0.000000] Scanning 1 areas for low memory corruption=0A=
[    0.000000] Base memory trampoline at [ffff880000094000] 94000 size =
24576=0A=
[    0.000000] Using GB pages for direct mapping=0A=
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]=0A=
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k=0A=
[    0.000000] BRK [0x1afd2000, 0x1afd2fff] PGTABLE=0A=
[    0.000000] BRK [0x1afd3000, 0x1afd3fff] PGTABLE=0A=
[    0.000000] BRK [0x1afd4000, 0x1afd4fff] PGTABLE=0A=
[    0.000000] init_memory_mapping: [mem 0x107fe00000-0x107fffffff]=0A=
[    0.000000]  [mem 0x107fe00000-0x107fffffff] page 1G=0A=
[    0.000000] init_memory_mapping: [mem 0x1060000000-0x107fdfffff]=0A=
[    0.000000]  [mem 0x1060000000-0x107fdfffff] page 1G=0A=
[    0.000000] init_memory_mapping: [mem 0x00100000-0x78f3efff]=0A=
[    0.000000]  [mem 0x00100000-0x001fffff] page 4k=0A=
[    0.000000]  [mem 0x00200000-0x78dfffff] page 2M=0A=
[    0.000000]  [mem 0x78e00000-0x78f3efff] page 4k=0A=
[    0.000000] init_memory_mapping: [mem 0x100000000-0x105fffffff]=0A=
[    0.000000]  [mem 0x100000000-0x105fffffff] page 1G=0A=
[    0.000000] RAMDISK: [mem 0x71200000-0x78f3efff]=0A=
[    0.000000] ACPI: Early table checksum verification disabled=0A=
[    0.000000] ACPI: RSDP 0x00000000000F0580 000024 (v02 SUPERM)=0A=
[    0.000000] ACPI: XSDT 0x00000000798B00A8 0000CC (v01                 =
01072009 AMI  00010013)=0A=
[    0.000000] ACPI: FACP 0x00000000798E0C50 00010C (v05 SUPERM SMCI--MB =
01072009 AMI  00010013)=0A=
[    0.000000] ACPI: DSDT 0x00000000798B0208 030A47 (v02 SUPERM SMCI--MB =
01072009 INTL 20091013)=0A=
[    0.000000] ACPI: FACS 0x0000000079D4EF80 000040=0A=
[    0.000000] ACPI: APIC 0x00000000798E0D60 000144 (v03 SUPERM SMCI--MB =
01072009 AMI  00010013)=0A=
[    0.000000] ACPI: FPDT 0x00000000798E0EA8 000044 (v01 SUPERM SMCI--MB =
01072009 AMI  00010013)=0A=
[    0.000000] ACPI: FIDT 0x00000000798E0EF0 00009C (v01 SUPERM SMCI--MB =
01072009 AMI  00010013)=0A=
[    0.000000] ACPI: SPMI 0x00000000798E0F90 000040 (v05 SUPERM SMCI--MB =
00000000 AMI. 00000000)=0A=
[    0.000000] ACPI: MCFG 0x00000000798E0FD0 00003C (v01 SUPERM SMCI--MB =
01072009 MSFT 00000097)=0A=
[    0.000000] ACPI: UEFI 0x00000000798E1010 000042 (v01 SUPERM SMCI--MB =
01072009      00000000)=0A=
[    0.000000] ACPI: HPET 0x00000000798E1058 000038 (v01 SUPERM SMCI--MB =
00000001 INTL 20091013)=0A=
[    0.000000] ACPI: MSCT 0x00000000798E1090 000090 (v01 SUPERM SMCI--MB =
00000001 INTL 20091013)=0A=
[    0.000000] ACPI: SLIT 0x00000000798E1120 000030 (v01 SUPERM SMCI--MB =
00000001 INTL 20091013)=0A=
[    0.000000] ACPI: SRAT 0x00000000798E1150 001158 (v03 SUPERM SMCI--MB =
00000001 INTL 20091013)=0A=
[    0.000000] ACPI: WDDT 0x00000000798E22A8 000040 (v01 SUPERM SMCI--MB =
00000000 INTL 20091013)=0A=
[    0.000000] ACPI: SSDT 0x00000000798E22E8 017141 (v02 SUPERM PmMgt    =
00000001 INTL 20120913)=0A=
[    0.000000] ACPI: SSDT 0x00000000798F9430 00264C (v02 SUPERM SpsNm    =
00000002 INTL 20120913)=0A=
[    0.000000] ACPI: SSDT 0x00000000798FBA80 000064 (v02 SUPERM SpsNvs   =
00000002 INTL 20120913)=0A=
[    0.000000] ACPI: PRAD 0x00000000798FBAE8 000102 (v02 SUPERM SMCI--MB =
00000002 INTL 20120913)=0A=
[    0.000000] ACPI: DMAR 0x00000000798FBBF0 000128 (v01 SUPERM SMCI--MB =
00000001 INTL 20091013)=0A=
[    0.000000] ACPI: HEST 0x00000000798FBD18 00027C (v01 SUPERM SMCI--MB =
00000001 INTL 00000001)=0A=
[    0.000000] ACPI: BERT 0x00000000798FBF98 000030 (v01 SUPERM SMCI--MB =
00000001 INTL 00000001)=0A=
[    0.000000] ACPI: ERST 0x00000000798FBFC8 000230 (v01 SUPERM SMCI--MB =
00000001 INTL 00000001)=0A=
[    0.000000] ACPI: EINJ 0x00000000798FC1F8 000130 (v01 SUPERM SMCI--MB =
00000001 INTL 00000001)=0A=
[    0.000000] ACPI: Local APIC address 0xfee00000=0A=
[    0.000000] SRAT: PXM 0 -> APIC 0x00 -> Node 0=0A=
[    0.000000] SRAT: PXM 0 -> APIC 0x02 -> Node 0=0A=
[    0.000000] SRAT: PXM 0 -> APIC 0x04 -> Node 0=0A=
[    0.000000] SRAT: PXM 0 -> APIC 0x06 -> Node 0=0A=
[    0.000000] SRAT: PXM 0 -> APIC 0x08 -> Node 0=0A=
[    0.000000] SRAT: PXM 0 -> APIC 0x0a -> Node 0=0A=
[    0.000000] SRAT: PXM 0 -> APIC 0x0c -> Node 0=0A=
[    0.000000] SRAT: PXM 0 -> APIC 0x0e -> Node 0=0A=
[    0.000000] SRAT: PXM 1 -> APIC 0x10 -> Node 1=0A=
[    0.000000] SRAT: PXM 1 -> APIC 0x12 -> Node 1=0A=
[    0.000000] SRAT: PXM 1 -> APIC 0x14 -> Node 1=0A=
[    0.000000] SRAT: PXM 1 -> APIC 0x16 -> Node 1=0A=
[    0.000000] SRAT: PXM 1 -> APIC 0x18 -> Node 1=0A=
[    0.000000] SRAT: PXM 1 -> APIC 0x1a -> Node 1=0A=
[    0.000000] SRAT: PXM 1 -> APIC 0x1c -> Node 1=0A=
[    0.000000] SRAT: PXM 1 -> APIC 0x1e -> Node 1=0A=
[    0.000000] SRAT: Node 0 PXM 0 [mem 0x00000000-0x7fffffff]=0A=
[    0.000000] SRAT: Node 0 PXM 0 [mem 0x100000000-0x87fffffff]=0A=
[    0.000000] SRAT: Node 1 PXM 1 [mem 0x880000000-0x107fffffff]=0A=
[    0.000000] NUMA: Initialized distance table, cnt=3D2=0A=
[    0.000000] NUMA: Node 0 [mem 0x00000000-0x7fffffff] + [mem =
0x100000000-0x87fffffff] -> [mem 0x00000000-0x87fffffff]=0A=
[    0.000000] NODE_DATA(0) allocated [mem 0x87fffb000-0x87fffffff]=0A=
[    0.000000] NODE_DATA(1) allocated [mem 0x107fff8000-0x107fffcfff]=0A=
[    0.000000] Reserving 384MB of memory at 512MB for crashkernel =
(System RAM: 65422MB)=0A=
[    0.000000]  [ffffea0000000000-ffffea0021ffffff] PMD -> =
[ffff88085fe00000-ffff88087fdfffff] on node 0=0A=
[    0.000000]  [ffffea0022000000-ffffea0041ffffff] PMD -> =
[ffff88105f600000-ffff88107f5fffff] on node 1=0A=
[    0.000000] Zone ranges:=0A=
[    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]=0A=
[    0.000000]   DMA32    [mem 0x0000000001000000-0x00000000ffffffff]=0A=
[    0.000000]   Normal   [mem 0x0000000100000000-0x000000107fffffff]=0A=
[    0.000000] Movable zone start for each node=0A=
[    0.000000] Early memory node ranges=0A=
[    0.000000]   node   0: [mem 0x0000000000001000-0x0000000000099fff]=0A=
[    0.000000]   node   0: [mem 0x0000000000100000-0x0000000078f3efff]=0A=
[    0.000000]   node   0: [mem 0x0000000100000000-0x000000087fffffff]=0A=
[    0.000000]   node   1: [mem 0x0000000880000000-0x000000107fffffff]=0A=
[    0.000000] Initmem setup node 0 [mem =
0x0000000000001000-0x000000087fffffff]=0A=
[    0.000000] On node 0 totalpages: 8359640=0A=
[    0.000000]   DMA zone: 64 pages used for memmap=0A=
[    0.000000]   DMA zone: 21 pages reserved=0A=
[    0.000000]   DMA zone: 3993 pages, LIFO batch:0=0A=
[    0.000000]   DMA32 zone: 7677 pages used for memmap=0A=
[    0.000000]   DMA32 zone: 491327 pages, LIFO batch:31=0A=
[    0.000000]   Normal zone: 122880 pages used for memmap=0A=
[    0.000000]   Normal zone: 7864320 pages, LIFO batch:31=0A=
[    0.000000] Initmem setup node 1 [mem =
0x0000000880000000-0x000000107fffffff]=0A=
[    0.000000] On node 1 totalpages: 8388608=0A=
[    0.000000]   Normal zone: 131072 pages used for memmap=0A=
[    0.000000]   Normal zone: 8388608 pages, LIFO batch:31=0A=
[    0.000000] ACPI: PM-Timer IO Port: 0x408=0A=
[    0.000000] ACPI: Local APIC address 0xfee00000=0A=
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])=0A=
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x02] high edge lint[0x1])=0A=
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x04] high edge lint[0x1])=0A=
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x06] high edge lint[0x1])=0A=
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x08] high edge lint[0x1])=0A=
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0a] high edge lint[0x1])=0A=
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0c] high edge lint[0x1])=0A=
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0e] high edge lint[0x1])=0A=
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x10] high edge lint[0x1])=0A=
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x12] high edge lint[0x1])=0A=
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x14] high edge lint[0x1])=0A=
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x16] high edge lint[0x1])=0A=
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x18] high edge lint[0x1])=0A=
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x1a] high edge lint[0x1])=0A=
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x1c] high edge lint[0x1])=0A=
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x1e] high edge lint[0x1])=0A=
[    0.000000] IOAPIC[0]: apic_id 1, version 32, address 0xfec00000, GSI =
0-23=0A=
[    0.000000] IOAPIC[1]: apic_id 2, version 32, address 0xfec01000, GSI =
24-47=0A=
[    0.000000] IOAPIC[2]: apic_id 3, version 32, address 0xfec40000, GSI =
48-71=0A=
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)=0A=
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high =
level)=0A=
[    0.000000] ACPI: IRQ0 used by override.=0A=
[    0.000000] ACPI: IRQ9 used by override.=0A=
[    0.000000] Using ACPI (MADT) for SMP configuration information=0A=
[    0.000000] ACPI: HPET id: 0x8086a701 base: 0xfed00000=0A=
[    0.000000] smpboot: Allowing 16 CPUs, 0 hotplug CPUs=0A=
[    0.000000] e820: [mem 0x90000000-0xfed1bfff] available for PCI =
devices=0A=
[    0.000000] Booting paravirtualized kernel on bare hardware=0A=
[    0.000000] clocksource: refined-jiffies: mask: 0xffffffff =
max_cycles: 0xffffffff, max_idle_ns: 7645519600211568 ns=0A=
[    0.000000] setup_percpu: NR_CPUS:256 nr_cpumask_bits:256 =
nr_cpu_ids:16 nr_node_ids:2=0A=
[    0.000000] PERCPU: Embedded 33 pages/cpu @ffff88085fc00000 s97560 =
r8192 d29416 u262144=0A=
[    0.000000] pcpu-alloc: s97560 r8192 d29416 u262144 alloc=3D1*2097152=0A=
[    0.000000] pcpu-alloc: [0] 00 01 02 03 04 05 06 07 [1] 08 09 10 11 =
12 13 14 15=0A=
[    0.000000] Built 2 zonelists in Node order, mobility grouping on.  =
Total pages: 16486534=0A=
[    0.000000] Policy zone: Normal=0A=
[    0.000000] Kernel command line: =
BOOT_IMAGE=3D/tftpboot/master_images/vmlinuz-4.3.0-scaleos+ =
initrd=3D/tftpboot/master_images/initramfs-4.3.0-scaleos+.img =
bootdev=3Dbr1 bridge=3Dbr1:eno1 console=3DttyS1,115200 enforcing=3D0 =
ip=3Dbr1:dhcp nofb nomodeset =
root=3Dnfs:10.0.1.1:/data/images/centos-scaleos-4.4:vers=3D3 selinux=3D0 =
vga=3Dnormal crashkernel=3D384M audit=3D0=0A=
[    0.000000] audit: disabled (until reboot)=0A=
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)=0A=
[    0.000000] Memory: 65338060K/66992992K available (7539K kernel code, =
1241K rwdata, 3440K rodata, 1372K init, 1264K bss, 1654932K reserved, 0K =
cma-reserved)=0A=
[    0.000000] SLUB: HWalign=3D64, Order=3D0-3, MinObjects=3D0, =
CPUs=3D16, Nodes=3D2=0A=
[    0.000000] Preemptible hierarchical RCU implementation.=0A=
[    0.000000] 	Build-time adjustment of leaf fanout to 64.=0A=
[    0.000000] 	RCU restricting CPUs from NR_CPUS=3D256 to =
nr_cpu_ids=3D16.=0A=
[    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=3D64, =
nr_cpu_ids=3D16=0A=
[    0.000000] NR_IRQS:16640 nr_irqs:1368 16=0A=
[    0.000000] Console: colour VGA+ 80x25=0A=
[    0.000000] console [ttyS1] enabled=0A=
[    0.000000] mempolicy: Enabling automatic NUMA balancing. Configure =
with numa_balancing=3D or the kernel.numa_balancing sysctl=0A=
[    0.000000] clocksource: hpet: mask: 0xffffffff max_cycles: =
0xffffffff, max_idle_ns: 133484882848 ns=0A=
[    0.000000] hpet clockevent registered=0A=
[    0.000000] tsc: Fast TSC calibration using PIT=0A=
[    0.000000] tsc: Detected 2099.995 MHz processor=0A=
[    0.000035] Calibrating delay loop (skipped), value calculated using =
timer frequency.. 4199.99 BogoMIPS (lpj=3D8399980)=0A=
[    0.010669] pid_max: default: 32768 minimum: 301=0A=
[    0.015297] ACPI: Core revision 20150818=0A=
[    0.077876] ACPI: 4 ACPI AML tables successfully acquired and loaded=0A=
[    0.084297] Security Framework initialized=0A=
[    0.088400] Yama: becoming mindful.=0A=
[    0.091894] AppArmor: AppArmor initialized=0A=
[    0.100954] Dentry cache hash table entries: 8388608 (order: 14, =
67108864 bytes)=0A=
[    0.122174] Inode-cache hash table entries: 4194304 (order: 13, =
33554432 bytes)=0A=
[    0.135218] Mount-cache hash table entries: 131072 (order: 8, 1048576 =
bytes)=0A=
[    0.142361] Mountpoint-cache hash table entries: 131072 (order: 8, =
1048576 bytes)=0A=
[    0.150384] Initializing cgroup subsys io=0A=
[    0.154403] Initializing cgroup subsys memory=0A=
[    0.158770] Initializing cgroup subsys devices=0A=
[    0.163220] Initializing cgroup subsys freezer=0A=
[    0.167669] Initializing cgroup subsys net_cls=0A=
[    0.172118] Initializing cgroup subsys perf_event=0A=
[    0.176829] Initializing cgroup subsys net_prio=0A=
[    0.181364] Initializing cgroup subsys hugetlb=0A=
[    0.185815] Initializing cgroup subsys pids=0A=
[    0.190031] CPU: Physical Processor ID: 0=0A=
[    0.194044] CPU: Processor Core ID: 0=0A=
[    0.198493] mce: CPU supports 22 MCE banks=0A=
[    0.202629] CPU0: Thermal monitoring enabled (TM1)=0A=
[    0.207454] Last level iTLB entries: 4KB 128, 2MB 8, 4MB 8=0A=
[    0.212944] Last level dTLB entries: 4KB 64, 2MB 0, 4MB 0, 1GB 4=0A=
[    0.219341] Freeing SMP alternatives memory: 24K (ffffffff9ae8f000 - =
ffffffff9ae95000)=0A=
[    0.228204] ftrace: allocating 28891 entries in 113 pages=0A=
[    0.246762] DMAR: Host address width 46=0A=
[    0.250606] DMAR: DRHD base: 0x000000fbffc000 flags: 0x0=0A=
[    0.255931] DMAR: dmar0: reg_base_addr fbffc000 ver 1:0 cap =
8d2078c106f0466 ecap f020de=0A=
[    0.263936] DMAR: DRHD base: 0x000000c7ffc000 flags: 0x1=0A=
[    0.269255] DMAR: dmar1: reg_base_addr c7ffc000 ver 1:0 cap =
8d2078c106f0466 ecap f020de=0A=
[    0.277258] DMAR: RMRR base: 0x0000007ba77000 end: 0x0000007ba86fff=0A=
[    0.283529] DMAR: ATSR flags: 0x0=0A=
[    0.286851] DMAR: RHSA base: 0x000000c7ffc000 proximity domain: 0x0=0A=
[    0.293122] DMAR: RHSA base: 0x000000fbffc000 proximity domain: 0x1=0A=
[    0.299393] DMAR-IR: IOAPIC id 3 under DRHD base  0xfbffc000 IOMMU 0=0A=
[    0.305750] DMAR-IR: IOAPIC id 1 under DRHD base  0xc7ffc000 IOMMU 1=0A=
[    0.312110] DMAR-IR: IOAPIC id 2 under DRHD base  0xc7ffc000 IOMMU 1=0A=
[    0.318466] DMAR-IR: HPET id 0 under DRHD base 0xc7ffc000=0A=
[    0.323868] DMAR-IR: x2apic is disabled because BIOS sets x2apic opt =
out bit.=0A=
[    0.330835] DMAR-IR: Use 'intremap=3Dno_x2apic_optout' to override =
the BIOS setting.=0A=
[    0.339474] DMAR-IR: Enabled IRQ remapping in xapic mode=0A=
[    0.344781] x2apic: IRQ remapping doesn't support X2APIC mode=0A=
[    0.350536] Switched APIC routing to physical flat.=0A=
[    0.356059] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 =
pin2=3D-1=0A=
[    0.401779] TSC deadline timer enabled=0A=
[    0.401782] smpboot: CPU0: Intel(R) Xeon(R) CPU E5-2620 v4 @ 2.10GHz =
(family: 0x6, model: 0x4f, stepping: 0x1)=0A=
[    0.411850] Performance Events: PEBS fmt2+, 16-deep LBR, Broadwell =
events, full-width counters, Intel PMU driver.=0A=
[    0.422196] ... version:                3=0A=
[    0.426201] ... bit width:              48=0A=
[    0.430296] ... generic registers:      8=0A=
[    0.434302] ... value mask:             0000ffffffffffff=0A=
[    0.439612] ... max period:             0000ffffffffffff=0A=
[    0.444920] ... fixed-purpose events:   3=0A=
[    0.448925] ... event mask:             00000007000000ff=0A=
[    0.494323] x86: Booting SMP configuration:=0A=
[    0.498508] .... node  #0, CPUs:        #1=0A=
[    0.516975] NMI watchdog: enabled on all CPUs, permanently consumes =
one hw-PMU counter.=0A=
[    0.537207]   #2  #3  #4  #5  #6  #7=0A=
[    0.681618] .... node  #1, CPUs:    #8  #9 #10 #11 #12 #13 #14 #15=0A=
[    0.968107] x86: Booted up 2 nodes, 16 CPUs=0A=
[    0.972478] smpboot: Total of 16 processors activated (67211.82 =
BogoMIPS)=0A=
[    1.007918] devtmpfs: initialized=0A=
[    1.011300] memory block size : 2048MB=0A=
[    1.013166] evm: security.selinux=0A=
[    1.016479] evm: security.SMACK64=0A=
[    1.019788] evm: security.SMACK64EXEC=0A=
[    1.023451] evm: security.SMACK64TRANSMUTE=0A=
[    1.027546] evm: security.SMACK64MMAP=0A=
[    1.031203] evm: security.ima=0A=
[    1.034171] evm: security.capability=0A=
[    1.037941] clocksource: jiffies: mask: 0xffffffff max_cycles: =
0xffffffff, max_idle_ns: 7645041785100000 ns=0A=
[    1.048757] NET: Registered protocol family 16=0A=
[    1.069233] cpuidle: using governor ladder=0A=
[    1.089363] cpuidle: using governor menu=0A=
[    1.093409] ACPI FADT declares the system doesn't support PCIe ASPM, =
so disable it=0A=
[    1.100977] ACPI: bus type PCI registered=0A=
[    1.104982] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5=0A=
[    1.111505] PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem =
0x80000000-0x8fffffff] (base 0x80000000)=0A=
[    1.120805] PCI: MMCONFIG at [mem 0x80000000-0x8fffffff] reserved in =
E820=0A=
[    1.127603] PCI: Using configuration type 1 for base access=0A=
[    1.145869] ACPI: Added _OSI(Module Device)=0A=
[    1.150054] ACPI: Added _OSI(Processor Device)=0A=
[    1.154500] ACPI: Added _OSI(3.0 _SCP Extensions)=0A=
[    1.159201] ACPI: Added _OSI(Processor Aggregator Device)=0A=
[    1.194315] [Firmware Bug]: ACPI: BIOS _OSI(Linux) query ignored=0A=
[    1.249205] ACPI: Dynamic OEM Table Load:=0A=
[    1.253245] ACPI: PRAD 0x0000000000000000 000102 (v02 SUPERM SMCI--MB =
00000002 INTL 20120913)=0A=
[    1.282866] ACPI: Interpreter enabled=0A=
[    1.286534] ACPI: (supports S0 S5)=0A=
[    1.289934] ACPI: Using IOAPIC for interrupt routing=0A=
[    1.294924] HEST: Enabling Firmware First mode for corrected errors.=0A=
[    1.301468] HEST: Table parsing has been initialized.=0A=
[    1.306521] PCI: Using host bridge windows from ACPI; if necessary, =
use "pci=3Dnocrs" and report a bug=0A=
[    1.350895] ACPI: PCI Root Bridge [UNC1] (domain 0000 [bus ff])=0A=
[    1.356824] acpi PNP0A03:02: _OSC: OS supports [ExtendedConfig ASPM =
ClockPM Segments MSI]=0A=
[    1.367409] acpi PNP0A03:02: _OSC: platform does not support [AER]=0A=
[    1.436501] acpi PNP0A03:02: _OSC: OS now controls [PCIeHotplug PME =
PCIeCapability]=0A=
[    1.444153] acpi PNP0A03:02: FADT indicates ASPM is unsupported, =
using BIOS configuration=0A=
[    1.452360] PCI host bridge to bus 0000:ff=0A=
[    1.456461] pci_bus 0000:ff: root bus resource [bus ff]=0A=
[    1.461698] pci 0000:ff:08.0: [8086:6f80] type 00 class 0x088000=0A=
[    1.461759] pci 0000:ff:08.2: [8086:6f32] type 00 class 0x110100=0A=
[    1.461812] pci 0000:ff:08.3: [8086:6f83] type 00 class 0x088000=0A=
[    1.461871] pci 0000:ff:09.0: [8086:6f90] type 00 class 0x088000=0A=
[    1.461920] pci 0000:ff:09.2: [8086:6f33] type 00 class 0x110100=0A=
[    1.461970] pci 0000:ff:09.3: [8086:6f93] type 00 class 0x088000=0A=
[    1.462027] pci 0000:ff:0b.0: [8086:6f81] type 00 class 0x088000=0A=
[    1.462073] pci 0000:ff:0b.1: [8086:6f36] type 00 class 0x110100=0A=
[    1.462121] pci 0000:ff:0b.2: [8086:6f37] type 00 class 0x110100=0A=
[    1.462166] pci 0000:ff:0b.3: [8086:6f76] type 00 class 0x088000=0A=
[    1.462215] pci 0000:ff:0c.0: [8086:6fe0] type 00 class 0x088000=0A=
[    1.462261] pci 0000:ff:0c.1: [8086:6fe1] type 00 class 0x088000=0A=
[    1.462306] pci 0000:ff:0c.2: [8086:6fe2] type 00 class 0x088000=0A=
[    1.462353] pci 0000:ff:0c.3: [8086:6fe3] type 00 class 0x088000=0A=
[    1.462398] pci 0000:ff:0c.4: [8086:6fe4] type 00 class 0x088000=0A=
[    1.462443] pci 0000:ff:0c.5: [8086:6fe5] type 00 class 0x088000=0A=
[    1.462490] pci 0000:ff:0c.6: [8086:6fe6] type 00 class 0x088000=0A=
[    1.462537] pci 0000:ff:0c.7: [8086:6fe7] type 00 class 0x088000=0A=
[    1.462584] pci 0000:ff:0f.0: [8086:6ff8] type 00 class 0x088000=0A=
[    1.462630] pci 0000:ff:0f.1: [8086:6ff9] type 00 class 0x088000=0A=
[    1.462677] pci 0000:ff:0f.4: [8086:6ffc] type 00 class 0x088000=0A=
[    1.462723] pci 0000:ff:0f.5: [8086:6ffd] type 00 class 0x088000=0A=
[    1.462769] pci 0000:ff:0f.6: [8086:6ffe] type 00 class 0x088000=0A=
[    1.462814] pci 0000:ff:10.0: [8086:6f1d] type 00 class 0x088000=0A=
[    1.462862] pci 0000:ff:10.1: [8086:6f34] type 00 class 0x110100=0A=
[    1.462910] pci 0000:ff:10.5: [8086:6f1e] type 00 class 0x088000=0A=
[    1.462955] pci 0000:ff:10.6: [8086:6f7d] type 00 class 0x110100=0A=
[    1.463001] pci 0000:ff:10.7: [8086:6f1f] type 00 class 0x088000=0A=
[    1.463047] pci 0000:ff:12.0: [8086:6fa0] type 00 class 0x088000=0A=
[    1.463056] pci 0000:ff:12.0: reg 0x14: [mem 0x00000000-0x0000000f]=0A=
[    1.463060] pci 0000:ff:12.0: reg 0x18: [mem 0x00000000-0x0000003f]=0A=
[    1.463064] pci 0000:ff:12.0: reg 0x1c: [mem 0x00000000-0x0000000f]=0A=
[    1.463068] pci 0000:ff:12.0: reg 0x20: [mem 0x00000000-0x0000003f]=0A=
[    1.463072] pci 0000:ff:12.0: reg 0x24: [mem 0x00000000-0x0000000f]=0A=
[    1.463104] pci 0000:ff:12.1: [8086:6f30] type 00 class 0x110100=0A=
[    1.463157] pci 0000:ff:13.0: [8086:6fa8] type 00 class 0x088000=0A=
[    1.463236] pci 0000:ff:13.1: [8086:6f71] type 00 class 0x088000=0A=
[    1.463318] pci 0000:ff:13.2: [8086:6faa] type 00 class 0x088000=0A=
[    1.463399] pci 0000:ff:13.3: [8086:6fab] type 00 class 0x088000=0A=
[    1.463481] pci 0000:ff:13.4: [8086:6fac] type 00 class 0x088000=0A=
[    1.463563] pci 0000:ff:13.5: [8086:6fad] type 00 class 0x088000=0A=
[    1.463646] pci 0000:ff:13.6: [8086:6fae] type 00 class 0x088000=0A=
[    1.463717] pci 0000:ff:13.7: [8086:6faf] type 00 class 0x088000=0A=
[    1.463791] pci 0000:ff:14.0: [8086:6fb0] type 00 class 0x088000=0A=
[    1.463873] pci 0000:ff:14.1: [8086:6fb1] type 00 class 0x088000=0A=
[    1.463956] pci 0000:ff:14.2: [8086:6fb2] type 00 class 0x088000=0A=
[    1.464038] pci 0000:ff:14.3: [8086:6fb3] type 00 class 0x088000=0A=
[    1.464118] pci 0000:ff:14.4: [8086:6fbc] type 00 class 0x088000=0A=
[    1.464190] pci 0000:ff:14.5: [8086:6fbd] type 00 class 0x088000=0A=
[    1.464262] pci 0000:ff:14.6: [8086:6fbe] type 00 class 0x088000=0A=
[    1.464334] pci 0000:ff:14.7: [8086:6fbf] type 00 class 0x088000=0A=
[    1.464409] pci 0000:ff:15.0: [8086:6fb4] type 00 class 0x088000=0A=
[    1.464492] pci 0000:ff:15.1: [8086:6fb5] type 00 class 0x088000=0A=
[    1.464575] pci 0000:ff:15.2: [8086:6fb6] type 00 class 0x088000=0A=
[    1.464658] pci 0000:ff:15.3: [8086:6fb7] type 00 class 0x088000=0A=
[    1.464744] pci 0000:ff:16.0: [8086:6f68] type 00 class 0x088000=0A=
[    1.464826] pci 0000:ff:16.6: [8086:6f6e] type 00 class 0x088000=0A=
[    1.464899] pci 0000:ff:16.7: [8086:6f6f] type 00 class 0x088000=0A=
[    1.464972] pci 0000:ff:17.0: [8086:6fd0] type 00 class 0x088000=0A=
[    1.465053] pci 0000:ff:17.4: [8086:6fb8] type 00 class 0x088000=0A=
[    1.465128] pci 0000:ff:17.5: [8086:6fb9] type 00 class 0x088000=0A=
[    1.465203] pci 0000:ff:17.6: [8086:6fba] type 00 class 0x088000=0A=
[    1.465275] pci 0000:ff:17.7: [8086:6fbb] type 00 class 0x088000=0A=
[    1.465355] pci 0000:ff:1e.0: [8086:6f98] type 00 class 0x088000=0A=
[    1.465427] pci 0000:ff:1e.1: [8086:6f99] type 00 class 0x088000=0A=
[    1.465498] pci 0000:ff:1e.2: [8086:6f9a] type 00 class 0x088000=0A=
[    1.465569] pci 0000:ff:1e.3: [8086:6fc0] type 00 class 0x088000=0A=
[    1.465577] pci 0000:ff:1e.3: [Firmware Bug]: reg 0x10: invalid BAR =
(can't size)=0A=
[    1.473018] pci 0000:ff:1e.4: [8086:6f9c] type 00 class 0x088000=0A=
[    1.473069] pci 0000:ff:1f.0: [8086:6f88] type 00 class 0x088000=0A=
[    1.473118] pci 0000:ff:1f.2: [8086:6f8a] type 00 class 0x088000=0A=
[    1.473224] ACPI: PCI Root Bridge [UNC0] (domain 0000 [bus 7f])=0A=
[    1.479145] acpi PNP0A03:03: _OSC: OS supports [ExtendedConfig ASPM =
ClockPM Segments MSI]=0A=
[    1.487799] acpi PNP0A03:03: _OSC: platform does not support [AER]=0A=
[    1.494769] acpi PNP0A03:03: _OSC: OS now controls [PCIeHotplug PME =
PCIeCapability]=0A=
[    1.502423] acpi PNP0A03:03: FADT indicates ASPM is unsupported, =
using BIOS configuration=0A=
[    1.510632] PCI host bridge to bus 0000:7f=0A=
[    1.514730] pci_bus 0000:7f: root bus resource [bus 7f]=0A=
[    1.519963] pci 0000:7f:08.0: [8086:6f80] type 00 class 0x088000=0A=
[    1.520013] pci 0000:7f:08.2: [8086:6f32] type 00 class 0x110100=0A=
[    1.520062] pci 0000:7f:08.3: [8086:6f83] type 00 class 0x088000=0A=
[    1.520116] pci 0000:7f:09.0: [8086:6f90] type 00 class 0x088000=0A=
[    1.520162] pci 0000:7f:09.2: [8086:6f33] type 00 class 0x110100=0A=
[    1.520210] pci 0000:7f:09.3: [8086:6f93] type 00 class 0x088000=0A=
[    1.520264] pci 0000:7f:0b.0: [8086:6f81] type 00 class 0x088000=0A=
[    1.520307] pci 0000:7f:0b.1: [8086:6f36] type 00 class 0x110100=0A=
[    1.520350] pci 0000:7f:0b.2: [8086:6f37] type 00 class 0x110100=0A=
[    1.520393] pci 0000:7f:0b.3: [8086:6f76] type 00 class 0x088000=0A=
[    1.520437] pci 0000:7f:0c.0: [8086:6fe0] type 00 class 0x088000=0A=
[    1.520480] pci 0000:7f:0c.1: [8086:6fe1] type 00 class 0x088000=0A=
[    1.520522] pci 0000:7f:0c.2: [8086:6fe2] type 00 class 0x088000=0A=
[    1.520565] pci 0000:7f:0c.3: [8086:6fe3] type 00 class 0x088000=0A=
[    1.520608] pci 0000:7f:0c.4: [8086:6fe4] type 00 class 0x088000=0A=
[    1.520651] pci 0000:7f:0c.5: [8086:6fe5] type 00 class 0x088000=0A=
[    1.520693] pci 0000:7f:0c.6: [8086:6fe6] type 00 class 0x088000=0A=
[    1.520736] pci 0000:7f:0c.7: [8086:6fe7] type 00 class 0x088000=0A=
[    1.520780] pci 0000:7f:0f.0: [8086:6ff8] type 00 class 0x088000=0A=
[    1.520822] pci 0000:7f:0f.1: [8086:6ff9] type 00 class 0x088000=0A=
[    1.520866] pci 0000:7f:0f.4: [8086:6ffc] type 00 class 0x088000=0A=
[    1.520909] pci 0000:7f:0f.5: [8086:6ffd] type 00 class 0x088000=0A=
[    1.520952] pci 0000:7f:0f.6: [8086:6ffe] type 00 class 0x088000=0A=
[    1.520997] pci 0000:7f:10.0: [8086:6f1d] type 00 class 0x088000=0A=
[    1.521040] pci 0000:7f:10.1: [8086:6f34] type 00 class 0x110100=0A=
[    1.521085] pci 0000:7f:10.5: [8086:6f1e] type 00 class 0x088000=0A=
[    1.521129] pci 0000:7f:10.6: [8086:6f7d] type 00 class 0x110100=0A=
[    1.521171] pci 0000:7f:10.7: [8086:6f1f] type 00 class 0x088000=0A=
[    1.521215] pci 0000:7f:12.0: [8086:6fa0] type 00 class 0x088000=0A=
[    1.521222] pci 0000:7f:12.0: reg 0x14: [mem 0x00000000-0x0000000f]=0A=
[    1.521226] pci 0000:7f:12.0: reg 0x18: [mem 0x00000000-0x0000003f]=0A=
[    1.521230] pci 0000:7f:12.0: reg 0x1c: [mem 0x00000000-0x0000000f]=0A=
[    1.521234] pci 0000:7f:12.0: reg 0x20: [mem 0x00000000-0x0000003f]=0A=
[    1.521237] pci 0000:7f:12.0: reg 0x24: [mem 0x00000000-0x0000000f]=0A=
[    1.521268] pci 0000:7f:12.1: [8086:6f30] type 00 class 0x110100=0A=
[    1.521320] pci 0000:7f:13.0: [8086:6fa8] type 00 class 0x088000=0A=
[    1.521399] pci 0000:7f:13.1: [8086:6f71] type 00 class 0x088000=0A=
[    1.521476] pci 0000:7f:13.2: [8086:6faa] type 00 class 0x088000=0A=
[    1.521554] pci 0000:7f:13.3: [8086:6fab] type 00 class 0x088000=0A=
[    1.521633] pci 0000:7f:13.4: [8086:6fac] type 00 class 0x088000=0A=
[    1.521711] pci 0000:7f:13.5: [8086:6fad] type 00 class 0x088000=0A=
[    1.521791] pci 0000:7f:13.6: [8086:6fae] type 00 class 0x088000=0A=
[    1.521861] pci 0000:7f:13.7: [8086:6faf] type 00 class 0x088000=0A=
[    1.521933] pci 0000:7f:14.0: [8086:6fb0] type 00 class 0x088000=0A=
[    1.522014] pci 0000:7f:14.1: [8086:6fb1] type 00 class 0x088000=0A=
[    1.522093] pci 0000:7f:14.2: [8086:6fb2] type 00 class 0x088000=0A=
[    1.522170] pci 0000:7f:14.3: [8086:6fb3] type 00 class 0x088000=0A=
[    1.522246] pci 0000:7f:14.4: [8086:6fbc] type 00 class 0x088000=0A=
[    1.522317] pci 0000:7f:14.5: [8086:6fbd] type 00 class 0x088000=0A=
[    1.522386] pci 0000:7f:14.6: [8086:6fbe] type 00 class 0x088000=0A=
[    1.522456] pci 0000:7f:14.7: [8086:6fbf] type 00 class 0x088000=0A=
[    1.522528] pci 0000:7f:15.0: [8086:6fb4] type 00 class 0x088000=0A=
[    1.522609] pci 0000:7f:15.1: [8086:6fb5] type 00 class 0x088000=0A=
[    1.522688] pci 0000:7f:15.2: [8086:6fb6] type 00 class 0x088000=0A=
[    1.522766] pci 0000:7f:15.3: [8086:6fb7] type 00 class 0x088000=0A=
[    1.522848] pci 0000:7f:16.0: [8086:6f68] type 00 class 0x088000=0A=
[    1.522927] pci 0000:7f:16.6: [8086:6f6e] type 00 class 0x088000=0A=
[    1.522997] pci 0000:7f:16.7: [8086:6f6f] type 00 class 0x088000=0A=
[    1.523069] pci 0000:7f:17.0: [8086:6fd0] type 00 class 0x088000=0A=
[    1.523146] pci 0000:7f:17.4: [8086:6fb8] type 00 class 0x088000=0A=
[    1.523219] pci 0000:7f:17.5: [8086:6fb9] type 00 class 0x088000=0A=
[    1.523290] pci 0000:7f:17.6: [8086:6fba] type 00 class 0x088000=0A=
[    1.523360] pci 0000:7f:17.7: [8086:6fbb] type 00 class 0x088000=0A=
[    1.523435] pci 0000:7f:1e.0: [8086:6f98] type 00 class 0x088000=0A=
[    1.523504] pci 0000:7f:1e.1: [8086:6f99] type 00 class 0x088000=0A=
[    1.523573] pci 0000:7f:1e.2: [8086:6f9a] type 00 class 0x088000=0A=
[    1.523641] pci 0000:7f:1e.3: [8086:6fc0] type 00 class 0x088000=0A=
[    1.523649] pci 0000:7f:1e.3: [Firmware Bug]: reg 0x10: invalid BAR =
(can't size)=0A=
[    1.531085] pci 0000:7f:1e.4: [8086:6f9c] type 00 class 0x088000=0A=
[    1.531134] pci 0000:7f:1f.0: [8086:6f88] type 00 class 0x088000=0A=
[    1.531180] pci 0000:7f:1f.2: [8086:6f8a] type 00 class 0x088000=0A=
[    1.537955] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-7e])=0A=
[    1.544134] acpi PNP0A08:00: _OSC: OS supports [ExtendedConfig ASPM =
ClockPM Segments MSI]=0A=
[    1.552665] acpi PNP0A08:00: _OSC: platform does not support [AER]=0A=
[    1.559374] acpi PNP0A08:00: _OSC: OS now controls [PCIeHotplug PME =
PCIeCapability]=0A=
[    1.567031] acpi PNP0A08:00: FADT indicates ASPM is unsupported, =
using BIOS configuration=0A=
[    1.575500] PCI host bridge to bus 0000:00=0A=
[    1.579597] pci_bus 0000:00: root bus resource [bus 00-7e]=0A=
[    1.585081] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7 =
window]=0A=
[    1.591871] pci_bus 0000:00: root bus resource [io  0x1000-0x7fff =
window]=0A=
[    1.598651] pci_bus 0000:00: root bus resource [mem =
0x000a0000-0x000bffff window]=0A=
[    1.606128] pci_bus 0000:00: root bus resource [mem =
0xfedb0000-0xfedb000f window]=0A=
[    1.613606] pci_bus 0000:00: root bus resource [mem =
0xfedc0000-0xfedc000f window]=0A=
[    1.621083] pci_bus 0000:00: root bus resource [mem =
0x90000000-0xc7ffbfff window]=0A=
[    1.628566] pci 0000:00:00.0: [8086:6f00] type 00 class 0x060000=0A=
[    1.628693] pci 0000:00:01.0: [8086:6f02] type 01 class 0x060400=0A=
[    1.628735] pci 0000:00:01.0: PME# supported from D0 D3hot D3cold=0A=
[    1.628801] pci 0000:00:01.0: System wakeup disabled by ACPI=0A=
[    1.634490] pci 0000:00:03.0: [8086:6f08] type 01 class 0x060400=0A=
[    1.634531] pci 0000:00:03.0: PME# supported from D0 D3hot D3cold=0A=
[    1.634598] pci 0000:00:03.0: System wakeup disabled by ACPI=0A=
[    1.640291] pci 0000:00:03.2: [8086:6f0a] type 01 class 0x060400=0A=
[    1.640332] pci 0000:00:03.2: PME# supported from D0 D3hot D3cold=0A=
[    1.640397] pci 0000:00:03.2: System wakeup disabled by ACPI=0A=
[    1.646086] pci 0000:00:04.0: [8086:6f20] type 00 class 0x088000=0A=
[    1.646102] pci 0000:00:04.0: reg 0x10: [mem 0xc732c000-0xc732ffff =
64bit]=0A=
[    1.646216] pci 0000:00:04.1: [8086:6f21] type 00 class 0x088000=0A=
[    1.646231] pci 0000:00:04.1: reg 0x10: [mem 0xc7328000-0xc732bfff =
64bit]=0A=
[    1.646345] pci 0000:00:04.2: [8086:6f22] type 00 class 0x088000=0A=
[    1.646359] pci 0000:00:04.2: reg 0x10: [mem 0xc7324000-0xc7327fff =
64bit]=0A=
[    1.646475] pci 0000:00:04.3: [8086:6f23] type 00 class 0x088000=0A=
[    1.646489] pci 0000:00:04.3: reg 0x10: [mem 0xc7320000-0xc7323fff =
64bit]=0A=
[    1.646602] pci 0000:00:04.4: [8086:6f24] type 00 class 0x088000=0A=
[    1.646616] pci 0000:00:04.4: reg 0x10: [mem 0xc731c000-0xc731ffff =
64bit]=0A=
[    1.646729] pci 0000:00:04.5: [8086:6f25] type 00 class 0x088000=0A=
[    1.646743] pci 0000:00:04.5: reg 0x10: [mem 0xc7318000-0xc731bfff =
64bit]=0A=
[    1.646856] pci 0000:00:04.6: [8086:6f26] type 00 class 0x088000=0A=
[    1.646870] pci 0000:00:04.6: reg 0x10: [mem 0xc7314000-0xc7317fff =
64bit]=0A=
[    1.646983] pci 0000:00:04.7: [8086:6f27] type 00 class 0x088000=0A=
[    1.646997] pci 0000:00:04.7: reg 0x10: [mem 0xc7310000-0xc7313fff =
64bit]=0A=
[    1.647109] pci 0000:00:05.0: [8086:6f28] type 00 class 0x088000=0A=
[    1.647221] pci 0000:00:05.1: [8086:6f29] type 00 class 0x088000=0A=
[    1.647343] pci 0000:00:05.2: [8086:6f2a] type 00 class 0x088000=0A=
[    1.647454] pci 0000:00:05.4: [8086:6f2c] type 00 class 0x080020=0A=
[    1.647465] pci 0000:00:05.4: reg 0x10: [mem 0xc7339000-0xc7339fff]=0A=
[    1.647591] pci 0000:00:11.0: [8086:8d7c] type 00 class 0xff0000=0A=
[    1.647774] pci 0000:00:11.4: [8086:8d62] type 00 class 0x010601=0A=
[    1.647799] pci 0000:00:11.4: reg 0x10: [io  0x7110-0x7117]=0A=
[    1.647807] pci 0000:00:11.4: reg 0x14: [io  0x7100-0x7103]=0A=
[    1.647816] pci 0000:00:11.4: reg 0x18: [io  0x70f0-0x70f7]=0A=
[    1.647824] pci 0000:00:11.4: reg 0x1c: [io  0x70e0-0x70e3]=0A=
[    1.647832] pci 0000:00:11.4: reg 0x20: [io  0x7020-0x703f]=0A=
[    1.647841] pci 0000:00:11.4: reg 0x24: [mem 0xc7338000-0xc73387ff]=0A=
[    1.647868] pci 0000:00:11.4: PME# supported from D3hot=0A=
[    1.647968] pci 0000:00:14.0: [8086:8d31] type 00 class 0x0c0330=0A=
[    1.647994] pci 0000:00:14.0: reg 0x10: [mem 0xc7300000-0xc730ffff =
64bit]=0A=
[    1.648041] pci 0000:00:14.0: PME# supported from D3hot D3cold=0A=
[    1.648136] pci 0000:00:16.0: [8086:8d3a] type 00 class 0x078000=0A=
[    1.648162] pci 0000:00:16.0: reg 0x10: [mem 0xc7337000-0xc733700f =
64bit]=0A=
[    1.648210] pci 0000:00:16.0: PME# supported from D0 D3hot D3cold=0A=
[    1.648303] pci 0000:00:16.1: [8086:8d3b] type 00 class 0x078000=0A=
[    1.648329] pci 0000:00:16.1: reg 0x10: [mem 0xc7336000-0xc733600f =
64bit]=0A=
[    1.648377] pci 0000:00:16.1: PME# supported from D0 D3hot D3cold=0A=
[    1.648482] pci 0000:00:1a.0: [8086:8d2d] type 00 class 0x0c0320=0A=
[    1.648509] pci 0000:00:1a.0: reg 0x10: [mem 0xc7334000-0xc73343ff]=0A=
[    1.648576] pci 0000:00:1a.0: PME# supported from D0 D3hot D3cold=0A=
[    1.648675] pci 0000:00:1c.0: [8086:8d10] type 01 class 0x060400=0A=
[    1.648734] pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold=0A=
[    1.648798] pci 0000:00:1c.0: System wakeup disabled by ACPI=0A=
[    1.654494] pci 0000:00:1c.2: [8086:8d14] type 01 class 0x060400=0A=
[    1.654554] pci 0000:00:1c.2: PME# supported from D0 D3hot D3cold=0A=
[    1.654618] pci 0000:00:1c.2: System wakeup disabled by ACPI=0A=
[    1.660320] pci 0000:00:1d.0: [8086:8d26] type 00 class 0x0c0320=0A=
[    1.660348] pci 0000:00:1d.0: reg 0x10: [mem 0xc7333000-0xc73333ff]=0A=
[    1.660414] pci 0000:00:1d.0: PME# supported from D0 D3hot D3cold=0A=
[    1.660512] pci 0000:00:1f.0: [8086:8d44] type 00 class 0x060100=0A=
[    1.660694] pci 0000:00:1f.2: [8086:8d02] type 00 class 0x010601=0A=
[    1.660716] pci 0000:00:1f.2: reg 0x10: [io  0x7070-0x7077]=0A=
[    1.660723] pci 0000:00:1f.2: reg 0x14: [io  0x7060-0x7063]=0A=
[    1.660730] pci 0000:00:1f.2: reg 0x18: [io  0x7050-0x7057]=0A=
[    1.660737] pci 0000:00:1f.2: reg 0x1c: [io  0x7040-0x7043]=0A=
[    1.660745] pci 0000:00:1f.2: reg 0x20: [io  0x7000-0x701f]=0A=
[    1.660752] pci 0000:00:1f.2: reg 0x24: [mem 0xc7332000-0xc73327ff]=0A=
[    1.660775] pci 0000:00:1f.2: PME# supported from D3hot=0A=
[    1.660866] pci 0000:00:1f.3: [8086:8d22] type 00 class 0x0c0500=0A=
[    1.660882] pci 0000:00:1f.3: reg 0x10: [mem 0xc7331000-0xc73310ff =
64bit]=0A=
[    1.660902] pci 0000:00:1f.3: reg 0x20: [io  0x0580-0x059f]=0A=
[    1.661183] pci 0000:01:00.0: [8086:1521] type 00 class 0x020000=0A=
[    1.661206] pci 0000:01:00.0: reg 0x10: [mem 0xc7220000-0xc723ffff]=0A=
[    1.661220] pci 0000:01:00.0: reg 0x18: [io  0x6020-0x603f]=0A=
[    1.661227] pci 0000:01:00.0: reg 0x1c: [mem 0xc7244000-0xc7247fff]=0A=
[    1.661285] pci 0000:01:00.0: PME# supported from D0 D3hot D3cold=0A=
[    1.661313] pci 0000:01:00.0: reg 0x184: [mem 0x00000000-0x00003fff =
64bit pref]=0A=
[    1.661315] pci 0000:01:00.0: VF(n) BAR0 space: [mem =
0x00000000-0x0001ffff 64bit pref] (contains BAR0 for 8 VFs)=0A=
[    1.671498] pci 0000:01:00.0: reg 0x190: [mem 0x00000000-0x00003fff =
64bit pref]=0A=
[    1.671500] pci 0000:01:00.0: VF(n) BAR3 space: [mem =
0x00000000-0x0001ffff 64bit pref] (contains BAR3 for 8 VFs)=0A=
[    1.681752] pci 0000:01:00.1: [8086:1521] type 00 class 0x020000=0A=
[    1.681774] pci 0000:01:00.1: reg 0x10: [mem 0xc7200000-0xc721ffff]=0A=
[    1.681788] pci 0000:01:00.1: reg 0x18: [io  0x6000-0x601f]=0A=
[    1.681795] pci 0000:01:00.1: reg 0x1c: [mem 0xc7240000-0xc7243fff]=0A=
[    1.681850] pci 0000:01:00.1: PME# supported from D0 D3hot D3cold=0A=
[    1.681874] pci 0000:01:00.1: reg 0x184: [mem 0x00000000-0x00003fff =
64bit pref]=0A=
[    1.681875] pci 0000:01:00.1: VF(n) BAR0 space: [mem =
0x00000000-0x0001ffff 64bit pref] (contains BAR0 for 8 VFs)=0A=
[    1.692053] pci 0000:01:00.1: reg 0x190: [mem 0x00000000-0x00003fff =
64bit pref]=0A=
[    1.692055] pci 0000:01:00.1: VF(n) BAR3 space: [mem =
0x00000000-0x0001ffff 64bit pref] (contains BAR3 for 8 VFs)=0A=
[    1.710252] pci 0000:00:01.0: PCI bridge to [bus 01]=0A=
[    1.715219] pci 0000:00:01.0:   bridge window [io  0x6000-0x6fff]=0A=
[    1.715222] pci 0000:00:01.0:   bridge window [mem =
0xc7200000-0xc72fffff]=0A=
[    1.715380] pci 0000:00:03.0: PCI bridge to [bus 02]=0A=
[    1.720730] pci 0000:03:00.0: [15b3:1003] type 00 class 0x028000=0A=
[    1.721245] pci 0000:03:00.0: reg 0x10: [mem 0xc7100000-0xc71fffff =
64bit]=0A=
[    1.721469] pci 0000:03:00.0: reg 0x18: [mem 0xc5800000-0xc5ffffff =
64bit pref]=0A=
[    1.723351] pci 0000:03:00.0: reg 0x134: [mem 0x00000000-0x007fffff =
64bit pref]=0A=
[    1.723354] pci 0000:03:00.0: VF(n) BAR2 space: [mem =
0x00000000-0x1f7fffff 64bit pref] (contains BAR2 for 63 VFs)=0A=
[    1.745718] pci 0000:00:03.2: PCI bridge to [bus 03]=0A=
[    1.750685] pci 0000:00:03.2:   bridge window [mem =
0xc7100000-0xc71fffff]=0A=
[    1.750689] pci 0000:00:03.2:   bridge window [mem =
0xc5800000-0xc5ffffff 64bit pref]=0A=
[    1.750728] pci 0000:00:1c.0: PCI bridge to [bus 04]=0A=
[    1.755762] pci 0000:05:00.0: [1a03:1150] type 01 class 0x060400=0A=
[    1.755876] pci 0000:05:00.0: supports D1 D2=0A=
[    1.755878] pci 0000:05:00.0: PME# supported from D0 D1 D2 D3hot =
D3cold=0A=
[    1.763723] pci 0000:00:1c.2: PCI bridge to [bus 05-06]=0A=
[    1.768951] pci 0000:00:1c.2:   bridge window [io  0x5000-0x5fff]=0A=
[    1.768954] pci 0000:00:1c.2:   bridge window [mem =
0xc6000000-0xc70fffff]=0A=
[    1.769031] pci 0000:06:00.0: [1a03:2000] type 00 class 0x030000=0A=
[    1.769074] pci 0000:06:00.0: reg 0x10: [mem 0xc6000000-0xc6ffffff]=0A=
[    1.769088] pci 0000:06:00.0: reg 0x14: [mem 0xc7000000-0xc701ffff]=0A=
[    1.769102] pci 0000:06:00.0: reg 0x18: [io  0x5000-0x507f]=0A=
[    1.769183] pci 0000:06:00.0: supports D1 D2=0A=
[    1.769185] pci 0000:06:00.0: PME# supported from D0 D1 D2 D3hot =
D3cold=0A=
[    1.769289] pci 0000:05:00.0: PCI bridge to [bus 06]=0A=
[    1.774264] pci 0000:05:00.0:   bridge window [io  0x5000-0x5fff]=0A=
[    1.774269] pci 0000:05:00.0:   bridge window [mem =
0xc6000000-0xc70fffff]=0A=
[    1.774307] pci_bus 0000:00: on NUMA node 0=0A=
[    1.775101] ACPI: PCI Root Bridge [PCI1] (domain 0000 [bus 80-fe])=0A=
[    1.781287] acpi PNP0A08:01: _OSC: OS supports [ExtendedConfig ASPM =
ClockPM Segments MSI]=0A=
[    1.789814] acpi PNP0A08:01: _OSC: platform does not support [AER]=0A=
[    1.796513] acpi PNP0A08:01: _OSC: OS now controls [PCIeHotplug PME =
PCIeCapability]=0A=
[    1.804164] acpi PNP0A08:01: FADT indicates ASPM is unsupported, =
using BIOS configuration=0A=
[    1.812493] PCI host bridge to bus 0000:80=0A=
[    1.816592] pci_bus 0000:80: root bus resource [bus 80-fe]=0A=
[    1.822074] pci_bus 0000:80: root bus resource [io  0x8000-0xffff =
window]=0A=
[    1.828856] pci_bus 0000:80: root bus resource [mem =
0xc8000000-0xfbffbfff window]=0A=
[    1.836343] pci 0000:80:04.0: [8086:6f20] type 00 class 0x088000=0A=
[    1.836360] pci 0000:80:04.0: reg 0x10: [mem 0xfbf1c000-0xfbf1ffff =
64bit]=0A=
[    1.836456] pci 0000:80:04.1: [8086:6f21] type 00 class 0x088000=0A=
[    1.836472] pci 0000:80:04.1: reg 0x10: [mem 0xfbf18000-0xfbf1bfff =
64bit]=0A=
[    1.836563] pci 0000:80:04.2: [8086:6f22] type 00 class 0x088000=0A=
[    1.836579] pci 0000:80:04.2: reg 0x10: [mem 0xfbf14000-0xfbf17fff =
64bit]=0A=
[    1.836669] pci 0000:80:04.3: [8086:6f23] type 00 class 0x088000=0A=
[    1.836685] pci 0000:80:04.3: reg 0x10: [mem 0xfbf10000-0xfbf13fff =
64bit]=0A=
[    1.836775] pci 0000:80:04.4: [8086:6f24] type 00 class 0x088000=0A=
[    1.836791] pci 0000:80:04.4: reg 0x10: [mem 0xfbf0c000-0xfbf0ffff =
64bit]=0A=
[    1.836881] pci 0000:80:04.5: [8086:6f25] type 00 class 0x088000=0A=
[    1.836897] pci 0000:80:04.5: reg 0x10: [mem 0xfbf08000-0xfbf0bfff =
64bit]=0A=
[    1.836986] pci 0000:80:04.6: [8086:6f26] type 00 class 0x088000=0A=
[    1.837002] pci 0000:80:04.6: reg 0x10: [mem 0xfbf04000-0xfbf07fff =
64bit]=0A=
[    1.837092] pci 0000:80:04.7: [8086:6f27] type 00 class 0x088000=0A=
[    1.837108] pci 0000:80:04.7: reg 0x10: [mem 0xfbf00000-0xfbf03fff =
64bit]=0A=
[    1.837195] pci 0000:80:05.0: [8086:6f28] type 00 class 0x088000=0A=
[    1.837283] pci 0000:80:05.1: [8086:6f29] type 00 class 0x088000=0A=
[    1.837382] pci 0000:80:05.2: [8086:6f2a] type 00 class 0x088000=0A=
[    1.837470] pci 0000:80:05.4: [8086:6f2c] type 00 class 0x080020=0A=
[    1.837482] pci 0000:80:05.4: reg 0x10: [mem 0xfbf20000-0xfbf20fff]=0A=
[    1.837580] pci_bus 0000:80: on NUMA node 1=0A=
[    1.837865] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 10 *11 12 =
14 15)=0A=
[    1.845161] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 *10 11 12 =
14 15)=0A=
[    1.852453] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 *5 6 10 11 12 =
14 15)=0A=
[    1.859557] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 10 *11 12 =
14 15)=0A=
[    1.866659] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 10 11 12 =
14 15) *0, disabled.=0A=
[    1.875117] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 10 11 12 =
14 15) *0, disabled.=0A=
[    1.883572] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 7 10 11 12 =
14 15) *0, disabled.=0A=
[    1.892030] ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 7 10 11 12 =
14 15) *0, disabled.=0A=
[    1.900551] ACPI: Enabled 2 GPEs in block 00 to 3F=0A=
[    1.905812] vgaarb: setting as boot device: PCI:0000:06:00.0=0A=
[    1.911470] vgaarb: device added: =
PCI:0000:06:00.0,decodes=3Dio+mem,owns=3Dio+mem,locks=3Dnone=0A=
[    1.919561] vgaarb: loaded=0A=
[    1.922269] vgaarb: bridge control possible 0000:06:00.0=0A=
[    1.927671] SCSI subsystem initialized=0A=
[    1.931489] libata version 3.00 loaded.=0A=
[    1.931505] ACPI: bus type USB registered=0A=
[    1.935536] usbcore: registered new interface driver usbfs=0A=
[    1.941029] usbcore: registered new interface driver hub=0A=
[    1.946386] usbcore: registered new device driver usb=0A=
[    1.951620] PCI: Using ACPI for IRQ routing=0A=
[    1.960272] PCI: pci_cache_line_size set to 64 bytes=0A=
[    1.960532] e820: reserve RAM buffer [mem 0x0009ac00-0x0009ffff]=0A=
[    1.960534] e820: reserve RAM buffer [mem 0x78f3f000-0x7bffffff]=0A=
[    1.960662] NetLabel: Initializing=0A=
[    1.964067] NetLabel:  domain hash size =3D 128=0A=
[    1.968421] NetLabel:  protocols =3D UNLABELED CIPSOv4=0A=
[    1.973394] NetLabel:  unlabeled traffic allowed by default=0A=
[    1.979033] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0, 0, 0, 0, 0=0A=
[    1.985367] hpet0: 8 comparators, 64-bit 14.318180 MHz counter=0A=
[    1.993265] clocksource: Switched to clocksource hpet=0A=
[    2.007284] AppArmor: AppArmor Filesystem Enabled=0A=
[    2.012045] pnp: PnP ACPI init=0A=
[    2.015451] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)=0A=
[    2.015562] system 00:01: [io  0x0500-0x057f] has been reserved=0A=
[    2.021482] system 00:01: [io  0x0400-0x047f] could not be reserved=0A=
[    2.027752] system 00:01: [io  0x0580-0x059f] has been reserved=0A=
[    2.033675] system 00:01: [io  0x0600-0x061f] has been reserved=0A=
[    2.039598] system 00:01: [io  0x0880-0x0883] has been reserved=0A=
[    2.045514] system 00:01: [io  0x0800-0x081f] has been reserved=0A=
[    2.051439] system 00:01: [mem 0xfed1c000-0xfed3ffff] has been =
reserved=0A=
[    2.058057] system 00:01: [mem 0xfed45000-0xfed8bfff] has been =
reserved=0A=
[    2.064675] system 00:01: [mem 0xff000000-0xffffffff] has been =
reserved=0A=
[    2.071292] system 00:01: [mem 0xfee00000-0xfeefffff] has been =
reserved=0A=
[    2.077910] system 00:01: [mem 0xfed12000-0xfed1200f] has been =
reserved=0A=
[    2.084528] system 00:01: [mem 0xfed12010-0xfed1201f] has been =
reserved=0A=
[    2.091146] system 00:01: [mem 0xfed1b000-0xfed1bfff] has been =
reserved=0A=
[    2.097766] system 00:01: Plug and Play ACPI device, IDs PNP0c02 =
(active)=0A=
[    2.097992] system 00:02: [io  0x0a00-0x0a0f] has been reserved=0A=
[    2.103915] system 00:02: [io  0x0a10-0x0a1f] has been reserved=0A=
[    2.109836] system 00:02: [io  0x0a20-0x0a2f] has been reserved=0A=
[    2.115752] system 00:02: [io  0x0a30-0x0a3f] has been reserved=0A=
[    2.121677] system 00:02: [io  0x0a40-0x0a4f] has been reserved=0A=
[    2.127600] system 00:02: Plug and Play ACPI device, IDs PNP0c02 =
(active)=0A=
[    2.127790] pnp 00:03: [dma 0 disabled]=0A=
[    2.127833] pnp 00:03: Plug and Play ACPI device, IDs PNP0501 (active)=0A=
[    2.128005] pnp 00:04: [dma 0 disabled]=0A=
[    2.128041] pnp 00:04: Plug and Play ACPI device, IDs PNP0501 (active)=0A=
[    2.128748] pnp: PnP ACPI: found 5 devices=0A=
[    2.139008] clocksource: acpi_pm: mask: 0xffffff max_cycles: =
0xffffff, max_idle_ns: 2085701024 ns=0A=
[    2.147896] pci 0000:ff:12.0: BAR 2: no space for [mem size =
0x00000040]=0A=
[    2.154514] pci 0000:ff:12.0: BAR 2: failed to assign [mem size =
0x00000040]=0A=
[    2.161479] pci 0000:ff:12.0: BAR 4: no space for [mem size =
0x00000040]=0A=
[    2.168096] pci 0000:ff:12.0: BAR 4: failed to assign [mem size =
0x00000040]=0A=
[    2.175060] pci 0000:ff:12.0: BAR 1: no space for [mem size =
0x00000010]=0A=
[    2.181670] pci 0000:ff:12.0: BAR 1: failed to assign [mem size =
0x00000010]=0A=
[    2.188627] pci 0000:ff:12.0: BAR 3: no space for [mem size =
0x00000010]=0A=
[    2.195245] pci 0000:ff:12.0: BAR 3: failed to assign [mem size =
0x00000010]=0A=
[    2.202210] pci 0000:ff:12.0: BAR 5: no space for [mem size =
0x00000010]=0A=
[    2.208829] pci 0000:ff:12.0: BAR 5: failed to assign [mem size =
0x00000010]=0A=
[    2.215795] pci_bus 0000:ff: Some PCI device resources are =
unassigned, try booting with pci=3Drealloc=0A=
[    2.224846] pci 0000:7f:12.0: BAR 2: no space for [mem size =
0x00000040]=0A=
[    2.231456] pci 0000:7f:12.0: BAR 2: failed to assign [mem size =
0x00000040]=0A=
[    2.238412] pci 0000:7f:12.0: BAR 4: no space for [mem size =
0x00000040]=0A=
[    2.245031] pci 0000:7f:12.0: BAR 4: failed to assign [mem size =
0x00000040]=0A=
[    2.251996] pci 0000:7f:12.0: BAR 1: no space for [mem size =
0x00000010]=0A=
[    2.258614] pci 0000:7f:12.0: BAR 1: failed to assign [mem size =
0x00000010]=0A=
[    2.265578] pci 0000:7f:12.0: BAR 3: no space for [mem size =
0x00000010]=0A=
[    2.272195] pci 0000:7f:12.0: BAR 3: failed to assign [mem size =
0x00000010]=0A=
[    2.279151] pci 0000:7f:12.0: BAR 5: no space for [mem size =
0x00000010]=0A=
[    2.285762] pci 0000:7f:12.0: BAR 5: failed to assign [mem size =
0x00000010]=0A=
[    2.292728] pci_bus 0000:7f: Some PCI device resources are =
unassigned, try booting with pci=3Drealloc=0A=
[    2.301775] pci_bus 0000:00: max bus depth: 2 pci_try_num: 3=0A=
[    2.301821] pci 0000:00:01.0: BAR 15: assigned [mem =
0x90000000-0x900fffff 64bit pref]=0A=
[    2.309650] pci 0000:00:1c.0: BAR 14: assigned [mem =
0x90100000-0x902fffff]=0A=
[    2.316528] pci 0000:00:1c.0: BAR 15: assigned [mem =
0x90300000-0x904fffff 64bit pref]=0A=
[    2.324359] pci 0000:00:1c.0: BAR 13: assigned [io  0x1000-0x1fff]=0A=
[    2.330544] pci 0000:01:00.0: BAR 7: assigned [mem =
0x90000000-0x9001ffff 64bit pref]=0A=
[    2.338297] pci 0000:01:00.0: BAR 10: assigned [mem =
0x90020000-0x9003ffff 64bit pref]=0A=
[    2.346134] pci 0000:01:00.1: BAR 7: assigned [mem =
0x90040000-0x9005ffff 64bit pref]=0A=
[    2.353881] pci 0000:01:00.1: BAR 10: assigned [mem =
0x90060000-0x9007ffff 64bit pref]=0A=
[    2.361713] pci 0000:00:01.0: PCI bridge to [bus 01]=0A=
[    2.366677] pci 0000:00:01.0:   bridge window [io  0x6000-0x6fff]=0A=
[    2.372776] pci 0000:00:01.0:   bridge window [mem =
0xc7200000-0xc72fffff]=0A=
[    2.379568] pci 0000:00:01.0:   bridge window [mem =
0x90000000-0x900fffff 64bit pref]=0A=
[    2.387314] pci 0000:00:03.0: PCI bridge to [bus 02]=0A=
[    2.392286] pci 0000:03:00.0: BAR 9: no space for [mem size =
0x1f800000 64bit pref]=0A=
[    2.399852] pci 0000:03:00.0: BAR 9: failed to assign [mem size =
0x1f800000 64bit pref]=0A=
[    2.407764] pci 0000:00:03.2: PCI bridge to [bus 03]=0A=
[    2.412734] pci 0000:00:03.2:   bridge window [mem =
0xc7100000-0xc71fffff]=0A=
[    2.419527] pci 0000:00:03.2:   bridge window [mem =
0xc5800000-0xc5ffffff 64bit pref]=0A=
[    2.427273] pci 0000:00:1c.0: PCI bridge to [bus 04]=0A=
[    2.432240] pci 0000:00:1c.0:   bridge window [io  0x1000-0x1fff]=0A=
[    2.438339] pci 0000:00:1c.0:   bridge window [mem =
0x90100000-0x902fffff]=0A=
[    2.445131] pci 0000:00:1c.0:   bridge window [mem =
0x90300000-0x904fffff 64bit pref]=0A=
[    2.452878] pci 0000:05:00.0: PCI bridge to [bus 06]=0A=
[    2.457846] pci 0000:05:00.0:   bridge window [io  0x5000-0x5fff]=0A=
[    2.463946] pci 0000:05:00.0:   bridge window [mem =
0xc6000000-0xc70fffff]=0A=
[    2.470742] pci 0000:00:1c.2: PCI bridge to [bus 05-06]=0A=
[    2.475972] pci 0000:00:1c.2:   bridge window [io  0x5000-0x5fff]=0A=
[    2.482071] pci 0000:00:1c.2:   bridge window [mem =
0xc6000000-0xc70fffff]=0A=
[    2.488866] pci_bus 0000:00: No. 2 try to assign unassigned res=0A=
[    2.488868] release child resource [mem 0xc5800000-0xc5ffffff 64bit =
pref]=0A=
[    2.488870] pci 0000:00:03.2: resource 15 [mem 0xc5800000-0xc5ffffff =
64bit pref] released=0A=
[    2.488871] pci 0000:00:03.2: PCI bridge to [bus 03]=0A=
[    2.493880] pci 0000:00:03.2: BAR 15: assigned [mem =
0x90800000-0xb07fffff 64bit pref]=0A=
[    2.501707] pci 0000:00:01.0: PCI bridge to [bus 01]=0A=
[    2.506677] pci 0000:00:01.0:   bridge window [io  0x6000-0x6fff]=0A=
[    2.512774] pci 0000:00:01.0:   bridge window [mem =
0xc7200000-0xc72fffff]=0A=
[    2.519564] pci 0000:00:01.0:   bridge window [mem =
0x90000000-0x900fffff 64bit pref]=0A=
[    2.527312] pci 0000:00:03.0: PCI bridge to [bus 02]=0A=
[    2.532284] pci 0000:03:00.0: BAR 2: assigned [mem =
0x90800000-0x90ffffff 64bit pref]=0A=
[    2.540169] pci 0000:03:00.0: BAR 9: assigned [mem =
0x91000000-0xb07fffff 64bit pref]=0A=
[    2.548049] pci 0000:00:03.2: PCI bridge to [bus 03]=0A=
[    2.553020] pci 0000:00:03.2:   bridge window [mem =
0xc7100000-0xc71fffff]=0A=
[    2.559812] pci 0000:00:03.2:   bridge window [mem =
0x90800000-0xb07fffff 64bit pref]=0A=
[    2.567556] pci 0000:00:1c.0: PCI bridge to [bus 04]=0A=
[    2.572525] pci 0000:00:1c.0:   bridge window [io  0x1000-0x1fff]=0A=
[    2.578624] pci 0000:00:1c.0:   bridge window [mem =
0x90100000-0x902fffff]=0A=
[    2.585415] pci 0000:00:1c.0:   bridge window [mem =
0x90300000-0x904fffff 64bit pref]=0A=
[    2.593161] pci 0000:05:00.0: PCI bridge to [bus 06]=0A=
[    2.598130] pci 0000:05:00.0:   bridge window [io  0x5000-0x5fff]=0A=
[    2.604230] pci 0000:05:00.0:   bridge window [mem =
0xc6000000-0xc70fffff]=0A=
[    2.611028] pci 0000:00:1c.2: PCI bridge to [bus 05-06]=0A=
[    2.616258] pci 0000:00:1c.2:   bridge window [io  0x5000-0x5fff]=0A=
[    2.622356] pci 0000:00:1c.2:   bridge window [mem =
0xc6000000-0xc70fffff]=0A=
[    2.629150] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7 window]=0A=
[    2.629152] pci_bus 0000:00: resource 5 [io  0x1000-0x7fff window]=0A=
[    2.629154] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff =
window]=0A=
[    2.629156] pci_bus 0000:00: resource 7 [mem 0xfedb0000-0xfedb000f =
window]=0A=
[    2.629157] pci_bus 0000:00: resource 8 [mem 0xfedc0000-0xfedc000f =
window]=0A=
[    2.629159] pci_bus 0000:00: resource 9 [mem 0x90000000-0xc7ffbfff =
window]=0A=
[    2.629160] pci_bus 0000:01: resource 0 [io  0x6000-0x6fff]=0A=
[    2.629162] pci_bus 0000:01: resource 1 [mem 0xc7200000-0xc72fffff]=0A=
[    2.629163] pci_bus 0000:01: resource 2 [mem 0x90000000-0x900fffff =
64bit pref]=0A=
[    2.629165] pci_bus 0000:03: resource 1 [mem 0xc7100000-0xc71fffff]=0A=
[    2.629167] pci_bus 0000:03: resource 2 [mem 0x90800000-0xb07fffff =
64bit pref]=0A=
[    2.629169] pci_bus 0000:04: resource 0 [io  0x1000-0x1fff]=0A=
[    2.629170] pci_bus 0000:04: resource 1 [mem 0x90100000-0x902fffff]=0A=
[    2.629172] pci_bus 0000:04: resource 2 [mem 0x90300000-0x904fffff =
64bit pref]=0A=
[    2.629173] pci_bus 0000:05: resource 0 [io  0x5000-0x5fff]=0A=
[    2.629175] pci_bus 0000:05: resource 1 [mem 0xc6000000-0xc70fffff]=0A=
[    2.629176] pci_bus 0000:06: resource 0 [io  0x5000-0x5fff]=0A=
[    2.629178] pci_bus 0000:06: resource 1 [mem 0xc6000000-0xc70fffff]=0A=
[    2.629182] pci_bus 0000:80: resource 4 [io  0x8000-0xffff window]=0A=
[    2.629183] pci_bus 0000:80: resource 5 [mem 0xc8000000-0xfbffbfff =
window]=0A=
[    2.629245] NET: Registered protocol family 2=0A=
[    2.634201] TCP established hash table entries: 524288 (order: 10, =
4194304 bytes)=0A=
[    2.642437] TCP bind hash table entries: 65536 (order: 8, 1048576 =
bytes)=0A=
[    2.649309] TCP: Hash tables configured (established 524288 bind =
65536)=0A=
[    2.656060] UDP hash table entries: 32768 (order: 8, 1048576 bytes)=0A=
[    2.662579] UDP-Lite hash table entries: 32768 (order: 8, 1048576 =
bytes)=0A=
[    2.669526] NET: Registered protocol family 1=0A=
[    2.713853] PCI: CLS mismatch (64 !=3D 32), using 64 bytes=0A=
[    2.713868] pci 0000:06:00.0: Video device with shadowed ROM=0A=
[    2.713961] Trying to unpack rootfs image as initramfs...=0A=
[    4.970326] Freeing initrd memory: 128252K (ffff880071200000 - =
ffff880078f3f000)=0A=
[    4.977843] PCI-DMA: Using software bounce buffering for IO (SWIOTLB)=0A=
[    4.984282] software IO TLB [mem 0x6d200000-0x71200000] (64MB) mapped =
at [ffff88006d200000-ffff8800711fffff]=0A=
[    4.994208] Intel CQM monitoring enabled=0A=
[    4.998247] microcode: CPU0 sig=3D0x406f1, pf=3D0x1, =
revision=3D0xb000010=0A=
[    5.004518] microcode: CPU1 sig=3D0x406f1, pf=3D0x1, =
revision=3D0xb000010=0A=
[    5.010788] microcode: CPU2 sig=3D0x406f1, pf=3D0x1, =
revision=3D0xb000010=0A=
[    5.017060] microcode: CPU3 sig=3D0x406f1, pf=3D0x1, =
revision=3D0xb000010=0A=
[    5.023330] microcode: CPU4 sig=3D0x406f1, pf=3D0x1, =
revision=3D0xb000010=0A=
[    5.029600] microcode: CPU5 sig=3D0x406f1, pf=3D0x1, =
revision=3D0xb000010=0A=
[    5.035872] microcode: CPU6 sig=3D0x406f1, pf=3D0x1, =
revision=3D0xb000010=0A=
[    5.042142] microcode: CPU7 sig=3D0x406f1, pf=3D0x1, =
revision=3D0xb000010=0A=
[    5.048413] microcode: CPU8 sig=3D0x406f1, pf=3D0x1, =
revision=3D0xb000010=0A=
[    5.054685] microcode: CPU9 sig=3D0x406f1, pf=3D0x1, =
revision=3D0xb000010=0A=
[    5.060953] microcode: CPU10 sig=3D0x406f1, pf=3D0x1, =
revision=3D0xb000010=0A=
[    5.067316] microcode: CPU11 sig=3D0x406f1, pf=3D0x1, =
revision=3D0xb000010=0A=
[    5.073672] microcode: CPU12 sig=3D0x406f1, pf=3D0x1, =
revision=3D0xb000010=0A=
[    5.080028] microcode: CPU13 sig=3D0x406f1, pf=3D0x1, =
revision=3D0xb000010=0A=
[    5.086388] microcode: CPU14 sig=3D0x406f1, pf=3D0x1, =
revision=3D0xb000010=0A=
[    5.092743] microcode: CPU15 sig=3D0x406f1, pf=3D0x1, =
revision=3D0xb000010=0A=
[    5.099151] microcode: Microcode Update Driver: v2.00 =
<tigran@aivazian.fsnet.co.uk>, Peter Oruba=0A=
[    5.107962] Scanning for low memory corruption every 60 seconds=0A=
[    5.114318] futex hash table entries: 4096 (order: 6, 262144 bytes)=0A=
[    5.120964] Initialise system trusted keyring=0A=
[    5.125474] HugeTLB registered 1 GB page size, pre-allocated 0 pages=0A=
[    5.131826] HugeTLB registered 2 MB page size, pre-allocated 0 pages=0A=
[    5.139826] zbud: loaded=0A=
[    5.142593] VFS: Disk quotas dquot_6.6.0=0A=
[    5.146562] VFS: Dquot-cache hash table entries: 512 (order 0, 4096 =
bytes)=0A=
[    5.154010] fuse init (API version 7.23)=0A=
[    5.158018] SGI XFS with ACLs, security attributes, realtime, no =
debug enabled=0A=
[    5.165743] Key type big_key registered=0A=
[    5.170282] Key type asymmetric registered=0A=
[    5.174381] Asymmetric key parser 'x509' registered=0A=
[    5.179302] Block layer SCSI generic (bsg) driver version 0.4 loaded =
(major 251)=0A=
[    5.186770] io scheduler noop registered=0A=
[    5.190695] io scheduler deadline registered (default)=0A=
[    5.195845] io scheduler cfq registered=0A=
[    5.201566] pcieport 0000:00:01.0: Signaling PME through PCIe PME =
interrupt=0A=
[    5.208537] pci 0000:01:00.0: Signaling PME through PCIe PME interrupt=0A=
[    5.215065] pci 0000:01:00.1: Signaling PME through PCIe PME interrupt=0A=
[    5.221596] pcie_pme 0000:00:01.0:pcie01: service driver pcie_pme =
loaded=0A=
[    5.221615] pcieport 0000:00:03.0: Signaling PME through PCIe PME =
interrupt=0A=
[    5.228578] pcie_pme 0000:00:03.0:pcie01: service driver pcie_pme =
loaded=0A=
[    5.228597] pcieport 0000:00:03.2: Signaling PME through PCIe PME =
interrupt=0A=
[    5.235561] pci 0000:03:00.0: Signaling PME through PCIe PME interrupt=0A=
[    5.242093] pcie_pme 0000:00:03.2:pcie01: service driver pcie_pme =
loaded=0A=
[    5.242112] pcieport 0000:00:1c.0: Signaling PME through PCIe PME =
interrupt=0A=
[    5.249076] pcie_pme 0000:00:1c.0:pcie01: service driver pcie_pme =
loaded=0A=
[    5.249097] pcieport 0000:00:1c.2: Signaling PME through PCIe PME =
interrupt=0A=
[    5.256055] pci 0000:05:00.0: Signaling PME through PCIe PME interrupt=0A=
[    5.262593] pci 0000:06:00.0: Signaling PME through PCIe PME interrupt=0A=
[    5.269120] pcie_pme 0000:00:1c.2:pcie01: service driver pcie_pme =
loaded=0A=
[    5.269127] pci_hotplug: PCI Hot Plug PCI Core version: 0.5=0A=
[    5.274713] pciehp 0000:00:1c.0:pcie04: Slot #0 AttnBtn- PwrCtrl- =
MRL- AttnInd- PwrInd- HotPlug+ Surprise+ Interlock- NoCompl+ LLActRep+=0A=
[    5.287015] pciehp 0000:00:1c.0:pcie04: service driver pciehp loaded=0A=
[    5.287020] pciehp: PCI Express Hot Plug Controller Driver version: =
0.4=0A=
[    5.293675] vga16fb: initializing=0A=
[    5.293677] vga16fb: mapped to 0xffff8800000a0000=0A=
[    5.555958] Console: switching to colour frame buffer device 80x30=0A=
[    5.571190] fb0: VGA16 VGA frame buffer device=0A=
[    5.575834] input: Power Button as =
/devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0C:00/input/input0=0A=
[    5.584185] ACPI: Power Button [PWRB]=0A=
[    5.587882] input: Power Button as =
/devices/LNXSYSTM:00/LNXPWRBN:00/input/input1=0A=
[    5.595276] ACPI: Power Button [PWRF]=0A=
[    5.599047] Warning: Processor Platform Limit event detected, but not =
handled.=0A=
[    5.606267] Consider compiling CPUfreq support into your kernel.=0A=
[    5.615140] ERST: Error Record Serialization Table (ERST) support is =
initialized.=0A=
[    5.622632] pstore: Registered erst as persistent store backend=0A=
[    5.628765] GHES: APEI firmware first mode is enabled by APEI bit and =
WHEA _OSC.=0A=
[    5.636289] Serial: 8250/16550 driver, 32 ports, IRQ sharing enabled=0A=
[    5.663140] 00:03: ttyS0 at I/O 0x3f8 (irq =3D 4, base_baud =3D =
115200) is a 16550A=0A=
[    5.690960] 00:04: ttyS1 at I/O 0x2f8 (irq =3D 3, base_baud =3D =
115200) is a 16550A=0A=
[    5.699671] Linux agpgart interface v0.103=0A=
[    5.707433] brd: module loaded=0A=
[    5.712353] loop: module loaded=0A=
[    5.715672] tun: Universal TUN/TAP device driver, 1.6=0A=
[    5.720723] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>=0A=
[    5.727160] xhci_hcd 0000:00:14.0: xHCI Host Controller=0A=
[    5.732395] xhci_hcd 0000:00:14.0: new USB bus registered, assigned =
bus number 1=0A=
[    5.739896] xhci_hcd 0000:00:14.0: hcc params 0x200077c1 hci version =
0x100 quirks 0x00009810=0A=
[    5.748338] xhci_hcd 0000:00:14.0: cache line size of 64 is not =
supported=0A=
[    5.748509] usb usb1: New USB device found, idVendor=3D1d6b, =
idProduct=3D0002=0A=
[    5.755298] usb usb1: New USB device strings: Mfr=3D3, Product=3D2, =
SerialNumber=3D1=0A=
[    5.762519] usb usb1: Product: xHCI Host Controller=0A=
[    5.767396] usb usb1: Manufacturer: Linux 4.3.0-scaleos+ xhci-hcd=0A=
[    5.773493] usb usb1: SerialNumber: 0000:00:14.0=0A=
[    5.778224] hub 1-0:1.0: USB hub found=0A=
[    5.781989] hub 1-0:1.0: 15 ports detected=0A=
[    5.787031] xhci_hcd 0000:00:14.0: xHCI Host Controller=0A=
[    5.792264] xhci_hcd 0000:00:14.0: new USB bus registered, assigned =
bus number 2=0A=
[    5.799709] usb usb2: New USB device found, idVendor=3D1d6b, =
idProduct=3D0003=0A=
[    5.806497] usb usb2: New USB device strings: Mfr=3D3, Product=3D2, =
SerialNumber=3D1=0A=
[    5.813719] usb usb2: Product: xHCI Host Controller=0A=
[    5.818595] usb usb2: Manufacturer: Linux 4.3.0-scaleos+ xhci-hcd=0A=
[    5.824692] usb usb2: SerialNumber: 0000:00:14.0=0A=
[    5.829433] hub 2-0:1.0: USB hub found=0A=
[    5.833195] hub 2-0:1.0: 6 ports detected=0A=
[    5.837728] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver=0A=
[    5.844271] ehci-pci: EHCI PCI platform driver=0A=
[    5.848918] ehci-pci 0000:00:1a.0: EHCI Host Controller=0A=
[    5.854153] ehci-pci 0000:00:1a.0: new USB bus registered, assigned =
bus number 3=0A=
[    5.861553] ehci-pci 0000:00:1a.0: debug port 2=0A=
[    5.869979] ehci-pci 0000:00:1a.0: cache line size of 64 is not =
supported=0A=
[    5.869995] ehci-pci 0000:00:1a.0: irq 18, io mem 0xc7334000=0A=
[    5.884310] ehci-pci 0000:00:1a.0: USB 2.0 started, EHCI 1.00=0A=
[    5.890107] usb usb3: New USB device found, idVendor=3D1d6b, =
idProduct=3D0002=0A=
[    5.896901] usb usb3: New USB device strings: Mfr=3D3, Product=3D2, =
SerialNumber=3D1=0A=
[    5.904123] usb usb3: Product: EHCI Host Controller=0A=
[    5.908998] usb usb3: Manufacturer: Linux 4.3.0-scaleos+ ehci_hcd=0A=
[    5.915096] usb usb3: SerialNumber: 0000:00:1a.0=0A=
[    5.919849] hub 3-0:1.0: USB hub found=0A=
[    5.923611] hub 3-0:1.0: 2 ports detected=0A=
[    5.927931] ehci-pci 0000:00:1d.0: EHCI Host Controller=0A=
[    5.933168] ehci-pci 0000:00:1d.0: new USB bus registered, assigned =
bus number 4=0A=
[    5.940571] ehci-pci 0000:00:1d.0: debug port 2=0A=
[    5.949022] ehci-pci 0000:00:1d.0: cache line size of 64 is not =
supported=0A=
[    5.949026] ehci-pci 0000:00:1d.0: irq 18, io mem 0xc7333000=0A=
[    5.964371] ehci-pci 0000:00:1d.0: USB 2.0 started, EHCI 1.00=0A=
[    5.970155] usb usb4: New USB device found, idVendor=3D1d6b, =
idProduct=3D0002=0A=
[    5.976947] usb usb4: New USB device strings: Mfr=3D3, Product=3D2, =
SerialNumber=3D1=0A=
[    5.984171] usb usb4: Product: EHCI Host Controller=0A=
[    5.989046] usb usb4: Manufacturer: Linux 4.3.0-scaleos+ ehci_hcd=0A=
[    5.992396] tsc: Refined TSC clocksource calibration: 2099.996 MHz=0A=
[    5.992398] clocksource: tsc: mask: 0xffffffffffffffff max_cycles: =
0x1e452ca2c89, max_idle_ns: 440795231168 ns=0A=
[    6.011320] usb usb4: SerialNumber: 0000:00:1d.0=0A=
[    6.016033] hub 4-0:1.0: USB hub found=0A=
[    6.019790] hub 4-0:1.0: 2 ports detected=0A=
[    6.023952] ehci-platform: EHCI generic platform driver=0A=
[    6.029190] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver=0A=
[    6.035376] ohci-pci: OHCI PCI platform driver=0A=
[    6.039845] ohci-platform: OHCI generic platform driver=0A=
[    6.045075] uhci_hcd: USB Universal Host Controller Interface driver=0A=
[    6.051478] i8042: PNP: No PS/2 controller found. Probing ports =
directly.=0A=
[    6.281141] usb 1-14: new high-speed USB device number 2 using =
xhci_hcd=0A=
[    6.336661] usb 4-1: new high-speed USB device number 2 using ehci-pci=0A=
[    6.343206] usb 3-1: new high-speed USB device number 2 using ehci-pci=0A=
[    6.420923] usb 1-14: New USB device found, idVendor=3D0557, =
idProduct=3D7000=0A=
[    6.427708] usb 1-14: New USB device strings: Mfr=3D0, Product=3D0, =
SerialNumber=3D0=0A=
[    6.435114] hub 1-14:1.0: USB hub found=0A=
[    6.439026] hub 1-14:1.0: 4 ports detected=0A=
[    6.505187] usb 4-1: New USB device found, idVendor=3D8087, =
idProduct=3D8002=0A=
[    6.511894] usb 4-1: New USB device strings: Mfr=3D0, Product=3D0, =
SerialNumber=3D0=0A=
[    6.519230] hub 4-1:1.0: USB hub found=0A=
[    6.523080] hub 4-1:1.0: 8 ports detected=0A=
[    6.527205] usb 3-1: New USB device found, idVendor=3D8087, =
idProduct=3D800a=0A=
[    6.533906] usb 3-1: New USB device strings: Mfr=3D0, Product=3D0, =
SerialNumber=3D0=0A=
[    6.541439] hub 3-1:1.0: USB hub found=0A=
[    6.545344] hub 3-1:1.0: 6 ports detected=0A=
[    6.740974] usb 1-14.1: new low-speed USB device number 3 using =
xhci_hcd=0A=
[    6.861261] usb 1-14.1: New USB device found, idVendor=3D0557, =
idProduct=3D2419=0A=
[    6.868228] usb 1-14.1: New USB device strings: Mfr=3D0, Product=3D0, =
SerialNumber=3D0=0A=
[    6.875686] usb 1-14.1: ep 0x81 - rounding interval to 64 =
microframes, ep desc says 80 microframes=0A=
[    6.884650] usb 1-14.1: ep 0x82 - rounding interval to 32 =
microframes, ep desc says 40 microframes=0A=
[    7.087041] clocksource: Switched to clocksource tsc=0A=
[    7.092908] i8042: No controller found=0A=
[    7.096716] mousedev: PS/2 mouse device common for all mice=0A=
[    7.102383] rtc_cmos 00:00: RTC can wake from S4=0A=
[    7.107130] rtc_cmos 00:00: rtc core: registered rtc_cmos as rtc0=0A=
[    7.113256] rtc_cmos 00:00: alarms up to one month, y3k, 114 bytes =
nvram, hpet irqs=0A=
[    7.120919] i2c /dev entries driver=0A=
[    7.124451] device-mapper: uevent: version 1.0.3=0A=
[    7.129140] device-mapper: ioctl: 4.33.0-ioctl (2015-8-18) =
initialised: dm-devel@redhat.com=0A=
[    7.137630] NET: Registered protocol family 17=0A=
[    7.142091] bridge: automatic filtering via arp/ip/ip6tables has been =
deprecated. Update your scripts to load br_netfilter if you need this.=0A=
[    7.154694] Key type dns_resolver registered=0A=
[    7.159609] registered taskstats version 1=0A=
[    7.163727] Loading compiled-in X.509 certificates=0A=
[    7.169340] Loaded X.509 cert 'Build time autogenerated kernel key: =
fcb48df8cc91623a1ff42cbf7c1438fa5c1cc5a5'=0A=
[    7.179277] zswap: loaded using pool lzo/zbud=0A=
[    7.185509] Key type trusted registered=0A=
[    7.192435] Key type encrypted registered=0A=
[    7.196455] AppArmor: AppArmor sha1 policy hashing enabled=0A=
[    7.201943] ima: No TPM chip found, activating TPM-bypass!=0A=
[    7.207455] evm: HMAC attrs: 0x1=0A=
[    7.211542] rtc_cmos 00:00: setting system clock to 2017-03-05 =
22:39:24 UTC (1488753564)=0A=
[    7.219644] BIOS EDD facility v0.16 2004-Jun-25, 0 devices found=0A=
[    7.225652] EDD information not available.=0A=
[   19.287683] Freeing unused kernel memory: 1372K (ffffffff9ad38000 - =
ffffffff9ae8f000)=0A=
[   19.295519] Write protecting the kernel read-only data: 12288k=0A=
[   19.301841] Freeing unused kernel memory: 640K (ffff88001a760000 - =
ffff88001a800000)=0A=
[   19.309971] Freeing unused kernel memory: 656K (ffff88001ab5c000 - =
ffff88001ac00000)=0A=
[   19.329158] systemd[1]: Inserted module 'autofs4'=0A=
[   19.335537] random: systemd urandom read with 9 bits of entropy =
available=0A=
[   19.343983] systemd[1]: systemd 219 running in system mode. (+PAM =
+AUDIT +SELINUX +IMA -APPARMOR +SMACK +SYSVINIT +UTMP +LIBCRYPTSETUP =
+GCRYPT +GNUTLS +ACL +XZ -LZ4 -SECCOMP +BLKID +ELFUTILS +KMOD +IDN)=0A=
[   19.362344] systemd[1]: Detected architecture x86-64.=0A=
[   19.367414] systemd[1]: Running in initial RAM disk.=0A=
[   19.386874] systemd[1]: No hostname configured.=0A=
[   19.391415] systemd[1]: Set hostname to <localhost>.=0A=
[   19.396401] systemd[1]: Initializing machine ID from random generator.=0A=
[   19.434927] systemd[1]: Created slice -.slice.=0A=
[   19.439399] systemd[1]: Starting -.slice.=0A=
[   19.450927] systemd[1]: Listening on Journal Socket.=0A=
[   19.455907] systemd[1]: Starting Journal Socket.=0A=
[   19.470930] systemd[1]: Listening on udev Control Socket.=0A=
[   19.476340] systemd[1]: Starting udev Control Socket.=0A=
[   19.490944] systemd[1]: Reached target Local File Systems.=0A=
[   19.496486] systemd[1]: Starting Local File Systems.=0A=
[   19.510981] systemd[1]: Created slice System Slice.=0A=
[   19.515876] systemd[1]: Starting System Slice.=0A=
[   19.520460] systemd[1]: Started Load Kernel Modules.=0A=
[   19.525868] systemd[1]: Starting Create list of required static =
device nodes for the current kernel...=0A=
[   19.547070] systemd[1]: Started dracut ask for additional cmdline =
parameters.=0A=
[   19.554646] systemd[1]: Starting dracut cmdline hook...=0A=
[   19.567069] systemd[1]: Started Dispatch Password Requests to Console =
Directory Watch.=0A=
[   19.575002] systemd[1]: Starting Dispatch Password Requests to =
Console Directory Watch.=0A=
[   19.595033] systemd[1]: Reached target Swap.=0A=
[   19.599322] systemd[1]: Starting Swap.=0A=
[   19.615030] systemd[1]: Reached target Paths.=0A=
[   19.619396] systemd[1]: Starting Paths.=0A=
[   19.631042] systemd[1]: Reached target Slices.=0A=
[   19.635492] systemd[1]: Starting Slices.=0A=
[   19.651091] systemd[1]: Listening on udev Kernel Socket.=0A=
[   19.656429] systemd[1]: Starting udev Kernel Socket.=0A=
[   19.671088] systemd[1]: Reached target Sockets.=0A=
[   19.675628] systemd[1]: Starting Sockets.=0A=
[   19.680042] systemd[1]: Starting Journal Service...=0A=
[   19.703103] systemd[1]: Reached target Timers.=0A=
[   19.707558] systemd[1]: Starting Timers.=0A=
[   19.711869] systemd[1]: Starting Apply Kernel Variables...=0A=
[   19.735151] systemd[1]: Started Journal Service.=0A=
[   19.855817] RPC: Registered named UNIX socket transport module.=0A=
[   19.861744] RPC: Registered udp transport module.=0A=
[   19.866455] RPC: Registered tcp transport module.=0A=
[   19.871164] RPC: Registered tcp NFSv4.1 backchannel transport module.=0A=
[   20.097414] pps_core: LinuxPPS API ver. 1 registered=0A=
[   20.102392] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 =
Rodolfo Giometti <giometti@linux.it>=0A=
[   20.112047] hidraw: raw HID events driver (C) Jiri Kosina=0A=
[   20.117773] PTP clock support registered=0A=
[   20.117837] ahci 0000:00:11.4: version 3.0=0A=
[   20.118090] ahci 0000:00:11.4: AHCI 0001.0300 32 slots 4 ports 6 Gbps =
0xf impl SATA mode=0A=
[   20.118092] ahci 0000:00:11.4: flags: 64bit ncq pm led clo pio slum =
part ems apst=0A=
[   20.140542] scsi host0: ahci=0A=
[   20.143997] dca service started, version 1.12.1=0A=
[   20.144079] scsi host1: ahci=0A=
[   20.144166] scsi host2: ahci=0A=
[   20.144616] usbcore: registered new interface driver usbhid=0A=
[   20.144616] usbhid: USB HID core driver=0A=
[   20.148251] scsi host3: ahci=0A=
[   20.148322] ata1: SATA max UDMA/133 abar m2048@0xc7338000 port =
0xc7338100 irq 30=0A=
[   20.148324] ata2: SATA max UDMA/133 abar m2048@0xc7338000 port =
0xc7338180 irq 30=0A=
[   20.148326] ata3: SATA max UDMA/133 abar m2048@0xc7338000 port =
0xc7338200 irq 30=0A=
[   20.148328] ata4: SATA max UDMA/133 abar m2048@0xc7338000 port =
0xc7338280 irq 30=0A=
[   20.148720] ahci 0000:00:1f.2: AHCI 0001.0300 32 slots 6 ports 6 Gbps =
0x3f impl SATA mode=0A=
[   20.148722] ahci 0000:00:1f.2: flags: 64bit ncq pm led clo pio slum =
part ems apst=0A=
[   20.181360] usbcore: registered new interface driver usbmouse=0A=
[   20.199929] scsi host4: ahci=0A=
[   20.200009] scsi host5: ahci=0A=
[   20.200090] scsi host6: ahci=0A=
[   20.200176] scsi host7: ahci=0A=
[   20.200257] scsi host8: ahci=0A=
[   20.200338] scsi host9: ahci=0A=
[   20.200378] ata5: SATA max UDMA/133 abar m2048@0xc7332000 port =
0xc7332100 irq 31=0A=
[   20.200379] ata6: SATA max UDMA/133 abar m2048@0xc7332000 port =
0xc7332180 irq 31=0A=
[   20.200382] ata7: SATA max UDMA/133 abar m2048@0xc7332000 port =
0xc7332200 irq 31=0A=
[   20.200385] ata8: SATA max UDMA/133 abar m2048@0xc7332000 port =
0xc7332280 irq 31=0A=
[   20.200386] ata9: SATA max UDMA/133 abar m2048@0xc7332000 port =
0xc7332300 irq 31=0A=
[   20.200388] ata10: SATA max UDMA/133 abar m2048@0xc7332000 port =
0xc7332380 irq 31=0A=
[   20.229200] usbcore: registered new interface driver usbkbd=0A=
[   20.279533] input: HID 0557:2419 as =
/devices/pci0000:00/0000:00:14.0/usb1/1-14/1-14.1/1-14.1:1.0/0003:0557:24=
19.0001/input/input2=0A=
[   20.323429] igb: Intel(R) Gigabit Ethernet Network Driver - version =
5.3.0-k=0A=
[   20.330396] igb: Copyright (c) 2007-2014 Intel Corporation.=0A=
[   20.331638] hid-generic 0003:0557:2419.0001: input,hidraw0: USB HID =
v1.00 Keyboard [HID 0557:2419] on usb-0000:00:14.0-14.1/input0=0A=
[   20.331751] input: HID 0557:2419 as =
/devices/pci0000:00/0000:00:14.0/usb1/1-14/1-14.1/1-14.1:1.1/0003:0557:24=
19.0002/input/input3=0A=
[   20.331829] hid-generic 0003:0557:2419.0002: input,hidraw1: USB HID =
v1.00 Mouse [HID 0557:2419] on usb-0000:00:14.0-14.1/input1=0A=
[   20.425324] igb 0000:01:00.0: added PHC on eth0=0A=
[   20.429869] igb 0000:01:00.0: Intel(R) Gigabit Ethernet Network =
Connection=0A=
[   20.436747] igb 0000:01:00.0: eth0: (PCIe:5.0Gb/s:Width x4) =
0c:c4:7a:80:9d:18=0A=
[   20.443954] igb 0000:01:00.0: eth0: PBA No: 060000-000=0A=
[   20.449095] igb 0000:01:00.0: Using MSI-X interrupts. 8 rx queue(s), =
8 tx queue(s)=0A=
[   20.463666] ata2: SATA link down (SStatus 0 SControl 300)=0A=
[   20.471668] ata1: SATA link down (SStatus 0 SControl 300)=0A=
[   20.477090] ata3: SATA link down (SStatus 0 SControl 300)=0A=
[   20.482513] ata4: SATA link down (SStatus 0 SControl 300)=0A=
[   20.510249] igb 0000:01:00.1: added PHC on eth1=0A=
[   20.514786] igb 0000:01:00.1: Intel(R) Gigabit Ethernet Network =
Connection=0A=
[   20.521665] igb 0000:01:00.1: eth1: (PCIe:5.0Gb/s:Width x4) =
0c:c4:7a:80:9d:19=0A=
[   20.523722] ata9: SATA link down (SStatus 0 SControl 300)=0A=
[   20.527719] ata10: SATA link down (SStatus 0 SControl 300)=0A=
[   20.527739] ata6: SATA link down (SStatus 0 SControl 300)=0A=
[   20.527766] ata5: SATA link up 6.0 Gbps (SStatus 133 SControl 300)=0A=
[   20.527790] ata8: SATA link down (SStatus 0 SControl 300)=0A=
[   20.527819] ata7: SATA link down (SStatus 0 SControl 300)=0A=
[   20.534211] ata5.00: ATA-9: INTEL SSDSC2BB240G6, G2010140, max =
UDMA/133=0A=
[   20.534212] ata5.00: 468862128 sectors, multi 1: LBA48 NCQ (depth =
31/32)=0A=
[   20.551288] ata5.00: configured for UDMA/133=0A=
[   20.551447] scsi 4:0:0:0: Direct-Access     ATA      INTEL SSDSC2BB24 =
0140 PQ: 0 ANSI: 5=0A=
[   20.551642] ata5.00: Enabling discard_zeroes_data=0A=
[   20.551655] sd 4:0:0:0: [sda] 468862128 512-byte logical blocks: (240 =
GB/223 GiB)=0A=
[   20.551656] sd 4:0:0:0: [sda] 4096-byte physical blocks=0A=
[   20.551698] sd 4:0:0:0: Attached scsi generic sg0 type 0=0A=
[   20.551745] sd 4:0:0:0: [sda] Write Protect is off=0A=
[   20.551747] sd 4:0:0:0: [sda] Mode Sense: 00 3a 00 00=0A=
[   20.551770] sd 4:0:0:0: [sda] Write cache: enabled, read cache: =
enabled, doesn't support DPO or FUA=0A=
[   20.551878] ata5.00: Enabling discard_zeroes_data=0A=
[   20.562091]  sda: sda1 sda2=0A=
[   20.562233] ata5.00: Enabling discard_zeroes_data=0A=
[   20.562340] sd 4:0:0:0: [sda] Attached SCSI disk=0A=
[   20.641272] igb 0000:01:00.1: eth1: PBA No: 060000-000=0A=
[   20.646421] igb 0000:01:00.1: Using MSI-X interrupts. 8 rx queue(s), =
8 tx queue(s)=0A=
[   20.655127] igb 0000:01:00.1 eno2: renamed from eth1=0A=
[   20.683901] igb 0000:01:00.0 eno1: renamed from eth0=0A=
[   24.166911] igb 0000:01:00.0 eno1: igb: eno1 NIC Link is Up 1000 Mbps =
Full Duplex, Flow Control: RX=0A=
[   24.233696] device eno1 entered promiscuous mode=0A=
[   24.264330] br1: port 1(eno1) entered forwarding state=0A=
[   24.269478] br1: port 1(eno1) entered forwarding state=0A=
[   29.753513] FS-Cache: Loaded=0A=
[   29.843269] FS-Cache: Netfs 'nfs' registered for caching=0A=
[   30.665521] systemd-journald[280]: Received SIGTERM from PID 1 =
(systemd).=0A=
[   30.827957] ip_tables: (C) 2000-2006 Netfilter Core Team=0A=
[   30.833338] systemd[1]: Inserted module 'ip_tables'=0A=
[   30.898127] random: nonblocking pool is initialized=0A=
[   31.418331] mlx4_core: Mellanox ConnectX core driver v2.2-1 (Feb, =
2014)=0A=
[   31.425747] mlx4_core: Initializing 0000:03:00.0=0A=
[   31.692485] systemd-journald[760]: Received request to flush runtime =
journal from PID 1=0A=
[   39.427095] mlx4_core 0000:03:00.0: Enabling SR-IOV with 4 VFs=0A=
[   39.534667] pci 0000:03:00.1: [15b3:1004] type 00 class 0x028000=0A=
[   39.542408] pci 0000:03:00.1: Max Payload Size set to 256 (was 128, =
max 256)=0A=
[   39.551356] mlx4_core: Initializing 0000:03:00.1=0A=
[   39.556223] mlx4_core 0000:03:00.1: enabling device (0000 -> 0002)=0A=
[   39.563556] mlx4_core 0000:03:00.1: Detected virtual function - =
running in slave mode=0A=
[   39.571441] mlx4_core 0000:03:00.1: PF is not ready - Deferring probe=0A=
[   39.578567] pci 0000:03:00.2: [15b3:1004] type 00 class 0x028000=0A=
[   39.586306] pci 0000:03:00.2: Max Payload Size set to 256 (was 128, =
max 256)=0A=
[   39.595325] mlx4_core: Initializing 0000:03:00.2=0A=
[   39.600012] mlx4_core 0000:03:00.2: enabling device (0000 -> 0002)=0A=
[   39.607194] mlx4_core 0000:03:00.2: Detected virtual function - =
running in slave mode=0A=
[   39.615067] mlx4_core 0000:03:00.2: PF is not ready - Deferring probe=0A=
[   39.622186] pci 0000:03:00.3: [15b3:1004] type 00 class 0x028000=0A=
[   39.629943] pci 0000:03:00.3: Max Payload Size set to 256 (was 128, =
max 256)=0A=
[   39.638838] mlx4_core: Initializing 0000:03:00.3=0A=
[   39.643523] mlx4_core 0000:03:00.3: enabling device (0000 -> 0002)=0A=
[   39.650692] mlx4_core 0000:03:00.3: Detected virtual function - =
running in slave mode=0A=
[   39.658583] mlx4_core 0000:03:00.3: PF is not ready - Deferring probe=0A=
[   39.665679] pci 0000:03:00.4: [15b3:1004] type 00 class 0x028000=0A=
[   39.673426] pci 0000:03:00.4: Max Payload Size set to 256 (was 128, =
max 256)=0A=
[   39.682313] mlx4_core: Initializing 0000:03:00.4=0A=
[   39.686993] mlx4_core 0000:03:00.4: enabling device (0000 -> 0002)=0A=
[   39.694146] mlx4_core 0000:03:00.4: Detected virtual function - =
running in slave mode=0A=
[   39.702027] mlx4_core 0000:03:00.4: PF is not ready - Deferring probe=0A=
[   39.708993] mlx4_core 0000:03:00.0: Running in master mode=0A=
[   39.714557] mlx4_core 0000:03:00.0: PCIe link speed is 8.0GT/s, =
device supports 8.0GT/s=0A=
[   39.722623] mlx4_core 0000:03:00.0: PCIe link width is x8, device =
supports x8=0A=
[   39.801741] mlx4_core: Initializing 0000:03:00.1=0A=
[   39.806397] mlx4_core 0000:03:00.1: enabling device (0000 -> 0002)=0A=
[   39.813534] mlx4_core 0000:03:00.1: Detected virtual function - =
running in slave mode=0A=
[   39.821407] mlx4_core 0000:03:00.1: Sending reset=0A=
[   39.826200] mlx4_core 0000:03:00.0: Received reset from slave:1=0A=
[   39.832157] mlx4_core 0000:03:00.1: Sending vhcr0=0A=
[   39.838124] mlx4_core 0000:03:00.1: HCA minimum page size:512=0A=
[   39.844551] mlx4_core 0000:03:00.1: Timestamping is not supported in =
slave mode=0A=
[   39.940223] mlx4_core: Initializing 0000:03:00.2=0A=
[   39.944881] mlx4_core 0000:03:00.2: enabling device (0000 -> 0002)=0A=
[   39.952019] mlx4_core 0000:03:00.2: Detected virtual function - =
running in slave mode=0A=
[   39.959892] mlx4_core 0000:03:00.2: Sending reset=0A=
[   39.964677] mlx4_core 0000:03:00.0: Received reset from slave:2=0A=
[   39.970884] mlx4_core 0000:03:00.2: Sending vhcr0=0A=
[   39.976829] mlx4_core 0000:03:00.2: HCA minimum page size:512=0A=
[   39.983281] mlx4_core 0000:03:00.2: Timestamping is not supported in =
slave mode=0A=
[   40.065557] mlx4_core: Initializing 0000:03:00.3=0A=
[   40.070213] mlx4_core 0000:03:00.3: enabling device (0000 -> 0002)=0A=
[   40.077352] mlx4_core 0000:03:00.3: Detected virtual function - =
running in slave mode=0A=
[   40.085228] mlx4_core 0000:03:00.3: Sending reset=0A=
[   40.089988] mlx4_core 0000:03:00.0: Received reset from slave:3=0A=
[   40.095995] mlx4_core 0000:03:00.3: Sending vhcr0=0A=
[   40.102006] mlx4_core 0000:03:00.3: HCA minimum page size:512=0A=
[   40.108429] mlx4_core 0000:03:00.3: Timestamping is not supported in =
slave mode=0A=
[   40.205165] mlx4_core: Initializing 0000:03:00.4=0A=
[   40.209819] mlx4_core 0000:03:00.4: enabling device (0000 -> 0002)=0A=
[   40.216956] mlx4_core 0000:03:00.4: Detected virtual function - =
running in slave mode=0A=
[   40.224824] mlx4_core 0000:03:00.4: Sending reset=0A=
[   40.229579] mlx4_core 0000:03:00.0: Received reset from slave:4=0A=
[   40.235537] mlx4_core 0000:03:00.4: Sending vhcr0=0A=
[   40.241507] mlx4_core 0000:03:00.4: HCA minimum page size:512=0A=
[   40.247951] mlx4_core 0000:03:00.4: Timestamping is not supported in =
slave mode=0A=
[   40.469702] mlx4_en: Mellanox ConnectX HCA Ethernet driver v2.2-1 =
(Feb 2014)=0A=
[   40.476957] mlx4_en 0000:03:00.0: registered PHC clock=0A=
[   40.524764] <mlx4_ib> mlx4_ib_add: mlx4_ib: Mellanox ConnectX =
InfiniBand driver v2.2-1 (Feb 2014)=0A=
[   40.533682] <mlx4_ib> check_flow_steering_support: Device managed =
flow steering is unavailable for IB port in multifunction env.=0A=
[   40.545808] <mlx4_ib> mlx4_ib_add: counter index 0 for port 1 =
allocated 0=0A=
[   40.623925] mlx4_core 0000:03:00.0: mlx4_ib: multi-function enabled=0A=
[   40.631343] mlx4_core 0000:03:00.0: mlx4_ib: initializing demux =
service for 128 qp1 clients=0A=
[   40.647828] <mlx4_ib> check_flow_steering_support: Device managed =
flow steering is unavailable for IB port in multifunction env.=0A=
[   40.663343] <mlx4_ib> mlx4_ib_add: counter index 1 for port 1 =
allocated 0=0A=
[   40.726266] mlx4_core 0000:03:00.1: mlx4_ib: multi-function enabled=0A=
[   40.732530] mlx4_core 0000:03:00.1: mlx4_ib: operating in qp1 tunnel =
mode=0A=
[   40.739352] <mlx4_ib> check_flow_steering_support: Device managed =
flow steering is unavailable for IB port in multifunction env.=0A=
[   40.751900] <mlx4_ib> mlx4_ib_add: counter index 2 for port 1 =
allocated 0=0A=
[   40.814660] mlx4_core 0000:03:00.2: mlx4_ib: multi-function enabled=0A=
[   40.820932] mlx4_core 0000:03:00.2: mlx4_ib: operating in qp1 tunnel =
mode=0A=
[   40.827756] <mlx4_ib> check_flow_steering_support: Device managed =
flow steering is unavailable for IB port in multifunction env.=0A=
[   40.840279] <mlx4_ib> mlx4_ib_add: counter index 3 for port 1 =
allocated 0=0A=
[   40.902905] mlx4_core 0000:03:00.3: mlx4_ib: multi-function enabled=0A=
[   40.909173] mlx4_core 0000:03:00.3: mlx4_ib: operating in qp1 tunnel =
mode=0A=
[   40.915994] <mlx4_ib> check_flow_steering_support: Device managed =
flow steering is unavailable for IB port in multifunction env.=0A=
[   40.928478] <mlx4_ib> mlx4_ib_add: counter index 4 for port 1 =
allocated 0=0A=
[   40.990941] mlx4_core 0000:03:00.4: mlx4_ib: multi-function enabled=0A=
[   40.997212] mlx4_core 0000:03:00.4: mlx4_ib: operating in qp1 tunnel =
mode=0A=
[   93.772057] evbug: Connected device: input0 (Power Button at =
PNP0C0C/button/input0)=0A=
[   93.772061] evbug: Connected device: input1 (Power Button at =
LNXPWRBN/button/input0)=0A=
[   93.772063] evbug: Connected device: input2 (HID 0557:2419 at =
usb-0000:00:14.0-14.1/input0)=0A=
[   93.824811] evbug: Connected device: input3 (HID 0557:2419 at =
usb-0000:00:14.0-14.1/input1)=0A=
[   93.833748] ipmi message handler version 39.2=0A=
[   93.852174] input: PC Speaker as /devices/platform/pcspkr/input/input4=0A=
[   93.858810] evbug: Connected device: input4 (PC Speaker at =
isa0061/input0)=0A=
[   93.858903] shpchp: Standard Hot Plug PCI Controller Driver version: =
0.4=0A=
[   93.905437] i801_smbus 0000:00:1f.3: SMBus using PCI interrupt=0A=
[   93.911455] ioatdma: Intel(R) QuickData Technology Driver 4.00=0A=
[   93.917450] EDAC MC: Ver: 3.0.0=0A=
[   93.917777] igb 0000:01:00.0: DCA enabled=0A=
[   93.917794] igb 0000:01:00.1: DCA enabled=0A=
[   93.928762] ipmi_si IPI0001:00: ipmi_si: probing via ACPI=0A=
[   93.934190] ipmi_si IPI0001:00: [io  0x0ca2] regsize 1 spacing 1 irq 0=0A=
[   93.937157] power_meter ACPI000D:00: Found ACPI power meter.=0A=
[   93.937183] power_meter ACPI000D:00: Ignoring unsafe software power =
cap!=0A=
[   93.937372] wmi: Mapper loaded=0A=
[   93.956148] ipmi_si: Adding ACPI-specified kcs state machine=0A=
[   93.961863] IPMI System Interface driver.=0A=
[   93.965968] ipmi_si: probing via SMBIOS=0A=
[   93.969813] ipmi_si: SMBIOS: io 0xca2 regsize 1 spacing 1 irq 0=0A=
[   93.975737] ipmi_si: Adding SMBIOS-specified kcs state machine =
duplicate interface=0A=
[   93.983330] ipmi_si: probing via SPMI=0A=
[   93.986995] ipmi_si: SPMI: io 0xca2 regsize 1 spacing 1 irq 0=0A=
[   93.987075] EDAC sbridge: Seeking for: PCI ID 8086:6fa0=0A=
[   93.987081] EDAC sbridge: Seeking for: PCI ID 8086:6fa0=0A=
[   93.987090] EDAC sbridge: Seeking for: PCI ID 8086:6fa0=0A=
[   93.987102] EDAC sbridge: Seeking for: PCI ID 8086:6ffc=0A=
[   93.987105] EDAC sbridge: Seeking for: PCI ID 8086:6ffc=0A=
[   93.987110] EDAC sbridge: Seeking for: PCI ID 8086:6ffc=0A=
[   93.987115] EDAC sbridge: Seeking for: PCI ID 8086:6ffd=0A=
[   93.987118] EDAC sbridge: Seeking for: PCI ID 8086:6ffd=0A=
[   93.987123] EDAC sbridge: Seeking for: PCI ID 8086:6ffd=0A=
[   93.987128] EDAC sbridge: Seeking for: PCI ID 8086:6f60=0A=
[   93.987136] EDAC sbridge: Seeking for: PCI ID 8086:6fa8=0A=
[   93.987140] EDAC sbridge: Seeking for: PCI ID 8086:6fa8=0A=
[   93.987145] EDAC sbridge: Seeking for: PCI ID 8086:6fa8=0A=
[   93.987149] EDAC sbridge: Seeking for: PCI ID 8086:6f71=0A=
[   93.987153] EDAC sbridge: Seeking for: PCI ID 8086:6f71=0A=
[   93.987158] EDAC sbridge: Seeking for: PCI ID 8086:6f71=0A=
[   93.987162] EDAC sbridge: Seeking for: PCI ID 8086:6faa=0A=
[   93.987166] EDAC sbridge: Seeking for: PCI ID 8086:6faa=0A=
[   93.987170] EDAC sbridge: Seeking for: PCI ID 8086:6faa=0A=
[   93.987175] EDAC sbridge: Seeking for: PCI ID 8086:6fab=0A=
[   93.987178] EDAC sbridge: Seeking for: PCI ID 8086:6fab=0A=
[   93.987183] EDAC sbridge: Seeking for: PCI ID 8086:6fab=0A=
[   93.987187] EDAC sbridge: Seeking for: PCI ID 8086:6fac=0A=
[   93.987191] EDAC sbridge: Seeking for: PCI ID 8086:6fac=0A=
[   93.987196] EDAC sbridge: Seeking for: PCI ID 8086:6fac=0A=
[   93.987200] EDAC sbridge: Seeking for: PCI ID 8086:6fad=0A=
[   93.987204] EDAC sbridge: Seeking for: PCI ID 8086:6fad=0A=
[   93.987208] EDAC sbridge: Seeking for: PCI ID 8086:6fad=0A=
[   93.987213] EDAC sbridge: Seeking for: PCI ID 8086:6faf=0A=
[   93.987216] EDAC sbridge: Seeking for: PCI ID 8086:6faf=0A=
[   93.987221] EDAC sbridge: Seeking for: PCI ID 8086:6faf=0A=
[   93.987225] EDAC sbridge: Seeking for: PCI ID 8086:6f68=0A=
[   93.987229] EDAC sbridge: Seeking for: PCI ID 8086:6f68=0A=
[   93.987235] EDAC sbridge: Seeking for: PCI ID 8086:6f68=0A=
[   93.987238] EDAC sbridge: Seeking for: PCI ID 8086:6f79=0A=
[   93.987247] EDAC sbridge: Seeking for: PCI ID 8086:6f6a=0A=
[   93.987256] EDAC sbridge: Seeking for: PCI ID 8086:6f6b=0A=
[   93.987265] EDAC sbridge: Seeking for: PCI ID 8086:6f6c=0A=
[   93.987274] EDAC sbridge: Seeking for: PCI ID 8086:6f6d=0A=
[   93.987397] EDAC MC0: Giving out device to module sbridge_edac.c =
controller Broadwell Socket#0: DEV 0000:ff:12.0 (POLLED)=0A=
[   93.987498] EDAC MC1: Giving out device to module sbridge_edac.c =
controller Broadwell Socket#1: DEV 0000:7f:12.0 (POLLED)=0A=
[   93.987499] EDAC sbridge:  Ver: 1.1.1=0A=
[   94.018428] ipmi_si: Adding SPMI-specified kcs state machine =
duplicate interface=0A=
[   94.018430] ipmi_si: Trying ACPI-specified kcs state machine at i/o =
address 0xca2, slave address 0x0, irq 0=0A=
[   94.044878] iTCO_vendor_support: vendor-support=3D0=0A=
[   94.082701] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.11=0A=
[   94.088328] iTCO_wdt: Found a Wellsburg TCO device (Version=3D2, =
TCOBASE=3D0x0460)=0A=
[   94.095657] iTCO_wdt: initialized. heartbeat=3D30 sec (nowayout=3D0)=0A=
[   94.161057] ipmi_si IPI0001:00: The BMC does not support clearing the =
recv irq bit, compensating, but the BMC needs to be fixed.=0A=
[   94.515604] AVX2 version of gcm_enc/dec engaged.=0A=
[   94.520229] AES CTR mode by8 optimization enabled=0A=
[   94.665516] ipmi_si IPI0001:00: Found new BMC (man_id: 0x002a7c, =
prod_id: 0x086f, dev_id: 0x20)=0A=
[   94.674229] ipmi_si IPI0001:00: IPMI kcs interface initialized=0A=
[   94.693473] ipmi device interface=0A=
[   94.715807] EXT4-fs (dm-0): mounted filesystem with ordered data =
mode. Opts: errors=3Dremount-ro=0A=
[   94.781884] intel_rapl: Found RAPL domain package=0A=
[   94.787277] intel_rapl: Found RAPL domain dram=0A=
[   94.793068] intel_rapl: DRAM domain energy unit 15300pj=0A=
[   94.798480] intel_rapl: Found RAPL domain package=0A=
[   94.803195] intel_rapl: Found RAPL domain dram=0A=
[   94.807649] intel_rapl: DRAM domain energy unit 15300pj=0A=
[  102.787758] Adjusting tsc more than 11% (9037742 vs 8867974)=0A=
[  226.402613] device veth0 entered promiscuous mode=0A=
[  226.408290] br1: port 2(veth0) entered forwarding state=0A=
[  226.414878] br1: port 2(veth0) entered forwarding state=0A=
[  226.422640] device veth2 entered promiscuous mode=0A=
[  226.427613] br2: port 1(veth2) entered forwarding state=0A=
[  226.434211] br2: port 1(veth2) entered forwarding state=0A=
[  226.506266] EXT4-fs (dm-1): mounted filesystem with ordered data =
mode. Opts: (null)=0A=
[  228.249263] Bridge firewalling registered=0A=
[  228.330164] nf_conntrack version 0.5.0 (65536 buckets, 262144 max)=0A=
[  228.523780] Initializing XFRM netlink socket=0A=
[  228.832010] XFS (dm-5): Mounting V4 Filesystem=0A=
[  228.858373] XFS (dm-5): Ending clean mount=0A=
[  228.906247] XFS (dm-6): Mounting V4 Filesystem=0A=
[  228.932568] XFS (dm-6): Ending clean mount=0A=
[  228.937518] device veth6c8e43c entered promiscuous mode=0A=
[  228.942813] br-702e67e7acc8: port 1(veth6c8e43c) entered forwarding =
state=0A=
[  228.949618] br-702e67e7acc8: port 1(veth6c8e43c) entered forwarding =
state=0A=
[  228.956471] br-702e67e7acc8: port 1(veth6c8e43c) entered disabled =
state=0A=
[  229.008805] XFS (dm-7): Mounting V4 Filesystem=0A=
[  229.031647] XFS (dm-7): Ending clean mount=0A=
[  229.084851] XFS (dm-8): Mounting V4 Filesystem=0A=
[  229.118546] XFS (dm-8): Ending clean mount=0A=
[  229.123601] device veth58a4a63 entered promiscuous mode=0A=
[  229.128891] br-702e67e7acc8: port 2(veth58a4a63) entered forwarding =
state=0A=
[  229.135693] br-702e67e7acc8: port 2(veth58a4a63) entered forwarding =
state=0A=
[  229.142568] br-702e67e7acc8: port 2(veth58a4a63) entered disabled =
state=0A=
[  229.199191] XFS (dm-9): Mounting V4 Filesystem=0A=
[  229.214522] eth0: renamed from vetha4d805a=0A=
[  229.231895] XFS (dm-9): Ending clean mount=0A=
[  229.250471] br-702e67e7acc8: port 1(veth6c8e43c) entered forwarding =
state=0A=
[  229.257272] br-702e67e7acc8: port 1(veth6c8e43c) entered forwarding =
state=0A=
[  229.286597] XFS (dm-10): Mounting V4 Filesystem=0A=
[  229.311533] XFS (dm-10): Ending clean mount=0A=
[  229.401335] XFS (dm-11): Mounting V4 Filesystem=0A=
[  229.414578] eth0: renamed from vethd05d560=0A=
[  229.424218] XFS (dm-11): Ending clean mount=0A=
[  229.458811] br-702e67e7acc8: port 2(veth58a4a63) entered forwarding =
state=0A=
[  229.465625] br-702e67e7acc8: port 2(veth58a4a63) entered forwarding =
state=0A=
[  229.537052] openvswitch: Open vSwitch switching datapath=0A=
[  229.878839] Key type ceph registered=0A=
[  229.882562] libceph: loaded (mon/osd proto 15/24)=0A=
[  229.894239] rbd: loaded (major 251)=0A=
[  229.905054] libceph: client3142149 fsid =
90740e7d-9c29-4f07-b151-295b74a86aef=0A=
[  229.913838] libceph: mon0 10.0.1.1:6789 session established=0A=
[  229.923697] rbd: rbd0: added with size 0x3200000000=0A=
[  229.975629] device ovs-system entered promiscuous mode=0A=
[  230.054116] device br-ex3 entered promiscuous mode=0A=
[  230.058651] EXT4-fs (rbd0): mounted filesystem with ordered data =
mode. Opts: (null)=0A=
[  230.066762] Ebtables v2.0 registered=0A=
[  230.066973] device veth3 entered promiscuous mode=0A=
[  230.074478] device br-ex2 entered promiscuous mode=0A=
[  230.230883] device br-int entered promiscuous mode=0A=
[  230.252956] device vxlan_sys_4789 entered promiscuous mode=0A=
[  230.265250] device br-tun entered promiscuous mode=0A=
[  230.276932] device br-ex entered promiscuous mode=0A=
[  230.281919] device veth1 entered promiscuous mode=0A=
[  231.403201] device virbr0-nic entered promiscuous mode=0A=
[  231.700847] virbr0: port 1(virbr0-nic) entered listening state=0A=
[  231.706702] virbr0: port 1(virbr0-nic) entered listening state=0A=
[  231.787652] virbr0: port 1(virbr0-nic) entered disabled state=0A=
[  233.149342] device qvbc5634aa9-9a entered promiscuous mode=0A=
[  233.179864] device qvoc5634aa9-9a entered promiscuous mode=0A=
[  233.210342] qbrc5634aa9-9a: port 1(qvbc5634aa9-9a) entered forwarding =
state=0A=
[  233.217320] qbrc5634aa9-9a: port 1(qvbc5634aa9-9a) entered forwarding =
state=0A=
[  233.351801] device qvof8e7cb34-2a entered promiscuous mode=0A=
[  233.369695] device qvbf8e7cb34-2a entered promiscuous mode=0A=
[  233.426483] qbrf8e7cb34-2a: port 1(qvbf8e7cb34-2a) entered forwarding =
state=0A=
[  233.433463] qbrf8e7cb34-2a: port 1(qvbf8e7cb34-2a) entered forwarding =
state=0A=
[  233.587606] device qvb2c2e5f89-da entered promiscuous mode=0A=
[  233.621324] device qvo2c2e5f89-da entered promiscuous mode=0A=
[  233.656562] qbr2c2e5f89-da: port 1(qvb2c2e5f89-da) entered forwarding =
state=0A=
[  233.663538] qbr2c2e5f89-da: port 1(qvb2c2e5f89-da) entered forwarding =
state=0A=
[  237.890039] Netfilter messages via NETLINK v0.30.=0A=
[  237.917747] ip_set: protocol 6=0A=
[  244.308493] br-702e67e7acc8: port 1(veth6c8e43c) entered forwarding =
state=0A=
[  244.500711] br-702e67e7acc8: port 2(veth58a4a63) entered forwarding =
state=0A=
[  384.774289] device qvbe4644161-08 entered promiscuous mode=0A=
[  384.799245] device qvoe4644161-08 entered promiscuous mode=0A=
[  384.824170] qbre4644161-08: port 1(qvbe4644161-08) entered forwarding =
state=0A=
[  384.824183] qbre4644161-08: port 1(qvbe4644161-08) entered forwarding =
state=0A=
[  384.940182] device tape4644161-08 entered promiscuous mode=0A=
[  384.972143] qbre4644161-08: port 2(tape4644161-08) entered forwarding =
state=0A=
[  384.972155] qbre4644161-08: port 2(tape4644161-08) entered forwarding =
state=0A=
[  533.445651] perf interrupt took too long (2505 > 2500), lowering =
kernel.perf_event_max_sample_rate to 50000=0A=
[ 1325.913049] libceph: osd3 10.0.1.91:6800 socket closed (con state =
OPEN)=0A=
[ 2226.922267] libceph: osd3 10.0.1.91:6800 socket closed (con state =
OPEN)=0A=
[ 3127.840384] libceph: osd3 10.0.1.91:6800 socket closed (con state =
OPEN)=0A=
[ 4028.765211] libceph: osd3 10.0.1.91:6800 socket closed (con state =
OPEN)=0A=
[ 4068.601460] device-mapper: thin: Deletion of thin device 132 failed.=0A=
[ 4085.616413] XFS (dm-12): Mounting V4 Filesystem=0A=
[ 4085.652532] XFS (dm-12): Ending clean mount=0A=
[ 4085.695930] XFS (dm-12): Unmounting Filesystem=0A=
[ 4085.865147] XFS (dm-12): Mounting V4 Filesystem=0A=
[ 4085.899001] XFS (dm-12): Ending clean mount=0A=
[ 4085.932121] XFS (dm-12): Unmounting Filesystem=0A=
[ 4086.077429] XFS (dm-12): Mounting V4 Filesystem=0A=
[ 4086.093737] XFS (dm-12): Ending clean mount=0A=
[ 4559.379424] qbre4644161-08: port 2(tape4644161-08) entered disabled =
state=0A=
[ 4559.382112] device tape4644161-08 left promiscuous mode=0A=
[ 4559.382114] qbre4644161-08: port 2(tape4644161-08) entered disabled =
state=0A=
[ 4590.718343] XFS (dm-5): Unmounting Filesystem=0A=
[ 4590.759827] device-mapper: ioctl: remove_all left 12 open device(s)=0A=
[ 5167.256345] Process accounting resumed=0A=
[ 5281.350152] device tape4644161-08 entered promiscuous mode=0A=
[ 5281.374114] qbre4644161-08: port 2(tape4644161-08) entered forwarding =
state=0A=
[ 5281.374136] qbre4644161-08: port 2(tape4644161-08) entered forwarding =
state=0A=
[ 6222.336196] libceph: osd3 10.0.1.91:6800 socket closed (con state =
OPEN)=0A=
[ 7123.348004] libceph: osd3 10.0.1.91:6800 socket closed (con state =
OPEN)=0A=
[ 7895.097684] device qvb7d0f18a1-08 entered promiscuous mode=0A=
[ 7895.124131] device qvo7d0f18a1-08 entered promiscuous mode=0A=
[ 7895.151869] qbr7d0f18a1-08: port 1(qvb7d0f18a1-08) entered forwarding =
state=0A=
[ 7895.151882] qbr7d0f18a1-08: port 1(qvb7d0f18a1-08) entered forwarding =
state=0A=
[ 7895.287299] device tap7d0f18a1-08 entered promiscuous mode=0A=
[ 7895.311249] qbr7d0f18a1-08: port 2(tap7d0f18a1-08) entered forwarding =
state=0A=
[ 7895.311260] qbr7d0f18a1-08: port 2(tap7d0f18a1-08) entered forwarding =
state=0A=
[ 8101.925660] qbre4644161-08: port 2(tape4644161-08) entered disabled =
state=0A=
[ 8101.928390] device tape4644161-08 left promiscuous mode=0A=
[ 8101.928395] qbre4644161-08: port 2(tape4644161-08) entered disabled =
state=0A=
[ 8102.365908] device tape4644161-08 entered promiscuous mode=0A=
[ 8102.393895] qbre4644161-08: port 2(tape4644161-08) entered forwarding =
state=0A=
[ 8102.393907] qbre4644161-08: port 2(tape4644161-08) entered forwarding =
state=0A=
[ 8948.101273] ------------[ cut here ]------------=0A=
[ 8948.105897] kernel BUG at fs/userfaultfd.c:269!=0A=
[ 8948.110424] invalid opcode: 0000 [#1] PREEMPT SMP=0A=
[ 8948.115261] Modules linked in: vhost_net vhost macvtap macvlan xt_CT =
xt_mac xt_comment xt_physdev xt_set ip_set_hash_net ip_set nfnetlink =
iptable_raw xt_CHECKSUM iptable_mangle ipt_REJECT nf_reject_ipv4 =
vport_vxlan ebtable_filter ebtables rbd libceph openvswitch xt_nat =
xt_tcpudp ipt_MASQUERADE nf_nat_masquerade_ipv4 xfrm_user xfrm_algo =
iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 xt_addrtype =
iptable_filter xt_conntrack nf_nat nf_conntrack br_netfilter veth =
coretemp intel_rapl iosf_mbi x86_pkg_temp_thermal kvm_intel ipmi_devintf =
kvm crct10dif_pclmul crc32_pclmul dm_thin_pool aesni_intel =
dm_persistent_data aes_x86_64 lrw dm_bio_prison gf128mul dm_bufio =
glue_helper ablk_helper cryptd iTCO_wdt iTCO_vendor_support ib_ipoib =
sb_edac input_leds ipmi_si edac_core ioatdma i2c_i801 led_class shpchp=0A=
[ 8948.187027]  pcspkr lpc_ich wmi joydev 8250_fintek rdma_ucm =
ipmi_msghandler acpi_power_meter evbug ib_ucm ib_uverbs ib_umad rdma_cm =
ib_cm iw_cm mlx4_ib mlx4_en ib_sa ib_mad vxlan ib_core udp_tunnel =
ib_addr mlx4_core ip_tables x_tables nfsv3 nfs_acl nfs lockd grace =
fscache igb i2c_algo_bit hid_generic usbkbd usbmouse dca hwmon usbhid =
ptp ahci hid libahci pps_core sunrpc autofs4=0A=
[ 8948.219866] CPU: 7 PID: 8838 Comm: vhost-8836 Not tainted =
4.3.0-scaleos+ #1=0A=
[ 8948.226819] Hardware name: Supermicro SYS-1028TR-TF/X10DRT-LIBF, BIOS =
2.0 12/17/2015=0A=
[ 8948.234557] task: ffff88104eb0b800 ti: ffff880150bb0000 task.ti: =
ffff880150bb0000=0A=
[ 8948.242034] RIP: 0010:[<ffffffff9a237bbc>]  [<ffffffff9a237bbc>] =
handle_userfault+0x3cc/0x440=0A=
[ 8948.250569] RSP: 0018:ffff880150bb3968  EFLAGS: 00010246=0A=
[ 8948.255878] RAX: 0000000080000000 RBX: ffff88006bf9cbf8 RCX: =
0000000000000200=0A=
[ 8948.263007] RDX: 0000000000000014 RSI: 00007fde5c77f000 RDI: =
ffff88084e156300=0A=
[ 8948.270136] RBP: ffff880150bb3a18 R08: 0000000000000000 R09: =
0000000000000000=0A=
[ 8948.277266] R10: ffff880000000bf8 R11: 0000000000000000 R12: =
ffff88104e5b3fc0=0A=
[ 8948.284395] R13: ffff88084e156300 R14: 00007fde5c77f000 R15: =
ffff8807b963f718=0A=
[ 8948.291526] FS:  0000000000000000(0000) GS:ffff88085fdc0000(0000) =
knlGS:0000000000000000=0A=
[ 8948.299610] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033=0A=
[ 8948.305350] CR2: 00007fde5c77f000 CR3: 000000104e6ff000 CR4: =
00000000003426e0=0A=
[ 8948.312479] DR0: 0000000000000000 DR1: 0000000000000000 DR2: =
0000000000000000=0A=
[ 8948.319610] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: =
0000000000000400=0A=
[ 8948.326739] Stack:=0A=
[ 8948.328750]  ffff880150bb3990 ffffffff9a18f90c 0000000000000000 =
ffff88085fdda588=0A=
[ 8948.336210]  ffff880150bb3b48 ffff880150bb3a70 0000000000000246 =
ffff88104eb0b800=0A=
[ 8948.343669]  0000000000000000 ffff88087fffce08 ffff88104e5b3fc0 =
00007fde00000000=0A=
[ 8948.351128] Call Trace:=0A=
[ 8948.353578]  [<ffffffff9a18f90c>] ? zone_statistics+0x7c/0xa0=0A=
[ 8948.359320]  [<ffffffff9a0a21dd>] ? get_parent_ip+0xd/0x50=0A=
[ 8948.364800]  [<ffffffff9a0a2268>] ? preempt_count_add+0x48/0x90=0A=
[ 8948.370718]  [<ffffffff9a1a1859>] handle_mm_fault+0x1659/0x1820=0A=
[ 8948.376640]  [<ffffffff9a179ee1>] ? __alloc_pages_nodemask+0x181/0x9c0=0A=
[ 8948.383163]  [<ffffffff9a06425f>] __do_page_fault+0x16f/0x490=0A=
[ 8948.388903]  [<ffffffff9a0645a2>] do_page_fault+0x22/0x30=0A=
[ 8948.394298]  [<ffffffff9a759ba8>] page_fault+0x28/0x30=0A=
[ 8948.399434]  [<ffffffff9a43428f>] ? copy_page_from_iter+0x6f/0x3c0=0A=
[ 8948.405608]  [<ffffffff9a433156>] ? copy_from_iter+0x76/0x2d0=0A=
[ 8948.411352]  [<ffffffff9a67b654>] =
skb_copy_datagram_from_iter+0xe4/0x1f0=0A=
[ 8948.418048]  [<ffffffff9a5b15a5>] tun_get_user+0x4b5/0x860=0A=
[ 8948.423530]  [<ffffffff9a5b1996>] tun_sendmsg+0x46/0x70=0A=
[ 8948.428753]  [<ffffffffc06acd52>] handle_tx+0x222/0x480 [vhost_net]=0A=
[ 8948.435020]  [<ffffffffc06acfe5>] handle_tx_kick+0x15/0x20 [vhost_net]=0A=
[ 8948.441544]  [<ffffffffc069efee>] vhost_worker+0xee/0x190 [vhost]=0A=
[ 8948.447632]  [<ffffffffc069ef00>] ? vhost_dev_ioctl+0x370/0x370 =
[vhost]=0A=
[ 8948.454241]  [<ffffffff9a0962d9>] kthread+0xc9/0xe0=0A=
[ 8948.459116]  [<ffffffff9a096210>] ? kthread_create_on_node+0x180/0x180=0A=
[ 8948.465639]  [<ffffffff9a757e4f>] ret_from_fork+0x3f/0x70=0A=
[ 8948.471032]  [<ffffffff9a096210>] ? kthread_create_on_node+0x180/0x180=0A=
[ 8948.477553] Code: 26 ff ff ff 48 8b 3a 48 89 f8 0f 1f 40 00 48 c1 ee =
09 4c 21 c0 81 e6 f8 0f 00 00 48 01 f0 48 83 3c 08 00 0f 84 20 fe ff ff =
eb 94 <0f> 0b 0f 0b f6 c2 08 0f 84 9e fc ff ff 0f 0b 48 8b 80 80 06 00=0A=
[ 8948.497519] RIP  [<ffffffff9a237bbc>] handle_userfault+0x3cc/0x440=0A=
[ 8948.503713]  RSP <ffff880150bb3968>=0A=

------=_NextPart_000_0137_01D2968B.96289BF0--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
