Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 4026D900086
	for <linux-mm@kvack.org>; Sun, 17 Apr 2011 02:46:07 -0400 (EDT)
Received: by qyk30 with SMTP id 30so2993011qyk.14
        for <linux-mm@kvack.org>; Sat, 16 Apr 2011 23:46:05 -0700 (PDT)
MIME-Version: 1.0
Reply-To: sedat.dilek@gmail.com
In-Reply-To: <BANLkTikAu1iZ38Gm-Wzk9wS1g7femXet9g@mail.gmail.com>
References: <20110416132546.765212221@intel.com>
	<BANLkTimY3t6Kc-+=00k3QR+AK2uqJpph4g@mail.gmail.com>
	<20110417014430.GA9419@localhost>
	<BANLkTik+Bcw7uz9aMi6OrAzwg1rJZmJL0Q@mail.gmail.com>
	<20110417041003.GA17032@localhost>
	<BANLkTikAu1iZ38Gm-Wzk9wS1g7femXet9g@mail.gmail.com>
Date: Sun, 17 Apr 2011 08:46:04 +0200
Message-ID: <BANLkTimWhWfp=44wD-rucgZ-Qx_i1NLUHQ@mail.gmail.com>
Subject: Re: [PATCH 00/12] IO-less dirty throttling v7
From: Sedat Dilek <sedat.dilek@googlemail.com>
Content-Type: multipart/mixed; boundary=0050450161c306b5ba04a117a1ea
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

--0050450161c306b5ba04a117a1ea
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Sun, Apr 17, 2011 at 6:46 AM, Sedat Dilek <sedat.dilek@googlemail.com> w=
rote:
> On Sun, Apr 17, 2011 at 6:10 AM, Wu Fengguang <fengguang.wu@intel.com> wr=
ote:
>> On Sun, Apr 17, 2011 at 11:18:43AM +0800, Sedat Dilek wrote:
>>> On Sun, Apr 17, 2011 at 3:44 AM, Wu Fengguang <fengguang.wu@intel.com> =
wrote:
>>> > Hi Sedat,
>>> >
>>> > On Sun, Apr 17, 2011 at 12:27:58AM +0800, Sedat Dilek wrote:
>>> >
>>> >> I pulled your tree into linux-next (next-20110415) on an i386 Debian=
 host.
>>> >>
>>> >> My build breaks here:
>>> >> ...
>>> >> =C2=A0 MODPOST vmlinux.o
>>> >> =C2=A0 GEN =C2=A0 =C2=A0 .version
>>> >> =C2=A0 CHK =C2=A0 =C2=A0 include/generated/compile.h
>>> >> =C2=A0 UPD =C2=A0 =C2=A0 include/generated/compile.h
>>> >> =C2=A0 CC =C2=A0 =C2=A0 =C2=A0init/version.o
>>> >> =C2=A0 LD =C2=A0 =C2=A0 =C2=A0init/built-in.o
>>> >> =C2=A0 LD =C2=A0 =C2=A0 =C2=A0.tmp_vmlinux1
>>> >> mm/built-in.o: In function `bdi_position_ratio':
>>> >> page-writeback.c:(.text+0x5c83): undefined reference to `__udivdi3'
>>> >
>>> > Yes it can be fixed by the attached patch.
>>> >
>>> >> mm/built-in.o: In function `calc_period_shift.part.10':
>>> >> page-writeback.c:(.text+0x6446): undefined reference to `____ilog2_N=
aN'
>>> >
>>> > I cannot reproduce this error. In the git tree, calc_period_shift() i=
s
>>> > actually quite simple:
>>> >
>>> > static int calc_period_shift(void)
>>> > {
>>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0return 2 + ilog2(default_backing_dev_info.=
avg_write_bandwidth);
>>> > }
>>> >
>>> > where avg_write_bandwidth is of type "unsigned long".
>>> >
>>> >> make[4]: *** [.tmp_vmlinux1] Error
>>> >>
>>> >> BTW, which kernel-config options have to be set besides
>>> >> CONFIG_BLK_DEV_THROTTLING=3Dy?
>>> >
>>> > No. I used your kconfig on 2.6.39-rc3 and it compiles OK for i386.
>>> >
>>> > I've pushed two patches into the git tree fixing the compile errors.
>>> > Thank you for trying it out and report!
>>> >
>>> > Thanks,
>>> > Fengguang
>>> >
>>>
>>> Thanks for your patch.
>>>
>>> The 1st part of the build-error is gone, but 2nd part still remains:
>>>
>>> =C2=A0 LD =C2=A0 =C2=A0 =C2=A0.tmp_vmlinux1
>>> mm/built-in.o: In function `calc_period_shift.part.10':
>>> page-writeback.c:(.text+0x6458): undefined reference to `____ilog2_NaN'
>>> make[4]: *** [.tmp_vmlinux1] Error 1
>>>
>>> I have attached some disasm-ed files.
>>
>> OK. I tried next-20110415 and your kconfig and still got no error.
>>
>> Please revert the last commit. It's not necessary anyway.
>>
>> commit 84a9890ddef487d9c6d70934c0a2addc65923bcf
>> Author: Wu Fengguang <fengguang.wu@intel.com>
>> Date: =C2=A0 Sat Apr 16 18:38:41 2011 -0600
>>
>> =C2=A0 =C2=A0writeback: scale dirty proportions period with writeout ban=
dwidth
>>
>> =C2=A0 =C2=A0CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
>> =C2=A0 =C2=A0Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
>>
>>> Unfortunately, I don't see any new commits in your GIT tree.
>>
>> Yeah I cannot see it in the web interface, too:
>>
>> http://git.kernel.org/?p=3Dlinux/kernel/git/wfg/writeback.git;a=3Dshortl=
og;h=3Drefs/heads/dirty-throttling-v7
>>
>> But they are in the dirty-throttling-v7 branch at kernel.org:
>>
>> commit d0e30163e390d87387ec13e3b1c2168238c26793
>> Author: Wu Fengguang <fengguang.wu@intel.com>
>> Date: =C2=A0 Sun Apr 17 11:59:12 2011 +0800
>>
>> =C2=A0 =C2=A0Revert "writeback: scale dirty proportions period with writ=
eout bandwidth"
>>
>> =C2=A0 =C2=A0This reverts commit 84a9890ddef487d9c6d70934c0a2addc65923bc=
f.
>>
>> =C2=A0 =C2=A0sedat.dilek@gmail.com:
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0LD =C2=A0 =C2=A0 =C2=A0.tmp_vmlinux1
>> =C2=A0 =C2=A0 =C2=A0mm/built-in.o: In function `calc_period_shift.part.1=
0':
>> =C2=A0 =C2=A0 =C2=A0page-writeback.c:(.text+0x6458): undefined reference=
 to `____ilog2_NaN'
