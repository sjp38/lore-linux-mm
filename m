Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 87BDC6B004A
	for <linux-mm@kvack.org>; Sun, 15 Apr 2012 05:47:07 -0400 (EDT)
Message-ID: <1334483226.20721.YahooMailNeo@web162003.mail.bf1.yahoo.com>
Date: Sun, 15 Apr 2012 02:47:06 -0700 (PDT)
From: PINTU KUMAR <pintu_agarwal@yahoo.com>
Reply-To: PINTU KUMAR <pintu_agarwal@yahoo.com>
Subject: [NEW]: Introducing shrink_all_memory from user space
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "pintu.k@samsung.com" <pintu.k@samsung.com>

Dear All,=0A=0AThis is regarding a small proposal for shrink_all_memory( ) =
function which is found in mm/vmscan.c.=0AFor those who are not aware, this=
 function helps in reclaiming specified amount of physical memory and retur=
ns number of freed pages.=0A=0ACurrently this function is under CONFIG_HIBE=
RNATION flag, so cannot be used by others without enabling hibernation.=0AM=
oreover this function is not exported to the outside world, so no driver ca=
n use it directly without including EXPORT_SYMBOL(shrink_all_memory) and re=
compiling the kernel.=0AThe purpose of using it under hibernation(kernel/po=
wer/snapshot.c) is to regain enough physical pages to create hibernation im=
age.=0A=0AThe same can be useful for some drivers who wants to allocate lar=
ge contiguous memory (in MBs) but his/her system is in very bad state and c=
ould not do so without rebooting.=0ADue to this bad state of the system the=
 user space application will be badly hurt on performance, and there could =
be a need to quickly reclaim all physical memory from user space.=0AThis co=
uld be very helpful for small embedded products and smart phones where rebo=
oting is never a preferred choice.=0A=0AWith this support in kernel, a smal=
l utility can be developed in user space which user can run and reclaim as =
many physical pages and noticed that his system performance is increased wi=
thout rebooting.=0A=0ATo make this work, I have performed a sample experime=
nt on my ubuntu(10.x) machine running with kernel-3.3.0. =0A=0AAlso I perfo=
rmed the similar experiment of one of our Samsung smart phones as well.=0A=
=0AFollowing are the results from Ubuntu:=0A=0A1) I downloaded kernel3.3.0 =
and made the respective changes in mm/vmscan.c. That is added EXPORT_SYMBOL=
(shrink_all_memory) under the function shrink_all_memory( ).=0A=A0=A0=A0 (N=
ote: CONFIG_HIBERNATION was already enabled for my system.)=0A=0A2) Then I =
build the kernel and installed it on my Ubuntu PC.=0A=0A3) After that I hav=
e developed a small kernel module (miscdevice: /dev/shrinkmem) to call shri=
nk_all_memory( ) under my driver write( ) function.=0A=0A4) Then from user =
space I just need to do this: =0A=0A=A0=A0=A0 # echo 100 > /dev/shrinkmem=
=A0=A0 (To reclaim 100MB of physical memory without reboot)=0A=0A=0AThe res=
ults that were obtained with this experiment is as follows:=0A=0A1) At some=
 point of time, the buddyinfo and free pages on my Ubuntu were as follows:=
=0Aroot@pintu-ubuntu:~/PintuHomeTest/KERNEL_ORG# cat /proc/buddyinfo ; free=
 -tmNode 0, zone=A0=A0=A0=A0=A0 DMA=A0=A0=A0 468=A0=A0=A0=A0 23=A0=A0=A0=A0=
=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=
=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=0ANode=
 0, zone=A0=A0 Normal=A0=A0=A0 898=A0=A0=A0 161=A0=A0=A0=A0 38=A0=A0=A0=A0=
=A0 8=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=
=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=0A=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0 =A0=A0=A0 total=A0=A0=A0=A0=A0=A0 used=A0=A0=A0=A0=A0=A0 fr=
ee=A0=A0=A0=A0 shared=A0=A0=A0 buffers=A0=A0=A0=A0 cached=0AMem:=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0 497=A0=A0=A0=A0=A0=A0=A0 489=A0=A0=A0=A0=A0=A0=A0=A0=
=A0 7=A0=A0=A0=A0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0=A0=A0=A0 37=A0=A0=A0=A0=
=A0=A0=A0 405=0A-/+ buffers/cache:=A0=A0=A0=A0=A0=A0=A0=A0 47=A0=A0=A0=A0=
=A0=A0=A0 449=0ASwap:=A0=A0=A0=A0=A0=A0=A0=A0 1458=A0=A0=A0=A0=A0=A0=A0 158=
=A0=A0=A0=A0=A0=A0 1300=0ATotal:=A0=A0=A0=A0=A0=A0=A0 1956=A0=A0=A0=A0=A0=
=A0=A0 648=A0=A0=A0=A0=A0=A0 1308=0A=0A=0A2) After doing "echo 100 > /dev/s=
hrinkmem" :=0A[19653.833916] [SHRINKMEM]: memsize(in MB) =3D 100=0A[19653.8=
63618] <SHRINKMEM>: Number of Pages Freed: 26756=0A[19653.863664] [SHRINKME=
M] : Device is Closed....=0A=0ANode 0, zone=A0=A0=A0=A0=A0 DMA=A0=A0=A0 411=
=A0=A0=A0 166=A0=A0=A0=A0 51=A0=A0=A0=A0=A0 5=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=
=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=
=A0=A0=A0=A0=A0 0=0ANode 0, zone=A0=A0 Normal=A0=A0 2915=A0=A0 3792=A0=A0 2=
475=A0=A0 1335=A0=A0=A0 730=A0=A0=A0=A0 23=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 =
0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=0A=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0 =A0=A0=A0 total=A0=A0=A0=A0=A0=A0 used=A0=A0=A0=A0=A0=A0=
 free=A0=A0=A0=A0 shared=A0=A0=A0 buffers=A0=A0=A0=A0 cached=0AMem:=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0 497=A0=A0=A0=A0=A0=A0=A0 323=A0=A0=A0=A0=A0=A0=A0 =
