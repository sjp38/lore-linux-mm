Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id C85A46B0169
	for <linux-mm@kvack.org>; Thu,  4 Aug 2011 03:22:31 -0400 (EDT)
Date: Thu, 4 Aug 2011 09:22:00 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 3/4] sparse: using kzalloc to clean up code
Message-ID: <20110804072200.GA21516@cmpxchg.org>
References: <1312427390-20005-1-git-send-email-lliubbo@gmail.com>
 <1312427390-20005-2-git-send-email-lliubbo@gmail.com>
 <1312427390-20005-3-git-send-email-lliubbo@gmail.com>
 <CAOJsxLGRmR1RNEOrTjtU_y+6mPF0S+Lh5uZyyoKGZ1w0DLEYqQ@mail.gmail.com>
 <CAA_GA1cLg6jwidoYKmxd9rTO8H2WYPzeKjVx6X5brpRizPU80Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAA_GA1cLg6jwidoYKmxd9rTO8H2WYPzeKjVx6X5brpRizPU80Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, cesarb@cesarb.net, emunson@mgebm.net, namhyung@gmail.com, mhocko@suse.cz, lucas.demarchi@profusion.mobi, aarcange@redhat.com, tj@kernel.org, vapier@gentoo.org, jkosina@suse.cz, rientjes@google.com, dan.magenheimer@oracle.com, yinghai@kernel.org, hpa@zytor.com

On Thu, Aug 04, 2011 at 02:55:17PM +0800, Bob Liu wrote:
> On Thu, Aug 4, 2011 at 2:10 PM, Pekka Enberg <penberg@kernel.org> wrote:
> > On Thu, Aug 4, 2011 at 6:09 AM, Bob Liu <lliubbo@gmail.com> wrote:
> >> This patch using kzalloc to clean up sparse_index_alloc() and
> >> __GFP_ZERO to clean up __kmalloc_section_memmap().
> >>
> >> Signed-off-by: Bob Liu <lliubbo@gmail.com>
> >> ---
> >>  mm/sparse.c |   24 +++++++-----------------
> >>  1 files changed, 7 insertions(+), 17 deletions(-)
> >>
> >> diff --git a/mm/sparse.c b/mm/sparse.c
> >> index 858e1df..9596635 100644
> >> --- a/mm/sparse.c
> >> +++ b/mm/sparse.c
> >> @@ -65,15 +65,12 @@ static struct mem_section noinline __init_refok *sparse_index_alloc(int nid)
> >>
> >>        if (slab_is_available()) {
> >>                if (node_state(nid, N_HIGH_MEMORY))
> >> -                       section = kmalloc_node(array_size, GFP_KERNEL, nid);
> >> +                       section = kzalloc_node(array_size, GFP_KERNEL, nid);
> >>                else
> >> -                       section = kmalloc(array_size, GFP_KERNEL);
> >> +                       section = kzalloc(array_size, GFP_KERNEL);
> >>        } else
> >>                section = alloc_bootmem_node(NODE_DATA(nid), array_size);
> >>
> >> -       if (section)
> >> -               memset(section, 0, array_size);
> >> -
> >
> > You now broke the alloc_bootmem_node() path.
> >
> 
> Yes.
> But In my opinion, the alloc_bootmem_node() will also return zeroed memory.
> I saw it has used kzalloc or memset() but i'm not pretty sure.
> CC'd yinghai@kernel.org,hpa@zytor.com

You are right, bootmem always returns zeroed memory.  But it deserves
mentioning in the changelog.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