>> =C2=A0 =C2=A0 =C2=A0make[4]: *** [.tmp_vmlinux1] Error 1
>>
>> commit fc5c8b04119a5bcc46865e66eec3e6133ecb56e9
>> Author: Wu Fengguang <fengguang.wu@intel.com>
>> Date: =C2=A0 Sun Apr 17 09:22:41 2011 -0600
>>
>> =C2=A0 =C2=A0writeback: quick CONFIG_BLK_DEV_THROTTLING=3Dn compile fix
>>
>> =C2=A0 =C2=A0Reported-by: Sedat Dilek <sedat.dilek@googlemail.com>
>> =C2=A0 =C2=A0Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
>>
>> commit c4a7e3f48dcfae71d0e3d2c55dcc381b3def1919
>> Author: Wu Fengguang <fengguang.wu@intel.com>
>> Date: =C2=A0 Sun Apr 17 09:04:44 2011 -0600
>>
>> =C2=A0 =C2=A0writeback: i386 compile fix
>>
>> =C2=A0 =C2=A0mm/built-in.o: In function `bdi_position_ratio':
>> =C2=A0 =C2=A0page-writeback.c:(.text+0x5c83): undefined reference to `__=
udivdi3'
>> =C2=A0 =C2=A0mm/built-in.o: In function `calc_period_shift.part.10':
>> =C2=A0 =C2=A0page-writeback.c:(.text+0x6446): undefined reference to `__=
__ilog2_NaN'
>> =C2=A0 =C2=A0make[4]: *** [.tmp_vmlinux1] Error
>>
>> =C2=A0 =C2=A0Reported-by: Sedat Dilek <sedat.dilek@googlemail.com>
>> =C2=A0 =C2=A0Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
>>
>>
>> Thanks,
>> Fengguang
>>
>
> The 2nd part disappears here, when I switch from gcc-4.6 to gcc-4.5.
>
> - Sedat -
>

Just FYI:

Build with gcc-4.6 is OK, now.

  (+) OK   writeback-dirty-throttling-v7-fix/writeback-i386-compile-fix.pat=
ch
  (+) OK   writeback-dirty-throttling-v7-fix/0001-Revert-writeback-scale-di=
rty-proportions-period-with.patch

In case of the ilog2 error I have g00gled a bit and found gcc-bug
#36359 and looked also at include/linux/log2.h [2].
Not sure if this is a gcc-4.6 bug and I shall open a ticket (or a
problem in your code?).
I have tried the testcase from [3], it gives same output for nm.
[4] I could not follow.

