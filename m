Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id D3C306B0032
	for <linux-mm@kvack.org>; Mon,  1 Jul 2013 10:34:44 -0400 (EDT)
Received: by mail-wi0-f182.google.com with SMTP id m6so3143728wiv.3
        for <linux-mm@kvack.org>; Mon, 01 Jul 2013 07:34:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <51D0C500.4060108@jp.fujitsu.com>
References: <20130523052421.13864.83978.stgit@localhost6.localdomain6>
	<20130523052547.13864.83306.stgit@localhost6.localdomain6>
	<20130523152445.17549682ae45b5aab3f3cde0@linux-foundation.org>
	<CAJGZr0LwivLTH+E7WAR1B9_6B4e=jv04KgCUL_PdVpi9JjDpBw@mail.gmail.com>
	<51A2BBA7.50607@jp.fujitsu.com>
	<CAJGZr0LmsFXEgb3UXVb+rqo1aq5KJyNxyNAD+DG+3KnJm_ZncQ@mail.gmail.com>
	<51A71B49.3070003@cn.fujitsu.com>
	<CAJGZr0Ld6Q4a4f-VObAbvqCp=+fTFNEc6M-Fdnhh28GTcSm1=w@mail.gmail.com>
	<20130603174351.d04b2ac71d1bab0df242e0ba@mxc.nes.nec.co.jp>
	<CAJGZr0+9VUweN1Ssdq6P9Lug1GnTB3+RPv77JLRmnw=rpd9+Dw@mail.gmail.com>
	<51D0C500.4060108@jp.fujitsu.com>
Date: Mon, 1 Jul 2013 18:34:43 +0400
Message-ID: <CAJGZr0Jwy6OLADBO9GExWVbwG_LMk41ZsSMZKvWmwcA9StVZQA@mail.gmail.com>
Subject: Re: [PATCH v8 9/9] vmcore: support mmap() on /proc/vmcore
From: Maxim Uvarov <muvarov@gmail.com>
Content-Type: multipart/alternative; boundary=f46d044282a61c4c6504e07421a4
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
Cc: Atsushi Kumagai <kumagai-atsushi@mxc.nes.nec.co.jp>, riel@redhat.com, kexec@lists.infradead.org, hughd@google.com, linux-kernel@vger.kernel.org, lisa.mitchell@hp.com, vgoyal@redhat.com, linux-mm@kvack.org, zhangyanfei@cn.fujitsu.com, ebiederm@xmission.com, kosaki.motohiro@jp.fujitsu.com, akpm@linux-foundation.org, walken@google.com, cpw@sgi.com, jingbai.ma@hp.com

--f46d044282a61c4c6504e07421a4
Content-Type: text/plain; charset=ISO-8859-1

2013/7/1 HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>

> (2013/06/29 1:40), Maxim Uvarov wrote:
>
>> Did test on 1TB machine. Total vmcore capture and save took 143 minutes
>> while vmcore size increased from 9Gb to 59Gb.
>>
>> Will do some debug for that.
>>
>> Maxim.
>>
>
> Please show me your kdump configuration file and tell me what you did in
> the test and how you confirmed the result.
>
>
Hello Hatayama,

I re-run tests in dev env. I took your latest kernel patchset from
patchwork for vmcore + devel branch of makedumpfile + fix to open and write
to /dev/null. Run this test on 1Tb memory machine with memory used by some
user space processes. crashkernel=384M.

Please see my results for makedumpfile process work:
[gzip compression]
-c -d31 /dev/null
real 37.8 m
user 29.51 m
sys 7.12 m

[no compression]
-d31 /dev/null
real 27 m
user 23 m
sys   4 m

[no compression, disable cyclic mode]
-d31 --non-cyclic /dev/null
real 26.25 m
user 23 m
sys 3.13 m

[gzip compression]
-c -d31 /dev/null
% time     seconds  usecs/call     calls    errors syscall
------ ----------- ----------- --------- --------- ----------------
 54.75   38.840351         110    352717           mmap
 44.55   31.607620          90    352716         1 munmap
  0.70    0.497668           0  25497667           brk
  0.00    0.000356           0    111920           write
  0.00    0.000280           0    111904           lseek
  0.00    0.000025           4         7           open
  0.00    0.000000           0       473           read
  0.00    0.000000           0         7           close
  0.00    0.000000           0         3           fstat
  0.00    0.000000           0         1           getpid
  0.00    0.000000           0         1           execve
  0.00    0.000000           0         1           uname
  0.00    0.000000           0         2           unlink
  0.00    0.000000           0         1           arch_prctl
------ ----------- ----------- --------- --------- ----------------
100.00   70.946300              26427420         1 total


I used 2.6.39 kernel + your patches due to mine machine successfully work
with it. I think that kernel version is not sufficient here due to
/proc/vmcore is  very isolated.

Is that the same numbers which you have?

Interesting is that makedumpfile almost all time works in user space. And
in case without compression  and without disk I/O process time is not
significantly reduced. What is the bottleneck in 'copy dump' phase?

Thank you,
Maxim.




> --
> Thanks.
> HATAYAMA, Daisuke
>
>


