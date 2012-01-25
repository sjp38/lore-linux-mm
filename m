Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx154.postini.com [74.125.245.154])
	by kanga.kvack.org (Postfix) with SMTP id 3BB9F6B004D
	for <linux-mm@kvack.org>; Wed, 25 Jan 2012 00:22:07 -0500 (EST)
References: <1327310360.96918.YahooMailNeo@web162003.mail.bf1.yahoo.com> <1327313719.76517.YahooMailNeo@web162002.mail.bf1.yahoo.com> <alpine.LSU.2.00.1201231125200.1677@eggly.anvils>
Message-ID: <1327468926.52380.YahooMailNeo@web162002.mail.bf1.yahoo.com>
Date: Tue, 24 Jan 2012 21:22:06 -0800 (PST)
From: PINTU KUMAR <pintu_agarwal@yahoo.com>
Reply-To: PINTU KUMAR <pintu_agarwal@yahoo.com>
Subject: Re: [Help] : RSS/PSS showing 0 during smaps for Xorg
In-Reply-To: <alpine.LSU.2.00.1201231125200.1677@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

________________________________=0A>From: Hugh Dickins <hughd@google.com>=
=0A>To: PINTU KUMAR <pintu_agarwal@yahoo.com> =0A>Cc: "linux-kernel@vger.ke=
rnel.org" <linux-kernel@vger.kernel.org>; "linux-mm@kvack.org" <linux-mm@kv=
ack.org> =0A>Sent: Tuesday, 24 January 2012 1:01 AM=0A>Subject: Re: [Help] =
: RSS/PSS showing 0 during smaps for Xorg=0A>=0A>On Mon, 23 Jan 2012, PINTU=
 KUMAR wrote:=0A>> Dear All,=0A>> =0A>> I am facing one problem for one of =
my kernel module for our linux mobile with kernel2.6.36.=0A>> =0A>> When I =
do cat /proc/<Xorg pid>/smaps | grep -A 11 /dev/ump , to track information =
for my=A0ump module,=0A>> we always get Rss/Pss as 0 kB as shown below:=0A>=
> cat /proc/1731/smaps | grep -A 11 /dev/ump=0A>> 414db000-415ff000 rw-s 00=
015000 00:12 6803=A0=A0=A0=A0=A0=A0 /dev/ump=0A>> Size:=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0 1168 kB=0A>> Rss:=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0 0 kB=0A>> Pss:=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0 0 kB=0A>> track_rss_value =3D 0, iswalkcalled =3D 1, smap_p=
te_range_called =3D 1,=A0swap_pte =3D 0,=A0not_pte_present =3D 0,=A0not_nor=
mal_page =3D 1=0A>> isspecial =3D 0, not_special =3D 1, isMixedMap =3D 0, p=
fnpages_null =3D 0, pfnoff_flag =3D 0, not_cow_mapping =3D 1,=A0normal_page=
_end =3D 0=0A>> =A0=0A>> After tracing down the problem, I found out that d=
uring "show_smaps" in fs/proc/task_mmu.c and during call to smaps_pte_range=
 the vm_normal_page() is always returning NULL for our /dev/ump driver.=0A>=
> (smaps_pte_range() is the place where Rss/Pss information is populated)=
=0A>> Thus mss->resident (Rss value) is never getting incremented.=A0 =0A>>=
 =A0=0A>> To trace the problem I added few flags during show_smaps & vm_nor=
mal_page() as shown above. The value of 1 indicates that the condition is e=
xecuted.=0A>> Thus "normal_page_end" indicates that the "vm_normal_page" ha=
s never ended successfully and always returns from =0A>> "!is_cow_mapping()=
".=0A>> =A0=0A>> So, I wanted to know the main cause for vm_normal_page() a=
lways returning NULL page for our ump driver. =0A>> What is that I am missi=
ng in my driver ?=0A>> =A0=0A>> Can anyone please let me know what could be=
 the problem in our driver.=0A>=0A>This not evidence of any problem in your=
 driver.=0A>=0A>vm_normal_page() returns NULL because the pages mapped by y=
our driver=0A>are not normal faultable and reclaimable pages, but an area o=
f physical=0A>memory mapped in by remap_pfn_range(), which sets the VM_PFNM=
AP flag.=0A>=0A>The mm subsystem does not count such pages towards rss (or =
pss),=0A>hence your 0s.=0A>=0A>Hugh=0A>=0A=0ADear Mr. Hugh,=0A=A0=0AThank y=
ou very much for your reply.=0AIs there a way to convert our mapped pages t=
o a normal pages. I tried pfn_to_page() but no effect.=0AI mean the page is=
 considered normal only if it is associated with "struct page" right???=0AI=
s is possible to convert these pages to a normal struct pages so that we ca=
n get the Rss/Pss value??=0A=A0=0AAlso, the VM_PFNMAP is being set for all =
dirvers during remap_pfn_range and stills shows Rss/Pss for other drivers.=
=0AThen why it is not shown for our driver?=0AHow to avoid remap_pfn_range =
to not to set VM_PFNMAP for our driver?=0A=A0=0APlease let me know.=0A=A0=
=0A=A0=0A=A0=0AThanks, Regards,=0APintu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
