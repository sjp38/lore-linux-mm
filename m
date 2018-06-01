Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id A55FD6B0005
	for <linux-mm@kvack.org>; Thu, 31 May 2018 20:03:32 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id g78-v6so77256wmg.9
        for <linux-mm@kvack.org>; Thu, 31 May 2018 17:03:32 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a206-v6sor146190wmh.77.2018.05.31.17.03.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 31 May 2018 17:03:29 -0700 (PDT)
MIME-Version: 1.0
From: Anton Eidelman <anton@lightbitslabs.com>
Date: Thu, 31 May 2018 17:03:27 -0700
Message-ID: <CAKYffwqAXWUhdmU7t+OzK1A2oODS+WsfMKJZyWVTwxzR2QbHbw@mail.gmail.com>
Subject: HARDENED_USERCOPY will BUG on multiple slub objects coalesced into an
 sk_buff fragment
Content-Type: multipart/alternative; boundary="0000000000004e20a5056d895068"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

--0000000000004e20a5056d895068
Content-Type: text/plain; charset="UTF-8"

Hello,

Here's a rare issue I reproduce on 4.12.10 (centos config): full log sample
below.
An innocent process (dhcpclient) is about to receive a datagram, but
during skb_copy_datagram_iter() usercopy triggers a BUG in:
usercopy.c:check_heap_object() -> slub.c:__check_heap_object(), because the
sk_buff fragment being copied crosses the 64-byte slub object boundary.

Example __check_heap_object() context:
  n=128    << usually 128, sometimes 192.
  object_size=64
  s->size=64
  page_address(page)=0xffff880233f7c000
  ptr=0xffff880233f7c540

My take on the root cause:
  When adding data to an skb, new data is appended to the current fragment
if the new chunk immediately follows the last one: by simply increasing the
frag->size, skb_frag_size_add().
  See include/linux/skbuff.h:skb_can_coalesce() callers.
  This happens very frequently for kmem_cache objects (slub/slab) with
intensive kernel level TCP traffic, and produces sk_buff fragments that
span multiple kmem_cache objects.
  However, if the same happens to receive data intended for user space,
usercopy triggers a BUG.
  This is quite rare but possible: fails after 5-60min of network traffic
(needs some unfortunate timing, e.g. only on QEMU, without
CONFIG_SLUB_DEBUG_ON etc).
  I used an instrumentation that counts coalesced chunks in the fragment,
in order to confirm that the failing fragment was legally constructed from
multiple slub objects.

On 4.17.0.rc3:
  I could not reproduce the issue with the latest kernel, but the changes
in usercopy.c and slub.c since 4.12 do not address the issue.
  Moreover, it would be quite hard to do without effectively disabling the
heap protection.
  However, looking at the recent changes in include/linux/sk_buff.h I
see skb_zcopy() that yields negative skb_can_coalesce() and may have masked
the problem.

Please, let me know what do you think?
4.12.10 is the centos official kernel with
CONFIG_HARDENED_USERCOPY enabled: if the problem is real we better have an
erratum for it.

Regards,
Anton Eidelman


[ 655.602500] usercopy: kernel memory exposure attempt detected from
ffff88022a31aa00 *(kmalloc-64) (192 bytes*)
[ 655.604254] ----------[ cut here ]----------
[ 655.604877] kernel BUG at mm/usercopy.c:72!
[ 655.606302] invalid opcode: 0000 1 SMP
[ 655.618390] CPU: 3 PID: 2335 Comm: dhclient Tainted: G O
4.12.10-1.el7.elrepo.x86_64 #1
[ 655.619666] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS
1.10.2-1ubuntu1 04/01/2014
[ 655.620926] task: ffff880229ab2d80 task.stack: ffffc90001198000
[ 655.621786] RIP: 0010:__check_object_size+0x74/0x190
[ 655.622489] RSP: 0018:ffffc9000119bbb8 EFLAGS: 00010246
[ 655.623236] RAX: 0000000000000060 RBX: ffff88022a31aa00 RCX:
0000000000000000
[ 655.624234] RDX: 0000000000000000 RSI: ffff88023fcce108 RDI:
ffff88023fcce108
[ 655.625237] RBP: ffffc9000119bbd8 R08: 00000000fffffffe R09:
0000000000000271
[ 655.626248] R10: 0000000000000005 R11: 0000000000000270 R12:
00000000000000c0
[ 655.627256] R13: ffff88022a31aac0 R14: 0000000000000001 R15:
00000000000000c0
[ 655.628268] FS: 00007fb54413b880(0000) GS:ffff88023fcc0000(0000)
knlGS:0000000000000000
[ 655.629561] CS: 0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 655.630289] CR2: 00007fb5439dc5c0 CR3: 000000023211d000 CR4:
00000000003406e0
[ 655.631268] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
0000000000000000
[ 655.632281] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7:
0000000000000400
[ 655.633318] Call Trace:
[ 655.633696] copy_page_to_iter_iovec+0x9c/0x180
[ 655.634351] copy_page_to_iter+0x22/0x160
[ 655.634943] skb_copy_datagram_iter+0x157/0x260
[ 655.635604] packet_recvmsg+0xcb/0x460
[ 655.636156] ? selinux_socket_recvmsg+0x17/0x20
[ 655.636816] sock_recvmsg+0x3d/0x50
[ 655.637330] ___sys_recvmsg+0xd7/0x1f0
[ 655.637892] ? kvm_clock_get_cycles+0x1e/0x20
[ 655.638533] ? ktime_get_ts64+0x49/0xf0
[ 655.639101] ? _copy_to_user+0x26/0x40
[ 655.639657] __sys_recvmsg+0x51/0x90
[ 655.640184] SyS_recvmsg+0x12/0x20
[ 655.640696] entry_SYSCALL_64_fastpath+0x1a/0xa5
--------------------------------------------------------------------------------------------------------------------------------------------

--0000000000004e20a5056d895068
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hello,<div><br></div><div>Here&#39;s a rare issue I reprod=
uce on 4.12.10 (centos config): full log sample below.</div><div>An innocen=
t process (dhcpclient) is about to receive a datagram, but during=C2=A0skb_=
copy_datagram_iter() usercopy triggers a BUG in:</div><div>usercopy.c:check=
_heap_object() -&gt; slub.c:__check_heap_object(), because the sk_buff frag=
ment being copied crosses the 64-byte slub object boundary.</div><div><br><=
/div><div>Example __check_heap_object() context:<br></div><div><div>=C2=A0 =
n=3D128=C2=A0 =C2=A0 &lt;&lt; usually 128, sometimes 192.</div><div>=C2=A0 =
object_size=3D64</div><div>=C2=A0 s-&gt;size=3D64</div><div>=C2=A0 page_add=
ress(page)=3D0xffff880233f7c000</div><div>=C2=A0 ptr=3D0xffff880233f7c540</=
div><div><br></div><div><div>My take on the root cause:</div><div>=C2=A0 Wh=
en adding data to an skb, new data is appended to the current fragment if t=
he new chunk immediately follows the last one: by simply increasing the fra=
g-&gt;size, skb_frag_size_add().</div><div>=C2=A0 See include/linux/skbuff.=
h:skb_can_coalesce() callers.</div><div>=C2=A0 This happens very frequently=
 for kmem_cache objects (slub/slab) with intensive kernel level TCP traffic=
