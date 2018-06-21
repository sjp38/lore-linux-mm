Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id CF3916B0007
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 03:33:37 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id k18-v6so1629782wrn.8
        for <linux-mm@kvack.org>; Thu, 21 Jun 2018 00:33:37 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q5-v6sor2261537wrp.81.2018.06.21.00.33.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 21 Jun 2018 00:33:36 -0700 (PDT)
Date: Thu, 21 Jun 2018 09:33:34 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH 1/4] mm/memory_hotplug: Make add_memory_resource use
 __try_online_node
Message-ID: <20180621073334.GA11407@techadventures.net>
References: <20180601125321.30652-1-osalvador@techadventures.net>
 <20180601125321.30652-2-osalvador@techadventures.net>
 <20180620151819.3f39226998bd80f7161fcea5@linux-foundation.org>
 <CAGM2reYgrpBrfhcw0O7K+sMU-qE-U_+2MzJWsG=7gSbU8n-=kA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGM2reYgrpBrfhcw0O7K+sMU-qE-U_+2MzJWsG=7gSbU8n-=kA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, osalvador@suse.de

On Wed, Jun 20, 2018 at 09:41:35PM -0400, Pavel Tatashin wrote:
> > I don't think __try_online_node() will ever return a value greater than
> > zero.  I assume what was meant was
> 
> Hi Andrew and Oscar,
> 
> Actually, the new __try_online_node()  returns:
> 1 -> a new node was allocated
> 0 -> node is already online
> -error -> an error encountered.
> 
> The function simply missing the return comment at the beginning.
> 
> Oscar, please check it via ./scripts/checkpatch.pl
> 
> Add comment explaining the return values.
> 
> And change:
>         ret = __try_online_node (nid, start, false);
>         new_node = !!(ret > 0);
>         if (ret < 0)
>                 goto error;
> To:
>         ret = __try_online_node (nid, start, false);
>         if (ret < 0)
>                 goto error;
>         new_node = ret;
> 
> Other than that the patch looks good to me, it simplifies the code.
> So, if the above is addressed:
> 
> Reviewed-by: Pavel Tatashin <pasha.tatashin@oracle.com>

Hi Pavel,

I'll do so, thanks!

> 
> Thank you,
> Pavel
> 
> >
> >         new_node = !!(ret >= 0);
> >
> > which may as well be
> >
> >         new_node = (ret >= 0);
> >
> > since both sides have bool type.
> >
> > The fact that testing didn't detect this is worrisome....
> >
> > > +     if (ret < 0)
> > > +             goto error;
> > > +
> > >
> > >       /* call arch's memory hotadd */
> > >       ret = arch_add_memory(nid, start, size, NULL, true);
> > > -
> > >       if (ret < 0)
> > >               goto error;
> > >
> > >
> > > ...
> > >
> >
> 

-- 
Oscar Salvador
SUSE L3
