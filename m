Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 9EE266B0005
	for <linux-mm@kvack.org>; Sun, 20 Jan 2013 11:03:55 -0500 (EST)
References: <1334483226.20721.YahooMailNeo@web162003.mail.bf1.yahoo.com> <CAFLxGvwJCMoiXFn3OgwiX+B50FTzGZmo6eG3xQ1KaPsEVZVA1g@mail.gmail.com> <1334490429.67558.YahooMailNeo@web162006.mail.bf1.yahoo.com> <CAFLxGvz5tmEi-39CZbJN+0zNd3ZpHXzZcNSFUpUWS_aMDJ4t6Q@mail.gmail.com> <20120418211032.47b243da@pyramind.ukuu.org.uk> <1334842941.92324.YahooMailNeo@web162006.mail.bf1.yahoo.com> <1358091177.96940.YahooMailNeo@web160103.mail.bf1.yahoo.com>
Message-ID: <1358697833.56285.YahooMailNeo@web160102.mail.bf1.yahoo.com>
Date: Sun, 20 Jan 2013 08:03:53 -0800 (PST)
From: PINTU KUMAR <pintu_agarwal@yahoo.com>
Reply-To: PINTU KUMAR <pintu_agarwal@yahoo.com>
Subject: Re: Introducing Aggressive Low Memory Booster [1]
In-Reply-To: <1358091177.96940.YahooMailNeo@web160103.mail.bf1.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "pintu.k@samsung.com" <pintu.k@samsung.com>, Anton Vorontsov <anton.vorontsov@linaro.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, richard -rw- weinberger <richard.weinberger@gmail.com>, "patches@linaro.org" <patches@linaro.org>, Mel Gorman <mgorman@suse.de>, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Hi,=0A=0ACan anybody provide any inputs/suggestions/improvements on the fol=
lowing.=0A=0AAccording to my experiments these proved to be a useful utilit=
y during low memory condition on the embedded devices.=0AIs there something=
 wrong I am doing?=0A=0APlease provide your suggestions.=0A=0AThanks,=0APin=
tu=0A=0A=0A=0A>________________________________=0A> From: PINTU KUMAR <pint=
u_agarwal@yahoo.com>=0A>To: "linux-mm@kvack.org" <linux-mm@kvack.org>; "lin=
ux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org> =0A>Cc: "linux-ar=
m-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>; "pint=
u.k@samsung.com" <pintu.k@samsung.com>; Anton Vorontsov <anton.vorontsov@li=
naro.org>; Alan Cox <alan@lxorguk.ukuu.org.uk>; richard -rw- weinberger <ri=
chard.weinberger@gmail.com>; "patches@linaro.org" <patches@linaro.org>; Mel=
 Gorman <mgorman@suse.de>; Wanpeng Li <liwanp@linux.vnet.ibm.com> =0A>Sent:=
 Sunday, 13 January 2013 9:02 PM=0A>Subject: Introducing Aggressive Low Mem=
