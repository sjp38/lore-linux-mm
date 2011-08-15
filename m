Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 334EC6B00EE
	for <linux-mm@kvack.org>; Mon, 15 Aug 2011 04:06:45 -0400 (EDT)
Received: by qyk27 with SMTP id 27so847558qyk.14
        for <linux-mm@kvack.org>; Mon, 15 Aug 2011 01:06:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1313384511.62052.YahooMailNeo@web162020.mail.bf1.yahoo.com>
References: <1313146843.1015.YahooMailNeo@web162014.mail.bf1.yahoo.com>
	<alpine.DEB.2.00.1108121053490.16906@router.home>
	<1313384511.62052.YahooMailNeo@web162020.mail.bf1.yahoo.com>
Date: Mon, 15 Aug 2011 16:06:40 +0800
Message-ID: <CAA_GA1ctXzhRgAzN5u=AFCL_5P+KORv8KM=AjDTedg0PwcEujw@mail.gmail.com>
Subject: Re: Tracking page allocation in Zone/Node
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pintu Agarwal <pintu_agarwal@yahoo.com>
Cc: Christoph Lameter <cl@linux.com>, "mgorman@suse.de" <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, Aug 15, 2011 at 1:01 PM, Pintu Agarwal <pintu_agarwal@yahoo.com> wr=
ote:
> Thanks Christoph for your reply :)
>
>> Weird system. One would expect it to only have NORMAL zones. Is this an
>> ARM system?
>
> Yes this is an ARM based system for linux mobile phone.
>
>> I am not sure that I understand you correctly but you can get the data f=
rom node 2 via
>> zone_page_state(NODE_DATA[2]->node_zones[ZONE_DMA], NR_FREE_PAGES);
>
> Yes, you got me right. I wanted to access Node 2 data from the preferred =
zone. This is helpful, thanks.
> But I want it to be dynamic. That is if Node 2 is over-loaded, then the a=
llocation happens from Node 1 or Node 0 as well.

In my opinion, current code will do this behavior.
If allocation from node 2 failed, it will try other nodes, so you
needn't to do it by yourself.

> Also it should work on normal desktop itself where there are DMA, Normal,=
 HighMem as well.
> How to make the above statement generic so that it should work in all sce=
narios?
>
>> or in __alloc_pages_nodemask
>> zone_page_state(preferred_zone, NR_FREE_PAGES);
>
> Yes, I tried exactly like this, but since I have only one zone (DMA), it =
always returns me the data from the first Node 0.
> This will only work, if I have 3 separate zones (DMA, Normal, HighMem)
>
> In "__alloc_pages_nodemask", before the actual allocation happens, how to=
 find out the allocation is going to happen from which zone and which Node.=
?
> (The _preferred_zone_ info is not enough, I need to know the Node number =
as well)
>
> Please help...
> I hope the question is clear know.
>
>
>
> Thanks,
> Pintu
>
>
> ----- Original Message -----
> From: Christoph Lameter <cl@linux.com>
> To: Pintu Agarwal <pintu_agarwal@yahoo.com>
> Cc: "mgorman@suse.de" <mgorman@suse.de>; "linux-mm@kvack.org" <linux-mm@k=
vack.org>
> Sent: Friday, 12 August 2011 9:38 PM
> Subject: Re: Tracking page allocation in Zone/Node
>
> On Fri, 12 Aug 2011, Pintu Agarwal wrote:
>
>> On my system I have only DMA zones with 3 nodes as follows:
>> Node 0, zone=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 DMA=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0 3=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 4=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 6=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0 4=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 5=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0 0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0 0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 0
>> Node 1, zone=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 DMA=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0 8=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 4=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 3=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0 8=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 7=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0 4=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 2=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0 0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 0
>> Node 2, zone=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 DMA=C2=A0=C2=A0=C2=A0=C2=A0 1=
0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 2=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 8=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0 3=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 2=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0 2=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 4=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0 1=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 2=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 2=C2=A0=
=C2=A0=C2=A0=C2=A0 28
>
> Weird system. One would expect it to only have NORMAL zones. Is this an
> ARM system?
>
>
>> In __alloc_pages_nodemask(...), just before "First Allocation Attempt" [=
that is before get_page_from_freelist(....)], I wanted to print=C2=A0all th=
e free pages from the "preferred_zone".
>> Using something like=C2=A0this :
>> totalfreepages =3D zone_page_state(zone, NR_FREE_PAGES);
>>
>> But in my case, there is only one zone (DMA) but 3 nodes.
>> Thus the above "zone_page_state" always returns totalfreepages only from=
 first Node 0.
>> But the allocation actually happening from Node 2.
>>
>> How can we point to the zone of Node 2 to get the actual value?
>>
>
>
> I am not sure that I understand you correctly but you can get the data
> from node 2 via
>
> zone_page_state(NODE_DATA[2]->node_zones[ZONE_DMA], NR_FREE_PAGES);
>
> or in __alloc_pages_nodemask
>
> zone_page_state(preferred_zone, NR_FREE_PAGES);
>
>

--=20
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
