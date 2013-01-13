Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 300606B0074
	for <linux-mm@kvack.org>; Sun, 13 Jan 2013 10:32:59 -0500 (EST)
References: <1334483226.20721.YahooMailNeo@web162003.mail.bf1.yahoo.com> <CAFLxGvwJCMoiXFn3OgwiX+B50FTzGZmo6eG3xQ1KaPsEVZVA1g@mail.gmail.com> <1334490429.67558.YahooMailNeo@web162006.mail.bf1.yahoo.com> <CAFLxGvz5tmEi-39CZbJN+0zNd3ZpHXzZcNSFUpUWS_aMDJ4t6Q@mail.gmail.com> <20120418211032.47b243da@pyramind.ukuu.org.uk> <1334842941.92324.YahooMailNeo@web162006.mail.bf1.yahoo.com>
Message-ID: <1358091177.96940.YahooMailNeo@web160103.mail.bf1.yahoo.com>
Date: Sun, 13 Jan 2013 07:32:57 -0800 (PST)
From: PINTU KUMAR <pintu_agarwal@yahoo.com>
Reply-To: PINTU KUMAR <pintu_agarwal@yahoo.com>
Subject: Introducing Aggressive Low Memory Booster [1]
In-Reply-To: <1334842941.92324.YahooMailNeo@web162006.mail.bf1.yahoo.com>
MIME-Version: 1.0
Content-Type: multipart/alternative; boundary="1520606428-2004289184-1358091177=:96940"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "pintu.k@samsung.com" <pintu.k@samsung.com>, Anton Vorontsov <anton.vorontsov@linaro.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, richard -rw- weinberger <richard.weinberger@gmail.com>, "patches@linaro.org" <patches@linaro.org>, Mel Gorman <mgorman@suse.de>, Wanpeng Li <liwanp@linux.vnet.ibm.com>

--1520606428-2004289184-1358091177=:96940
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

Hi,=0A=0AHere I am trying to introduce a new feature in kernel called "Aggr=
essive Low Memory Booster".=0AThe main advantage of this will be to boost t=
he available free memory of the system to "certain level" during extremely =
low memory condition.=0A=0APlease provide your comments to improve further.=
=0ACan it be used along with vmpressure_fd ???=0A=0A=0AIt can be invoked as=
 follows:=0A=A0=A0=A0 a) Automatically by kernel memory management when the=
 memory threshold falls below 10MB.=0A=A0=A0=A0 b) From user space program/=
scripts by passing the "required amount of memory to be reclaimed".=0A=A0=
=A0=A0 Example: echo 100 > /dev/shrinkmem=0A=A0=A0=A0 c) using sys interfac=
e - /sys/kernel/debug/shrinkallmem=0A=A0=A0=A0 d) using an ioctl call and r=
eturning number of pages reclaimed.=0A=A0=A0=A0 e) using a new system call =
- shrinkallmem(&nrpages);=0A=A0=A0=A0 f) During CMA to reclaim and shrink a=
 specific CMA regions.=0A=0A=0AI have developed a kernel module to verify t=
