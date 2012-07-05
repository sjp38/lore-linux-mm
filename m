Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 6885C6B0073
	for <linux-mm@kvack.org>; Thu,  5 Jul 2012 12:15:39 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so9414186ghr.14
        for <linux-mm@kvack.org>; Thu, 05 Jul 2012 09:15:38 -0700 (PDT)
Message-ID: <4FF5BD9D.9040101@gmail.com>
Date: Fri, 06 Jul 2012 00:15:25 +0800
From: Jiang Liu <liuj97@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 2/4] mm: make consistent use of PG_slab flag
References: <1341287837-7904-1-git-send-email-jiang.liu@huawei.com> <1341287837-7904-2-git-send-email-jiang.liu@huawei.com> <alpine.DEB.2.00.1207050945310.4984@router.home>
In-Reply-To: <alpine.DEB.2.00.1207050945310.4984@router.home>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Mel Gorman <mgorman@suse.de>, Yinghai Lu <yinghai@kernel.org>, Tony Luck <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Keping Chen <chenkeping@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 07/05/2012 10:47 PM, Christoph Lameter wrote:
> On Tue, 3 Jul 2012, Jiang Liu wrote:
> 
>> PG_slabobject:	mark whether a (compound) page hosts SLUB/SLOB objects.
> 
> Any subsystem may allocate a compound page to store metadata.
> 
> The compound pages used by SLOB and SLUB are not managed in any way but
> the calls to kfree and kmalloc are converted to calls to the page
> allocator. There is no "management" by the slab allocators for these
> cases and its inaccurate to say that these are SLUB/SLOB objects since the
> allocators never deal with these objects.
> 
Hi Chris,
	I think there's a little difference with SLUB and SLOB for compound page.
For SLOB, it relies on the page allocator to allocate compound page to fulfill
request bigger than one page. For SLUB, it relies on the page allocator if the
request is bigger than two pages. So SLUB may allocate a 2-pages compound page
to host SLUB managed objects.
	My proposal may be summarized as below:
	1) PG_slab flag marks a memory object is allocated from slab allocator.
	2) PG_slabobject marks a (compound) page hosts SLUB/SLOB managed objects.
	3) Only set PG_slab/PG_slabobject on the head page of compound pages.
	4) For SLAB, PG_slabobject is redundant and so not used.

	A summary of proposed usage of PG_slab(S) and PG_slabobject(O) with 
SLAB/SLUB/SLOB allocators as below:
pagesize	SLAB			SLUB			SLOB
1page		S			S,O			S,O
2page		S			S,O			S
>=4page		S			S			S

	Thanks!
	Gerry


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