-- 
Best regards,
Maxim Uvarov

--f46d044282a61c4c6504e07421a4
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">2013/7/1 HATAYAMA Daisuke <span dir=3D"l=
tr">&lt;<a href=3D"mailto:d.hatayama@jp.fujitsu.com" target=3D"_blank">d.ha=
tayama@jp.fujitsu.com</a>&gt;</span><br><blockquote class=3D"gmail_quote" s=
tyle=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
<div class=3D"im">(2013/06/29 1:40), Maxim Uvarov wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">
Did test on 1TB machine. Total vmcore capture and save took 143 minutes whi=
le vmcore size increased from 9Gb to 59Gb.<br>
<br>
Will do some debug for that.<br>
<br>
Maxim.<br>
</blockquote>
<br></div>
Please show me your kdump configuration file and tell me what you did in th=
e test and how you confirmed the result.<span class=3D"HOEnZb"><font color=
=3D"#888888"><br>
<br></font></span></blockquote><div><br>Hello Hatayama,<br><br>I re-run tes=
ts in dev env. I took your latest kernel patchset from patchwork for vmcore=
 + devel branch of makedumpfile + fix to open and write to /dev/null. Run t=
his test on 1Tb memory machine with memory used by some user space processe=
s. crashkernel=3D384M.<br>
<br>Please see my results for makedumpfile process work:<br>[gzip compressi=
on]<br>-c -d31 /dev/null<br>real 37.8 m<br>user 29.51 m<br>sys 7.12 m<br><b=
r>[no compression]<br>-d31 /dev/null<br>real 27 m<br>user 23 m<br>sys=A0=A0=
 4 m<br>
<br>[no compression, disable cyclic mode]<br>-d31 --non-cyclic /dev/null<br=
>real 26.25 m<br>user 23 m<br>sys 3.13 m<br><br>[gzip compression]<br>-c -d=
31 /dev/null<br>% time=A0=A0=A0=A0 seconds=A0 usecs/call=A0=A0=A0=A0 calls=
=A0=A0=A0 errors syscall<br>
------ ----------- ----------- --------- --------- ----------------<br>=A05=
4.75=A0=A0 38.840351=A0=A0=A0=A0=A0=A0=A0=A0 110=A0=A0=A0 352717=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0 mmap<br>=A044.55=A0=A0 31.607620=A0=A0=A0=A0=A0=A0=A0=
=A0=A0 90=A0=A0=A0 352716=A0=A0=A0=A0=A0=A0=A0=A0 1 munmap<br>=A0 0.70=A0=
=A0=A0 0.497668=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 0=A0 25497667=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0 brk<br>
=A0 0.00=A0=A0=A0 0.000356=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 0=A0=A0=A0 111920=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 write<br>=A0 0.00=A0=A0=A0 0.000280=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0 0=A0=A0=A0 111904=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 lseek=
<br>=A0 0.00=A0=A0=A0 0.000025=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 4=A0=A0=A0=A0=
=A0=A0=A0=A0 7=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 open<br>=A0 0.00=A0=A0=A0 0.00=
0000=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0=A0 473=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0 read<br>
=A0 0.00=A0=A0=A0 0.000000=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0=
=A0=A0=A0 7=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 close<br>=A0 0.00=A0=A0=A0 0.0000=
00=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0=A0=A0=A0 3=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0 fstat<br>=A0 0.00=A0=A0=A0 0.000000=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0 0=A0=A0=A0=A0=A0=A0=A0=A0 1=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 getpid<br>=
=A0 0.00=A0=A0=A0 0.000000=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0=
=A0=A0=A0 1=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 execve<br>
=A0 0.00=A0=A0=A0 0.000000=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0=
=A0=A0=A0 1=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 uname<br>=A0 0.00=A0=A0=A0 0.0000=
00=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0=A0=A0=A0 2=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0 unlink<br>=A0 0.00=A0=A0=A0 0.000000=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0 0=A0=A0=A0=A0=A0=A0=A0=A0 1=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 arch_pr=
ctl<br>------ ----------- ----------- --------- --------- ----------------<=
br>
100.00=A0=A0 70.946300=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 26427420=A0=
=A0=A0=A0=A0=A0=A0=A0 1 total<br><br><br>I used 2.6.39 kernel + your patche=
s due to mine machine successfully work with it. I think that kernel versio=
n is not sufficient here due to /proc/vmcore is=A0 very isolated.<br>
<br>Is that the same numbers which you have?<br><br>Interesting is that mak=
edumpfile almost all time works in user space. And in case without compress=
ion=A0 and without disk I/O process time is not significantly reduced. What=
 is the bottleneck in &#39;copy dump&#39; phase?<br>
<br>Thank you,<br>Maxim.<br><br><br>=A0</div><blockquote class=3D"gmail_quo=
te" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex"=
><span class=3D"HOEnZb"><font color=3D"#888888">
-- <br>
Thanks.<br>
HATAYAMA, Daisuke<br>
<br>
</font></span></blockquote></div><br><br clear=3D"all"><br>-- <br>Best rega=
rds,<br>Maxim Uvarov

--f46d044282a61c4c6504e07421a4--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