he (b) part.=0A=0AHere is the snapshot of the write call:=0A+static ssize_t=
 shrinkmem_write(struct file *file, const char *buff,=0A+=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
 size_t length, loff_t *pos)=0A+{=0A+=A0=A0=A0=A0=A0=A0=A0 int ret =3D -1;=
=0A+=A0=A0=A0=A0=A0=A0=A0 unsigned long memsize =3D 0;=0A+=A0=A0=A0=A0=A0=
=A0=A0 unsigned long nr_reclaim =3D 0;=0A+=A0=A0=A0=A0=A0=A0=A0 unsigned lo=
ng pages =3D 0;=0A+=A0=A0=A0=A0=A0=A0=A0 ret =3D kstrtoul_from_user(buff, l=
ength, 0, &memsize);=0A+=A0=A0=A0=A0=A0=A0=A0 if (ret < 0) {=0A+=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 printk(KERN_ERR "[SHRINKMEM]: kstrtoul=
_from_user: Failed !\n");=0A+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 =
return -1;=0A+=A0=A0=A0=A0=A0=A0=A0 }=0A+=A0=A0=A0=A0=A0=A0=A0 printk(KERN_=
INFO "[SHRINKMEM]: memsize(in MB) =3D %ld\n",=0A+=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 (unsi=
gned long)memsize);=0A+=A0=A0=A0=A0=A0=A0=A0 memsize =3D memsize*(1024UL*10=
24UL);=0A+=A0=A0=A0=A0=A0=A0=A0 nr_reclaim =3D memsize / PAGE_SIZE;=0A+=A0=
=A0=A0=A0=A0=A0=A0 pages =3D shrink_all_memory(nr_reclaim);=0A+=A0=A0=A0=A0=
=A0=A0=A0 printk(KERN_INFO "<SHRINKMEM>: Number of Pages Freed: %lu\n", pag=
es);=0A+=A0=A0=A0=A0=A0=A0=A0 return pages;=0A+}=0APlease note: This requir=
es CONFIG_HIBERNATION to be permanently enabled in the kernel.=0A=0A=0ASeve=
ral experiments have been performed on Ubuntu(kernel 3.3) to verify it unde=
r low memory conditions.=0A=0AFollowing are some results obtained:=0A------=
-------------------------------=0A=0ANode 0, zone=A0=A0=A0=A0=A0 DMA=A0=A0=
=A0 290=A0=A0=A0 115=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=
=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=
=A0=A0 0=A0=A0=A0=A0=A0 0=0ANode 0, zone=A0=A0 Normal=A0=A0=A0 304=A0=A0=A0=
 540=A0=A0=A0 116=A0=A0=A0=A0 13=A0=A0=A0=A0=A0 2=A0=A0=A0=A0=A0 2=A0=A0=A0=
=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 =
0=0A=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=0A=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 total=A0=A0=A0=A0=A0=A0 used=
=A0=A0=A0=A0=A0=A0 free=A0=A0=A0=A0 shared=A0=A0=A0 buffers=A0=A0=A0=A0 cac=
hed=0AMem:=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 497=A0=A0=A0=A0=A0=A0=A0 487=A0=A0=
=A0=A0=A0=A0=A0=A0 10=A0=A0=A0=A0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0=A0=A0=A0 =
63=A0=A0=A0=A0=A0=A0=A0 303=0A-/+ buffers/cache:=A0=A0=A0=A0=A0=A0=A0 120=
=A0=A0=A0=A0=A0=A0=A0 376=0ASwap:=A0=A0=A0=A0=A0=A0=A0=A0 1458=A0=A0=A0=A0=
=A0=A0=A0=A0 34=A0=A0=A0=A0=A0=A0 1424=0ATotal:=A0=A0=A0=A0=A0=A0=A0 1956=
=A0=A0=A0=A0=A0=A0=A0 522=A0=A0=A0=A0=A0=A0 1434=0A=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=0ATotal Memory Freed: 3=
42 MB=0ATotal Memory Freed: 53 MB=0ATotal Memory Freed: 23 MB=0ATotal Memor=
y Freed: 10 MB=0ATotal Memory Freed: 15 MB=0ATotal Memory Freed: -1 MB=0ANo=
de 0, zone=A0=A0=A0=A0=A0 DMA=A0=A0=A0=A0=A0 6=A0=A0=A0=A0=A0 6=A0=A0=A0=A0=
=A0 7=A0=A0=A0=A0=A0 8=A0=A0=A0=A0 10=A0=A0=A0=A0=A0 9=A0=A0=A0=A0=A0 7=A0=
=A0=A0=A0=A0 4=A0=A0=A0=A0=A0 1=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=0ANode 0,=
 zone=A0=A0 Normal=A0=A0 2129=A0=A0 2612=A0=A0 2166=A0=A0 1723=A0=A0 1260=
=A0=A0=A0 759=A0=A0=A0 359=A0=A0=A0 108=A0=A0=A0=A0 10=A0=A0=A0=A0=A0 0=A0=
=A0=A0=A0=A0 0=0A=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=0A=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 total=A0=A0=A0=A0=
=A0=A0 used=A0=A0=A0=A0=A0=A0 free=A0=A0=A0=A0 shared=A0=A0=A0 buffers=A0=
=A0=A0=A0 cached=0AMem:=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 497=A0=A0=A0=A0=A0=A0=
=A0=A0 47=A0=A0=A0=A0=A0=A0=A0 449=A0=A0=A0=A0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0=A0=A0=A0=A0 5=0A-/+ buffers/cache:=A0=A0=
=A0=A0=A0=A0=A0=A0 41=A0=A0=A0=A0=A0=A0=A0 455=0ASwap:=A0=A0=A0=A0=A0=A0=A0=
=A0 1458=A0=A0=A0=A0=A0=A0=A0=A0 97=A0=A0=A0=A0=A0=A0 1361=0ATotal:=A0=A0=
=A0=A0=A0=A0=A0 1956=A0=A0=A0=A0=A0=A0=A0 145=A0=A0=A0=A0=A0=A0 1811=0A=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=0A=
=0AIt was verified using a sample shell script "reclaim_memory.sh" which ke=
eps recovering memory by doing "echo 500 > /dev/shrinkmem" until no further=
 reclaim is possible.=0A=0AThe experiments were performed with various scen=
arios as follows:=0Aa) Just after the boot up - (could recover around 150MB=
 with 512MB RAM)=0Ab) After running many applications include youtube video=
