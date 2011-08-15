Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id C8CB46B00EE
	for <linux-mm@kvack.org>; Mon, 15 Aug 2011 01:01:54 -0400 (EDT)
References: <1313146843.1015.YahooMailNeo@web162014.mail.bf1.yahoo.com> <alpine.DEB.2.00.1108121053490.16906@router.home>
Message-ID: <1313384511.62052.YahooMailNeo@web162020.mail.bf1.yahoo.com>
Date: Sun, 14 Aug 2011 22:01:51 -0700 (PDT)
From: Pintu Agarwal <pintu_agarwal@yahoo.com>
Reply-To: Pintu Agarwal <pintu_agarwal@yahoo.com>
Subject: Re: Tracking page allocation in Zone/Node
In-Reply-To: <alpine.DEB.2.00.1108121053490.16906@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: "mgorman@suse.de" <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Thanks Christoph for your reply :)=0A=A0=0A> Weird system. One would expect=
 it to only have NORMAL zones. Is this an=0A> ARM system?=0A=A0=0AYes this =
is an ARM based system for linux mobile phone.=0A=A0=0A> I am not sure that=
 I understand you correctly but you can get the data from node 2 via=0A> zo=
ne_page_state(NODE_DATA[2]->node_zones[ZONE_DMA], NR_FREE_PAGES);=0A=A0=0AY=
es, you got me right. I wanted to access Node 2 data from the preferred zon=
e. This is helpful, thanks.=0ABut I want it to be dynamic. That is if Node =
2 is over-loaded, then the allocation happens from Node 1 or Node 0 as well=
.=0AAlso it should work on normal desktop itself where there are DMA, Norma=
l, HighMem as well.=0AHow to make the above statement generic so that it sh=
ould work in all scenarios?=0A=A0=0A> or in __alloc_pages_nodemask=0A> zone=
_page_state(preferred_zone, NR_FREE_PAGES);=0A=0AYes, I tried exactly like =
this, but since I have only one zone (DMA), it always returns me the data f=
rom the first Node 0.=0AThis will only work, if I have 3 separate zones (DM=
A, Normal, HighMem)=0A=A0=0AIn "__alloc_pages_nodemask", before the actual =
allocation happens, how to find out the allocation is going to happen from =
which zone and which Node.?=0A(The _preferred_zone_ info is not enough, I n=
eed to know the Node number as well)=0A=A0=0APlease help...=0AI hope the qu=
estion is clear know.=0A=A0=0A=A0=0A=A0=0AThanks,=0APintu=0A=A0=0A=A0=0A---=
-- Original Message -----=0AFrom: Christoph Lameter <cl@linux.com>=0ATo: Pi=
ntu Agarwal <pintu_agarwal@yahoo.com>=0ACc: "mgorman@suse.de" <mgorman@suse=
.de>; "linux-mm@kvack.org" <linux-mm@kvack.org>=0ASent: Friday, 12 August 2=
011 9:38 PM=0ASubject: Re: Tracking page allocation in Zone/Node=0A=0AOn Fr=
i, 12 Aug 2011, Pintu Agarwal wrote:=0A=0A> On my system I have only DMA zo=
nes with 3 nodes as follows:=0A> Node 0, zone=A0=A0=A0=A0=A0 DMA=A0=A0=A0=
=A0=A0 3=A0=A0=A0=A0=A0 4=A0=A0=A0=A0=A0 6=A0=A0=A0=A0=A0 4=A0=A0=A0=A0=A0 =
5=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=
=A0=A0=A0 0=A0=A0=A0=A0=A0 0=0A> Node 1, zone=A0=A0=A0=A0=A0 DMA=A0=A0=A0=
=A0=A0 8=A0=A0=A0=A0=A0 4=A0=A0=A0=A0=A0 3=A0=A0=A0=A0=A0 8=A0=A0=A0=A0=A0 =
7=A0=A0=A0=A0=A0 4=A0=A0=A0=A0=A0 2=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=
=A0=A0=A0 0=A0=A0=A0=A0=A0 0=0A> Node 2, zone=A0=A0=A0=A0=A0 DMA=A0=A0=A0=
=A0 10=A0=A0=A0=A0=A0 2=A0=A0=A0=A0=A0 8=A0=A0=A0=A0=A0 3=A0=A0=A0=A0=A0 2=
=A0=A0=A0=A0=A0 2=A0=A0=A0=A0=A0 4=A0=A0=A0=A0=A0 1=A0=A0=A0=A0=A0 2=A0=A0=
=A0=A0=A0 2=A0=A0=A0=A0 28=0A=0AWeird system. One would expect it to only h=
ave NORMAL zones. Is this an=0AARM system?=0A=0A=0A> In __alloc_pages_nodem=
ask(...), just before "First Allocation Attempt" [that is before get_page_f=
rom_freelist(....)], I wanted to print=A0all the free pages from the "prefe=
rred_zone".=0A> Using something like=A0this :=0A> totalfreepages =3D zone_p=
age_state(zone, NR_FREE_PAGES);=0A> =A0=0A> But in my case, there is only o=
ne zone (DMA) but 3 nodes.=0A> Thus the above "zone_page_state" always retu=
rns totalfreepages only from first Node 0.=0A> But the allocation actually =
happening from Node 2.=0A> =A0=0A> How can we point to the zone of Node 2 t=
o get the actual value?=0A>=0A=0A=0AI am not sure that I understand you cor=
rectly but you can get the data=0Afrom node 2 via=0A=0Azone_page_state(NODE=
_DATA[2]->node_zones[ZONE_DMA], NR_FREE_PAGES);=0A=0Aor in __alloc_pages_no=
demask=0A=0Azone_page_state(preferred_zone, NR_FREE_PAGES);=0A

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