, and produces sk_buff fragments that span multiple kmem_cache objects.</di=
v></div><div>=C2=A0 However, if the same happens to receive data intended f=
or user space, usercopy triggers a BUG.</div><div>=C2=A0 This is quite rare=
 but possible: fails after 5-60min of network traffic (needs some unfortuna=
te timing, e.g. only on QEMU, without CONFIG_SLUB_DEBUG_ON etc).</div></div=
><div>=C2=A0 I used an instrumentation that counts coalesced chunks in the =
fragment, in order to confirm that the failing fragment was legally constru=
cted from multiple slub objects.</div><div><br></div><div>On=C2=A0<span sty=
le=3D"color:rgb(34,34,34);font-family:arial,sans-serif;font-size:small;font=
-style:normal;font-variant-ligatures:normal;font-variant-caps:normal;font-w=
eight:400;letter-spacing:normal;text-align:start;text-indent:0px;text-trans=
form:none;white-space:normal;word-spacing:0px;background-color:rgb(255,255,=
255);text-decoration-style:initial;text-decoration-color:initial;float:none=
;display:inline">4.17.0.rc3:</span></div><div>=C2=A0 I could not reproduce =
the issue with the latest kernel, but the changes in usercopy.c and slub.c =
since 4.12 do not address the issue.</div><div>=C2=A0 Moreover, it would be=
 quite hard to do without effectively disabling the heap protection.</div><=
div>=C2=A0 However, looking at the recent changes in include/linux/sk_buff.=
h I see=C2=A0skb_zcopy() that yields negative skb_can_coalesce()=C2=A0and m=
ay have masked the problem.</div><div><br></div><div>Please, let me know wh=
at do you think?</div><div>4.12.10 is the centos official kernel with CONFI=
G_HARDENED_USERCOPY=C2=A0enabled: if the problem is real we better have an =
erratum for it.=C2=A0</div><div><br></div><div>Regards,<br>Anton Eidelman</=
div><div><br></div><div><br></div><div><span style=3D"color:rgb(23,43,77);f=
ont-family:-apple-system,BlinkMacSystemFont,&quot;Segoe UI&quot;,Roboto,Oxy=
gen,Ubuntu,&quot;Fira Sans&quot;,&quot;Droid Sans&quot;,&quot;Helvetica Neu=
e&quot;,sans-serif;font-size:14px;font-style:normal;font-variant-ligatures:=
normal;font-variant-caps:normal;font-weight:400;letter-spacing:normal;text-=
align:start;text-indent:0px;text-transform:none;white-space:normal;word-spa=
cing:0px;background-color:rgb(244,245,247);text-decoration-style:initial;te=
xt-decoration-color:initial;float:none;display:inline">[ 655.602500] userco=
py: kernel memory exposure attempt detected from ffff88022a31aa00 </span><s=
pan style=3D"color:rgb(23,43,77);font-family:-apple-system,BlinkMacSystemFo=
nt,&quot;Segoe UI&quot;,Roboto,Oxygen,Ubuntu,&quot;Fira Sans&quot;,&quot;Dr=
oid Sans&quot;,&quot;Helvetica Neue&quot;,sans-serif;font-size:14px;font-st=
yle:normal;font-variant-ligatures:normal;font-variant-caps:normal;letter-sp=
acing:normal;text-align:start;text-indent:0px;text-transform:none;white-spa=
ce:normal;word-spacing:0px;background-color:rgb(244,245,247);text-decoratio=
n-style:initial;text-decoration-color:initial;float:none;display:inline"><b=
>(kmalloc-64) (192 bytes</b></span><span style=3D"color:rgb(23,43,77);font-=
family:-apple-system,BlinkMacSystemFont,&quot;Segoe UI&quot;,Roboto,Oxygen,=
Ubuntu,&quot;Fira Sans&quot;,&quot;Droid Sans&quot;,&quot;Helvetica Neue&qu=
ot;,sans-serif;font-size:14px;font-style:normal;font-variant-ligatures:norm=
al;font-variant-caps:normal;font-weight:400;letter-spacing:normal;text-alig=
n:start;text-indent:0px;text-transform:none;white-space:normal;word-spacing=
:0px;background-color:rgb(244,245,247);text-decoration-style:initial;text-d=
ecoration-color:initial;float:none;display:inline">)</span><br style=3D"col=
or:rgb(23,43,77);font-family:-apple-system,BlinkMacSystemFont,&quot;Segoe U=
I&quot;,Roboto,Oxygen,Ubuntu,&quot;Fira Sans&quot;,&quot;Droid Sans&quot;,&=
quot;Helvetica Neue&quot;,sans-serif;font-size:14px;font-style:normal;font-=
variant-ligatures:normal;font-variant-caps:normal;font-weight:400;letter-sp=
acing:normal;text-align:start;text-indent:0px;text-transform:none;white-spa=
ce:normal;word-spacing:0px;background-color:rgb(244,245,247);text-decoratio=
n-style:initial;text-decoration-color:initial"><span style=3D"color:rgb(23,=
43,77);font-family:-apple-system,BlinkMacSystemFont,&quot;Segoe UI&quot;,Ro=
boto,Oxygen,Ubuntu,&quot;Fira Sans&quot;,&quot;Droid Sans&quot;,&quot;Helve=
tica Neue&quot;,sans-serif;font-size:14px;font-style:normal;font-variant-li=
gatures:normal;font-variant-caps:normal;font-weight:400;letter-spacing:norm=
al;text-align:start;text-indent:0px;text-transform:none;white-space:normal;=
word-spacing:0px;background-color:rgb(244,245,247);text-decoration-style:in=
itial;text-decoration-color:initial;float:none;display:inline">[ 655.604254=
] ----------</span><del style=3D"color:rgb(23,43,77);font-family:-apple-sys=
tem,BlinkMacSystemFont,&quot;Segoe UI&quot;,Roboto,Oxygen,Ubuntu,&quot;Fira=
 Sans&quot;,&quot;Droid Sans&quot;,&quot;Helvetica Neue&quot;,sans-serif;fo=