s, large tar files download - =0A=0A=A0=A0 [until free mem becomes < 10MB]=
=0A=A0=A0 [Could recover around 300MB in one shot]=0Ac) Run reclaim, while =
download is in progress and video still playing - (Not applications killed)=
=0A=0Ad) revoke all background applications again, after running reclaim - =
(No impact, normal behavior)=0A=A0=A0 [Just it took little extra time to la=
unch, as if it was launched for first time]=0A=0A=0APlease see more discuss=
ions on this in the last year mailing list:=0A=0Ahttps://lkml.org/lkml/2012=
/4/15/35 =0A=0A=0AThank You!=0AWith regards,=0APintu Kumar=0ASamsung - Indi=
a
--1520606428-2004289184-1358091177=:96940
Content-Type: text/html; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

<html><body><div style=3D"color:#000; background-color:#fff; font-family:lu=
cida console, sans-serif;font-size:12pt"><div><span>Hi,</span></div><div st=
yle=3D"color: rgb(0, 0, 0); font-size: 16px; font-family: lucida console,sa=
ns-serif; background-color: transparent; font-style: normal;"><br><span></s=
pan></div><div style=3D"color: rgb(0, 0, 0); font-size: 16px; font-family: =
lucida console,sans-serif; background-color: transparent; font-style: norma=
l;"><span>Here I am trying to introduce a new feature in kernel called "Agg=
ressive Low Memory Booster".</span></div><div style=3D"color: rgb(0, 0, 0);=
 font-size: 16px; font-family: lucida console,sans-serif; background-color:=
 transparent; font-style: normal;"><span>The main advantage of this will be=
 to boost the available free memory of the system to "certain level" during=
 extremely low memory condition.</span></div><div style=3D"color: rgb(0, 0,=
 0); font-size: 16px; font-family: lucida console,sans-serif;
 background-color: transparent; font-style: normal;"><br></div><div style=
=3D"color: rgb(0, 0, 0); font-size: 16px; font-family: lucida console,sans-=
serif; background-color: transparent; font-style: normal;">Please provide y=
our comments to improve further.</div><div style=3D"color: rgb(0, 0, 0); fo=
nt-size: 16px; font-family: lucida console,sans-serif; background-color: tr=
ansparent; font-style: normal;">Can it be used along with vmpressure_fd ???=
<br><span></span></div><div style=3D"color: rgb(0, 0, 0); font-size: 16px; =
font-family: lucida console,sans-serif; background-color: transparent; font=
-style: normal;"><span><br></span></div><div style=3D"color: rgb(0, 0, 0); =
font-size: 16px; font-family: lucida console,sans-serif; background-color: =
transparent; font-style: normal;">It can be invoked as follows:</div><div s=
tyle=3D"color: rgb(0, 0, 0); font-size: 16px; font-family: lucida console,s=
ans-serif; background-color: transparent; font-style: normal;"><span
 class=3D"tab">&nbsp;&nbsp;&nbsp; a) Automatically by kernel memory managem=
