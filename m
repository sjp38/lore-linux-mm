Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A589B6B0208
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 04:00:17 -0400 (EDT)
Received: by gwb15 with SMTP id 15so597996gwb.14
        for <linux-mm@kvack.org>; Thu, 15 Apr 2010 01:00:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4BC6BE78.1030503@kernel.org>
References: <9918f566ab0259356cded31fd1dd80da6cae0c2b.1271171877.git.minchan.kim@gmail.com>
	 <d5d70d4b57376bc89f178834cf0e424eaa681ab4.1271171877.git.minchan.kim@gmail.com>
	 <20100413154820.GC25756@csn.ul.ie> <4BC65237.5080408@kernel.org>
	 <v2j28c262361004141831h8f2110d5pa7a1e3063438cbf8@mail.gmail.com>
	 <4BC6BE78.1030503@kernel.org>
Date: Thu, 15 Apr 2010 17:00:15 +0900
Message-ID: <h2w28c262361004150100ne936d943u28f76c0f171d3db8@mail.gmail.com>
Subject: Re: [PATCH 2/6] change alloc function in pcpu_alloc_pages
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Tejun Heo <tj@kernel.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Bob Liu <lliubbo@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Apr 15, 2010 at 4:21 PM, Tejun Heo <tj@kernel.org> wrote:
> Hello,
>
> On 04/15/2010 10:31 AM, Minchan Kim wrote:
>> Hi, Tejun.
>>> This being a pretty cold path, I don't really see much benefit in
>>> converting it to alloc_pages_node_exact(). =C2=A0It ain't gonna make an=
y
>>> difference. =C2=A0I'd rather stay with the safer / boring one unless
>>> there's a pressing reason to convert.
>>
>> Actually, It's to weed out not-good API usage as well as some
>> performance gain. =C2=A0But I don't think to need it strongly.
>> Okay. Please keep in mind about this and correct it if you confirms
>> it in future. :)
>
> Hmm... if most users are converting over to alloc_pages_node_exact(),
> I think it would be better to convert percpu too. =C2=A0I thought it was =
a
> performance optimization (of rather silly kind too). =C2=A0So, this is to
> weed out -1 node id usage? =C2=A0Wouldn't it be better to update
> alloc_pages_node() such that it whines once per each caller if it's
> called with -1 node id and after updating most users convert the
> warning into WARN_ON_ONCE()? =C2=A0Having two variants for this seems
> rather extreme to me.

Yes. I don't like it.
With it, someone who does care about API usage uses alloc_pages_exact_node =
but
someone who don't have a time or careless uses alloc_pages_node.
It would make API fragmentation and not good.
Maybe we can weed out -1 and make new API which is more clear.

* struct page *alloc_pages_any_node(gfp_t gfp_mask, unsigned int order);
* struct page *alloc_pages_exact_node(int nid, gfp_mask, unsigned int order=
);

So firstly we have to make sure users who use alloc_pages_node can
change alloc_pages_node with alloc_pages_exact_node.

After all of it was weed out, I will change alloc_pages_node with
alloc_pages_any_node.


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