nt-size:14px;font-style:normal;font-variant-ligatures:normal;font-variant-c=
aps:normal;font-weight:400;letter-spacing:normal;text-align:start;text-inde=
nt:0px;text-transform:none;white-space:normal;word-spacing:0px;background-c=
olor:rgb(244,245,247)">[ cut here ]</del><span style=3D"color:rgb(23,43,77)=
;font-family:-apple-system,BlinkMacSystemFont,&quot;Segoe UI&quot;,Roboto,O=
xygen,Ubuntu,&quot;Fira Sans&quot;,&quot;Droid Sans&quot;,&quot;Helvetica N=
eue&quot;,sans-serif;font-size:14px;font-style:normal;font-variant-ligature=
s:normal;font-variant-caps:normal;font-weight:400;letter-spacing:normal;tex=
t-align:start;text-indent:0px;text-transform:none;white-space:normal;word-s=
pacing:0px;background-color:rgb(244,245,247);text-decoration-style:initial;=
text-decoration-color:initial;float:none;display:inline">----------</span><=
br style=3D"color:rgb(23,43,77);font-family:-apple-system,BlinkMacSystemFon=
t,&quot;Segoe UI&quot;,Roboto,Oxygen,Ubuntu,&quot;Fira Sans&quot;,&quot;Dro=
id Sans&quot;,&quot;Helvetica Neue&quot;,sans-serif;font-size:14px;font-sty=
le:normal;font-variant-ligatures:normal;font-variant-caps:normal;font-weigh=
t:400;letter-spacing:normal;text-align:start;text-indent:0px;text-transform=
:none;white-space:normal;word-spacing:0px;background-color:rgb(244,245,247)=
;text-decoration-style:initial;text-decoration-color:initial"><span style=
=3D"color:rgb(23,43,77);font-family:-apple-system,BlinkMacSystemFont,&quot;=
Segoe UI&quot;,Roboto,Oxygen,Ubuntu,&quot;Fira Sans&quot;,&quot;Droid Sans&=
quot;,&quot;Helvetica Neue&quot;,sans-serif;font-size:14px;font-style:norma=
l;font-variant-ligatures:normal;font-variant-caps:normal;font-weight:400;le=
tter-spacing:normal;text-align:start;text-indent:0px;text-transform:none;wh=
ite-space:normal;word-spacing:0px;background-color:rgb(244,245,247);text-de=
coration-style:initial;text-decoration-color:initial;float:none;display:inl=
ine">[ 655.604877] kernel BUG at mm/usercopy.c:72!</span><br style=3D"color=
:rgb(23,43,77);font-family:-apple-system,BlinkMacSystemFont,&quot;Segoe UI&=
quot;,Roboto,Oxygen,Ubuntu,&quot;Fira Sans&quot;,&quot;Droid Sans&quot;,&qu=
ot;Helvetica Neue&quot;,sans-serif;font-size:14px;font-style:normal;font-va=
riant-ligatures:normal;font-variant-caps:normal;font-weight:400;letter-spac=
ing:normal;text-align:start;text-indent:0px;text-transform:none;white-space=
:normal;word-spacing:0px;background-color:rgb(244,245,247);text-decoration-=
style:initial;text-decoration-color:initial"><span style=3D"color:rgb(23,43=
,77);font-family:-apple-system,BlinkMacSystemFont,&quot;Segoe UI&quot;,Robo=
to,Oxygen,Ubuntu,&quot;Fira Sans&quot;,&quot;Droid Sans&quot;,&quot;Helveti=
ca Neue&quot;,sans-serif;font-size:14px;font-style:normal;font-variant-liga=
tures:normal;font-variant-caps:normal;font-weight:400;letter-spacing:normal=
;text-align:start;text-indent:0px;text-transform:none;white-space:normal;wo=
rd-spacing:0px;background-color:rgb(244,245,247);text-decoration-style:init=
ial;text-decoration-color:initial;float:none;display:inline">[ 655.606302] =
invalid opcode: 0000 1 SMP</span><br style=3D"color:rgb(23,43,77);font-fami=
ly:-apple-system,BlinkMacSystemFont,&quot;Segoe UI&quot;,Roboto,Oxygen,Ubun=
tu,&quot;Fira Sans&quot;,&quot;Droid Sans&quot;,&quot;Helvetica Neue&quot;,=
sans-serif;font-size:14px;font-style:normal;font-variant-ligatures:normal;f=
ont-variant-caps:normal;font-weight:400;letter-spacing:normal;text-align:st=
art;text-indent:0px;text-transform:none;white-space:normal;word-spacing:0px=
;background-color:rgb(244,245,247);text-decoration-style:initial;text-decor=
ation-color:initial"><span style=3D"color:rgb(23,43,77);font-family:-apple-=
system,BlinkMacSystemFont,&quot;Segoe UI&quot;,Roboto,Oxygen,Ubuntu,&quot;F=
ira Sans&quot;,&quot;Droid Sans&quot;,&quot;Helvetica Neue&quot;,sans-serif=
;font-size:14px;font-style:normal;font-variant-ligatures:normal;font-varian=
t-caps:normal;font-weight:400;letter-spacing:normal;text-align:start;text-i=
ndent:0px;text-transform:none;white-space:normal;word-spacing:0px;backgroun=
d-color:rgb(244,245,247);text-decoration-style:initial;text-decoration-colo=
r:initial;float:none;display:inline">[ 655.618390] CPU: 3 PID: 2335 Comm: d=
hclient Tainted: G O 4.12.10-1.el7.elrepo.x86_64 #1</span><br style=3D"colo=
r:rgb(23,43,77);font-family:-apple-system,BlinkMacSystemFont,&quot;Segoe UI=
&quot;,Roboto,Oxygen,Ubuntu,&quot;Fira Sans&quot;,&quot;Droid Sans&quot;,&q=
uot;Helvetica Neue&quot;,sans-serif;font-size:14px;font-style:normal;font-v=
ariant-ligatures:normal;font-variant-caps:normal;font-weight:400;letter-spa=
cing:normal;text-align:start;text-indent:0px;text-transform:none;white-spac=
e:normal;word-spacing:0px;background-color:rgb(244,245,247);text-decoration=
-style:initial;text-decoration-color:initial"><span style=3D"color:rgb(23,4=
3,77);font-family:-apple-system,BlinkMacSystemFont,&quot;Segoe UI&quot;,Rob=
oto,Oxygen,Ubuntu,&quot;Fira Sans&quot;,&quot;Droid Sans&quot;,&quot;Helvet=
ica Neue&quot;,sans-serif;font-size:14px;font-style:normal;font-variant-lig=
atures:normal;font-variant-caps:normal;font-weight:400;letter-spacing:norma=
l;text-align:start;text-indent:0px;text-transform:none;white-space:normal;w=
ord-spacing:0px;background-color:rgb(244,245,247);text-decoration-style:ini=
tial;text-decoration-color:initial;float:none;display:inline">[ 655.619666]=
 Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1ubuntu=
1 04/01/2014</span><br style=3D"color:rgb(23,43,77);font-family:-apple-syst=
em,BlinkMacSystemFont,&quot;Segoe UI&quot;,Roboto,Oxygen,Ubuntu,&quot;Fira =
Sans&quot;,&quot;Droid Sans&quot;,&quot;Helvetica Neue&quot;,sans-serif;fon=
t-size:14px;font-style:normal;font-variant-ligatures:normal;font-variant-ca=
ps:normal;font-weight:400;letter-spacing:normal;text-align:start;text-inden=
t:0px;text-transform:none;white-space:normal;word-spacing:0px;background-co=
lor:rgb(244,245,247);text-decoration-style:initial;text-decoration-color:in=
itial"><span style=3D"color:rgb(23,43,77);font-family:-apple-system,BlinkMa=
cSystemFont,&quot;Segoe UI&quot;,Roboto,Oxygen,Ubuntu,&quot;Fira Sans&quot;=
,&quot;Droid Sans&quot;,&quot;Helvetica Neue&quot;,sans-serif;font-size:14p=
x;font-style:normal;font-variant-ligatures:normal;font-variant-caps:normal;=
font-weight:400;letter-spacing:normal;text-align:start;text-indent:0px;text=
-transform:none;white-space:normal;word-spacing:0px;background-color:rgb(24=
4,245,247);text-decoration-style:initial;text-decoration-color:initial;floa=
t:none;display:inline">[ 655.620926] task: ffff880229ab2d80 task.stack: fff=
fc90001198000</span><br style=3D"color:rgb(23,43,77);font-family:-apple-sys=
tem,BlinkMacSystemFont,&quot;Segoe UI&quot;,Roboto,Oxygen,Ubuntu,&quot;Fira=
 Sans&quot;,&quot;Droid Sans&quot;,&quot;Helvetica Neue&quot;,sans-serif;fo=