ent when the memory threshold falls below 10MB.</span></div><div style=3D"c=
olor: rgb(0, 0, 0); font-size: 16px; font-family: lucida console,sans-serif=
; background-color: transparent; font-style: normal;"><span class=3D"tab">&=
nbsp;&nbsp;&nbsp; </span><span class=3D"tab">b) From user space program/scr=
ipts by passing the "required amount of memory to be reclaimed".</span></di=
v><div style=3D"color: rgb(0, 0, 0); font-size: 16px; font-family: lucida c=
onsole,sans-serif; background-color: transparent; font-style: normal;"><spa=
n class=3D"tab">&nbsp;&nbsp;&nbsp; </span><span class=3D"tab">Example</span=
><span class=3D"tab"></span><span class=3D"tab">: echo 100 &gt; /dev/shrink=
mem</span></div><div style=3D"color: rgb(0, 0, 0); font-size: 16px; font-fa=
mily: lucida console,sans-serif; background-color: transparent; font-style:=
 normal;"><span class=3D"tab">&nbsp;&nbsp;&nbsp; </span><span class=3D"tab"=
>c) using sys
 interface - /sys/kernel/debug/shrinkallmem</span></div><div style=3D"color=
: rgb(0, 0, 0); font-size: 16px; font-family: lucida console,sans-serif; ba=
ckground-color: transparent; font-style: normal;"><span class=3D"tab">&nbsp=
;&nbsp;&nbsp; </span><span class=3D"tab">d) using an ioctl call and returni=
ng number of pages reclaimed.</span></div><div style=3D"color: rgb(0, 0, 0)=
; font-size: 16px; font-family: lucida console,sans-serif; background-color=
: transparent; font-style: normal;"><span class=3D"tab">&nbsp;&nbsp;&nbsp; =
</span><span class=3D"tab">e) using a new system call - shrinkallmem(&amp;n=
rpages);</span></div><div style=3D"color: rgb(0, 0, 0); font-size: 16px; fo=
nt-family: lucida console,sans-serif; background-color: transparent; font-s=
tyle: normal;"><span class=3D"tab">&nbsp;&nbsp;&nbsp; </span><span class=3D=
"tab">f) During CMA to reclaim and shrink a specific CMA regions.<br></span=
></div><div style=3D"color: rgb(0, 0, 0); font-size: 16px; font-family: luc=
ida
 console,sans-serif; background-color: transparent; font-style: normal;"><b=