ory Booster [1]=0A> =0A>=0A>Hi,=0A>=0A>=0A>Here I am trying to introduce a =
new feature in kernel called "Aggressive Low Memory Booster".=0A>The main a=
dvantage of this will be to boost the available free memory of the system t=
o "certain level" during extremely low memory condition.=0A>=0A>=0A>Please =
provide your comments to improve further.=0A>Can it be used along with vmpr=
essure_fd ???=0A>=0A>=0A>=0A>It can be invoked as follows:=0A>=A0=A0=A0 a) =
Automatically by kernel memory management when the memory threshold falls b=
elow 10MB.=0A>=A0=A0=A0 b) From user space program/scripts by passing the "=
required amount of memory to be reclaimed".=0A>=A0=A0=A0 Example: echo 100 =
> /dev/shrinkmem=0A>=A0=A0=A0 c) using sys interface - /sys/kernel/debug/sh=
rinkallmem=0A>=A0=A0=A0 d) using an ioctl call and returning number of page=
s reclaimed.=0A>=A0=A0=A0 e) using a new system call - shrinkallmem(&nrpage=
s);=0A>=A0=A0=A0 f) During CMA to reclaim and shrink a specific CMA regions=
.=0A>=0A>=0A>=0A>I have developed a kernel module to verify the (b) part.=
=0A>=0A>=0A>Here is the snapshot of the write call:=0A>+static ssize_t shri=
nkmem_write(struct file *file, const char *buff,=0A>+=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 si=
ze_t length, loff_t *pos)=0A>+{=0A>+=A0=A0=A0=A0=A0=A0=A0 int ret =3D -1;=
=0A>+=A0=A0=A0=A0=A0=A0=A0 unsigned long memsize =3D 0;=0A>+=A0=A0=A0=A0=A0=
=A0=A0 unsigned long nr_reclaim =3D 0;=0A>+=A0=A0=A0=A0=A0=A0=A0 unsigned l=
ong pages =3D 0;=0A>+=A0=A0=A0=A0=A0=A0=A0 ret =3D kstrtoul_from_user(buff,=
 length, 0, &memsize);=0A>+=A0=A0=A0=A0=A0=A0=A0 if (ret < 0) {=0A>+=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 printk(KERN_ERR "[SHRINKMEM]: kstrt=
oul_from_user: Failed !\n");=0A>+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0 return=0A-1;=0A>+=A0=A0=A0=A0=A0=A0=A0 }=0A>+=A0=A0=A0=A0=A0=A0=A0 prin=
tk(KERN_INFO "[SHRINKMEM]: memsize(in MB) =3D %ld\n",=0A>+=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0 (unsigned long)memsize);=0A>+=A0=A0=A0=A0=A0=A0=A0 memsize =3D memsize*=
(1024UL*1024UL);=0A>+=A0=A0=A0=A0=A0=A0=A0 nr_reclaim =3D memsize / PAGE_SI=
ZE;=0A>+=A0=A0=A0=A0=A0=A0=A0 pages =3D shrink_all_memory(nr_reclaim);=0A>+=
=A0=A0=A0=A0=A0=A0=A0 printk(KERN_INFO "<SHRINKMEM>: Number of Pages Freed:=
 %lu\n", pages);=0A>+=A0=A0=A0=A0=A0=A0=A0 return pages;=0A>+}=0A>Please no=
te: This requires CONFIG_HIBERNATION to be permanently enabled in the kerne=
l.=0A>=0A>=0A>Several experiments have been performed on Ubuntu(kernel 3.3)=
 to verify it under low memory conditions.=0A>=0A>=0A>Following are some re=
sults obtained:=0A>-------------------------------------=0A>=0A>Node 0, zon=
e=A0=A0=A0=A0=A0 DMA=A0=A0=A0 290=A0=A0=A0 115=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=
=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=
=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=0A>Node 0, zone=A0=A0 N=
ormal=A0=A0=A0 304=A0=A0=A0 540=A0=A0=A0 116=A0=A0=A0=A0 13=A0=A0=A0=A0=A0 =
2=A0=A0=A0=A0=A0 2=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=
=A0=A0=A0 0=A0=A0=A0=A0=A0 0=0A>=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=0A>=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 t=
otal=A0=A0=A0=A0=A0=A0=0Aused=A0=A0=A0=A0=A0=A0 free=A0=A0=A0=A0 shared=A0=
=A0=A0 buffers=A0=A0=A0=A0 cached=0A>Mem:=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 497=
=A0=A0=A0=A0=A0=A0=A0 487=A0=A0=A0=A0=A0=A0=A0=A0 10=A0=A0=A0=A0=A0=A0=A0=
=A0=A0 0=A0=A0=A0=A0=A0=A0=A0=A0 63=A0=A0=A0=A0=A0=A0=A0 303=0A>-/+ buffers=
/cache:=A0=A0=A0=A0=A0=A0=A0 120=A0=A0=A0=A0=A0=A0=A0 376=0A>Swap:=A0=A0=A0=
=A0=A0=A0=A0=A0 1458=A0=A0=A0=A0=A0=A0=A0=A0 34=A0=A0=A0=A0=A0=A0 1424=0A>T=
otal:=A0=A0=A0=A0=A0=A0=A0 1956=A0=A0=A0=A0=A0=A0=A0 522=A0=A0=A0=A0=A0=A0 =
1434=0A>=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=0A>Total Memory Freed: 342 MB=0A>Total Memory Freed: 53 MB=0A>Tot=
al=0AMemory Freed: 23 MB=0A>Total Memory Freed: 10 MB=0A>Total Memory Freed=
: 15 MB=0A>Total Memory Freed: -1 MB=0A>Node 0, zone=A0=A0=A0=A0=A0 DMA=A0=
=A0=A0=A0=A0 6=A0=A0=A0=A0=A0 6=A0=A0=A0=A0=A0 7=A0=A0=A0=A0=A0 8=A0=A0=A0=
=A0 10=A0=A0=A0=A0=A0 9=A0=A0=A0=A0=A0 7=A0=A0=A0=A0=A0 4=A0=A0=A0=A0=A0 1=
=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=0A>Node 0, zone=A0=A0 Normal=A0=A0 2129=
=A0=A0 2612=A0=A0 2166=A0=A0 1723=A0=A0 1260=A0=A0=A0 759=A0=A0=A0 359=A0=
=A0=A0 108=A0=A0=A0=A0 10=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=0A>=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=0A>=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 total=A0=A0=A0=A0=A0=A0=0Aused=A0=A0=A0=A0=
=A0=A0 free=A0=A0=A0=A0 shared=A0=A0=A0 buffers=A0=A0=A0=A0 cached=0A>Mem:=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 497=A0=A0=A0=A0=A0=A0=A0=A0 47=A0=A0=A0=A0=
=A0=A0=A0 449=A0=A0=A0=A0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0=A0=A0=A0=A0 0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0 5=0A>-/+ buffers/cache:=A0=A0=A0=A0=A0=A0=A0=A0 41=
=A0=A0=A0=A0=A0=A0=A0 455=0A>Swap:=A0=A0=A0=A0=A0=A0=A0=A0 1458=A0=A0=A0=A0=
=A0=A0=A0=A0 97=A0=A0=A0=A0=A0=A0 1361=0A>Total:=A0=A0=A0=A0=A0=A0=A0 1956=
=A0=A0=A0=A0=A0=A0=A0 145=A0=A0=A0=A0=A0=A0 1811=0A>=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=0A>=0A>=0A>It was ve=
rified using a sample shell script "reclaim_memory.sh" which keeps recoveri=
ng memory by doing "echo 500 > /dev/shrinkmem" until no further reclaim is =
possible.=0A>=0A>=0A>The experiments were performed with various scenarios =
as follows:=0A>a) Just after the boot up - (could recover around 150MB with=
 512MB RAM)=0A>b) After running many applications include youtube videos, l=
arge tar files download - =0A>=0A>=A0=A0 [until free mem becomes < 10MB]=0A=
>=A0=A0 [Could recover around 300MB in one shot]=0A>c) Run reclaim, while d=
ownload is in progress and video still playing - (Not applications killed)=
=0A>=0A>d) revoke all background applications again, after running reclaim =
- (No impact, normal behavior)=0A>=A0=A0 [Just it took little extra time to=
 launch, as if it was launched for first time]=0A>=0A>=0A>=0A>=0A>Please se=
e more discussions on this in the last year mailing list:=0A>=0A>https://lk=
ml.org/lkml/2012/4/15/35=0A>=0A>=0A>=0A>Thank You!=0A>With regards,=0A>Pint=
u Kumar=0A>Samsung - India=0A>=0A>=0A>=0A>=0A>=0A>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
