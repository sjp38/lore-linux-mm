Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 52B306B0106
	for <linux-mm@kvack.org>; Mon, 16 Apr 2012 14:50:34 -0400 (EDT)
Received: by lbbgp10 with SMTP id gp10so2145985lbb.14
        for <linux-mm@kvack.org>; Mon, 16 Apr 2012 11:50:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1334483226.20721.YahooMailNeo@web162003.mail.bf1.yahoo.com>
References: <1334483226.20721.YahooMailNeo@web162003.mail.bf1.yahoo.com>
Date: Mon, 16 Apr 2012 11:50:31 -0700
Message-ID: <CALWz4izONZq7gOz-h0MWqEgyuOF8PQEmP3FAMp_rKLcKx3X01Q@mail.gmail.com>
Subject: Re: [NEW]: Introducing shrink_all_memory from user space
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: PINTU KUMAR <pintu_agarwal@yahoo.com>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "pintu.k@samsung.com" <pintu.k@samsung.com>

On Sun, Apr 15, 2012 at 2:47 AM, PINTU KUMAR <pintu_agarwal@yahoo.com> wrot=
e:
> Dear All,
>
> This is regarding a small proposal for shrink_all_memory( ) function whic=
h is found in mm/vmscan.c.
> For those who are not aware, this function helps in reclaiming specified =
amount of physical memory and returns number of freed pages.
>
> Currently this function is under CONFIG_HIBERNATION flag, so cannot be us=
ed by others without enabling hibernation.
> Moreover this function is not exported to the outside world, so no driver=
 can use it directly without including EXPORT_SYMBOL(shrink_all_memory) and=
 recompiling the kernel.
> The purpose of using it under hibernation(kernel/power/snapshot.c) is to =
regain enough physical pages to create hibernation image.
>
> The same can be useful for some drivers who wants to allocate large conti=
guous memory (in MBs) but his/her system is in very bad state and could not=
 do so without rebooting.
> Due to this bad state of the system the user space application will be ba=
dly hurt on performance, and there could be a need to quickly reclaim all p=
hysical memory from user space.
> This could be very helpful for small embedded products and smart phones w=
here rebooting is never a preferred choice.
>
> With this support in kernel, a small utility can be developed in user spa=
ce which user can run and reclaim as many physical pages and noticed that h=
is system performance is increased without rebooting.
>
> To make this work, I have performed a sample experiment on my ubuntu(10.x=
) machine running with kernel-3.3.0.
>
> Also I performed the similar experiment of one of our Samsung smart phone=
s as well.
>
> Following are the results from Ubuntu:
>
> 1) I downloaded kernel3.3.0 and made the respective changes in mm/vmscan.=
c. That is added EXPORT_SYMBOL(shrink_all_memory) under the function shrink=
_all_memory( ).
> =A0=A0=A0 (Note: CONFIG_HIBERNATION was already enabled for my system.)
>
> 2) Then I build the kernel and installed it on my Ubuntu PC.
>
> 3) After that I have developed a small kernel module (miscdevice: /dev/sh=
rinkmem) to call shrink_all_memory( ) under my driver write( ) function.
>
> 4) Then from user space I just need to do this:
>
> =A0=A0=A0 # echo 100 > /dev/shrinkmem=A0=A0 (To reclaim 100MB of physical=
 memory without reboot)