r></div><div style=3D"color: rgb(0, 0, 0); font-size: 16px; font-family: lu=
cida console,sans-serif; background-color: transparent; font-style: normal;=
">I have developed a kernel module to verify the (b) part.</div><div style=
=3D"color: rgb(0, 0, 0); font-size: 16px; font-family: lucida console,sans-=
serif; background-color: transparent; font-style: normal;"><br></div><div s=
tyle=3D"color: rgb(0, 0, 0); font-size: 16px; font-family: lucida console,s=
ans-serif; background-color: transparent; font-style: normal;">Here is the =
snapshot of the write call:</div><div style=3D"color: rgb(0, 0, 0); font-si=
ze: 16px; font-family: lucida console,sans-serif; background-color: transpa=
rent; font-style: normal;">+static ssize_t shrinkmem_write(struct file *fil=
e, const char
 *buff,<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; size_t length, loff_t *pos=
)<br>+{<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; int ret =3D -1;<br>+=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; unsigned long memsize =3D 0;<br>=
+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; unsigned long nr_reclaim =3D 0;=
<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; unsigned long pages =3D 0;<=
br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ret =3D kstrtoul_from_user(b=
uff, length, 0, &amp;memsize);<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p; if (ret &lt; 0) {<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; printk(KERN_ERR "[SHRINKMEM]: kstr=
toul_from_user: Failed !\n");<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; return
 -1;<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; }<br>+&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp; printk(KERN_INFO "[SHRINKMEM]: memsize(in MB) =3D=
 %ld\n",<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; (unsigned long)memsize);<=
br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; memsize =3D memsize*(1024UL*=
1024UL);<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; nr_reclaim =3D mems=
ize / PAGE_SIZE;<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; pages =3D s=
hrink_all_memory(nr_reclaim);<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
; printk(KERN_INFO "&lt;SHRINKMEM&gt;: Number of Pages Freed: %lu\n", pages=
);<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; return pages;<br>+}</div>=
<div style=3D"color: rgb(0, 0, 0); font-size: 16px; font-family: lucida con=
sole,sans-serif; background-color: transparent; font-style: normal;">Please
 note: This requires CONFIG_HIBERNATION to be permanently enabled in the ke=
rnel.<br><br></div><div style=3D"color: rgb(0, 0, 0); font-size: 16px; font=
-family: lucida console,sans-serif; background-color: transparent; font-sty=
le: normal;">Several experiments have been performed on Ubuntu(kernel 3.3) =
to verify it under low memory conditions.</div><div style=3D"color: rgb(0, =
0, 0); font-size: 16px; font-family: lucida console,sans-serif; background-=
color: transparent; font-style: normal;"><br></div><div style=3D"color: rgb=
(0, 0, 0); font-size: 16px; font-family: lucida console,sans-serif; backgro=
und-color: transparent; font-style: normal;">Following are some results obt=
ained:</div><div style=3D"color: rgb(0, 0, 0); font-size: 16px; font-family=
: lucida console,sans-serif; background-color: transparent; font-style: nor=
mal;">-------------------------------------<br></div><div style=3D"color: r=
gb(0, 0, 0); font-size: 16px; font-family: lucida console,sans-serif;
 background-color: transparent; font-style: normal;">Node 0, zone&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp; DMA&nbsp;&nbsp;&nbsp; 290&nbsp;&nbsp;&nbsp; 115&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0<br>Node 0, zone&nb=
sp;&nbsp; Normal&nbsp;&nbsp;&nbsp; 304&nbsp;&nbsp;&nbsp; 540&nbsp;&nbsp;&nb=
sp; 116&nbsp;&nbsp;&nbsp;&nbsp; 13&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 2&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0<br>=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; total&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;
 used&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; free&nbsp;&nbsp;&nbsp;&nbsp; shar=
ed&nbsp;&nbsp;&nbsp; buffers&nbsp;&nbsp;&nbsp;&nbsp; cached<br>Mem:&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 497&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp; 487&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
 10&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 63&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p; 303<br>-/+ buffers/cache:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 120&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 376<br>Swap:&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp; 1458&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp; 34&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1424<br>Total:&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp; 1956&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 5=
22&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1434<br>=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>Total Memory Freed: 342=
 MB<br>Total Memory Freed: 53 MB<br>Total
 Memory Freed: 23 MB<br>Total Memory Freed: 10 MB<br>Total Memory Freed: 15=
 MB<br>Total Memory Freed: -1 MB<br>Node 0, zone&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp; DMA&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 6&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 6&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp; 7&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 8&nbsp;&nbsp;&nb=
sp;&nbsp; 10&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 9&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
7&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 4&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0<br>Node 0, zone&nbsp=
;&nbsp; Normal&nbsp;&nbsp; 2129&nbsp;&nbsp; 2612&nbsp;&nbsp; 2166&nbsp;&nbs=
p; 1723&nbsp;&nbsp; 1260&nbsp;&nbsp;&nbsp; 759&nbsp;&nbsp;&nbsp; 359&nbsp;&=
nbsp;&nbsp; 108&nbsp;&nbsp;&nbsp;&nbsp; 10&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0<br>=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; total&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;
 used&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; free&nbsp;&nbsp;&nbsp;&nbsp; shar=
ed&nbsp;&nbsp;&nbsp; buffers&nbsp;&nbsp;&nbsp;&nbsp; cached<br>Mem:&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 497&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 47&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
449&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp; 5<br>-/+ buffers/cache:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp; 41&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 455<br>Swap:&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1458&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp; 97&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1361<br>To=
tal:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1956&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp; 145&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1811<br>=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D</div>=
<div style=3D"color: rgb(0, 0, 0); font-size:
 16px; font-family: lucida console,sans-serif; background-color: transparen=
t; font-style: normal;"><br></div><div style=3D"color: rgb(0, 0, 0); font-s=
ize: 16px; font-family: lucida console,sans-serif; background-color: transp=
arent; font-style: normal;">It was verified using a sample shell script "re=
claim_memory.sh" which keeps recovering memory by doing "echo 500 &gt; /dev=
/shrinkmem" until no further reclaim is possible.</div><div style=3D"color:=
 rgb(0, 0, 0); font-size: 16px; font-family: lucida console,sans-serif; bac=
kground-color: transparent; font-style: normal;"><br></div><div style=3D"co=
lor: rgb(0, 0, 0); font-size: 16px; font-family: lucida console,sans-serif;=
 background-color: transparent; font-style: normal;">The experiments were p=
erformed with various scenarios as follows:</div><div style=3D"color: rgb(0=
, 0, 0); font-size: 16px; font-family: lucida console,sans-serif; backgroun=
d-color: transparent; font-style: normal;">a) Just after the boot up -
 (could recover around 150MB with 512MB RAM)</div><div style=3D"color: rgb(=
