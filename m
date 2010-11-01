Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 4C0798D0001
	for <linux-mm@kvack.org>; Mon,  1 Nov 2010 19:21:45 -0400 (EDT)
Received: by iwn38 with SMTP id 38so6908339iwn.14
        for <linux-mm@kvack.org>; Mon, 01 Nov 2010 16:21:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LNX.2.00.1011012056250.12889@swampdragon.chaosbits.net>
References: <alpine.LNX.2.00.1011012038490.12889@swampdragon.chaosbits.net>
	<20101101200122.GH840@cmpxchg.org>
	<alpine.LNX.2.00.1011012056250.12889@swampdragon.chaosbits.net>
Date: Tue, 2 Nov 2010 08:21:43 +0900
Message-ID: <AANLkTinAHXcG+ar2Wd9QjT58OOory_g87Tv4LnN53L-6@mail.gmail.com>
Subject: Re: [PATCH] cgroup: prefer [kv]zalloc over [kv]malloc+memset in
 memory controller code.
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Jesper Juhl <jj@chaosbits.net>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelianov <xemul@openvz.org>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, containers@lists.linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Tue, Nov 2, 2010 at 4:59 AM, Jesper Juhl <jj@chaosbits.net> wrote:
> On Mon, 1 Nov 2010, Johannes Weiner wrote:
>
>> On Mon, Nov 01, 2010 at 08:40:56PM +0100, Jesper Juhl wrote:
>> > Hi (please CC me on replies),
>> >
>> >
>> > Apologies to those who receive this multiple times. I screwed up the T=
o:
>> > field in my original mail :-(
>> >
>> >
>> > In mem_cgroup_alloc() we currently do either kmalloc() or vmalloc() th=
en
>> > followed by memset() to zero the memory. This can be more efficiently
>> > achieved by using kzalloc() and vzalloc().
>> >
>> >
>> > Signed-off-by: Jesper Juhl <jj@chaosbits.net>
>>
>> Looks good to me, but there is also the memset after kmalloc in
>> alloc_mem_cgroup_per_zone_info().
>
> Dang, I missed that one. Thanks for pointing it out.
>
> Hmm, I'm wondering if we should perhaps add kzalloc_node()/vzalloc_node()
> just like kzalloc() and vzalloc()..

I am not against that.
As looking code, there are many places to use kzalloc_node but few vzalloc_=
node.
Although it is, Only adding kzalloc_node would make code rather ugly like t=
his.

if (some size > limit)
  ptr =3D  kzalloc_node(...);
else  {
  prt =3D vmalloc_node(...)
  vmalloced =3D 1;
}

if (ptr && vmalloced)
   memset(prt, xxxx);

So if we will add kzalloc_node, we have to add vzalloc_node, too.

>
>> Can you switch that over as well in
>> this patch? =A0You can pass __GFP_ZERO to kmalloc_node() for zeroing.
>>
>
> Sure thing.
>
>
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