nt-size:14px;font-style:normal;font-variant-ligatures:normal;font-variant-c=
aps:normal;font-weight:400;letter-spacing:normal;text-align:start;text-inde=
nt:0px;text-transform:none;white-space:normal;word-spacing:0px;background-c=
olor:rgb(244,245,247);text-decoration-style:initial;text-decoration-color:i=
nitial"><span style=3D"color:rgb(23,43,77);font-family:-apple-system,BlinkM=
acSystemFont,&quot;Segoe UI&quot;,Roboto,Oxygen,Ubuntu,&quot;Fira Sans&quot=
;,&quot;Droid Sans&quot;,&quot;Helvetica Neue&quot;,sans-serif;font-size:14=
px;font-style:normal;font-variant-ligatures:normal;font-variant-caps:normal=
;font-weight:400;letter-spacing:normal;text-align:start;text-indent:0px;tex=
t-transform:none;white-space:normal;word-spacing:0px;background-color:rgb(2=
44,245,247);text-decoration-style:initial;text-decoration-color:initial;flo=
at:none;display:inline">[ 655.621786] RIP: 0010:__check_object_size+0x74/0x=
190</span><br style=3D"color:rgb(23,43,77);font-family:-apple-system,BlinkM=
acSystemFont,&quot;Segoe UI&quot;,Roboto,Oxygen,Ubuntu,&quot;Fira Sans&quot=
;,&quot;Droid Sans&quot;,&quot;Helvetica Neue&quot;,sans-serif;font-size:14=
px;font-style:normal;font-variant-ligatures:normal;font-variant-caps:normal=
;font-weight:400;letter-spacing:normal;text-align:start;text-indent:0px;tex=
t-transform:none;white-space:normal;word-spacing:0px;background-color:rgb(2=
44,245,247);text-decoration-style:initial;text-decoration-color:initial"><s=
pan style=3D"color:rgb(23,43,77);font-family:-apple-system,BlinkMacSystemFo=
nt,&quot;Segoe UI&quot;,Roboto,Oxygen,Ubuntu,&quot;Fira Sans&quot;,&quot;Dr=
oid Sans&quot;,&quot;Helvetica Neue&quot;,sans-serif;font-size:14px;font-st=
yle:normal;font-variant-ligatures:normal;font-variant-caps:normal;font-weig=
ht:400;letter-spacing:normal;text-align:start;text-indent:0px;text-transfor=
m:none;white-space:normal;word-spacing:0px;background-color:rgb(244,245,247=
);text-decoration-style:initial;text-decoration-color:initial;float:none;di=
splay:inline">[ 655.622489] RSP: 0018:ffffc9000119bbb8 EFLAGS: 00010246</sp=
an><br style=3D"color:rgb(23,43,77);font-family:-apple-system,BlinkMacSyste=
mFont,&quot;Segoe UI&quot;,Roboto,Oxygen,Ubuntu,&quot;Fira Sans&quot;,&quot=
;Droid Sans&quot;,&quot;Helvetica Neue&quot;,sans-serif;font-size:14px;font=
-style:normal;font-variant-ligatures:normal;font-variant-caps:normal;font-w=
eight:400;letter-spacing:normal;text-align:start;text-indent:0px;text-trans=
form:none;white-space:normal;word-spacing:0px;background-color:rgb(244,245,=
247);text-decoration-style:initial;text-decoration-color:initial"><span sty=
le=3D"color:rgb(23,43,77);font-family:-apple-system,BlinkMacSystemFont,&quo=
t;Segoe UI&quot;,Roboto,Oxygen,Ubuntu,&quot;Fira Sans&quot;,&quot;Droid San=
s&quot;,&quot;Helvetica Neue&quot;,sans-serif;font-size:14px;font-style:nor=
mal;font-variant-ligatures:normal;font-variant-caps:normal;font-weight:400;=
letter-spacing:normal;text-align:start;text-indent:0px;text-transform:none;=
white-space:normal;word-spacing:0px;background-color:rgb(244,245,247);text-=
decoration-style:initial;text-decoration-color:initial;float:none;display:i=
nline">[ 655.623236] RAX: 0000000000000060 RBX: ffff88022a31aa00 RCX: 00000=
00000000000</span><br style=3D"color:rgb(23,43,77);font-family:-apple-syste=
m,BlinkMacSystemFont,&quot;Segoe UI&quot;,Roboto,Oxygen,Ubuntu,&quot;Fira S=
ans&quot;,&quot;Droid Sans&quot;,&quot;Helvetica Neue&quot;,sans-serif;font=
-size:14px;font-style:normal;font-variant-ligatures:normal;font-variant-cap=
s:normal;font-weight:400;letter-spacing:normal;text-align:start;text-indent=
:0px;text-transform:none;white-space:normal;word-spacing:0px;background-col=
or:rgb(244,245,247);text-decoration-style:initial;text-decoration-color:ini=
tial"><span style=3D"color:rgb(23,43,77);font-family:-apple-system,BlinkMac=
SystemFont,&quot;Segoe UI&quot;,Roboto,Oxygen,Ubuntu,&quot;Fira Sans&quot;,=
&quot;Droid Sans&quot;,&quot;Helvetica Neue&quot;,sans-serif;font-size:14px=
;font-style:normal;font-variant-ligatures:normal;font-variant-caps:normal;f=
ont-weight:400;letter-spacing:normal;text-align:start;text-indent:0px;text-=
transform:none;white-space:normal;word-spacing:0px;background-color:rgb(244=
,245,247);text-decoration-style:initial;text-decoration-color:initial;float=
:none;display:inline">[ 655.624234] RDX: 0000000000000000 RSI: ffff88023fcc=
e108 RDI: ffff88023fcce108</span><br style=3D"color:rgb(23,43,77);font-fami=
ly:-apple-system,BlinkMacSystemFont,&quot;Segoe UI&quot;,Roboto,Oxygen,Ubun=
tu,&quot;Fira Sans&quot;,&quot;Droid Sans&quot;,&quot;Helvetica Neue&quot;,=
sans-serif;font-size:14px;font-style:normal;font-variant-ligatures:normal;f=
ont-variant-caps:normal;font-weight:400;letter-spacing:normal;text-align:st=
art;text-indent:0px;text-transform:none;white-space:normal;word-spacing:0px=
;background-color:rgb(244,245,247);text-decoration-style:initial;text-decor=
ation-color:initial"><span style=3D"color:rgb(23,43,77);font-family:-apple-=
system,BlinkMacSystemFont,&quot;Segoe UI&quot;,Roboto,Oxygen,Ubuntu,&quot;F=
ira Sans&quot;,&quot;Droid Sans&quot;,&quot;Helvetica Neue&quot;,sans-serif=
;font-size:14px;font-style:normal;font-variant-ligatures:normal;font-varian=
t-caps:normal;font-weight:400;letter-spacing:normal;text-align:start;text-i=
ndent:0px;text-transform:none;white-space:normal;word-spacing:0px;backgroun=
d-color:rgb(244,245,247);text-decoration-style:initial;text-decoration-colo=
r:initial;float:none;display:inline">[ 655.625237] RBP: ffffc9000119bbd8 R0=
8: 00000000fffffffe R09: 0000000000000271</span><br style=3D"color:rgb(23,4=
3,77);font-family:-apple-system,BlinkMacSystemFont,&quot;Segoe UI&quot;,Rob=
oto,Oxygen,Ubuntu,&quot;Fira Sans&quot;,&quot;Droid Sans&quot;,&quot;Helvet=
ica Neue&quot;,sans-serif;font-size:14px;font-style:normal;font-variant-lig=
atures:normal;font-variant-caps:normal;font-weight:400;letter-spacing:norma=
l;text-align:start;text-indent:0px;text-transform:none;white-space:normal;w=
ord-spacing:0px;background-color:rgb(244,245,247);text-decoration-style:ini=
tial;text-decoration-color:initial"><span style=3D"color:rgb(23,43,77);font=
-family:-apple-system,BlinkMacSystemFont,&quot;Segoe UI&quot;,Roboto,Oxygen=
,Ubuntu,&quot;Fira Sans&quot;,&quot;Droid Sans&quot;,&quot;Helvetica Neue&q=
uot;,sans-serif;font-size:14px;font-style:normal;font-variant-ligatures:nor=
mal;font-variant-caps:normal;font-weight:400;letter-spacing:normal;text-ali=
gn:start;text-indent:0px;text-transform:none;white-space:normal;word-spacin=
g:0px;background-color:rgb(244,245,247);text-decoration-style:initial;text-=
decoration-color:initial;float:none;display:inline">[ 655.626248] R10: 0000=
000000000005 R11: 0000000000000270 R12: 00000000000000c0</span><br style=3D=
"color:rgb(23,43,77);font-family:-apple-system,BlinkMacSystemFont,&quot;Seg=
oe UI&quot;,Roboto,Oxygen,Ubuntu,&quot;Fira Sans&quot;,&quot;Droid Sans&quo=
t;,&quot;Helvetica Neue&quot;,sans-serif;font-size:14px;font-style:normal;f=
ont-variant-ligatures:normal;font-variant-caps:normal;font-weight:400;lette=
r-spacing:normal;text-align:start;text-indent:0px;text-transform:none;white=
-space:normal;word-spacing:0px;background-color:rgb(244,245,247);text-decor=
ation-style:initial;text-decoration-color:initial"><span style=3D"color:rgb=
(23,43,77);font-family:-apple-system,BlinkMacSystemFont,&quot;Segoe UI&quot=
;,Roboto,Oxygen,Ubuntu,&quot;Fira Sans&quot;,&quot;Droid Sans&quot;,&quot;H=
elvetica Neue&quot;,sans-serif;font-size:14px;font-style:normal;font-varian=
t-ligatures:normal;font-variant-caps:normal;font-weight:400;letter-spacing:=
normal;text-align:start;text-indent:0px;text-transform:none;white-space:nor=
mal;word-spacing:0px;background-color:rgb(244,245,247);text-decoration-styl=
e:initial;text-decoration-color:initial;float:none;display:inline">[ 655.62=
7256] R13: ffff88022a31aac0 R14: 0000000000000001 R15: 00000000000000c0</sp=
an><br style=3D"color:rgb(23,43,77);font-family:-apple-system,BlinkMacSyste=
mFont,&quot;Segoe UI&quot;,Roboto,Oxygen,Ubuntu,&quot;Fira Sans&quot;,&quot=
;Droid Sans&quot;,&quot;Helvetica Neue&quot;,sans-serif;font-size:14px;font=
-style:normal;font-variant-ligatures:normal;font-variant-caps:normal;font-w=
eight:400;letter-spacing:normal;text-align:start;text-indent:0px;text-trans=
form:none;white-space:normal;word-spacing:0px;background-color:rgb(244,245,=
247);text-decoration-style:initial;text-decoration-color:initial"><span sty=
le=3D"color:rgb(23,43,77);font-family:-apple-system,BlinkMacSystemFont,&quo=
t;Segoe UI&quot;,Roboto,Oxygen,Ubuntu,&quot;Fira Sans&quot;,&quot;Droid San=
s&quot;,&quot;Helvetica Neue&quot;,sans-serif;font-size:14px;font-style:nor=
mal;font-variant-ligatures:normal;font-variant-caps:normal;font-weight:400;=
letter-spacing:normal;text-align:start;text-indent:0px;text-transform:none;=
white-space:normal;word-spacing:0px;background-color:rgb(244,245,247);text-=
decoration-style:initial;text-decoration-color:initial;float:none;display:i=
nline">[ 655.628268] FS: 00007fb54413b880(0000) GS:ffff88023fcc0000(0000) k=
nlGS:0000000000000000</span><br style=3D"color:rgb(23,43,77);font-family:-a=
pple-system,BlinkMacSystemFont,&quot;Segoe UI&quot;,Roboto,Oxygen,Ubuntu,&q=
uot;Fira Sans&quot;,&quot;Droid Sans&quot;,&quot;Helvetica Neue&quot;,sans-=
serif;font-size:14px;font-style:normal;font-variant-ligatures:normal;font-v=
ariant-caps:normal;font-weight:400;letter-spacing:normal;text-align:start;t=
ext-indent:0px;text-transform:none;white-space:normal;word-spacing:0px;back=
ground-color:rgb(244,245,247);text-decoration-style:initial;text-decoration=
-color:initial"><span style=3D"color:rgb(23,43,77);font-family:-apple-syste=
m,BlinkMacSystemFont,&quot;Segoe UI&quot;,Roboto,Oxygen,Ubuntu,&quot;Fira S=
ans&quot;,&quot;Droid Sans&quot;,&quot;Helvetica Neue&quot;,sans-serif;font=
-size:14px;font-style:normal;font-variant-ligatures:normal;font-variant-cap=
s:normal;font-weight:400;letter-spacing:normal;text-align:start;text-indent=
:0px;text-transform:none;white-space:normal;word-spacing:0px;background-col=
or:rgb(244,245,247);text-decoration-style:initial;text-decoration-color:ini=
tial;float:none;display:inline">[ 655.629561] CS: 0010 DS: 0000 ES: 0000 CR=
0: 0000000080050033</span><br style=3D"color:rgb(23,43,77);font-family:-app=
le-system,BlinkMacSystemFont,&quot;Segoe UI&quot;,Roboto,Oxygen,Ubuntu,&quo=
t;Fira Sans&quot;,&quot;Droid Sans&quot;,&quot;Helvetica Neue&quot;,sans-se=
rif;font-size:14px;font-style:normal;font-variant-ligatures:normal;font-var=
iant-caps:normal;font-weight:400;letter-spacing:normal;text-align:start;tex=
t-indent:0px;text-transform:none;white-space:normal;word-spacing:0px;backgr=
ound-color:rgb(244,245,247);text-decoration-style:initial;text-decoration-c=
olor:initial"><span style=3D"color:rgb(23,43,77);font-family:-apple-system,=
BlinkMacSystemFont,&quot;Segoe UI&quot;,Roboto,Oxygen,Ubuntu,&quot;Fira San=
s&quot;,&quot;Droid Sans&quot;,&quot;Helvetica Neue&quot;,sans-serif;font-s=
ize:14px;font-style:normal;font-variant-ligatures:normal;font-variant-caps:=
normal;font-weight:400;letter-spacing:normal;text-align:start;text-indent:0=
px;text-transform:none;white-space:normal;word-spacing:0px;background-color=
:rgb(244,245,247);text-decoration-style:initial;text-decoration-color:initi=
al;float:none;display:inline">[ 655.630289] CR2: 00007fb5439dc5c0 CR3: 0000=
00023211d000 CR4: 00000000003406e0</span><br style=3D"color:rgb(23,43,77);f=
ont-family:-apple-system,BlinkMacSystemFont,&quot;Segoe UI&quot;,Roboto,Oxy=
gen,Ubuntu,&quot;Fira Sans&quot;,&quot;Droid Sans&quot;,&quot;Helvetica Neu=
e&quot;,sans-serif;font-size:14px;font-style:normal;font-variant-ligatures:=
normal;font-variant-caps:normal;font-weight:400;letter-spacing:normal;text-=
align:start;text-indent:0px;text-transform:none;white-space:normal;word-spa=
cing:0px;background-color:rgb(244,245,247);text-decoration-style:initial;te=
xt-decoration-color:initial"><span style=3D"color:rgb(23,43,77);font-family=
:-apple-system,BlinkMacSystemFont,&quot;Segoe UI&quot;,Roboto,Oxygen,Ubuntu=
,&quot;Fira Sans&quot;,&quot;Droid Sans&quot;,&quot;Helvetica Neue&quot;,sa=
ns-serif;font-size:14px;font-style:normal;font-variant-ligatures:normal;fon=
t-variant-caps:normal;font-weight:400;letter-spacing:normal;text-align:star=
t;text-indent:0px;text-transform:none;white-space:normal;word-spacing:0px;b=
ackground-color:rgb(244,245,247);text-decoration-style:initial;text-decorat=
ion-color:initial;float:none;display:inline">[ 655.631268] DR0: 00000000000=
00000 DR1: 0000000000000000 DR2: 0000000000000000</span><br style=3D"color:=
rgb(23,43,77);font-family:-apple-system,BlinkMacSystemFont,&quot;Segoe UI&q=
uot;,Roboto,Oxygen,Ubuntu,&quot;Fira Sans&quot;,&quot;Droid Sans&quot;,&quo=
t;Helvetica Neue&quot;,sans-serif;font-size:14px;font-style:normal;font-var=
iant-ligatures:normal;font-variant-caps:normal;font-weight:400;letter-spaci=
ng:normal;text-align:start;text-indent:0px;text-transform:none;white-space:=
normal;word-spacing:0px;background-color:rgb(244,245,247);text-decoration-s=
tyle:initial;text-decoration-color:initial"><span style=3D"color:rgb(23,43,=
77);font-family:-apple-system,BlinkMacSystemFont,&quot;Segoe UI&quot;,Robot=
o,Oxygen,Ubuntu,&quot;Fira Sans&quot;,&quot;Droid Sans&quot;,&quot;Helvetic=
a Neue&quot;,sans-serif;font-size:14px;font-style:normal;font-variant-ligat=
ures:normal;font-variant-caps:normal;font-weight:400;letter-spacing:normal;=
text-align:start;text-indent:0px;text-transform:none;white-space:normal;wor=
d-spacing:0px;background-color:rgb(244,245,247);text-decoration-style:initi=
al;text-decoration-color:initial;float:none;display:inline">[ 655.632281] D=
R3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400</span><br =
style=3D"color:rgb(23,43,77);font-family:-apple-system,BlinkMacSystemFont,&=
quot;Segoe UI&quot;,Roboto,Oxygen,Ubuntu,&quot;Fira Sans&quot;,&quot;Droid =
Sans&quot;,&quot;Helvetica Neue&quot;,sans-serif;font-size:14px;font-style:=
normal;font-variant-ligatures:normal;font-variant-caps:normal;font-weight:4=
00;letter-spacing:normal;text-align:start;text-indent:0px;text-transform:no=
ne;white-space:normal;word-spacing:0px;background-color:rgb(244,245,247);te=
xt-decoration-style:initial;text-decoration-color:initial"><span style=3D"c=
olor:rgb(23,43,77);font-family:-apple-system,BlinkMacSystemFont,&quot;Segoe=
 UI&quot;,Roboto,Oxygen,Ubuntu,&quot;Fira Sans&quot;,&quot;Droid Sans&quot;=