0, 0, 0); font-size: 16px; font-family: lucida console,sans-serif; backgrou=
nd-color: transparent; font-style: normal;">b) After running many applicati=
ons include youtube videos, large tar files download - <br></div><div style=
=3D"color: rgb(0, 0, 0); font-size: 16px; font-family: lucida console,sans-=
serif; background-color: transparent; font-style: normal;"><span class=3D"t=
ab">&nbsp;&nbsp; </span>[until free mem becomes &lt; 10MB]</div><div style=
=3D"color: rgb(0, 0, 0); font-size: 16px; font-family: lucida console,sans-=
serif; background-color: transparent; font-style: normal;"><span class=3D"t=
ab">&nbsp;&nbsp; [Could recover around 300MB in one shot]</span></div><div =
style=3D"color: rgb(0, 0, 0); font-size: 16px; font-family: lucida console,=
sans-serif; background-color: transparent; font-style: normal;"><span class=
=3D"tab">c) Run reclaim, while download is in progress and video still play=
ing -
 (Not applications killed)<br></span></div><div style=3D"color: rgb(0, 0, 0=
); font-size: 16px; font-family: lucida console,sans-serif; background-colo=
r: transparent; font-style: normal;"><span class=3D"tab">d) revoke all back=
ground applications again, after running reclaim - (No impact, normal behav=
ior)</span></div><div style=3D"color: rgb(0, 0, 0); font-size: 16px; font-f=
amily: lucida console,sans-serif; background-color: transparent; font-style=
: normal;"><span class=3D"tab">&nbsp;&nbsp; [Just it took little extra time=
 to launch, as if it was launched for first time]</span></div><div style=3D=
"color: rgb(0, 0, 0); font-size: 16px; font-family: lucida console,sans-ser=
if; background-color: transparent; font-style: normal;"><br><span class=3D"=
tab"></span></div><div style=3D"color: rgb(0, 0, 0); font-size: 16px; font-=
family: lucida console,sans-serif; background-color: transparent; font-styl=
e: normal;"><span class=3D"tab"><br></span></div><div style=3D"color: rgb(0=
, 0, 0);
 font-size: 16px; font-family: lucida console,sans-serif; background-color:=
 transparent; font-style: normal;">Please see more discussions on this in t=
he last year mailing list:<br></div><div style=3D"color: rgb(0, 0, 0); font=
-size: 16px; font-family: lucida console,sans-serif; background-color: tran=
sparent; font-style: normal;">https://lkml.org/lkml/2012/4/15/35 <br><span>=
</span></div><div style=3D"color: rgb(0, 0, 0); font-size: 16px; font-famil=
y: lucida console,sans-serif; background-color: transparent; font-style: no=
rmal;"><br><span></span></div><div style=3D"color: rgb(0, 0, 0); font-size:=
 16px; font-family: lucida console,sans-serif; background-color: transparen=
t; font-style: normal;"><span>Thank You!</span></div><div style=3D"color: r=
gb(0, 0, 0); font-size: 16px; font-family: lucida console,sans-serif; backg=
round-color: transparent; font-style: normal;"><span>With regards,</span></=
div><div style=3D"color: rgb(0, 0, 0); font-size: 16px; font-family: lucida
 console,sans-serif; background-color: transparent; font-style: normal;"><s=
pan>Pintu Kumar</span></div><div style=3D"color: rgb(0, 0, 0); font-size: 1=
6px; font-family: lucida console,sans-serif; background-color: transparent;=
 font-style: normal;"><span>Samsung - India</span></div><div style=3D"color=
: rgb(0, 0, 0); font-size: 16px; font-family: lucida console,sans-serif; ba=
ckground-color: transparent; font-style: normal;"><br></div><div style=3D"c=
olor: rgb(0, 0, 0); font-size: 16px; font-family: lucida console,sans-serif=
; background-color: transparent; font-style: normal;"><br> </div>   </div><=
/body></html>
--1520606428-2004289184-1358091177=:96940--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
