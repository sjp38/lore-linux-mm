Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4B1678E0001
	for <linux-mm@kvack.org>; Fri, 21 Dec 2018 01:18:08 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id e12so4910086edd.16
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 22:18:08 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p50sor10173595eda.9.2018.12.20.22.18.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 20 Dec 2018 22:18:06 -0800 (PST)
MIME-Version: 1.0
References: <1545299439-31370-1-git-send-email-kernelfans@gmail.com>
 <1545299439-31370-3-git-send-email-kernelfans@gmail.com> <20181220113547.GC9104@dhcp22.suse.cz>
 <CAFgQCTvxNGTKD+DP_LxF86WoVnCHnPkWoSqdGeXQxXNVYD_orw@mail.gmail.com> <20181220124419.GD9104@dhcp22.suse.cz>
In-Reply-To: <20181220124419.GD9104@dhcp22.suse.cz>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Fri, 21 Dec 2018 14:17:54 +0800
Message-ID: <CAFgQCTsTTQLyEr6NG4QvpYuuovathge6t+1ej_1edkGCai-jXw@mail.gmail.com>
Subject: Re: [PATCHv2 2/3] mm/numa: build zonelist when alloc for device on
 offline node
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Bjorn Helgaas <bhelgaas@google.com>, Jonathan Cameron <Jonathan.Cameron@huawei.com>, David Rientjes <rientjes@google.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>

On Thu, Dec 20, 2018 at 8:44 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Thu 20-12-18 20:26:28, Pingfan Liu wrote:
> > On Thu, Dec 20, 2018 at 7:35 PM Michal Hocko <mhocko@kernel.org> wrote:
> > >
> > > On Thu 20-12-18 17:50:38, Pingfan Liu wrote:
> > > [...]
> > > > @@ -453,7 +456,12 @@ static inline int gfp_zonelist(gfp_t flags)
> > > >   */
> > > >  static inline struct zonelist *node_zonelist(int nid, gfp_t flags)
> > > >  {
> > > > -     return NODE_DATA(nid)->node_zonelists + gfp_zonelist(flags);
> > > > +     if (unlikely(!possible_zonelists[nid])) {
> > > > +             WARN_ONCE(1, "alloc from offline node: %d\n", nid);
> > > > +             if (unlikely(build_fallback_zonelists(nid)))
> > > > +                     nid = first_online_node;
> > > > +     }
> > > > +     return possible_zonelists[nid] + gfp_zonelist(flags);
> > > >  }
> > >
> > > No, please don't do this. We do not want to make things work magically
> >
> > For magically, if you mean directly replies on zonelist instead of on
> > pgdat struct, then it is easy to change
>
> No, I mean that we _know_ which nodes are possible. Platform is supposed
> to tell us. We should just do the intialization properly. What we do now
> instead is a pile of hacks that fit magically together. And that should
> be changed.
>
Not agree. Here is the typical lazy to do, and at this point there is
also possible node info for us to check and build pgdat instance.

> > > and we definitely do not want to put something like that into the hot
> >
> > But  the cose of "unlikely" can be ignored, why can it not be placed
> > in the path?
>
> unlikely will simply put the code outside of the hot path. The condition
> is still there. There are people desperately fighting to get every
> single cycle out of the page allocator. Now you want them to pay a
> branch which is relevant only for few obscure HW setups.
>
Data is more convincing.
I test with the following program  built with -O2 on x86. No
observable performance difference between adding an extra unlikely
condition. And it is apparent that the frequency of checking on
unlikely is much higher than my patch.
#include <stdio.h>
#define unlikely_notrace(x)     __builtin_expect(!!(x), 0)
#define unlikely(x) unlikely_notrace(x)
#define TEST_UNLIKELY 1
int main(int argc, char *argv[])
{
        unsigned long i,j;
        unsigned long end = (unsigned long)1 << 36;
        unsigned long x = 9;
        for (i = 1; i < end; i++) {
#ifdef TEST_UNLIKELY
                if (unlikely(i == end - 1))
                        x *= 8;
#endif
                x *= i;
                x = x%100000 + 1;
        }
        return 0;
}

> > > path. We definitely need zonelists to be build transparently for all
> > > possible nodes during the init time.
> >
> > That is the point, whether the all nodes should be instanced at boot
> > time, or not be instanced until there is requirement.
>
> And that should be done at init time. We have all the information
> necessary at that time.
> --

Will see other guys' comment.

Thanks and regards,
Pingfan