>
>
> The results that were obtained with this experiment is as follows:
>
> 1) At some point of time, the buddyinfo and free pages on my Ubuntu were =
as follows:
> root@pintu-ubuntu:~/PintuHomeTest/KERNEL_ORG# cat /proc/buddyinfo ; free =
-tmNode 0, zone=A0=A0=A0=A0=A0 DMA=A0=A0=A0 468=A0=A0=A0=A0 23=A0=A0=A0=A0=
=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=
=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0
> Node 0, zone=A0=A0 Normal=A0=A0=A0 898=A0=A0=A0 161=A0=A0=A0=A0 38=A0=A0=
=A0=A0=A0 8=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=
=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0 total=A0=A0=A0=A0=A0=A0 us=
ed=A0=A0=A0=A0=A0=A0 free=A0=A0=A0=A0 shared=A0=A0=A0 buffers=A0=A0=A0=A0 c=
ached
> Mem:=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 497=A0=A0=A0=A0=A0=A0=A0 489=A0=A0=A0=
=A0=A0=A0=A0=A0=A0 7=A0=A0=A0=A0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0=A0=A0=A0 3=
7=A0=A0=A0=A0=A0=A0=A0 405
> -/+ buffers/cache:=A0=A0=A0=A0=A0=A0=A0=A0 47=A0=A0=A0=A0=A0=A0=A0 449
> Swap:=A0=A0=A0=A0=A0=A0=A0=A0 1458=A0=A0=A0=A0=A0=A0=A0 158=A0=A0=A0=A0=
=A0=A0 1300
> Total:=A0=A0=A0=A0=A0=A0=A0 1956=A0=A0=A0=A0=A0=A0=A0 648=A0=A0=A0=A0=A0=
=A0 1308
>
>
> 2) After doing "echo 100 > /dev/shrinkmem" :
> [19653.833916] [SHRINKMEM]: memsize(in MB) =3D 100
> [19653.863618] <SHRINKMEM>: Number of Pages Freed: 26756
> [19653.863664] [SHRINKMEM] : Device is Closed....
>
> Node 0, zone=A0=A0=A0=A0=A0 DMA=A0=A0=A0 411=A0=A0=A0 166=A0=A0=A0=A0 51=
=A0=A0=A0=A0=A0 5=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=
=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0
> Node 0, zone=A0=A0 Normal=A0=A0 2915=A0=A0 3792=A0=A0 2475=A0=A0 1335=A0=
=A0=A0 730=A0=A0=A0=A0 23=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 =
0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0 total=A0=A0=A0=A0=A0=A0 us=
ed=A0=A0=A0=A0=A0=A0 free=A0=A0=A0=A0 shared=A0=A0=A0 buffers=A0=A0=A0=A0 c=
ached
> Mem:=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 497=A0=A0=A0=A0=A0=A0=A0 323=A0=A0=A0=
=A0=A0=A0=A0 173=A0=A0=A0=A0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0=A0=A0=A0 37=A0=
=A0=A0=A0=A0=A0=A0 238
> -/+ buffers/cache:=A0=A0=A0=A0=A0=A0=A0=A0 47=A0=A0=A0=A0=A0=A0=A0 449
> Swap:=A0=A0=A0=A0=A0=A0=A0=A0 1458=A0=A0=A0=A0=A0=A0=A0 158=A0=A0=A0=A0=
=A0=A0 1300
> Total:=A0=A0=A0=A0=A0=A0=A0 1956=A0=A0=A0=A0=A0=A0=A0 481=A0=A0=A0=A0=A0=
=A0 1474
>
>
> 3) After running again with : echo 512 > /dev/shrinkmem
> [21961.064534] [SHRINKMEM]: memsize(in MB) =3D 512
> [21961.109497] <SHRINKMEM>: Number of Pages Freed: 61078
> [21961.109562] [SHRINKMEM] : Device is Closed....
> Node 0, zone=A0=A0=A0=A0=A0 DMA=A0=A0=A0 116=A0=A0=A0=A0 99=A0=A0=A0=A0 8=
7=A0=A0=A0=A0 58=A0=A0=A0=A0 16=A0=A0=A0=A0=A0 6=A0=A0=A0=A0=A0 1=A0=A0=A0=
=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0
> Node 0, zone=A0=A0 Normal=A0=A0 6697=A0=A0 6939=A0=A0 5529=A0=A0 3756=A0=
=A0 1442=A0=A0=A0 203=A0=A0=A0=A0 17=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=
=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0 total=A0=A0=A0=A0=A0=A0 us=
ed=A0=A0=A0=A0=A0=A0 free=A0=A0=A0=A0 shared=A0=A0=A0 buffers=A0=A0=A0=A0 c=
ached
> Mem:=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 497=A0=A0=A0=A0=A0=A0=A0=A0 87=A0=A0=
=A0=A0=A0=A0=A0 410=A0=A0=A0=A0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0=A0=A0=A0 37=
=A0=A0=A0=A0=A0=A0=A0=A0=A0 9
> -/+ buffers/cache:=A0=A0=A0=A0=A0=A0=A0=A0 40=A0=A0=A0=A0=A0=A0=A0 456
> Swap:=A0=A0=A0=A0=A0=A0=A0=A0 1458=A0=A0=A0=A0=A0=A0=A0 158=A0=A0=A0=A0=
=A0=A0 1300
> Total:=A0=A0=A0=A0=A0=A0=A0 1956=A0=A0=A0=A0=A0=A0=A0 245=A0=A0=A0=A0=A0=
=A0 1711
>
>
> 4) Thus in both the cases huge number of free pages were reclaimed.
>
> 5) After running this on my system, the performance was improved quickly.
>
> 6) I performed the same experiment on our Samsung Smart phones as well. A=
nd I have seen a drastic improve in performance after running this for 3/4 =
times.
> =A0=A0=A0 In case of phones it is more helpful as there is no swap space.
>
> 7) Your feedback and suggestion is important. Based on the feedback, I ca=
n plan to submit the patches officially after performing basic cleanups.
>
>
> Future Work
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> Our final goal is to use it during lowmem notifier where shrink_all_memor=
y will be called automatically in background if the memory pressure falls b=
elow certain limit defined by the system.
> For example we can measure the percentage memory fragmentation level of t=
he system across each zone and if the fragmentation percentage goes above s=
ay 80-85% during lowmem notifier, we can invoke shrink_all_memory() in back=
ground.

Does it make sense to let kswapd reclaim pages at background w/ user
configured watermark?

--Ying

>
> This can be used by some application which requires large mmap or shared =
memory mapping.
>
> This can be even using inside the multimedia drivers that requires large =
contiguous memory to check if that many memory pages can be reclaimed or no=
t.
>
>
> Please provide your valuable feedback and suggestion.
>
>
> Thank you very much !
>
>
> With Regards,
> Pintu Kumar
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
> Don't email: <a hrefmailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