- Sedat -

[1] http://gcc.gnu.org/bugzilla/show_bug.cgi?id=3D36359
[2] http://git.us.kernel.org/?p=3Dlinux/kernel/git/wfg/writeback.git;a=3Dbl=
ob;f=3Dinclude/linux/log2.h#l18
[3] http://gcc.gnu.org/bugzilla/show_bug.cgi?id=3D36359#c12
[4] http://gcc.gnu.org/bugzilla/show_bug.cgi?id=3D36359#c17

--0050450161c306b5ba04a117a1ea
Content-Type: application/octet-stream; name="testcase_gcc-bug-36359.tar.xz"
Content-Disposition: attachment; filename="testcase_gcc-bug-36359.tar.xz"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gmlm2g720

/Td6WFoAAATm1rRGAgAhARYAAAB0L+Wj4Cf/A3JdADoZSs4f1m1AWwTuqiAiBCGe+e+3aWtINz2D
e+rgXJ4Nk2S+kfj4AQ2U5FE9ODepsjtsOfKaSsiidiP17qDN49D1zrKGmJubq/zTxw+mMa9QLLFK
RwtCw8QFHFc9XXd36TswiLi9Swo/0NDh3Sdl49eFxZ7SQOACktc7O2UjFNU9UTXl0OC7JEkUhu7x
ypBM3QEz4VirZkvaz3o45JRJOtboGcJDPnv4Z3JpH7tUJ45ICiNm5TPGZzzIF1BwLqMjtF5kg2sj
TGpYy8nP9NOusmCsxleHbCowzPNAgyFZaDY0AiNKjnB8+rZyzLfGVcu5KR0VXmzaeYtwYA2mQJUm
8aRaSPtFysevqDIzNvLp61RHxhy2LmOv+X8dAtosP9+19m6Eu4P7D3t52ass1xTH0jOqqTu4XOOg
5fvFiAcEG65XnFl/Joh5Kr5kZhe5ogLMmKsTzHw51OrDCoqviTl30Otzglp0Y1c6s1el/aqRpdzL
nRb7esbxS2d8AmnMuTisrxfatbKzXuyWcdoTJs6u9TVj2jBFvPLXCmpRA6gQPnLA3rwEvXyBV22f
FaUaWYZ3I4D3ieoB28AIB7/m/ZO4Thy2mVDuwqn/vIeXZnoR4IXtjGuw80HOCaL4KiYopy7YFnP3
BVSusDMxvynWgnM+FEmU1LEslO2daGrZo/uHCGYxA++i8e4GPJZop9pDv6dWrBhBOKt7pyyyybRf
i6O4wae065UG4BwtrJ4mxa2gF/YzwnXKR+lAM1gng7VPBuhRatqZ74kvcshDmCHNTfvMWrNl3WaW
qG2Vm2JH13vQcscMt0f22LiWUc2w2MUm/X2WTOxZcZNASJgkwlKnRL+lDt2kCcnyAdHgFWG88DFB
q3dB3EHNpcYvWkjtwsleobS4iijym5/9OkvQG1HheG8IaHF+mLSboJjzrdi28E6r1R1Q4ulKKsM/
ozwX0LwqFi0NOKz5FAjfszPKKJSs8/E4HeOkH/+a+lcck274Osl4TIp90WcdmngIQ+XTz30xzr66
5Rz+EmqVIMn1W63t75TctjRUL29zDPGU0jrTFqYHiHrMuVfUg995UT4C7WEgyKYEuhGiySFUpCaX
MODm/B+/sD4x+mB0RZdBKNbE5FpoXJRWzs4ytfLvZwfyRhhCyG0Nr2haMnDgQ9KojvnPaAX6Z2wl
AAAAACVvYa4DlRcOAAGOB4BQAADu5SrUscRn+wIAAAAABFla
--0050450161c306b5ba04a117a1ea
Content-Type: application/octet-stream;
	name="testcase_gcc-bug-36359.tar.xz.sha256sum"
Content-Disposition: attachment;
	filename="testcase_gcc-bug-36359.tar.xz.sha256sum"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gmlm2moz1

YzVhYjJjMjk0MjA3NzJkNDllNDk0MmVjNzI5OTlmNDJiODM5M2QxNGM3NzYyNDI3YWMzODVlZGFh
ODkzNmFmMiAgdGVzdGNhc2VfZ2NjLWJ1Zy0zNjM1OS50YXIueHoK
--0050450161c306b5ba04a117a1ea--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