173=A0=A0=A0=A0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0=A0=A0=A0 37=A0=A0=A0=A0=A0=
=A0=A0 238=0A-/+ buffers/cache:=A0=A0=A0=A0=A0=A0=A0=A0 47=A0=A0=A0=A0=A0=
=A0=A0 449=0ASwap:=A0=A0=A0=A0=A0=A0=A0=A0 1458=A0=A0=A0=A0=A0=A0=A0 158=A0=
=A0=A0=A0=A0=A0 1300=0ATotal:=A0=A0=A0=A0=A0=A0=A0 1956=A0=A0=A0=A0=A0=A0=
=A0 481=A0=A0=A0=A0=A0=A0 1474=0A=0A=0A3) After running again with : echo 5=
12 > /dev/shrinkmem=0A[21961.064534] [SHRINKMEM]: memsize(in MB) =3D 512=0A=
[21961.109497] <SHRINKMEM>: Number of Pages Freed: 61078=0A[21961.109562] [=
SHRINKMEM] : Device is Closed....=0ANode 0, zone=A0=A0=A0=A0=A0 DMA=A0=A0=
=A0 116=A0=A0=A0=A0 99=A0=A0=A0=A0 87=A0=A0=A0=A0 58=A0=A0=A0=A0 16=A0=A0=
=A0=A0=A0 6=A0=A0=A0=A0=A0 1=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=
=A0 0=A0=A0=A0=A0=A0 0=0ANode 0, zone=A0=A0 Normal=A0=A0 6697=A0=A0 6939=A0=
=A0 5529=A0=A0 3756=A0=A0 1442=A0=A0=A0 203=A0=A0=A0=A0 17=A0=A0=A0=A0=A0 0=
=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=0A=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0 =A0=A0=A0 total=A0=A0=A0=A0=A0=A0 used=A0=A0=A0=A0=A0=A0 fr=
ee=A0=A0=A0=A0 shared=A0=A0=A0 buffers=A0=A0=A0=A0 cached=0AMem:=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0 497=A0=A0=A0=A0=A0=A0=A0=A0 87=A0=A0=A0=A0=A0=A0=A0 4=
10=A0=A0=A0=A0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0=A0=A0=A0 37=A0=A0=A0=A0=A0=
=A0=A0=A0=A0 9=0A-/+ buffers/cache:=A0=A0=A0=A0=A0=A0=A0=A0 40=A0=A0=A0=A0=
=A0=A0=A0 456=0ASwap:=A0=A0=A0=A0=A0=A0=A0=A0 1458=A0=A0=A0=A0=A0=A0=A0 158=
=A0=A0=A0=A0=A0=A0 1300=0ATotal:=A0=A0=A0=A0=A0=A0=A0 1956=A0=A0=A0=A0=A0=
=A0=A0 245=A0=A0=A0=A0=A0=A0 1711=0A=0A=0A4) Thus in both the cases huge nu=
mber of free pages were reclaimed. =0A=0A5) After running this on my system=
, the performance was improved quickly.=0A=0A6) I performed the same experi=
ment on our Samsung Smart phones as well. And I have seen a drastic improve=
 in performance after running this for 3/4 times.=0A=A0=A0=A0 In case of ph=
ones it is more helpful as there is no swap space.=0A=0A7) Your feedback an=
d suggestion is important. Based on the feedback, I can plan to submit the =
patches officially after performing basic cleanups.=0A=0A=0AFuture Work=0A=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=0AOur final goal is to use it during lowmem =
notifier where shrink_all_memory will be called automatically in background=
 if the memory pressure falls below certain limit defined by the system.=0A=
For example we can measure the percentage memory fragmentation level of the=
 system across each zone and if the fragmentation percentage goes above say=
 80-85% during lowmem notifier, we can invoke shrink_all_memory() in backgr=
ound.=0A=0AThis can be used by some application which requires large mmap o=
r shared memory mapping.=0A=0AThis can be even using inside the multimedia =
drivers that requires large contiguous memory to check if that many memory =
pages can be reclaimed or not.=0A=0A=0APlease provide your valuable feedbac=
k and suggestion.=0A=0A=0AThank you very much !=0A=0A=0AWith Regards,=0APin=
tu Kumar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
