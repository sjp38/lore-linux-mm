Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id ACB516B0071
	for <linux-mm@kvack.org>; Wed, 10 Feb 2010 22:32:24 -0500 (EST)
Received: by pzk5 with SMTP id 5so1540606pzk.29
        for <linux-mm@kvack.org>; Wed, 10 Feb 2010 16:45:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4B72E74C.9040001@nortel.com>
References: <4B71927D.6030607@nortel.com>
	 <20100210093140.12D9.A69D9226@jp.fujitsu.com>
	 <4B72E74C.9040001@nortel.com>
Date: Thu, 11 Feb 2010 09:45:42 +0900
Message-ID: <28c262361002101645g3fd08cc7t6a72d27b1f94db62@mail.gmail.com>
Subject: Re: tracking memory usage/leak in "inactive" field in /proc/meminfo?
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Chris Friesen <cfriesen@nortel.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Hi, Chris.

On Thu, Feb 11, 2010 at 2:05 AM, Chris Friesen <cfriesen@nortel.com> wrote:
> On 02/09/2010 06:32 PM, KOSAKI Motohiro wrote:
>
>> can you please post your /proc/meminfo?
>
>
> On 02/09/2010 09:50 PM, Balbir Singh wrote:
>> Do you have swap enabled? Can you help with the OOM killed dmesg log?
>> Does the situation get better after OOM killing.
>
>
> On 02/09/2010 10:09 PM, KOSAKI Motohiro wrote:
>
>> Chris, 2.6.27 is a bit old. plese test it on latest kernel. and please
> don't use
>> any proprietary drivers.
>
>
> Thanks for the replies.
>
> Swap is enabled in the kernel, but there is no swap configured. =C2=A0ipc=
s
> shows little consumption there.
>
> The test load relies on a number of kernel modifications, making it
> difficult to use newer kernels. (This is an embedded system.) =C2=A0There=
 are
> no closed-source drivers loaded, though there are some that are not in
> vanilla kernels. =C2=A0I haven't yet tried to reproduce the problem with =
a
> minimal load--I've been more focused on trying to understand what's
> going on in the code first. =C2=A0It's on my list to try though.
>
> Here are some /proc/meminfo outputs from a test run where we
> artificially chewed most of the free memory to try and force the oom
> killer to fire sooner (otherwise it takes days for the problem to trigger=
).
>
> It's spaced with tabs so I'm not sure if it'll stay aligned. =C2=A0The fi=
rst
> row is the sample number. =C2=A0All the HugePages entries were 0. =C2=A0T=
he
> DirectMap entries were constant. SwapTotal/SwapFree/SwapCached were 0,
> as were Writeback/NFS_Unstable/Bounce/WritebackTmp.
>
> Samples were taken 10 minutes apart. =C2=A0Between samples 49 and 50 the
> oom-killer fired.
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A013 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A049 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A050
> MemTotal =C2=A0 =C2=A0 =C2=A0 =C2=A04042848 =C2=A0 =C2=A0 =C2=A0 =C2=A0 4=
042848 =C2=A0 =C2=A0 =C2=A0 =C2=A0 4042848
> MemFree =C2=A0 =C2=A0 =C2=A0 =C2=A0 113512 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A052668 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 69536
> Buffers =C2=A0 =C2=A0 =C2=A0 =C2=A0 20 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A024 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A076
> Cached =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A01285588 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 1287456 =C2=A0 =C2=A0 =C2=A0 =C2=A0 1295128
> Active =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A02883224 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 3369440 =C2=A0 =C2=A0 =C2=A0 =C2=A0 2850172
> Inactive =C2=A0 =C2=A0 =C2=A0 =C2=A0913756 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0487944 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0990152
> Dirty =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 36 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0216 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 252
> AnonPages =C2=A0 =C2=A0 =C2=A0 2274756 =C2=A0 =C2=A0 =C2=A0 =C2=A0 230544=
8 =C2=A0 =C2=A0 =C2=A0 =C2=A0 2279216
> Mapped =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A010804 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 12772 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 15760
> Slab =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A062324 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 62568 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 63608
> SReclaimable =C2=A0 =C2=A024092 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 23912 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 24848
> SUnreclaim =C2=A0 =C2=A0 =C2=A038232 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 3=
8656 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 38760
> PageTables =C2=A0 =C2=A0 =C2=A011960 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 1=
2144 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 11848
> CommitLimit =C2=A0 =C2=A0 2021424 =C2=A0 =C2=A0 =C2=A0 =C2=A0 2021424 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 2021424
> Committed_AS =C2=A0 =C2=A012666508 =C2=A0 =C2=A0 =C2=A0 =C2=A012745200 =
=C2=A0 =C2=A0 =C2=A0 =C2=A07700484
> VmallocUsed =C2=A0 =C2=A0 23256 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 23256 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 23256
>
> It's hard to get a good picture from just a few samples, so I've
> attached an ooffice spreadsheet showing three separate runs. =C2=A0The
> samples above are from sheet 3 in the document.
>
> In those spreadsheets I notice that
> memfree+active+inactive+slab+pagetables is basically a constant.
> However, if I don't use active+inactive then I can't make the numbers
> add up. =C2=A0And the difference between active+inactive and
> buffers+cached+anonpages+dirty+mapped+pagetables+vmallocused grows
> almost monotonically.

Such comparison is not right. That's because code pages of program account
with cached and mapped but they account just one in lru list(active +
inactive).
Also, if you use mmap on any file, above is applied.

I can't find any clue with your attachment.
You said you used kernel with some modification and non-vanilla drivers.
So I suspect that. Maybe kernel memory leak?

Now kernel don't account kernel memory allocations except SLAB.
I think this patch can help you find the kernel memory leak.
(It isn't merged with mainline by somewhy but it is useful to you :)

http://marc.info/?l=3Dlinux-mm&m=3D123782029809850&w=3D2


>
> Thanks,
>
> Chris
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
