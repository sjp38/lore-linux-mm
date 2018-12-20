Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id BD6B38E0002
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 07:26:42 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id c3so2228182eda.3
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 04:26:42 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id ci2-v6sor4104191ejb.26.2018.12.20.04.26.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 20 Dec 2018 04:26:40 -0800 (PST)
MIME-Version: 1.0
References: <1545299439-31370-1-git-send-email-kernelfans@gmail.com>
 <1545299439-31370-3-git-send-email-kernelfans@gmail.com> <20181220113547.GC9104@dhcp22.suse.cz>
In-Reply-To: <20181220113547.GC9104@dhcp22.suse.cz>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Thu, 20 Dec 2018 20:26:28 +0800
Message-ID: <CAFgQCTvxNGTKD+DP_LxF86WoVnCHnPkWoSqdGeXQxXNVYD_orw@mail.gmail.com>
Subject: Re: [PATCHv2 2/3] mm/numa: build zonelist when alloc for device on
 offline node
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Bjorn Helgaas <bhelgaas@google.com>, Jonathan Cameron <Jonathan.Cameron@huawei.com>, David Rientjes <rientjes@google.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>

On Thu, Dec 20, 2018 at 7:35 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Thu 20-12-18 17:50:38, Pingfan Liu wrote:
> [...]
> > @@ -453,7 +456,12 @@ static inline int gfp_zonelist(gfp_t flags)
> >   */
> >  static inline struct zonelist *node_zonelist(int nid, gfp_t flags)
> >  {
> > -     return NODE_DATA(nid)->node_zonelists + gfp_zonelist(flags);
> > +     if (unlikely(!possible_zonelists[nid])) {
> > +             WARN_ONCE(1, "alloc from offline node: %d\n", nid);
> > +             if (unlikely(build_fallback_zonelists(nid)))
> > +                     nid = first_online_node;
> > +     }
> > +     return possible_zonelists[nid] + gfp_zonelist(flags);
> >  }
>
> No, please don't do this. We do not want to make things work magically

For magically, if you mean directly replies on zonelist instead of on
pgdat struct, then it is easy to change
> and we definitely do not want to put something like that into the hot

But  the cose of "unlikely" can be ignored, why can it not be placed
in the path?
> path. We definitely need zonelists to be build transparently for all
> possible nodes during the init time.

That is the point, whether the all nodes should be instanced at boot
time, or not be instanced until there is requirement.

To replace the possible_zonelists, I bring out the following draft
(locking issue is not considered)
diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 0705164..24e8ae6 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -453,6 +453,11 @@ static inline int gfp_zonelist(gfp_t flags)
  */
 static inline struct zonelist *node_zonelist(int nid, gfp_t flags)
 {
+       if (unlikely(!node_data[nid])) {
+               WARN_ONCE(1, "alloc from offline node: %d\n", nid);
+               if (unlikely(build_offline_node(nid)))
+                       nid = first_online_node;
+       }
        return NODE_DATA(nid)->node_zonelists + gfp_zonelist(flags);
 }

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2ec9cc4..4ef15fc 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5261,6 +5261,21 @@ static void build_zonelists(pg_data_t *pgdat)
        build_thisnode_zonelists(pgdat);
 }

+int build_offline_node(int nid)
+{
+       unsigned long zones_size[MAX_NR_ZONES] = {0};
+       unsigned long zholes_size[MAX_NR_ZONES] = {0};
+       pg_data_t *pgdat;
+
+       pgdat = kzalloc(sizeof(pg_data_t), GFP_ATOMIC);
+       if (!pgdat)
+               return -ENOMEM
+       node_data[nid] = pgdat;
+       free_area_init_node(nid, zones_size, 0, zholes_size);
+       build_zonelists(pgdat);
+       return 0;
+}
+

Thanks and regards,
Pingfan
