Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id A01956B0082
	for <linux-mm@kvack.org>; Wed, 20 Jul 2011 10:47:51 -0400 (EDT)
Message-ID: <4E26EA93.5020302@parallels.com>
Date: Wed, 20 Jul 2011 18:47:47 +0400
From: Konstantin Khlebnikov <khlebnikov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm-slab: allocate kmem_cache with __GFP_REPEAT
References: <20110720121612.28888.38970.stgit@localhost6>	 <alpine.DEB.2.00.1107201611010.3528@tiger> <4E26D7EA.3000902@parallels.com>	 <alpine.DEB.2.00.1107201638520.4921@tiger>	 <alpine.DEB.2.00.1107200852590.32737@router.home>	 <20110720142018.GL5349@suse.de>  <4E26E705.8050704@parallels.com> <1311172859.2338.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
In-Reply-To: <1311172859.2338.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Matt Mackall <mpm@selenic.com>

Eric Dumazet wrote:
> Le mercredi 20 juillet 2011 =C3=A0 18:32 +0400, Konstantin Khlebnikov a
> =C3=A9crit :
>
>> I catch this on our rhel6-openvz kernel, and yes it very patchy,
>> but I don't see any reasons why this cannot be reproduced on mainline ke=
rnel.
>>
>> there was abount ten containers with random stuff, node already do inten=
sive swapout but still alive,
>> in this situation starting new containers sometimes (1 per 1000) fails d=
ue to kmem_cache_create failures in nf_conntrack,
>> there no other messages except:
>> Unable to create nf_conn slab cache
>> and some
>> nf_conntrack: falling back to vmalloc.
>> (it try allocates huge hash table and do it via vmalloc if kmalloc fails=
)
>
>
> Does this kernel contain commit 6d4831c2 ?
> (vfs: avoid large kmalloc()s for the fdtable)
>

yes, but not exactly, in our kerner it looks like:

static inline void * alloc_fdmem(unsigned int size)
{
	if (size <=3D PAGE_SIZE)
		return kmalloc(size, GFP_KERNEL);
	else
		return vmalloc(size);
}

and looks like this change is came from ancient times =3D)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