,&quot;Helvetica Neue&quot;,sans-serif;font-size:14px;font-style:normal;fon=
t-variant-ligatures:normal;font-variant-caps:normal;font-weight:400;letter-=
spacing:normal;text-align:start;text-indent:0px;text-transform:none;white-s=
pace:normal;word-spacing:0px;background-color:rgb(244,245,247);text-decorat=
ion-style:initial;text-decoration-color:initial;float:none;display:inline">=
[ 655.633318] Call Trace:</span><br style=3D"color:rgb(23,43,77);font-famil=
y:-apple-system,BlinkMacSystemFont,&quot;Segoe UI&quot;,Roboto,Oxygen,Ubunt=
u,&quot;Fira Sans&quot;,&quot;Droid Sans&quot;,&quot;Helvetica Neue&quot;,s=
ans-serif;font-size:14px;font-style:normal;font-variant-ligatures:normal;fo=
nt-variant-caps:normal;font-weight:400;letter-spacing:normal;text-align:sta=
rt;text-indent:0px;text-transform:none;white-space:normal;word-spacing:0px;=
background-color:rgb(244,245,247);text-decoration-style:initial;text-decora=
tion-color:initial"><span style=3D"color:rgb(23,43,77);font-family:-apple-s=
ystem,BlinkMacSystemFont,&quot;Segoe UI&quot;,Roboto,Oxygen,Ubuntu,&quot;Fi=
ra Sans&quot;,&quot;Droid Sans&quot;,&quot;Helvetica Neue&quot;,sans-serif;=
font-size:14px;font-style:normal;font-variant-ligatures:normal;font-variant=
-caps:normal;font-weight:400;letter-spacing:normal;text-align:start;text-in=
dent:0px;text-transform:none;white-space:normal;word-spacing:0px;background=
-color:rgb(244,245,247);text-decoration-style:initial;text-decoration-color=
:initial;float:none;display:inline">[ 655.633696] copy_page_to_iter_iovec+0=
x9c/0x180</span><br style=3D"color:rgb(23,43,77);font-family:-apple-system,=
BlinkMacSystemFont,&quot;Segoe UI&quot;,Roboto,Oxygen,Ubuntu,&quot;Fira San=
s&quot;,&quot;Droid Sans&quot;,&quot;Helvetica Neue&quot;,sans-serif;font-s=
ize:14px;font-style:normal;font-variant-ligatures:normal;font-variant-caps:=
normal;font-weight:400;letter-spacing:normal;text-align:start;text-indent:0=
px;text-transform:none;white-space:normal;word-spacing:0px;background-color=
:rgb(244,245,247);text-decoration-style:initial;text-decoration-color:initi=
al"><span style=3D"color:rgb(23,43,77);font-family:-apple-system,BlinkMacSy=
stemFont,&quot;Segoe UI&quot;,Roboto,Oxygen,Ubuntu,&quot;Fira Sans&quot;,&q=
uot;Droid Sans&quot;,&quot;Helvetica Neue&quot;,sans-serif;font-size:14px;f=
ont-style:normal;font-variant-ligatures:normal;font-variant-caps:normal;fon=
t-weight:400;letter-spacing:normal;text-align:start;text-indent:0px;text-tr=
ansform:none;white-space:normal;word-spacing:0px;background-color:rgb(244,2=
45,247);text-decoration-style:initial;text-decoration-color:initial;float:n=
one;display:inline">[ 655.634351] copy_page_to_iter+0x22/0x160</span><br st=
yle=3D"color:rgb(23,43,77);font-family:-apple-system,BlinkMacSystemFont,&qu=
ot;Segoe UI&quot;,Roboto,Oxygen,Ubuntu,&quot;Fira Sans&quot;,&quot;Droid Sa=
ns&quot;,&quot;Helvetica Neue&quot;,sans-serif;font-size:14px;font-style:no=
rmal;font-variant-ligatures:normal;font-variant-caps:normal;font-weight:400=
;letter-spacing:normal;text-align:start;text-indent:0px;text-transform:none=
;white-space:normal;word-spacing:0px;background-color:rgb(244,245,247);text=
-decoration-style:initial;text-decoration-color:initial"><span style=3D"col=
or:rgb(23,43,77);font-family:-apple-system,BlinkMacSystemFont,&quot;Segoe U=
I&quot;,Roboto,Oxygen,Ubuntu,&quot;Fira Sans&quot;,&quot;Droid Sans&quot;,&=
quot;Helvetica Neue&quot;,sans-serif;font-size:14px;font-style:normal;font-=
variant-ligatures:normal;font-variant-caps:normal;font-weight:400;letter-sp=
acing:normal;text-align:start;text-indent:0px;text-transform:none;white-spa=
ce:normal;word-spacing:0px;background-color:rgb(244,245,247);text-decoratio=
n-style:initial;text-decoration-color:initial;float:none;display:inline">[ =
655.634943] skb_copy_datagram_iter+0x157/0x260</span><br style=3D"color:rgb=
(23,43,77);font-family:-apple-system,BlinkMacSystemFont,&quot;Segoe UI&quot=
;,Roboto,Oxygen,Ubuntu,&quot;Fira Sans&quot;,&quot;Droid Sans&quot;,&quot;H=
elvetica Neue&quot;,sans-serif;font-size:14px;font-style:normal;font-varian=
t-ligatures:normal;font-variant-caps:normal;font-weight:400;letter-spacing:=
normal;text-align:start;text-indent:0px;text-transform:none;white-space:nor=
mal;word-spacing:0px;background-color:rgb(244,245,247);text-decoration-styl=
e:initial;text-decoration-color:initial"><span style=3D"color:rgb(23,43,77)=
;font-family:-apple-system,BlinkMacSystemFont,&quot;Segoe UI&quot;,Roboto,O=
xygen,Ubuntu,&quot;Fira Sans&quot;,&quot;Droid Sans&quot;,&quot;Helvetica N=
eue&quot;,sans-serif;font-size:14px;font-style:normal;font-variant-ligature=
s:normal;font-variant-caps:normal;font-weight:400;letter-spacing:normal;tex=
t-align:start;text-indent:0px;text-transform:none;white-space:normal;word-s=
pacing:0px;background-color:rgb(244,245,247);text-decoration-style:initial;=
text-decoration-color:initial;float:none;display:inline">[ 655.635604] pack=
et_recvmsg+0xcb/0x460</span><br style=3D"color:rgb(23,43,77);font-family:-a=
pple-system,BlinkMacSystemFont,&quot;Segoe UI&quot;,Roboto,Oxygen,Ubuntu,&q=
uot;Fira Sans&quot;,&quot;Droid Sans&quot;,&quot;Helvetica Neue&quot;,sans-=
serif;font-size:14px;font-style:normal;font-variant-ligatures:normal;font-v=
ariant-caps:normal;font-weight:400;letter-spacing:normal;text-align:start;t=
ext-indent:0px;text-transform:none;white-space:normal;word-spacing:0px;back=
ground-color:rgb(244,245,247);text-decoration-style:initial;text-decoration=
-color:initial"><span style=3D"color:rgb(23,43,77);font-family:-apple-syste=
m,BlinkMacSystemFont,&quot;Segoe UI&quot;,Roboto,Oxygen,Ubuntu,&quot;Fira S=
ans&quot;,&quot;Droid Sans&quot;,&quot;Helvetica Neue&quot;,sans-serif;font=
-size:14px;font-style:normal;font-variant-ligatures:normal;font-variant-cap=
s:normal;font-weight:400;letter-spacing:normal;text-align:start;text-indent=
:0px;text-transform:none;white-space:normal;word-spacing:0px;background-col=
or:rgb(244,245,247);text-decoration-style:initial;text-decoration-color:ini=
tial;float:none;display:inline">[ 655.636156] ? selinux_socket_recvmsg+0x17=
/0x20</span><br style=3D"color:rgb(23,43,77);font-family:-apple-system,Blin=
kMacSystemFont,&quot;Segoe UI&quot;,Roboto,Oxygen,Ubuntu,&quot;Fira Sans&qu=
ot;,&quot;Droid Sans&quot;,&quot;Helvetica Neue&quot;,sans-serif;font-size:=
14px;font-style:normal;font-variant-ligatures:normal;font-variant-caps:norm=
al;font-weight:400;letter-spacing:normal;text-align:start;text-indent:0px;t=
ext-transform:none;white-space:normal;word-spacing:0px;background-color:rgb=
(244,245,247);text-decoration-style:initial;text-decoration-color:initial">=
<span style=3D"color:rgb(23,43,77);font-family:-apple-system,BlinkMacSystem=
Font,&quot;Segoe UI&quot;,Roboto,Oxygen,Ubuntu,&quot;Fira Sans&quot;,&quot;=
Droid Sans&quot;,&quot;Helvetica Neue&quot;,sans-serif;font-size:14px;font-=
style:normal;font-variant-ligatures:normal;font-variant-caps:normal;font-we=
ight:400;letter-spacing:normal;text-align:start;text-indent:0px;text-transf=
orm:none;white-space:normal;word-spacing:0px;background-color:rgb(244,245,2=
47);text-decoration-style:initial;text-decoration-color:initial;float:none;=
display:inline">[ 655.636816] sock_recvmsg+0x3d/0x50</span><br style=3D"col=
or:rgb(23,43,77);font-family:-apple-system,BlinkMacSystemFont,&quot;Segoe U=
I&quot;,Roboto,Oxygen,Ubuntu,&quot;Fira Sans&quot;,&quot;Droid Sans&quot;,&=
quot;Helvetica Neue&quot;,sans-serif;font-size:14px;font-style:normal;font-=
variant-ligatures:normal;font-variant-caps:normal;font-weight:400;letter-sp=
acing:normal;text-align:start;text-indent:0px;text-transform:none;white-spa=
ce:normal;word-spacing:0px;background-color:rgb(244,245,247);text-decoratio=
n-style:initial;text-decoration-color:initial"><span style=3D"color:rgb(23,=
43,77);font-family:-apple-system,BlinkMacSystemFont,&quot;Segoe UI&quot;,Ro=
boto,Oxygen,Ubuntu,&quot;Fira Sans&quot;,&quot;Droid Sans&quot;,&quot;Helve=
tica Neue&quot;,sans-serif;font-size:14px;font-style:normal;font-variant-li=
gatures:normal;font-variant-caps:normal;font-weight:400;letter-spacing:norm=
al;text-align:start;text-indent:0px;text-transform:none;white-space:normal;=
word-spacing:0px;background-color:rgb(244,245,247);text-decoration-style:in=
itial;text-decoration-color:initial;float:none;display:inline">[ 655.637330=
] ___sys_recvmsg+0xd7/0x1f0</span><br style=3D"color:rgb(23,43,77);font-fam=
ily:-apple-system,BlinkMacSystemFont,&quot;Segoe UI&quot;,Roboto,Oxygen,Ubu=
ntu,&quot;Fira Sans&quot;,&quot;Droid Sans&quot;,&quot;Helvetica Neue&quot;=
,sans-serif;font-size:14px;font-style:normal;font-variant-ligatures:normal;=
font-variant-caps:normal;font-weight:400;letter-spacing:normal;text-align:s=
tart;text-indent:0px;text-transform:none;white-space:normal;word-spacing:0p=
x;background-color:rgb(244,245,247);text-decoration-style:initial;text-deco=
ration-color:initial"><span style=3D"color:rgb(23,43,77);font-family:-apple=
-system,BlinkMacSystemFont,&quot;Segoe UI&quot;,Roboto,Oxygen,Ubuntu,&quot;=
Fira Sans&quot;,&quot;Droid Sans&quot;,&quot;Helvetica Neue&quot;,sans-seri=
f;font-size:14px;font-style:normal;font-variant-ligatures:normal;font-varia=
nt-caps:normal;font-weight:400;letter-spacing:normal;text-align:start;text-=
indent:0px;text-transform:none;white-space:normal;word-spacing:0px;backgrou=
nd-color:rgb(244,245,247);text-decoration-style:initial;text-decoration-col=
or:initial;float:none;display:inline">[ 655.637892] ? kvm_clock_get_cycles+=
0x1e/0x20</span><br style=3D"color:rgb(23,43,77);font-family:-apple-system,=
BlinkMacSystemFont,&quot;Segoe UI&quot;,Roboto,Oxygen,Ubuntu,&quot;Fira San=
s&quot;,&quot;Droid Sans&quot;,&quot;Helvetica Neue&quot;,sans-serif;font-s=
ize:14px;font-style:normal;font-variant-ligatures:normal;font-variant-caps:=
normal;font-weight:400;letter-spacing:normal;text-align:start;text-indent:0=
px;text-transform:none;white-space:normal;word-spacing:0px;background-color=
:rgb(244,245,247);text-decoration-style:initial;text-decoration-color:initi=
al"><span style=3D"color:rgb(23,43,77);font-family:-apple-system,BlinkMacSy=
stemFont,&quot;Segoe UI&quot;,Roboto,Oxygen,Ubuntu,&quot;Fira Sans&quot;,&q=
uot;Droid Sans&quot;,&quot;Helvetica Neue&quot;,sans-serif;font-size:14px;f=
ont-style:normal;font-variant-ligatures:normal;font-variant-caps:normal;fon=
t-weight:400;letter-spacing:normal;text-align:start;text-indent:0px;text-tr=
ansform:none;white-space:normal;word-spacing:0px;background-color:rgb(244,2=
45,247);text-decoration-style:initial;text-decoration-color:initial;float:n=
one;display:inline">[ 655.638533] ? ktime_get_ts64+0x49/0xf0</span><br styl=
e=3D"color:rgb(23,43,77);font-family:-apple-system,BlinkMacSystemFont,&quot=
;Segoe UI&quot;,Roboto,Oxygen,Ubuntu,&quot;Fira Sans&quot;,&quot;Droid Sans=
&quot;,&quot;Helvetica Neue&quot;,sans-serif;font-size:14px;font-style:norm=
al;font-variant-ligatures:normal;font-variant-caps:normal;font-weight:400;l=
etter-spacing:normal;text-align:start;text-indent:0px;text-transform:none;w=
hite-space:normal;word-spacing:0px;background-color:rgb(244,245,247);text-d=
ecoration-style:initial;text-decoration-color:initial"><span style=3D"color=
:rgb(23,43,77);font-family:-apple-system,BlinkMacSystemFont,&quot;Segoe UI&=
quot;,Roboto,Oxygen,Ubuntu,&quot;Fira Sans&quot;,&quot;Droid Sans&quot;,&qu=
ot;Helvetica Neue&quot;,sans-serif;font-size:14px;font-style:normal;font-va=
riant-ligatures:normal;font-variant-caps:normal;font-weight:400;letter-spac=
ing:normal;text-align:start;text-indent:0px;text-transform:none;white-space=
:normal;word-spacing:0px;background-color:rgb(244,245,247);text-decoration-=
style:initial;text-decoration-color:initial;float:none;display:inline">[ 65=
5.639101] ? _copy_to_user+0x26/0x40</span><br style=3D"color:rgb(23,43,77);=
font-family:-apple-system,BlinkMacSystemFont,&quot;Segoe UI&quot;,Roboto,Ox=
ygen,Ubuntu,&quot;Fira Sans&quot;,&quot;Droid Sans&quot;,&quot;Helvetica Ne=
ue&quot;,sans-serif;font-size:14px;font-style:normal;font-variant-ligatures=
:normal;font-variant-caps:normal;font-weight:400;letter-spacing:normal;text=
-align:start;text-indent:0px;text-transform:none;white-space:normal;word-sp=
acing:0px;background-color:rgb(244,245,247);text-decoration-style:initial;t=
ext-decoration-color:initial"><span style=3D"color:rgb(23,43,77);font-famil=
y:-apple-system,BlinkMacSystemFont,&quot;Segoe UI&quot;,Roboto,Oxygen,Ubunt=
u,&quot;Fira Sans&quot;,&quot;Droid Sans&quot;,&quot;Helvetica Neue&quot;,s=
ans-serif;font-size:14px;font-style:normal;font-variant-ligatures:normal;fo=
nt-variant-caps:normal;font-weight:400;letter-spacing:normal;text-align:sta=
rt;text-indent:0px;text-transform:none;white-space:normal;word-spacing:0px;=
background-color:rgb(244,245,247);text-decoration-style:initial;text-decora=
tion-color:initial;float:none;display:inline">[ 655.639657] __sys_recvmsg+0=
x51/0x90</span><br style=3D"color:rgb(23,43,77);font-family:-apple-system,B=
linkMacSystemFont,&quot;Segoe UI&quot;,Roboto,Oxygen,Ubuntu,&quot;Fira Sans=
&quot;,&quot;Droid Sans&quot;,&quot;Helvetica Neue&quot;,sans-serif;font-si=
ze:14px;font-style:normal;font-variant-ligatures:normal;font-variant-caps:n=
ormal;font-weight:400;letter-spacing:normal;text-align:start;text-indent:0p=
x;text-transform:none;white-space:normal;word-spacing:0px;background-color:=
rgb(244,245,247);text-decoration-style:initial;text-decoration-color:initia=
l"><span style=3D"color:rgb(23,43,77);font-family:-apple-system,BlinkMacSys=
temFont,&quot;Segoe UI&quot;,Roboto,Oxygen,Ubuntu,&quot;Fira Sans&quot;,&qu=
ot;Droid Sans&quot;,&quot;Helvetica Neue&quot;,sans-serif;font-size:14px;fo=
nt-style:normal;font-variant-ligatures:normal;font-variant-caps:normal;font=
-weight:400;letter-spacing:normal;text-align:start;text-indent:0px;text-tra=
nsform:none;white-space:normal;word-spacing:0px;background-color:rgb(244,24=
5,247);text-decoration-style:initial;text-decoration-color:initial;float:no=
ne;display:inline">[ 655.640184] SyS_recvmsg+0x12/0x20</span><br style=3D"c=
olor:rgb(23,43,77);font-family:-apple-system,BlinkMacSystemFont,&quot;Segoe=
 UI&quot;,Roboto,Oxygen,Ubuntu,&quot;Fira Sans&quot;,&quot;Droid Sans&quot;=
