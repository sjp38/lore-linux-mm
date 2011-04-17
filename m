Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 33285900086
	for <linux-mm@kvack.org>; Sun, 17 Apr 2011 00:47:02 -0400 (EDT)
Received: by qwa26 with SMTP id 26so2980882qwa.14
        for <linux-mm@kvack.org>; Sat, 16 Apr 2011 21:47:00 -0700 (PDT)
MIME-Version: 1.0
Reply-To: sedat.dilek@gmail.com
In-Reply-To: <20110417041003.GA17032@localhost>
References: <20110416132546.765212221@intel.com>
	<BANLkTimY3t6Kc-+=00k3QR+AK2uqJpph4g@mail.gmail.com>
	<20110417014430.GA9419@localhost>
	<BANLkTik+Bcw7uz9aMi6OrAzwg1rJZmJL0Q@mail.gmail.com>
	<20110417041003.GA17032@localhost>
Date: Sun, 17 Apr 2011 06:46:58 +0200
Message-ID: <BANLkTikAu1iZ38Gm-Wzk9wS1g7femXet9g@mail.gmail.com>
Subject: Re: [PATCH 00/12] IO-less dirty throttling v7
From: Sedat Dilek <sedat.dilek@googlemail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Sun, Apr 17, 2011 at 6:10 AM, Wu Fengguang <fengguang.wu@intel.com> wrot=
e:
> On Sun, Apr 17, 2011 at 11:18:43AM +0800, Sedat Dilek wrote:
>> On Sun, Apr 17, 2011 at 3:44 AM, Wu Fengguang <fengguang.wu@intel.com> w=
rote:
>> > Hi Sedat,
>> >
>> > On Sun, Apr 17, 2011 at 12:27:58AM +0800, Sedat Dilek wrote:
>> >
>> >> I pulled your tree into linux-next (next-20110415) on an i386 Debian =
host.
>> >>
>> >> My build breaks here:
>> >> ...
>> >> =C2=A0 MODPOST vmlinux.o
>> >> =C2=A0 GEN =C2=A0 =C2=A0 .version
>> >> =C2=A0 CHK =C2=A0 =C2=A0 include/generated/compile.h
>> >> =C2=A0 UPD =C2=A0 =C2=A0 include/generated/compile.h
>> >> =C2=A0 CC =C2=A0 =C2=A0 =C2=A0init/version.o
>> >> =C2=A0 LD =C2=A0 =C2=A0 =C2=A0init/built-in.o
>> >> =C2=A0 LD =C2=A0 =C2=A0 =C2=A0.tmp_vmlinux1
>> >> mm/built-in.o: In function `bdi_position_ratio':
>> >> page-writeback.c:(.text+0x5c83): undefined reference to `__udivdi3'
>> >
>> > Yes it can be fixed by the attached patch.
>> >
>> >> mm/built-in.o: In function `calc_period_shift.part.10':
>> >> page-writeback.c:(.text+0x6446): undefined reference to `____ilog2_Na=
N'
>> >
>> > I cannot reproduce this error. In the git tree, calc_period_shift() is
>> > actually quite simple:
>> >
>> > static int calc_period_shift(void)
>> > {
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0return 2 + ilog2(default_backing_dev_info.a=
vg_write_bandwidth);
>> > }
>> >
>> > where avg_write_bandwidth is of type "unsigned long".
>> >
>> >> make[4]: *** [.tmp_vmlinux1] Error
>> >>
>> >> BTW, which kernel-config options have to be set besides
>> >> CONFIG_BLK_DEV_THROTTLING=3Dy?
>> >
>> > No. I used your kconfig on 2.6.39-rc3 and it compiles OK for i386.
>> >
>> > I've pushed two patches into the git tree fixing the compile errors.
>> > Thank you for trying it out and report!
>> >
>> > Thanks,
>> > Fengguang
>> >
>>
>> Thanks for your patch.
>>
>> The 1st part of the build-error is gone, but 2nd part still remains:
>>
>> =C2=A0 LD =C2=A0 =C2=A0 =C2=A0.tmp_vmlinux1
>> mm/built-in.o: In function `calc_period_shift.part.10':
>> page-writeback.c:(.text+0x6458): undefined reference to `____ilog2_NaN'
>> make[4]: *** [.tmp_vmlinux1] Error 1
>>
>> I have attached some disasm-ed files.
>
> OK. I tried next-20110415 and your kconfig and still got no error.
>
> Please revert the last commit. It's not necessary anyway.
>
> commit 84a9890ddef487d9c6d70934c0a2addc65923bcf
> Author: Wu Fengguang <fengguang.wu@intel.com>
> Date: =C2=A0 Sat Apr 16 18:38:41 2011 -0600
>
> =C2=A0 =C2=A0writeback: scale dirty proportions period with writeout band=
width
>
> =C2=A0 =C2=A0CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
> =C2=A0 =C2=A0Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
>
>> Unfortunately, I don't see any new commits in your GIT tree.
>
> Yeah I cannot see it in the web interface, too:
>
> http://git.kernel.org/?p=3Dlinux/kernel/git/wfg/writeback.git;a=3Dshortlo=
g;h=3Drefs/heads/dirty-throttling-v7
>
> But they are in the dirty-throttling-v7 branch at kernel.org:
>
> commit d0e30163e390d87387ec13e3b1c2168238c26793
> Author: Wu Fengguang <fengguang.wu@intel.com>
> Date: =C2=A0 Sun Apr 17 11:59:12 2011 +0800
>
> =C2=A0 =C2=A0Revert "writeback: scale dirty proportions period with write=
out bandwidth"
>
> =C2=A0 =C2=A0This reverts commit 84a9890ddef487d9c6d70934c0a2addc65923bcf=
.
>
> =C2=A0 =C2=A0sedat.dilek@gmail.com:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0LD =C2=A0 =C2=A0 =C2=A0.tmp_vmlinux1
> =C2=A0 =C2=A0 =C2=A0mm/built-in.o: In function `calc_period_shift.part.10=
':
> =C2=A0 =C2=A0 =C2=A0page-writeback.c:(.text+0x6458): undefined reference =
to `____ilog2_NaN'
> =C2=A0 =C2=A0 =C2=A0make[4]: *** [.tmp_vmlinux1] Error 1
>
> commit fc5c8b04119a5bcc46865e66eec3e6133ecb56e9
> Author: Wu Fengguang <fengguang.wu@intel.com>
> Date: =C2=A0 Sun Apr 17 09:22:41 2011 -0600
>
> =C2=A0 =C2=A0writeback: quick CONFIG_BLK_DEV_THROTTLING=3Dn compile fix
>
> =C2=A0 =C2=A0Reported-by: Sedat Dilek <sedat.dilek@googlemail.com>
> =C2=A0 =C2=A0Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
>
> commit c4a7e3f48dcfae71d0e3d2c55dcc381b3def1919
> Author: Wu Fengguang <fengguang.wu@intel.com>
> Date: =C2=A0 Sun Apr 17 09:04:44 2011 -0600
>
> =C2=A0 =C2=A0writeback: i386 compile fix
>
> =C2=A0 =C2=A0mm/built-in.o: In function `bdi_position_ratio':
> =C2=A0 =C2=A0page-writeback.c:(.text+0x5c83): undefined reference to `__u=
divdi3'
> =C2=A0 =C2=A0mm/built-in.o: In function `calc_period_shift.part.10':
> =C2=A0 =C2=A0page-writeback.c:(.text+0x6446): undefined reference to `___=
_ilog2_NaN'
> =C2=A0 =C2=A0make[4]: *** [.tmp_vmlinux1] Error
>
> =C2=A0 =C2=A0Reported-by: Sedat Dilek <sedat.dilek@googlemail.com>
> =C2=A0 =C2=A0Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
>
>
> Thanks,
> Fengguang
>

The 2nd part disappears here, when I switch from gcc-4.6 to gcc-4.5.

- Sedat -

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
