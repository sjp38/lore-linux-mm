Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 26973900086
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 02:57:41 -0400 (EDT)
Received: by qwa26 with SMTP id 26so3455201qwa.14
        for <linux-mm@kvack.org>; Sun, 17 Apr 2011 23:57:39 -0700 (PDT)
MIME-Version: 1.0
Reply-To: sedat.dilek@gmail.com
In-Reply-To: <20110418001333.GA8890@localhost>
References: <20110416132546.765212221@intel.com>
	<BANLkTimY3t6Kc-+=00k3QR+AK2uqJpph4g@mail.gmail.com>
	<20110417014430.GA9419@localhost>
	<BANLkTik+Bcw7uz9aMi6OrAzwg1rJZmJL0Q@mail.gmail.com>
	<20110417041003.GA17032@localhost>
	<20110418001333.GA8890@localhost>
Date: Mon, 18 Apr 2011 08:57:39 +0200
Message-ID: <BANLkTinQoTgQR_hPGo6vEHbS-rGypkAmZw@mail.gmail.com>
Subject: Re: [PATCH 00/12] IO-less dirty throttling v7
From: Sedat Dilek <sedat.dilek@googlemail.com>
Content-Type: multipart/mixed; boundary=001636b14767451d8804a12be8aa
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

--001636b14767451d8804a12be8aa
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Mon, Apr 18, 2011 at 2:13 AM, Wu Fengguang <fengguang.wu@intel.com> wrot=
e:
> Hi Sedat,
>
>> Please revert the last commit. It's not necessary anyway.
>>
>> commit 84a9890ddef487d9c6d70934c0a2addc65923bcf
>> Author: Wu Fengguang <fengguang.wu@intel.com>
>> Date: =C2=A0 Sat Apr 16 18:38:41 2011 -0600
>>
>> =C2=A0 =C2=A0 writeback: scale dirty proportions period with writeout ba=
ndwidth
>>
>> =C2=A0 =C2=A0 CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
>> =C2=A0 =C2=A0 Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
>
> Please do revert that commit, because I found a sleep-inside-spinlock
> bug with it. Here is the fixed one (but you don't have to track this
> optional patch).
>
> Thanks,
> Fengguang
> ---
> Subject: writeback: scale dirty proportions period with writeout bandwidt=
h
> Date: Sat Apr 16 18:38:41 CST 2011
>
> CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
> =C2=A0mm/page-writeback.c | =C2=A0 24 ++++++++++++------------
> =C2=A01 file changed, 12 insertions(+), 12 deletions(-)
>
> --- linux-next.orig/mm/page-writeback.c 2011-04-17 20:52:13.000000000 +08=
00
> +++ linux-next/mm/page-writeback.c =C2=A0 =C2=A0 =C2=A02011-04-18 07:57:0=
1.000000000 +0800
> @@ -121,20 +121,13 @@ static struct prop_descriptor vm_complet
> =C2=A0static struct prop_descriptor vm_dirties;
>
> =C2=A0/*
> - * couple the period to the dirty_ratio:
> + * couple the period to global write throughput:
> =C2=A0*
> - * =C2=A0 period/2 ~ roundup_pow_of_two(dirty limit)
> + * =C2=A0 period/2 ~ roundup_pow_of_two(write IO throughput)
> =C2=A0*/
> =C2=A0static int calc_period_shift(void)
> =C2=A0{
> - =C2=A0 =C2=A0 =C2=A0 unsigned long dirty_total;
> -
> - =C2=A0 =C2=A0 =C2=A0 if (vm_dirty_bytes)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dirty_total =3D vm_dir=
ty_bytes / PAGE_SIZE;
> - =C2=A0 =C2=A0 =C2=A0 else
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dirty_total =3D (vm_di=
rty_ratio * determine_dirtyable_memory()) /
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 100;
> - =C2=A0 =C2=A0 =C2=A0 return 2 + ilog2(dirty_total - 1);
> + =C2=A0 =C2=A0 =C2=A0 return 2 + ilog2(default_backing_dev_info.avg_writ=
e_bandwidth);
> =C2=A0}
>
> =C2=A0/*
> @@ -143,6 +136,13 @@ static int calc_period_shift(void)
> =C2=A0static void update_completion_period(void)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int shift =3D calc_period_shift();
> +
> + =C2=A0 =C2=A0 =C2=A0 if (shift > PROP_MAX_SHIFT)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 shift =3D PROP_MAX_SHI=
FT;
> +
> + =C2=A0 =C2=A0 =C2=A0 if (abs(shift - vm_completions.pg[0].shift) <=3D 1=
)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return;
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0prop_change_shift(&vm_completions, shift);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0prop_change_shift(&vm_dirties, shift);
> =C2=A0}
> @@ -180,7 +180,6 @@ int dirty_ratio_handler(struct ctl_table
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0ret =3D proc_dointvec_minmax(table, write, buf=
fer, lenp, ppos);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (ret =3D=3D 0 && write && vm_dirty_ratio !=
=3D old_ratio) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 update_completion_peri=
od();
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0vm_dirty_bytes =3D=
 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return ret;
> @@ -196,7 +195,6 @@ int dirty_bytes_handler(struct ctl_table
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0ret =3D proc_doulongvec_minmax(table, write, b=
uffer, lenp, ppos);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (ret =3D=3D 0 && write && vm_dirty_bytes !=
=3D old_bytes) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 update_completion_peri=
od();
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0vm_dirty_ratio =3D=
 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return ret;
> @@ -1044,6 +1042,8 @@ snapshot:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0bdi->bw_time_stamp =3D now;
> =C2=A0unlock:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_unlock(&dirty_lock);
> + =C2=A0 =C2=A0 =C2=A0 if (gbdi->bw_time_stamp =3D=3D now)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 update_completion_peri=
od();
> =C2=A0}
>
> =C2=A0static unsigned long max_pause(struct backing_dev_info *bdi,
>

Unfortunately, this "v2" patch still breaks with gcc-4.6 here:

  LD      .tmp_vmlinux1
mm/built-in.o: In function `calc_period_shift.part.10':
page-writeback.c:(.text+0x6458): undefined reference to `____ilog2_NaN'
make[4]: *** [.tmp_vmlinux1] Error 1

My patchset against next-20110415 looks like this:

  (+) OK   writeback-dirty-throttling-v7/writeback-dirty-throttling-v7.patc=
h
  (+) OK   writeback-dirty-throttling-post-v7/0001-writeback-i386-compile-f=
ix.patch
  (+) OK   writeback-dirty-throttling-post-v7/0002-writeback-quick-CONFIG_B=
LK_DEV_THROTTLING-n-compile-.patch
  (+) OK   writeback-dirty-throttling-post-v7/0003-Revert-writeback-scale-d=
irty-proportions-period-with.patch
  (+) OK   writeback-dirty-throttling-v7-fix/writeback-scale-dirty-proporti=
ons-period-with-writeout-bandwidth-v2.patch

Attached are the disasm of mm/page-writeback.o (v2, gcc-4.6) and the
disasm of yesterday's experiments with gcc-4.5.

[ gcc-4.5 ]

00006574 <calc_period_shift>:
    6574:       a1 90 00 00 00          mov    0x90,%eax        6575:
R_386_32  default_backing_dev_info
    6579:       55                      push   %ebp
    657a:       89 e5                   mov    %esp,%ebp
    657c:       e8 02 f8 ff ff          call   5d83 <__ilog2_u32>
    6581:       5d                      pop    %ebp
    6582:       83 c0 02                add    $0x2,%eax
    6585:       c3                      ret

[ gcc-4.6 ]

000008c9 <calc_period_shift.part.10>:
     8c9:       8b 15 90 00 00 00       mov    0x90,%edx        8cb:
R_386_32   default_backing_dev_info
     8cf:       55                      push   %ebp
     8d0:       89 e5                   mov    %esp,%ebp
     8d2:       85 d2                   test   %edx,%edx
     8d4:       0f 88 46 01 00 00       js     a20
<calc_period_shift.part.10+0x157>
     8da:       f7 c2 00 00 00 40       test   $0x40000000,%edx
     8e0:       b8 20 00 00 00          mov    $0x20,%eax
     8e5:       0f 85 3a 01 00 00       jne    a25
<calc_period_shift.part.10+0x15c>
     8eb:       f7 c2 00 00 00 20       test   $0x20000000,%edx
     8f1:       b0 1f                   mov    $0x1f,%al
     8f3:       0f 85 2c 01 00 00       jne    a25
<calc_period_shift.part.10+0x15c>
     8f9:       f7 c2 00 00 00 10       test   $0x10000000,%edx
     8ff:       b0 1e                   mov    $0x1e,%al
     901:       0f 85 1e 01 00 00       jne    a25
<calc_period_shift.part.10+0x15c>
     907:       f7 c2 00 00 00 08       test   $0x8000000,%edx
     90d:       b0 1d                   mov    $0x1d,%al
     90f:       0f 85 10 01 00 00       jne    a25
<calc_period_shift.part.10+0x15c>
     915:       f7 c2 00 00 00 04       test   $0x4000000,%edx
     91b:       b0 1c                   mov    $0x1c,%al
     91d:       0f 85 02 01 00 00       jne    a25
<calc_period_shift.part.10+0x15c>
     923:       f7 c2 00 00 00 02       test   $0x2000000,%edx
     929:       b0 1b                   mov    $0x1b,%al
     92b:       0f 85 f4 00 00 00       jne    a25
<calc_period_shift.part.10+0x15c>
     931:       f7 c2 00 00 00 01       test   $0x1000000,%edx
     937:       b0 1a                   mov    $0x1a,%al
     939:       0f 85 e6 00 00 00       jne    a25
<calc_period_shift.part.10+0x15c>
     93f:       f7 c2 00 00 80 00       test   $0x800000,%edx
     945:       b0 19                   mov    $0x19,%al
     947:       0f 85 d8 00 00 00       jne    a25
<calc_period_shift.part.10+0x15c>
     94d:       f7 c2 00 00 40 00       test   $0x400000,%edx
     953:       b0 18                   mov    $0x18,%al
     955:       0f 85 ca 00 00 00       jne    a25
<calc_period_shift.part.10+0x15c>
     95b:       f7 c2 00 00 20 00       test   $0x200000,%edx
     961:       b0 17                   mov    $0x17,%al
     963:       0f 85 bc 00 00 00       jne    a25
<calc_period_shift.part.10+0x15c>
     969:       f7 c2 00 00 10 00       test   $0x100000,%edx
     96f:       b0 16                   mov    $0x16,%al
     971:       0f 85 ae 00 00 00       jne    a25
<calc_period_shift.part.10+0x15c>
     977:       f7 c2 00 00 08 00       test   $0x80000,%edx
     97d:       b0 15                   mov    $0x15,%al
     97f:       0f 85 a0 00 00 00       jne    a25
<calc_period_shift.part.10+0x15c>
     985:       f7 c2 00 00 04 00       test   $0x40000,%edx
     98b:       b0 14                   mov    $0x14,%al
     98d:       0f 85 92 00 00 00       jne    a25
<calc_period_shift.part.10+0x15c>
     993:       f7 c2 00 00 02 00       test   $0x20000,%edx
     999:       b0 13                   mov    $0x13,%al
     99b:       0f 85 84 00 00 00       jne    a25
<calc_period_shift.part.10+0x15c>
     9a1:       f7 c2 00 00 01 00       test   $0x10000,%edx
     9a7:       b0 12                   mov    $0x12,%al
     9a9:       75 7a                   jne    a25
<calc_period_shift.part.10+0x15c>
     9ab:       f6 c6 80                test   $0x80,%dh
     9ae:       b0 11                   mov    $0x11,%al
     9b0:       75 73                   jne    a25
<calc_period_shift.part.10+0x15c>
     9b2:       f6 c6 40                test   $0x40,%dh
     9b5:       b0 10                   mov    $0x10,%al
     9b7:       75 6c                   jne    a25
<calc_period_shift.part.10+0x15c>
     9b9:       f6 c6 20                test   $0x20,%dh
     9bc:       b0 0f                   mov    $0xf,%al
     9be:       75 65                   jne    a25
<calc_period_shift.part.10+0x15c>
     9c0:       f6 c6 10                test   $0x10,%dh
     9c3:       b0 0e                   mov    $0xe,%al
     9c5:       75 5e                   jne    a25
<calc_period_shift.part.10+0x15c>
     9c7:       f6 c6 08                test   $0x8,%dh
     9ca:       b0 0d                   mov    $0xd,%al
     9cc:       75 57                   jne    a25
<calc_period_shift.part.10+0x15c>
     9ce:       f6 c6 04                test   $0x4,%dh
     9d1:       b0 0c                   mov    $0xc,%al
     9d3:       75 50                   jne    a25
<calc_period_shift.part.10+0x15c>
     9d5:       f6 c6 02                test   $0x2,%dh
     9d8:       b0 0b                   mov    $0xb,%al
     9da:       75 49                   jne    a25
<calc_period_shift.part.10+0x15c>
     9dc:       f6 c6 01                test   $0x1,%dh
     9df:       b0 0a                   mov    $0xa,%al
     9e1:       75 42                   jne    a25
<calc_period_shift.part.10+0x15c>
     9e3:       f6 c2 80                test   $0x80,%dl
     9e6:       b0 09                   mov    $0x9,%al
     9e8:       75 3b                   jne    a25
<calc_period_shift.part.10+0x15c>
     9ea:       f6 c2 40                test   $0x40,%dl
     9ed:       b0 08                   mov    $0x8,%al
     9ef:       75 34                   jne    a25
<calc_period_shift.part.10+0x15c>
     9f1:       f6 c2 20                test   $0x20,%dl
     9f4:       b0 07                   mov    $0x7,%al
     9f6:       75 2d                   jne    a25
<calc_period_shift.part.10+0x15c>
     9f8:       f6 c2 10                test   $0x10,%dl
     9fb:       b0 06                   mov    $0x6,%al
     9fd:       75 26                   jne    a25
<calc_period_shift.part.10+0x15c>
     9ff:       f6 c2 08                test   $0x8,%dl
     a02:       b0 05                   mov    $0x5,%al
     a04:       75 1f                   jne    a25
<calc_period_shift.part.10+0x15c>
     a06:       f6 c2 04                test   $0x4,%dl
     a09:       b0 04                   mov    $0x4,%al
     a0b:       75 18                   jne    a25
<calc_period_shift.part.10+0x15c>
     a0d:       f6 c2 02                test   $0x2,%dl
     a10:       b0 03                   mov    $0x3,%al
     a12:       75 11                   jne    a25
<calc_period_shift.part.10+0x15c>
     a14:       80 e2 01                and    $0x1,%dl
     a17:       b0 02                   mov    $0x2,%al
     a19:       75 0a                   jne    a25
<calc_period_shift.part.10+0x15c>
     a1b:       e8 fc ff ff ff          call   a1c
<calc_period_shift.part.10+0x153>    a1c: R_386_PC32 ____ilog2_NaN
     a20:       b8 21 00 00 00          mov    $0x21,%eax
     a25:       5d                      pop    %ebp
     a26:       c3                      ret

00000a27 <calc_period_shift>:
     a27:       55                      push   %ebp
     a28:       83 ca ff                or     $0xffffffff,%edx
     a2b:       89 e5                   mov    %esp,%ebp
     a2d:       0f bd 05 90 00 00 00    bsr    0x90,%eax        a30:
R_386_32   default_backing_dev_info
     a34:       0f 44 c2                cmove  %edx,%eax
     a37:       5d                      pop    %ebp
     a38:       83 c0 02                add    $0x2,%eax
     a3b:       c3                      ret

- EOT -

- Sedat -

--001636b14767451d8804a12be8aa
Content-Type: application/octet-stream;
	name="mm_page-writeback.o_v2.disasm.xz"
Content-Disposition: attachment; filename="mm_page-writeback.o_v2.disasm.xz"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gmn1kct70

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
--001636b14767451d8804a12be8aa
Content-Type: application/octet-stream;
	name="gcc-4.5_mm_page-writeback.o.disasm.xz"
Content-Disposition: attachment;
	filename="gcc-4.5_mm_page-writeback.o.disasm.xz"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gmn1r4mt1

/Td6WFoAAATm1rRGAgAhARwAAAAQz1jM4lSFTF1dAAUcbYJYlI1cdEMqTyu9q5MrU3ej2+Djow7A
ToV0gep2w0IJqd+UspGxT6qrMcOK0MzN01NdJQoIviUnsLWoGW+MwXhxeg6olTGOhrSEUeyyL3OG
A/BN2QSlh+zjslJgo/5J1gmCqA+0aQjgnATFNuDv04MzTADqNtn/ah5FaMAEOV2NxHM3HkRoeOCd
rwKhD7UYQ4mPGvxsaPsB5/vfi3E2qJV5Qcb7gliOO413PgS5stzsXUK4RwhreIsrl+Nu9+XYjpN3
/t/u0oi2MDEzgj67IIKlhcgedR6CmfDmrFs45+XKLrPjZPwC7RAXHbsbC1iitBzvGzdY+dY8ZUhq
WJb2l/opR2OBBdWqOv4NA3MyOasR5yd9a9ii1AKNIJsRmFqK90EqFQqEYHuDsJ7tHjjvp922QAJ+
qD77w6OKFbNqpBF41mgTfFPClsXES2ElJhJus7ikmqU5aRmC/uT5dnIYTPD5mcTMg8YbEncuGSzv
wmtE0/PMoYFxMdYtYjSZCw/zpIgr143e//ulwIKlVaEdSIsnjV5WQ26YzzoyBOe2EPR+GHRws2s9
W7z2abaqOzCnTEziuqsRF2OQ5E+SW39RnZkJfzOZWp/PYm7pRf25Y5O6SxDfOr9pGyNsS8taYzPj
rHaOGYXBgjqwgPbXcI2FsMsH8UK5PaC3aZEEbT+xSI7IT476qs93wGFhXXiRo1Vw+nlyt+f8Id+q
za+Nf58glOLehU++g/ZXM2uLS6MJ7M3qf1FTT4vxgvvC3beQPEHJaiYWIKPH0d1khNM4BrlYHPW3
52JoBVJXn8rrStP56hr9gFTobCfCwZvySDzxAacucH89Za3Kt+XW+tk6ajuaHfbzVqzOqZxxEuzz
9DXfjxEeaZs6jF6k1q/Mqa/rqvOgCOxl2HsuLWTe6aVGCOu+3mCEivgCzBEBnUpgV4/pZKzEKvVo
Y0qgTnpcpbo0r5FUQLFMDEUO0VpwFpzXfFAk/1ehWhFP1OYjFg3Vr+Q9SH8gGQ5B0ZQltHGaM5fI
Kh0n0Qz/N4slwN68LRz292/6gpubjo/x1fd4mP1WFMTpWRzW3wxgAEBbCQpI1Y6DJ5lJ0iGhaDQS
nqmwsu++e76XXVk6IvDiFOOlKjOGLjEBX9UltYSRD+TnWi8uIbKM59YoZJ1sScO+2wOOCEFuhh1V
mZ9H+iNR3z14ziT3xkiTWljyWtSEB3RxOa/oDsZHGN3KpKCxomKZcwizsUBrtnTIK2dNQi38RW8P
fkyJ/jaIUrGTfHF8yD+CF89y9UGzzSyPwd5j3f/06R+JD+9K66EZt2JNmW88qtnZHS4Np2CPpAql
diiEMgA+fc/RZ2aE9akb9mPXPc2p4Ap54Wn5+mZQIhRS7uGSgYM3UO+etHpP9wFLZ6I8SJh5bg4z
gYJCjOwSkk0R1if3j/yWnGeznPk5zhvDQpMPJdEoZPKbEAlTaPPXCMk7A6b4jqfhfPQcx0H23hZa
JmpnxLm+8GRXspggKyiAxcEg5EwQbPAlhAGCtlmKQg5rwA34rMr8/rA7Oe7ZYVjYfVjPOHkpzwOg
qWV9+0oGvm7XbYnNDIk++fJo7vaWHvsNd8e/3oBqInxa6zFW1Td7Z8W/sKovwA1LdD3XtAEbiqC0
6EgXjnnLlk6mgRCPqRz/PYaeZ2av2wAEmov3PzMwt8p+unBeL6yyD1YYf3qMvt3ALTxrqYCgYJoS
nbBCY0F0H4TzAU3MGM2cWPOR6URuJUEwK+ApUP+EYd8A8qyVSCv6LkzzzRujwJ2kWJyqkrB2l1AP
iwXIeZ/6cxDZ/Z4L2FLMBCEJ9UXSp/1Z3019qx80Ca3aCCOO4lTLZBenPfwv2wxiU5lXO2DPIhGQ
xW1s/1HZ83gjgBhD0NKxyZnpY2WSiOgjY722o9G66+1EqyCeocJ/WRx+yJis2pAwfUIHBHSnvriJ
ZgZDByKGohNY0EfrpWLjIx3xn7yzqz2JxlWCNKbdvtdwxgyRZOnCapChIBlJHua51ccwZwTqRYtM
VeKx+on96fax8YBPivY1LK53W1DwuV+DZIIKgy+LJV+CXJC2KlW4oOB82EcIKfmfCItj0tCgdZE4
VT43T4Y4r9Ou+RinmsNYRLKTvkUVE7SO1H8UFt+e+JXvKE/G+HHV4Nayj2bcQseahAXGU8jN3Kdz
kZwPtSJf6SKQd1OILxSrhilQ4ZO6KKntx+XuBZSpUBLbh2kX+Vg9/z2Cr77YczgYjU5d1iauia+C
IJVNo8zjXYzbasAkl9ZRhBUPzeN3LUsN65x8P8TLymQ3HmIG3Ngl103iAW1fSPiK6RK58/T/nx8g
20ZE7W6QyqppiTGQ+jEIXbcVXjXHqEOS5GJ6iAEZJZQRFPZ0C0J4QmVKxQ9rknNzR3q/8qjgfPZH
rvo7pHaPwnRRD5/b4Y+PZZ0GqFrnLHC44id7muOM1QAQY37fKGNK0OicatnCjZ8ZMMKH29/84n+t
bovQOQCX25Ycfn3NlplTBYJPaAhOFoT4vpOQyuR42HZPs5x6gJMdwzIl6+cTbrSEWyFEvTdOMRrH
pl82GKJ2bRDWlDc5qMYKS09lAKwfmVVanvPWSwA9R8bU56sIwp4mOheo5z7GDBPFU8pp2Bmru55J
5I1HMDDnwYvpVYuwtUDhUkxdR/CxrrCmwUMx03GrZ38d9Yv62MznPescV1tpvWRDXz5uJQcoo6v4
GbRM2tZmLYggy41jdt5JgfPjaHJT9a+Wd+8wDTHuK0mwFXvgt9TtLeVIvanUDAfjItNb9NWAPeNg
df4YUyPALE7uqm0HOi3VBHJ8FxbtZWlzfbFzw6kL+zcezicpDIwnzBCEKrnEUqvdIzRBzmz+bU+Q
omX92XLwp4+lP3xIiynBxWReNKUuN6i8ekVvbEdT2Vu078+UXcvKmQXKPSS2lxOmzKOKzSuVuIr2
aQOr1R3Jd23KfPTYAvDWXDQ50cne4NXTJJh1TAA6Yr447hKNp5n6QH9Zl7dAQ5nsCGUb1hsTaiz+
N00SFHdm8J+m+mEyjplXXAnju+RT/+rX/LRWvkF/DaKxq8WWKkxpqyFEa2/Hj21P0jrbFDvVxdQe
HMgYW28rEsceE0kqZoPiS2NWsvWBdxC6zRF58H53ZpJmFKJggK+DzjAvYKFkmZ4hShm47ShSUgS+
01MwORt2rwWhzrtKu/HasCplEMOPQT1nTp0AO8nFY5DJSYj2nHd0bemlJEzhClF09EBHSCjl1ak/
9rmGmS0w39wr8ZFJuK6Fe6WZP/jk+MpSY7TH0VQRSSRTfIjeMGdEJuhzb1TDn5UdaZBXEvsr8VzS
mp1EyU3pxP4kj/pF31/3nmI0bGJX1fa+/7wpzX+pxDAH5Gi85oTVD4AIk2b/8SiStvheSmlJM2CM
gS7nfrpx5O/92lhHl/CkC3OpCQqFFeoOtPReyYgO5JusmQYBMPsCgdvdmcBrYvVAxFVNu0khdWin
WJzk6jajagA/UHVbsPMSRCjkqiEt2rEWq95ZosKZCHoiO2x4Rx8f6jPENTKHdO4ckF8ik2St3rww
r+DjM8EIBeD6B1jg3gsCZl5FIjLluR6hCcVCaNo9k5TYTI5q0qmyWnU4qCfzatbF1MamwG1twWjX
qVtDoyKMcQQ7HYTnraps+x81wmKBQVTHm6rUE9e+WjidC7MazbXeGa/GTN9gM1zJNqYWtvMDjtb7
K+nk5J9AlIog5/Z0ztPl+9M8ztKd/Me3x2x8RHulR1D2bGbgRyYBW2xmUXX8jTL9Zi3kxpb0oRCI
YX35L8UPLbNKzC0ULpy3nadwwv+xWpoG+8Tu5bxq/F3UhhGIFzIffyfpauRtZ7JETdTFIuMNXy0q
QlUK4IvkkvVm/nSci3ajALIyvA0qcMccLpiOAXFRf4tYluRbMU28oulQd/nUBmiFt2M20l5pRuCg
R0SrPRb5OcQoUG+GXc5GFNuzBrh8fefZlNeAuvudTP3Pu3hfn+iTaiq+LutwXw8s8Ih0zmtMpNog
HQlHOpSiRCeNmex1KveMmBCIGwu61dkBBlKTkRhmCCS4lF8NEuzKiTziLJhZh+zFagl83kyZPzFV
vtNhC6gJ4T1pNqELN/GVJAwtK0AVsu/6WqDAdVbjrV0kaxEu2sr0VLO7L8OYGPwcFFINtat0jpbL
ej/oQRhQPEYBK4msQxVeVWXVBJVbgo+80wdNM2zsQiR6AgnuPClnbXaSVaUON0vcuipPGf5o77wm
iXsmYflhvnYg5q81HUKv6E+du1Adq2XP47gnkYnrvGeJgF5Vx3DZSwfz21vvsLptiYjG84StC4DR
EQybZFCrJ8qSx3VqF27IVDJ5SIG8gvvan2yUVUAFZ35WjXRAzMQB91Kov/tkUP9JmQKNRDekSclg
4tjn1vfUplvjXSnLm+gF1H3wRkfx47Pv5BjRru1d6XqfAxFOH/Fhl0+po8jtWZVNp9fBGPRTxQe+
qlYHXX4Wj2FMJXoCAAoa1OC7aTcXEezlMj9QZgYSFH07M0EgjCpQMHJ/vIJH6IhCD7mABxgT8NaK
sfdNortIzn5oOw9g+hmnU/k6BVZKvSCPtt2EDkyNSV8YU2E6EM/jki1F0GacO2bpyn5oIPLJccxJ
Hae9yD+bgbZQkg20CEbeyhWl3nACiLngjpp1QEWQQ9LoexLGgGNReAIImTEsuYlqxm1TAQzK3JFD
W8KBuhvuEGqnAj4htSHl4v0nKTwIhngE4fWGrUd3H0QoEYButD6z3F+UcvijAa7Mr+aU5R0FRTTd
hDOr7XoUZDSrT1OO/pxbRVVSUDIDApbyx2RdN/QwMFd2HuzxyoLbJor8qpSyHkoQ5fdyu4MXklYb
n2+WT8AVIujlR8mrbbOmyuCFsxZtNbZQDQJCNQqgm5DFDbm1ve/mzGOePQ0edG8zmpR4QiNEvkZ/
cthIiVZTxqekSpMxnxSSsN7o843F/tutSrvZaW+MA3U2Ax/m6v9r28wM2sj+0mhqDYxl+8uL9xN/
J9FNd3+6S60uqbVPcQNLY1zk8VdGIwt0OsmwQGRZQrFVeJ2uzjC80BaNdEf60+ThrJANyJzsH6t+
7vNSRdAPfBmt5WSM8Zu18JO7QzdnJf34Pn67WRwZw/AUTZ+PIHWU4iDdf/rKts7klYHCGUcMafC9
gWITs7nGeuOo6BpRNWOIYke4o+Wx8+e/6C0qEUkbRJ+bPDty8QPUO0bRHSSvXvpsmZImYvESDiHX
z0Od86khtD+UkHznx2NkucsoqOerw13OaoRR+yZUpS/VreTsa3MIfFRJEERjs5Z0bojFohSezbIq
uU59hjKVksVfB/thGbV7i1Ipf/nDyrOMxPk0yhZCVZkn/kLbvTPmG5AIgK9u6UjJgjTtvh9Jzgtb
Wu35oB4VDSLGrVA/dLATqV+Py1zjFsMsRDuGZTPQKo83Y7hIYynlXwhD7iq8BkAoyNJllbGwI9xd
25IdiAJx4R+F9LjmOkqwlahbigBz2WHIDnpaGoU+Tga+2xVJT7+3TXG9gsmaGgnN+q9m6JbbLiHh
QXXafdlWCtbbgRFqMwecBJTL9fnv4H1XiuW0cWqrR+u8sKfJQyyi72lzTlmZGLfXdPw0NWO0jN3F
8lTGIpX1x/gaoaQiKecsF2Dz+Q+4t5qm+NHZuCfyBTJ3x/DrFMKo90g0jNbZ6p2iWRE2PuAmDXKJ
/VZ1qckOeIrbZFx5EYIB8zK17cGHtgVfwS2c3Q5ZSZO6YE+oj8E5DopU/iwhMCsFpJNjemGIO7bd
zibg1dl9CZ08GGnx8WI7hGQUZowgjjMD87PjsN227BvOMACjDDh3w+O13l3tDqmY3olrNpd7Ii+7
BM0/o5VL/zRCJ7i1LRNV0UGcV8Y/6Izb/BEDaSgBjbk6a6QMaPnzY89k/Q9RpMmW2lGkjzEZ/qbU
5wDPQniwNTih78ovXrMIoBw6BW62k/WVCk03eexwjDXLNS5qvnIFkySXplAkz3EfwrQjRKlb+hBv
doUgjPIHjVjjha08QIAGNPmQ7vjr820OIuMW+9IUvKFma7MEZj3RrJu7k6Q/IKYiDUw1TZ5oIK62
ykoPmBdTK0mW2NeRAIcApmnN3AkJpvKIHqz3BlpSLGGIH473g1rdfBWi16j16Xq/u1TfJRHzhBhK
EhjeB/woRUZ3dOAHMru6MFKMm7s7c8JSKkgBYolYqJAr1XkqEtgH5sW0YIDsYf33jhbx04d3XlsQ
xrQQc7KrmlFIpLamb8jokDJdY1oGzIKNUMPnxyMPdnK28h/FYog2juX6yPghFLt/up8CwDx/y3En
ww+IT61GBfsU8/CUKvsjIHWxPMJlJEseb88N47tq6wq3dth4fsyAQc7N38nizVbPuHLcPXLFpmz4
PCyiuGOrPKSMUj8vLRnZ2PcU021gPsrkqpW131ro2F+SJxqVjoxMQq8LVZ2u2bbNSLdED+gePA11
uE15AvgoCme2rsQIzJGlFFJjwLmBR5k1Tj+iadQ7ygiSuFefJj6WS3lOi0+DuepHvqC162NKRkkq
xJIWQ3oKlS/yw7Um8pGst0SLDeNKkocOp4MBidO2t8Q8Xf7dyJC7F38nvHM7EG1qWpJr50QYoe3J
/4UzjZn/Nxkyj+akKgqGDVkdHDBF6ijU1s4niWo2NvIW0IfEzxuAfcBuXDiRf0sgPnDbgfw/ONRH
aUK8QyO1dTebAO3Ih8TkAU5JZ483c7Skwdjl67WFHdr3NK6nK/U+SU97gUx6mrxe/GLnXqA4TnQc
3HGW/T1omRTT5dFpErFO1IjWTEElDcuKzApL1ToxdzODQ8kK0BtKJJiV1Nb4kVhJ+tx/GnOgoVY5
HCkvOUXnkiQanhRqSGFvdU3OSA9p7UO2k20bPYaj1m+NCznH0ADd4h/472BIDTtmi0Pn2MTxTs4b
cckVy01t/iuXk1Ty4G6AkbYNcX9NQsLiwsyxIZcFXy3V1msv1ft1gfNwEYb5H7McDhJGX6FjNGB9
GAb11Ylq1ZawKBXfXPP43HusL8dUpvbikL3WL320j7lGiPn1PVPbBomb7xL2WxIlBS4eqFlNO5Kh
JybPBzBIGF0n6ahtPbnaLRu/543EGojbcNHni3G9Bf38Ydn3rFAwphXrexQV6C3hTa/O9FOx9veA
q2w4vel67dYfWGZAH4L1EU5OUgSjb44fWxgHjkJYxV9IxbMKk1QwB13k/OI1LRr2zI4KOKEYlmGs
0rniwiDpumtZ23LncUrMp05/zw1t2AdhbmqYD7OXX/VJ4yy40rpLQehXgzOe2X1eoMvKxXAWTQtK
3+w9Fg1euce2pyZf31Z/nxntFdziX+L2p+ypjo+4V4OawpjkyDkIFuM+Ra5BtLEBete9aRYLrM45
OOAMxoEBNyZ8odoNcWmRRRtlXiDKyTQ5Ko2UkEdazIYRDB6mkwnWtoJkBtWMjOSMhb96iPW7xe85
oDN5bEjhrs02SSIvmQh6K4EEeBjo65rS51UM8LkQ0jFxOXEriVYzOxyV4nX7CjK6yrczQwGobV9y
Yb9A8GfdPC5PFOkC/02mHhgZJBXwbOGHiwEvhRsUW3y3mP0XoGGhr7PPP8UGZzB+kbtD9AU4QJc2
li+/WAC2mBuNQJcv/ZLbAoQ7yuFvK9A+qH+XjFSZVtOqSzB4Uu1Fyvr4dnHAMaMsSg/DyYavdf94
2U1ucaOQQ8vKIYkjIJ3jLffnraEBFxw37LAHVubrNTQSIzTdfqU2g7bXgVYFEer4oFVli0c6O8Wf
JhMmXqARrIZKr4ZQkAAxqcNFDCYATT0Bbz86Pw1RVrneAJSRmIk1f8flaMveORfjn9k1oVejJdPB
pXF3YMuoBRGN4QNTpYH68l18EmhNHwzzQUSEnv0E1fyG5FyDVP08oI1+PeAeaLJORgskx9KTnOhc
JYKXP03wUCJ/tMMIaUU++2+uo2pG7+wkdrBvDaGGXeEcLOhquIR3AQGu6NzFjiGcArAWW8+j6cel
uIsfnc6+5MKoQgqS1H5YgvC16xqKNDTngzqEQgqdAyeDJn0MGrXj2LSLk+MJgzkiB40eErnkd1iy
rbSTCcFbtBrwEGwU3yfhOHqGYFE+E9AkcmUSzOX2kSDgi/WoakEnOIhwccydB40GnUzOs663Um64
+Jirde98dy5pTq0N6Er/4Z+kBjh9ZAQVs2A+jUETr5N1aWeOKvR5BPlaUgO6urCw53DYLtskyFSf
uQBRLEG9/on+tf0yy/1e7iUjeexSI2FTtDsuKDQb4evaP4nr6PkLirnZIw28oauYJd+wHiEGRcbS
Ay56ZKLeN/VnsYmx0oxzr++T15b8FPKuXifLT3eGz9WLFpDa4l6I2nUNDV6PoNRcj6ytC7C49PiJ
aUYjGNWNNV8nxvxMM62Ty6mxlk9LF1fQhC+R6xY70EiwVzmKF+wTd4iUzOepYgxMcRJFa6VjFoZS
3EMu6HC6/i2XezyUUNGiVhSrPcBMYKBvPCEpcWYEbR2laPF+sv0kkAAU2jqC0Zd22XS80DtKCrog
TgTM5x/EAiSemKwbJiKMYrCq0FGgfcZJgB1MalKOxbsZ1SVeebZHpwXJuQraYiC+3H3fayvJGEHF
CcwY1xG7M7M46HZh5ebdCoBAoXg0MDpkoEH4eLxw7vhX/pmk69frkFQ5/RjwlGF/Ct2Juxob4QE1
dbR1MNcbbRHKYhPjIvykYGIlFdYk0RVS0EctrpaGYUIoGFq/okJEmGsb2WF4MhKE1d3r9DROWsKl
kLU06gtHu7ZheFd9m1OZvDg0XsQPMyTOVIZqwUZSCwYcAPBol49nF9iFYEA58ZCVWvXT9uEp+w/b
UdLeYCCp0kQvtQXnsISwDq1urpvgYg4hAZQi9Xp23yE3QJACL65oTsqmaGsRlUg/OGMnKr4aY/R+
EtMJYRLnhPi4JtcBP2rTK+37HKinxkuew9jCPQx2LTA2wt/pf/DBkbwv6sVtI8BuTk3TBg7Pg/+Q
9Qoiac/AHDCX3hmw/eOC+m2CbMl9ORYW5Boe156b68RWM2rCTTH4rtiX/wzNMvVKHDlAHaivImmB
Gm2Quar72Lb25aZhVXnt6icJkRoaUySk1LeE/3LU7KdcpfORJIC1nVJCIs6oYOfKXPYyRUsCmzRn
BmiLeOY0Yc8OPbxoLFhfPg3+/iu2tcM1AUoqT3Cfpu4J9c64wWFlM6ZdX5YunF7wsOzEuDJcg/k/
2e+M5+J/PaNHhcfEJD/1LyKHIuCoCr4gzziZQ+lp7v0zI0w9Gd8nmps2XD0jRgC+qCtrqpepYkKj
OKkTYFmJMD95Bcw2/TIW0tSX2DQIcik9jzvsuI5srG/0jVL0MAXwJfx7eHtr7R8/yN8vwgmX/uHh
OVEJe0uOJIWenUtiY44w2Dd78sM+92p2QC1ppjOs1VzNOrU2YrOAT9QhrnfVGVX1gIYyWPA6pxGg
baX3WTizJPmObOjGziIxM7T+LjDxp/I6kUbE1C6563Kzxnqn/S51YN62USzM9xd/gTBe9QNuuXnY
UN1pB4XGWLqJxj2TSklz84prI0u0aZlR7PW7BwkmrU2VHVywYfuFyD0JKPRq6Xy8DpRyBoRqsXcu
27G8RabjUrGLDAdX4pdMl3IicUTm1c0yHfS/yi+7yqLVFmWvBtcebJx2b6XntGeBEV4PaVrCfKiz
NJV4JZ/IWhHSZzRXC0VyDj1Io0BFj6e9suKKDbh2FVmc/RHThoh4afpzQ+CITv04DZVnDaG69K1Z
ShW7NRMM/isOc3k07tXU7cUjtykNpLrX0YBb9mu+NJ65HSLzsUVCO5HPM5uXAiIQUufiS+t2tqa7
+pqGBuvnr3OtkOvpNvVr+aSDcbGT5UkVC15KGn4RtdHZZXDz/T3+DD8HKPIJOPf6G7qy6N/ohQct
WdhjBzHE7QWXnB3PqS/dveDdTkxvNAoWA4AHbj7IcmMex+PcV/791lCNUElKudZLmbYdKJ+6mMqO
gEZa0DmU0ItMv6EVQlVXQf41Ad7h9jads9sf7MvN6lMWIeSElTMyYZ0T0AixQgbFb4WxCZTOcrHL
vEZ1mgPWeHU+ph+vpX63I+PjJQP1BMZTBIGq/EZVEFqZMjHFQhwKEigruWRJBvMJTXvB0OtJql7y
0/lqnZX/GdFKS1vg7jcGUWhBOc5xW64emNDyhs8qRodqKb0x/w7CBsKABQ2Fb6Bl/4Djr4XQYtZ8
1yvkZG50zbd1idnz0wEkJPtbT2uSbuzNtpiDjxO+8PqeKxWW/hi1nZq5ny7cIBKkV0nBAFTAbmRR
MbtpDlIgnIYVBlAgjUzzKRKMvcptIH/9V43n3jrn4eyDe0Me7KxDbYQZGBG3/rozEUHWLWIli9pB
NKxljLOmEGeNiR1NjP+q7kSq1LuYlixXOXIkKiGfu0hM/Q/uIG8ifQ9uUgnde4qrVFNyOEbUsx6l
kMKauvUFZW5gKYkcxkjHkrYorIhj/yFs6JajSviiisFjrRZoUNBflZ/ZP52LNlMvsiRRp/FX2zto
6Dqa0ZXKSz+YNq9wlcWwwSdTXZGHZVCHb4TEDpludwDCHDngRg4MGRAy2KmzjtvSIKAdE5C2WH4Q
UKTwsLKI933mLGx63g4ahpbL/MflHyh2epEFLY4qxaZi+vPojcWIhnJXO4cmDMcaE9S7uT1msfZQ
nklYBN1bRqoYf5QZC+dF/DdUjg+LvynhkvUUlARJsvW9o8WLS1yiNyim8EnIfFc0L5xYVvbnsXOc
yVeVeh2YH6nUfAKSYvIaMQClKVPveZbH4SPS8QfoH/yKkfit7U6rZ3DHt7I36OHQ8SXefK/3JnDw
PJbGp7hfM5L9YolAhQxPBKQ4CuYT86hqi8MNJGDrMl3Me/MRzjOJSmOueWpR8vcZxwet3OdK0R9o
xiiNn9ssu7XIwcjfP0dr4uENOdV2/JsX3461Sreb75lI2jwOW8wXf8jD3HmApHQ2DYFR1QnltgQS
yxxYA1yAQmeIq0oWxbQH7U7SJGMEc70iMSA38jmG/tIziSr8gZEDVgJ4OFzafd5XH3ZbUTP2M2r1
HSB3ibI5qFLNNz8yx+DD10moTRDkBvYlHaU4lO68+8I0b79ofWLmFkC3SyV1GcjHwLTZrlJVV0sP
kBr5AyIP/6UgZtR7kqoM+1URCkTPICNcMfnHWfqoxirdYwp2amWMNWhtHdsM6v8UegaFWp9OPAvX
gzd/WY9XUe8uFjCV4JHfgMxs5xzAj7FiekIgNw1dEQ3w2FDQZ3fYUGUd/3oQbccMCoTMUOxTSZy9
To5QjAPXm4k3nH9z5yg9eE43ZPlap4L7ncnWSRnvIsTSnb98/9uKuCWC2MHk40l9MNA1N027i2wM
gStj7ux90lxy+RbTF20xEeDo/a8fo8RyHI3hKt21hqDOyl0K1ENKhobsGeistLQq+lpMvaAd7SL/
2Wo9U+FStltQA/gtptrsTgmTRveUemwLM+3ntLSbzX4dmHygzMCNeZc9X8v90rWr/l3ptzRQaAmv
VP0IYZEPAjrf633yfl+LCwP1keSQoC+TyjQVSt58ppmcIk0UE0LKD6Gh2dluFI2d/NMmpRP0MNv7
PMEps0DTcHPVIzKWE3CqLILFAPXxtWzMVM9gBovO6byCNGxi11GUpjGA6jFgDcEWDMTCatyDrfxY
o1FpTcDQDPK6qZscdkfdK3R3aa/DLUYt360nyGiQxpmj2Mq5br3ZJl7/k8+ZobN4iJBeqnnBgTSP
uNu7ijuOxhCcYfqa4fAjOXCmYBpiupaA850dNr8HwiCWmw7E4YKHPBhFKgQDcoU92fXPnYyRn552
iOt/0l57iAgJY/tHX50ERrj7qCYJrBBmnqkZGbKWiUbbb0195X58PDDuTiiRy8KMUMFl07LA/Yl6
5yVbwRCqki50sOyPAIdRgG7P17UHFt+usNd2+O1mm5/N1axZ5KjVc0IzIH6eDox1Gmr1RDHSYiJ0
juHEicQrmcNLy7swHiWIpb9AV6X5qMK0dSk9qxXSUKwEH4w1MGHTgpIFBoDtcL3ggqCM6fh2NcX8
P0B1NklLLdtA9KhK4YNCJcHewwGOGLWs1/iFwBDwP1R+crkbeTisqlOHPacdyqbDufV8/+fkoRQD
v3a/Wy+ih130v5OHc4R39GvFHbwobCPDvzDlTzE+sB6Poc0TJ5Epxaxl8OH/sxRCZlrjtJ/qE/eP
Hr18TlRW9S40APgPQYjb9ES+aCM7yK8g7SLzZfA2H72T2S0OhkTNpfrWfjvRReC6WjwA6nG+XG1Y
iXN0l5oZBXdmsYq0fgjA4bln05u7N5fGV8JckFVMBFgSG4YWqn4ZWeRfCJaEhVpbUwKiZ9dvS+1p
GeTWoDO9Ajiq2WaOeHGhZuG8wvhM7yvGbcG0P9WJVAqU+oYDpwupG/JjW7/yEQF+Bw7mgSM5aMUC
YAT/3XA0NM74oViJonTv2XVBeFhalZtzK/91cKtMuHkm0ApNiE3syfIFNTKpXYm8vrcrHr7c2WV+
wEar7ZYOyO7d3zmwfGSUeaYqLu7eLbzG81e21umsMJzcs1N6kOlMBIJM1dxq58OkiV7upez4tbEw
n4P0FqjzJ9iypOOSBcxnXIOEYRpxbGSzIB8SjuBHcpu0Xh8xUPRS2S73GBHGsSJqGu0VfX3BEV/2
N1M3nVF4tE87YSD1pieGZn2cKJUuNPEq66jOaK83AbslM+LCZNZHcsx3z6B3JlW5S3InsttmCaM8
UhLd3LWOFLmd6cjlK2duj6sjhNNsQ1/ReGxcf7wPN0cziSag9UxSjb+1J+hhF6vTGnndeQeWHcjv
ww3rcaeIThsnHbvXchdYrdmBLm/Uru60fRwERKhxZiiOrbjRiuNv/9XAHsv0P9grm349NCay4O56
MqwDUvYeLuwfQudX08L75S5OZb/PNMw+CJ1rFl8VZ21iAeOlp1mTu48URURdP6GFWHQUND+PjLm0
AWk/2D2Te2lX+J81Z1eET/FKjDTWAO32/wnxGKEuhcar09J/2MjKOBITaJHTxdLpFW1PiQdIOx8Y
ffukZZO339iN5uMmOdlVFMz4I1Zx1YkuYkrZjir1VqkKFi/ovBaifkUgEao6CfBNqeo8voL0hRoG
ePSO9HjrWvkA6ooulfYD6SFDt4G/tW+l/pAjWbYaCsfFWgrb1JOJXWcgzS4XMoHrS39i+Lq1nQeW
Xm2sID8xKSyl3oGvyneQB5BGedCb64iLZb15Wpc5Ie31VDPKmslhsZYgRklfpsR/c2/EERe51qwh
I0+X4jewyBw/96U8rhdKpFHBpPVWZHSdMogaE9yTLLe9ggEE0bslK5AmtqZDSM+yn3Bv27MvT1te
JDXiUfvAvgFm2gTaklJMGKxhEmvOEbkt1ZV6EvhExSaYyJD4zYcP2eoSU8I64WBEHHjXmeKJ/wZU
SKQjOuBwK94ea3yNZQoaq1VF77AG5JFiN9pJfC6vcQMCy2ueUeoxb/rzaFFMfSzezkkK8abwQ2ys
wjV/YJa0IRXGUzXpBXfvajzf0moEUREQw4zAqXSFljjA5vh0b8yU6keJz5XDWbyu+w2KszCAoqOo
RkhE//XqvN1tJYTjGITTcPAXauhKrPLoFB8qH+wOJ4Ba14xszNUsZ/YV4TmNwmDqE1asbqFtB4OR
cyLZ3IW3NW/0pftZDQZsYcoC5SCaC/QJeXIN4gKLDS2CyF56O7KAbxb3wb9f/1hS3UC5t4G1HT6N
9V1Qa3eOVKx+DuuF6UL2BVDkFU8tdndC21Z9n2YGw9u7SyIh5UGCC+OKCzMQ7mhsm3AVaapP/7kF
Jfo7DDdrM+br4xKrv7X0pgANVlWMz+Cu8Hk6vmk7f5iGqA56yj6MqhZKEEYiBbacv5vFhfI9s5JW
U2UOgoIZWWnnQFDlIvafHfE0ZNnfiSWCNjLwoj3ImV31vHYPs1fC97NUrFushDtEwA/Axt3GB2SE
miENheNoZLGspF8G0cKtNBKfNcCJ5L2YT0zWjtZSyfkaqXBH2Ekmf+3mAU7IDejZUgZQhBhBHVnM
S0TUkGhr29bIEDwPN6m5DmJSvEwoEXui12dgD6XUBlKCKzP91NGnjRCY+wButkgNADssRUjAxIw7
PmZBhUh2B7sDESeCD23JSW+ut8O82X/anCaIKK5yxw0b64Fqz6swWZLFxQoNp9hxj9Lne6QgsHyr
jm9YwysYXOzTyu0zDlIXsHdU8dIHEfXWxeY5f0/lmK7699vuCzOOO6LYTeXtp/3m9lGpTWxVxE4M
2UQIJodARIcnMlW1Let/bg/rP0wSYdtZek6mvyp7fEOUa8Az4nlorXtEKwPHjdIBwEFuHS980+V0
ftDxgbARFQXhWkgYSNyJHXw911SF9n1U3GxRNM9BVT3eL+cqqFXLb5pCBlKr/30hSoIYuHWg3IwH
ugEtqCiRuV3QuUjpjQa2KmxoJMvPv807jwf9toInnEOdOA91hNfwoee1+lSPmQRis/BHcWRHTYX0
SAL2BFLA2o4DkW3MPJC/gXjxrPnrfP+Ex+Kv2e7s6UzdrA5qOxTaNG3c2N9pJ2SX1uNIAuJlkoF7
8oVnGg+oh8JAOMQopXgIX1P4K74zrBNq9OpFl+/cR3EuCM48Ro/82GQwpK8F0wc8gx1/8aPhGUEi
p3z/DafzuP8GLLGR6KtYr2UBPrG1T1rKM0t0P8KuelUaZMF+iEFukr408ll2IBL5JB9eDF36N/vA
DRbDn3SVazh2lwBGinzSNgOty4F1O6iKAOfOcZU+au3lXFa3fr2Z8nPmxszrLxOiK4/V9ftf6QPY
/HkIRZirRd/GRyrNH1qsycJEVqlmptD4qB2nNt7NOAfGel01rBVJvkcPPdKFnJCmqtb+kE7p0sSh
HDLQCRtuIESpKkccDhWw5WqYGTGo1de4c3WJCTdu5kCCTTT5OrMt/Qd45fVscLuTNLQHnoyoAJ6K
Y89ZVhYA/9SdzCRIcucc88puryHeDpU/CdCq1HHNnFehiFo/+Cq7iMaIFZYGM1BFgjkI7MLG3Jah
Zem4Y0m417g7CGv0KoVZeYbzP0gzokJT0xssgtZUUf/W058ylolFgWOup52jG9cQfoznSNqJwKXH
pr6oKtOgZIuNmAbiKzy6iCyE8kbzCXdfFnBIRjKt3X6KWCPfbCFDWrNA+G1SiAxupSJxNORHh7S/
/b8j5ee5vds/tsdBmpduVCsVSQKc9tGxh2+5VUheTzSCQ1LvsaiWhio7qRXkdoAeRavJycu1dK9q
mBxc5QNzFpJl/BoKHy22ofmxp3dDYaQbQiG1wBRz20EZydK3FD86Wto/BZpd170jfTjYHTsyDVsQ
ky1KEpJ3XhDNLw9+LenpeD+9VflKtRnNtkMkPyxVnPD7fxAavmsrdWew07Qb5aTzd3MfZUWM7ooq
yzdNCA0hHfq2fzPGz7AMZZNx3CeCAnfLNoJeic6Ov9W0ekSwRkodXs5I9iqvUXvHPPTOACV3qrBb
LRTcnXeOHlcd3H9QF3xNrIu7FrF0lIo+crhoUnhgA21pnJK4nnpEwUEsQG02UhgnjDFc0/VspvWZ
nMXa94AJo8PgEGk8zEtzSz2QzCPP0VgVnVDSDB7uxpRJbJUemDJ8NfshBYgIjvWovCPoysewFJx7
rmEK3YYLmH9SXODul6s0kJKIAbhwfhG3GW9xZHRBiA7qc0XWyrbThOcrziJ6hBXP5wQ0C1WdyROc
sWy8i6tpuJJ4Q7HQTi4vDdghSmOn84clW24Il41rzF8N+QfP5pAdK1ZN+e0uKtWI7ik+wlV4hMR4
VqRS4LVg4bjGTlWIL4htKoLTe5IBb9v4S+/dd2AW28t1v8wB8BgG6Bxd9rfZmlJNSra8PChyLGgM
ud4OlfeJNwbTNlM66+99caaPJid31NHjuhtTNU2XmY/UE/v5CCTjw/4jh/DlaqiQf+DCJ3iLl7WP
KbCVvunBb+c0jFxJnHKut5uNOYujy0Nl2Oc3XkKAehYPdw6MbdPErx9CGnyMViiqQQXNq1NpayzJ
3OQ0Bo7W0FD7ZYjmEZMssk1E0Vp9Fxj3klsCSEPBxmLVLAXGx5GNDxpc+AgPd6yGmUUiT8In1qQv
PbyMN5KsdmUuj3LkihScd6k/73R/c+rqw3AWtUN5847ji/FVhPU6V+90908mjL4w/sNo8B/oi3MA
LmJ/A+bnlFj2xssyQHGLCdPhhwrBREnNbVng1iGJ8A+qegE2aelRcU7v4cPa1OSkXZpOBLQbXDiV
iEpAedLGL0lLZ5oSB6IW7PkkupIu34nhs2GdD+rtKTcrqWfZKnHfuYvo6zN1aPZ4W3PMJTSR3n0Y
uq4fzVcSdDMN8EWuyrw5+Xa36pXavba0zHvOA7T6VqdYTk1B8smwUp6OeRR89iRbKGDSCf2aLsT/
nURmz16CJv7DlX0ETU9H67vThBvJherPs3Zoqc4pEaNFFSJdFjt4i+5/cQce0gTIWaITlVvVGrSG
wF11QdlIuOG56yB7KAsCx+Cvnvzdopikovhp/7aiNqPrPdERnmPNyc9o7C+t0TJRYBnTS0/QSBK7
vfb9pWnIiFHHGBWHManQ1/oOabpeL7cLM9TumwgAJrtdARRb2zyUuUW4D8z7f2av6MAxXqg5qPzV
E6kUMOUXN30zi4QPTEfwBhN6oFMSJtO7iSp0MEo99QNNU1T6eFj0SUmYgnkEicsRtZzvxtjKV75n
Qq5pfNqXXxAsDvMhaaJkXX7yKmUzd9gfBiWdRPC79ROBdg23FAlu6IO48TtuVxz9jFhDhKUseloM
GIO/gkg6ICPhnucXiOqhwLCEljSG1j9GmW94f59bxFzV+GVQAnDCQvQJE98xuaSlJe9DD26Hw8pU
PWNeoAuuFoADRCXB+HA9i6WNC7RXle1/ixZKV/T1vGbwZtPpp79tBE2P7DX6YsKHDpjZRtKNv11J
lZ5mKMxKNWZAoKwHGjsAyh7o4wi8negr3bwkJ63dCQKBCjPqxU2xYu3P+FEB9PU8c8IxHXJgcfUJ
FDvQvEAINiAhwPkIhB9PNC6pKuiRBa5N0p7Nb70wPqfrkGhfS9c2R+V6JoQHBdknf9WVkTmUtYGN
jwPsZplYkvNK+Bu/Z7HTCZUQBwz0htweBYt/8kRnuNseegIibd6DJYdfrNpZAm/V60jFagjATQ7N
J3eyfp09azb0VFDsZXdhYhA4sy9arDr6dMj6qTTbnMQUbsHNtFiIbgsZrBdJ+/bJVURfzZIZmwSr
bx6fL/f9vJVoj38akgdK7T6B1NUGZ4T6QB2b3QMF0vnXbvvnlqm14iQn+Z/kFeaXQnh1X/M7ZiTF
5WSmFHpJNJ6X+O4hRSNtRBU8V1B4SxWrHULOL3cb94uzs5hYGzTi0M+bngG/mVOE0GuH3a+eGJ3W
f1dKl6+EARaP1zIFNkeenGw4g4KY8LBfYR6IMBijEMH1ZdH7fWjtcEtMfHtkG4wcgcwe4zyY/8eg
JNGOWffCaqI1pMOes1Rm/a3ddX4dyurI24oE9+QeJ47SrkD2OK/2DmOkU9M4B22tbCQGoYQvT5q5
c6eWCy9MPynD+nWOZmH7YnMaUWKpAEIfChyD/syGW/SrR+8nd7FMKYuNHd1WtBa5s+uvwgPutigb
77hYKO0nX5omahJrkPMCMY85u1smO9OJFZp3uqPtY8x3CVfg9QTgGAnZGIaffQRrvoObm9HQkXf+
T7KSloNtUjKcDuSvQHpE/fnhBQ5p4uV76go2AC9in3e5g4ZOuWD4QoPZWp2uGpQxVay96CS/lWNk
2uWcRMkYzZRniciCN4oZk64E4Zy0YG/IaAd/X6hsVg3Wp5wPvL4esWYk4NtIhHOLe3NjRaWL7HGC
q8xlj+eLkfdJR22ov06c8BzW9JMORfHikwBa7xO1QrIdi+EUkf1vca+qD4OQ6bdH0JkjoaGvyZ+y
EwFLX1P3yBs3qWZZlaujNkXdhuYHHNmPYLJUHDZ6hj6yVpmQ6HakI9FfFp0SNCo+vmSCxFHLWk1C
J55EPrZQiLW7mqvq2GPWmAzn2IWGaJCXc4Wk8hM8NvtUXWHy0gpVNR1wzWtS/TD3QRqOu2d5PRwx
RJpeiAFkpQPNCDSyJ0y9EQII+GLhaUS3ga1Tdl+NZHr4X0mgWLibHju5ATeKidaubwu8ITSDmu/e
MU2UiGaMUIIbs4njRylxJa/hC+ybXiXLjZDhcabGbC/J5WEJHl6M+jnNzp88ioKsQkBQbTg1XO2E
d8CG6HohzLmdx/riFI2CCggRWF+lUdHzoF2Gps3EgY3pgdrSELRn0GEIKX22pfeGgY1ieWCDdbFk
HG+W37NJGLJhaeb6Eaw8euRNv2J50KUK9/tZkMqESMu4GCuGgULFnigTYod7n23xsBlSfLKrrNM0
j935FpmFOEHO5ySSjjojVpOU5JOUhFL5FMielyZXdoBbBpMa+yMsJZhhv0qSILxdc/gJDyRL5xqp
AvRjQnGVqIszo0i5j13bQb+H4tPp63FEdl+O81qZ6VG0zyGVREeXK7zvY2FXhvpbs81sisGGt191
Kh+owm47luVqGYrkxveION4jPOELj21+tLoMC2ggrLE3ZdOxx/HbVL7DTq7kEnl8DloxwDfMEr+u
XBeyk25ReUoDJ7jOD7TxeQBNpN+dhWVPQM3Ea8/kTnBIyrwNJAw6jRyvGTlBoYQAHrOikZdq+oW8
jny4ldryoaS3AvtIvsCYD97JafgxSjx+eri5myTgh2Q7oET2OThqfIhWWYHbT9ZJRBIezEpkXFDQ
ppFkPxHOG4jSoOs4DzSOTJ7Omjt6QjewvOwlE2+ek14f0FveUEzXWDSFslCEnb4j2Yog6RludLEZ
wNNYUNL7bT6yA+sfnGz5NRerJJ0aCAhTAw0EAJsfwtgHmqhuuL4sDugxLdPasU4ePUlk8dYOOhTo
IKeQ+kA0mh60LmFEZAOXu0pxN0olZQ6gQApZcDu90G8Tj1pN6bDoG9a0CMDNlvLMTXWWH1lvCYph
uBuwcRwpRRB6E5idKYWXgnbcW3pg7ywTBsFHX/gHcP2u5CQ5Yfk3DJyGJhDFDu/y+63XDHQS/Dxl
Zsjj1Va3ob0JIvQt7na8fpl2eFBetC1yZ9T2fqRq8oqToaYpR/NbI4wdxABbos6EMn5k2uW6bFew
XvoRIZUw15rYFof2pJcDXZ1LjDE405JK64/dqNHk6f2ouY411ZmlLp/QNUSBmatlV684PzmGO3BN
KJMAnuhvyfPjJF3SCFRmbf/jrKSOgkK/ugO9/G1JxQsAQjZqXHWPe85XDOAmeTzaClnmLK7D1HMV
3uJpzbHT4FTG3o87XlmpVjF+GRNkKcV96OiY7/P8cfip2sW6LqHE0bt4dE8pr2yoDuldHtMclruY
psUTH99HYxuZrmPY2pIPp3gLkxnQoH+DH7mpJ//UHm3fs3Iq8PQfhbe3D1fhoqT5loZwzLZ4QVpd
ZfOhHdLO4LiGxNDoxN3RKbJ/x65ryegpkJcuVxgTdKIVdD1iFuL/FnPlnu82M8OznyOIM1nIyNgh
78wCrrbFHw+5YZtywn1vyNqj/BbUGON5wfzlT7i3NrYI+gFC7358gq72UnqUmIIq06TkROoiRvf6
E0NTbOr6heuCZe0D0SQIvZ+CnvMqLykrWtUYmGm4+o7YrS+KF8uGpXB7m5Q24h2LqpaUtsR8o9Nb
npeNxAuaJZ6AV2ykVeh/lulk9Y+1uiiF+iU8FSBdLs2H4WBab7tcLlTGH+UNiDd1oDQLC1Kw2Hk6
lWyu+G2vG0zaAGuIjKgXbcAp47vGuqBbMwXiwgvxCU4q3d6N/i7xb+4rBbSwm5Wcf5vEBfYm1Gij
OHUjCgkyIuZvo9dbBKI7eCzt5Z3DdfcoMo8b0+CA3+WKF/TZR5oKbU6U2Dzjp4ucXxLv50HAwNmh
fWbuBkcoCf6halBpYM5YMFaNKmSgrA6dWMazfDbrIVamtxBgzcaMH6nVXuVf7kwOxm6hibGtOLBa
Z+DVQzKnpQjqWcwAo7uQaBSY9+mIu9Yi7QzMRd8jQ/4eJrN3MeNoyBBenWR+ft7U6VOpXE6RbzKJ
SDE6pPLN/S6aXpRQjeRsgtTUqG+YI0ygE1WMg9ZH1tvfRYADSLNOsTWuZm096YB8mTMmY0+tHr+V
EF3TrR1mRjybMt8ymCrtA83hHVWY7URJfJPqTnH5ncTKzxQE2SBD2TadkggcskaUfd3z+MilaLue
qy6RbbgXH5t94cYHV1noGi5Qg6pPgWw+tvjEOqCfdWscU4ng+0V7omjMwWdaWFWU9FeWytqz0OYa
vlMKOP5gRFOT0U7N9sk1oQrPsiOLn55H6FdBC0R9yqWqKC+lfBnL/DSnkweL8MtuaaW1k3wHw1vP
aW2D9apNkT4xaF3aaUq+c8V+P801UIBGhZRWEzYaua4bpaF6OV6uz3wvgmHb1rYXm3LjMjfx18vJ
WWjfCX8p9UVbwpefuSRvnVQsq2VxjFHhFK1/zJXQHjeZMKYnhnBArXb3KE5rvXFpASwuIwSSGkx5
VzZKTvUBJdKqvE/jjVUsF6NPEoIKzaNxCK6ywyjVvQ98HvauXHeew8dsr9/vBBxR8ITLiZ2hjsCd
mD1YxtMdRI2ivFykpmh5oR8UAyqMHwBmB8ew8COU+gijXqXxAYiDTgX+bBHGlBM1pTyHogxzpFff
ddFUEw9MVynL3hRZus8QmuxH0xco/xMk1AwabP9EG2VbxdxZOdXb5NwvJp2HOaqfvwCuhYtjEbxT
hyQ5ssnt/jNpbOL0nfKKQwWe3Ghqjcxl+s8g718P8JPPKnEMcuNh7Oq+dPrRZOyAPqq4SXRNSauD
1XJK9L8GdPCSV257ghk+uLtsIupmr38EgnAEqaWrMuZul7Txksv0zdKFYmOK4Y0cd70nMprc/0cE
3LufbiHBoiKRMxIODe0iYNKV1xvpe4OiUxfSgnB8ghZIDJKCrQ4P2pG4klV5MW9Ud6RxQ6YOKgkV
YQxF4cMG0es15U0nfuhQw4IkNi82ERiwDyJELBcS3Zl3577JfW3pzFsRbT5Zi+VVZEVyzVvuA0Wm
3q4A8MbzMKK+566z+8gBlM916NfqHKrK3JUBKbNeCQ5L5QuIVLyCaqcTPXARXgm7lJ25yN0KwXZW
IcwVHji16kM1rQ17SNRL6PzfVFT+4htoU5qtQRATQqbWuFP9EmPhcROQ+FamjwK1OzA6+IgU0/kD
aVzEcHPoCxJoRaWuJujqDZSWuQeNr/EDmCsYDrSpG/7twUsqnEcVbx6oM3TJPzf/CDbvIMNBEkFt
TJQPSqMXITTStGY46O4plHUFSy9kEj1XgHVhTgloYMMxBRSeN7V24OC191bI6nip57RfD63S3UZ+
1WzUgDuVrYYm22gJnBo90XksUIs73bXMnmOu3BUVXgtgEtssDGuaaB7tO5jg8osfw8vXoRBRU8ej
U+iVAvzUU0hBF80ocJy62n+0MAreQVs5bTof8LXDOib/1w0/bk7N0/hOQ0IkLmd/962HVyeNGd9r
3lnsMA5L3lraLoqi+NW36HXMOaTtYBhZG+SP7lul13zJ6fbmypum7x4T83QFpA7ExmMYU0zeQsKW
HNQ16yEO4BhZYlrwieZekGucw5vTqsrF+fpGUf1DegSn74OfZnC0+dpdIblCoeMB2TyB8//0qshb
8UNprQQpHyz3tV/rGwjDnDVUwelGtO0WD7fAlUiOOsDsIpsf1TS6an+sGYOa8umVnGYp6LDgGeqX
kjuSARwAkULUo+IkWc5/SYzIH3LU//ijw4B/diN5thsVIR50h+xRzJDoFRzavj35eAM3abyaCHA0
JJjqzG3ksnCHGfbL/8w7F8trnHjMLuriPxjQdU32YkABqnbFGXsjeN18SqPvI+HeJnJAT9rNWVaT
hz6gf3au3vlouNOX8j7hrneQrWMHvbaHeCrM5CJffwtLqiJJ3XP24WuqgY8ozTUcoBhX77whMmXv
/3FuFYz6aTrlGL8SxoEs+sZpFDUGlvmbt7i/bpA8pgjHrYsy03XyESwvTC8K0FTF23lt8zs6iKsb
ZBfxvfH8Df3Y+q29hLUzanqx5VH8ib7GccKByKaODSjv2y2Ux6hwbS16Q+pCvixbSTlcop4+ZGYt
DL24befUpcKHTdDlzqYqDnWS8p4LJibvFKYtjcEAUbS869DE93+vi+MRbvSJv7KZv4HmVcTwYyyZ
WXf89/DVJyLS/JF2d4wQUMnxxB2zG+J4miP92xR2ThbyJmbz9dcBtC6Wr/cBtuTU7GMKP18kpM4d
pBHMEV30stF6XZ4Cvc2VJdOzpp05qoq85VbnfNebMm/0g9bGiExhry30ImZkkvDejnQE4pGacBLA
WkGAGjWr+GKJa0Bgp2SQEWtlLVN3FtXyK+ixJbpbNectlrhK9D+JaEhBYwWDxmNcwMQmJ9ZR7PJa
PZlYzYRUv9ZXR/8AljtKtSjoXP/JHwBcCNl2QV7B95ZxzkY+hh5TTq4y+FD36GP54BSlxQ+Yn3dT
UTgkuIxdsfMB7wMFrtRAZiUMirjohueCc+0iPeLYibfTDnrqD7h5ZsDY4IVm7WsJghYoryRUfUiu
fSQoct/RHo2n83cYgy/BIaXGhv1LzOfhtxIhQqWh5FG6DoLkRcUp1vT+AOrGdMc68C1Hb+S5Q+cn
fEVq5SeaB9Yu2JMXLG2uSRvEe34LoJGs1T5P6weEY1ks3yzF+hGg8Q97OvMA72FkFjz2hlOEI8tG
VzsQpo+szYXq/gSSf1IxNvD7OdFNaxtRdIX00zXiDa5g7VToYTGFSXnKdnzmND8/fy/g83M+78OS
P2MdO4e1kerf7J2moc7LxiL3bsT02GxXvz1YANpZ1sMJdP1RFEwcRZF4LFOwaPMQJcdqQ3lbPCwq
vlp0QVjhXuCVjua4IpnwUg3Jaybh4paj1qhqcGxGIJIddAy3tnEN4rJ0QENYaaQaLljxgjk4ljCx
6YIEQbVTymWRJkpxM3+pZ+YBdcZBKC8SYz87TAXjiUePPp4yy0dAVJsVZfsgSbBz/NoUUfe3wGdp
qNstqsNhsX7Ax81elV3PJz7zPzhIF8pJ1Sz5zU7a15h2DAZjAv3aql6WUhDGVtfYJZWy1/+8tIvO
iQnGLbQWF/qGEmBrQYl+ePPAUtXJYmOE65wbwls9hPMcSZFoHWIgSfA2eYGBW1wV+JWTse4ndxqD
qytE2+3j1QIbEgtEvSqYDOQQgNvBLT9TW3x+Lb45leKr3T7BxGhtIxR7dS6MHAn+FwiEJO47qERR
iavPgjpohkkfNCehgMeJS4EBAwixnaqoZLcFgStyrRVt+DJOfNyk14A9pgFpXKS7gDfaqL3vCtkQ
XAk2pEdDiQHnVDyhAfnaqEZ1A9s4L7BxJHTVft3XiCHUwqBHbCd4sRfNVbByd8pHo3GiF2LzTYF5
vN5Sjg3Uw/se54PTgXwaRfRjX/3OnM0LSO9vi02zJwh4hJfyn+FHDoTPortX2t+1s6tz66rm1S0Y
/he+Zcrkhsasa5jdg0z7en0HWCpJorVsgLBVz/BT1CaaZOtAH1hkrlklVr1pIJRNRydHucm1BR1Q
Ab5llFz7VeNwK4ZG/9aErVfK9u9K7009cvb2B04YkuaVaQ6A48jR3td0+Ow0zaYhptjMrVSP+bf5
rj9dvM3rhMADRlUdkLfUqJhtBl56O7uFIpnF17tgvpPVytlCdBVIlX6Psmq2iiasgf89dggtVzaF
Tde6NfwWgFfql0DkrXnDRllFy0uDqZbOJp5HgiJLOP/qq79Rte3nZWPdpOX8/SBViOiV/cQyerlW
/xCSf04lij7wXtyd/c/cASlO0u+hvInKL8LkhSvAWIdZkbaZy2KygVmkqazjzEu2fCvPTVJ6+Sfk
rXlhIUJ9FsvRO22pr0S5m7pBx/butezjnINDQniwCu2/ub1661T3cZQLHtpzex+ubLzIhq+R1gkM
XBNzdGmZ+Qv+YasiQgoBhWIPJbSrS/kdGEDTmkox/SAjZG1JWbJVAML1D3N8hasTHeH1RFFl5E/i
mFEmWJnFJiy4yhRiwolILdBLa7RpUNI7tqsZZyNaLCIfn/fosVQ/SY08svn0nqanp4qU6ZKHFjZY
u00GpVtP5P7OKsRzanC/PM4qTQHP7b0aTGkZkPZqh/xXuSIQ4hOiKJOMaC1EDfpaEF6QjZCxIxux
2VQFr9M1fIyHLmzE7af5YMd7udpmNwElhEcz2qcyFz4wcaxMAQAIHarJJEf8jFfpGF2swWex5RqM
UjWjH6oh5r5h2AX91fEcP8Im+1sA5u2J2vzlA1U/KGA5QQTZS1Dyn6RyEkxD+ihApqnTNd0mAUp8
vdQmpSABvEXdYNzlocHrlBU5KJh5QddAde5ryCCuu5VaAP6OdH5vUFCL9phm+hinlKut7jPxyzYp
2xt3pMyksAbTFjJLRwS3hMbzkqigvzABgMptGa+PfVj28xcchVFaOctf3zH4gH3+quqZ1lVR4Lzn
8u4BYFcXyRYDaGJxfW94dwO6CDpRLZBg82qMd7cuGxHOsvzVHxgli4zDmi8D6qzGUmrswrjNr+Vs
zBLvoLI6fy+mm3fmjjL1RDkaxwg3bVeL2t3k6xeqDf2vRY9S2pyBKd+zcd3fsBKFQ2MgZwNj3fTP
AGobDayC3MBw+4BWdyOAoLV/E1F0pKL0kuuMXyk3e3eacnIKhfIywpwioHwghe39UkwzL+B4fKlw
5oVPGhAmPzUU77GVUdp85MQ2UoUrnwCGV7Ps5KDN3KFGNthb2LzY+NyKEyynXfbqdH+wc+Tlq4Ci
DCeLqCilLQBy2hVnE0PQRyl7rff49ycyAnB/EgA/R1E9MjQolgfGCpixb92MpXyFf+CwybDjmHs+
T+oAxjd4Yfaw0833T1TzW3/HLod7PiuVssisjg3FDG1kOkYmLjkSkQSmg9auaPeemtzLjK2xlYPh
Gp9I1mmoFwaxVW7NBsOb6HRjKqNQucSQ0kasMbMMIFrOvdXSltCvqrS6Yx6NZlwyN3PmHpjgMLy3
rReccMHBNpZKtbdGOe1dNeM5b8h01kG9GPXQvyuREdxrODvVlii8Z5MWRtivfsNYqAqCQLxcCNjJ
KFjgnN1D1xEoXZDzsbTMT458TTSE3/PfAtyGvsdD/R9ald4mFRf9Y2RDJFnRrCKRDFUDSbvg5cmp
t3XXrPjWHjsj4DdXLuccudAJAkdp4SRm0mg5eK2zdI380/mqGzrOLrYgAIpzUt4nSDp910BynBIb
qpN2z3oRtG/xx/aYKNzy8ro2QW/XOegPnhXlZCa/N3LZ4+ViOqqA+lKrymai4aTHB/n31RXOQo7j
5Wr5yUPLeJ/v6vVYu6HQnIltmUXfiCD2rxEap/JxufWrpO1Jo2VJkDghexxdXF7GLB71QuL6Hq0l
2MqN0q/+W9ju/I0f1s4ZY8L6EOMXt7Y+vcUl+WUshEa7eQfzjV7c4DUV8QOt7RBn0sxZZGsWltpf
RNLDuT1R75NW+RUzaVdhtULrLHnc9za6h//aLmgzYg+GcP7iHgIXsyGLlq0r+eF70SF5iQfR+gIl
otgah9P40NhVdScr8ULo7rpiL4CdEUykBKmNANK0zN0uKQK1L8S1cwulo5VVLBV007+K3phzAtLH
73kjsuYlaOfKekmAxMRq9wZRov6nVLQPyxbu86fq11ekIPgGDq8nJcTE+QS8OaEscd/eWW/UqvYD
aoDfu/lbLmOx5ZC2AgyfL918egpHo07mtUYuyNEjU14o8FfGGLG70Qpt3mFIPNjIupB/gOlrO8y4
142Cs2zKbORoeZNWZOzwBdHOVVptQ+3ZgbA33KqxDKpGrHW7a+soVjX68k3ni+Vyi3+SfXAZiVDS
ip13wPzG77dexxvwB+dK+fWE+dMmXl6OsENbvKVXoIoTrKyLcTNyc3YXkjTTX+EL8WvOzyMbnUcU
c08cx/65GSg/4gUP1k4QF0dAYdEMBgPAy5NdBMj8IClXqWH/DJLOZ3cFC85hL0O048jEnxXWJREO
+zhaUVUFeFP9aFoONUOp6z061GywpXmzOanNfbC2P8PKxTUKd9pZoDnkiVbaiPzv3J/qsaDVW2Uc
neu8v1NH7hz3BZtQbWK6gJtitLOCkzPfvZeZ17Yifxo5lHRqclPrcyFnb02shPPl+F2Qjx1x1pCm
EHgq3inRU9GFezukV2A+LOCo0Nzil5enjsjO5e4AAAAAxrRLRVfUxOUAAfmYAYapCY5Po0uxxGf7
AgAAAAAEWVo=
--001636b14767451d8804a12be8aa--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