,&quot;Helvetica Neue&quot;,sans-serif;font-size:14px;font-style:normal;fon=
t-variant-ligatures:normal;font-variant-caps:normal;font-weight:400;letter-=
spacing:normal;text-align:start;text-indent:0px;text-transform:none;white-s=
pace:normal;word-spacing:0px;background-color:rgb(244,245,247);text-decorat=
ion-style:initial;text-decoration-color:initial"><span style=3D"color:rgb(2=
3,43,77);font-family:-apple-system,BlinkMacSystemFont,&quot;Segoe UI&quot;,=
Roboto,Oxygen,Ubuntu,&quot;Fira Sans&quot;,&quot;Droid Sans&quot;,&quot;Hel=
vetica Neue&quot;,sans-serif;font-size:14px;font-style:normal;font-variant-=
ligatures:normal;font-variant-caps:normal;font-weight:400;letter-spacing:no=
rmal;text-align:start;text-indent:0px;text-transform:none;white-space:norma=
l;word-spacing:0px;background-color:rgb(244,245,247);text-decoration-style:=
initial;text-decoration-color:initial;float:none;display:inline">[ 655.6406=
96] entry_SYSCALL_64_fastpath+0x1a/0xa5</span><br style=3D"color:rgb(23,43,=
77);font-family:-apple-system,BlinkMacSystemFont,&quot;Segoe UI&quot;,Robot=
o,Oxygen,Ubuntu,&quot;Fira Sans&quot;,&quot;Droid Sans&quot;,&quot;Helvetic=
a Neue&quot;,sans-serif;font-size:14px;font-style:normal;font-variant-ligat=
ures:normal;font-variant-caps:normal;font-weight:400;letter-spacing:normal;=
text-align:start;text-indent:0px;text-transform:none;white-space:normal;wor=
d-spacing:0px;background-color:rgb(244,245,247);text-decoration-style:initi=
al;text-decoration-color:initial"><span style=3D"color:rgb(23,43,77);font-f=
amily:-apple-system,BlinkMacSystemFont,&quot;Segoe UI&quot;,Roboto,Oxygen,U=
buntu,&quot;Fira Sans&quot;,&quot;Droid Sans&quot;,&quot;Helvetica Neue&quo=
t;,sans-serif;font-size:14px;font-style:normal;font-variant-ligatures:norma=
l;font-variant-caps:normal;font-weight:400;letter-spacing:normal;text-align=
:start;text-indent:0px;text-transform:none;white-space:normal;word-spacing:=
0px;background-color:rgb(244,245,247);text-decoration-style:initial;text-de=
coration-color:initial;float:none;display:inline">-------------------------=
---------------------------------------------------------------------------=
----------------------------------------</span><br style=3D"color:rgb(23,43=
,77);font-family:-apple-system,BlinkMacSystemFont,&quot;Segoe UI&quot;,Robo=
to,Oxygen,Ubuntu,&quot;Fira Sans&quot;,&quot;Droid Sans&quot;,&quot;Helveti=
ca Neue&quot;,sans-serif;font-size:14px;font-style:normal;font-variant-liga=
tures:normal;font-variant-caps:normal;font-weight:400;letter-spacing:normal=
;text-align:start;text-indent:0px;text-transform:none;white-space:normal;wo=
rd-spacing:0px;background-color:rgb(244,245,247);text-decoration-style:init=
ial;text-decoration-color:initial"><br></div></div>

--0000000000004e20a5056d895068--
