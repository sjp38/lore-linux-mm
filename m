Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 55A796B026F
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 10:24:53 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id o18-v6so895504qko.21
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 07:24:53 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id i3-v6si1031537qvg.215.2018.07.17.07.24.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jul 2018 07:24:52 -0700 (PDT)
Date: Tue, 17 Jul 2018 22:24:43 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: [PATCH] mm/page_alloc: Deprecate kernelcore=nn and movable_core=
Message-ID: <20180717142443.GG1724@MiWiFi-R3L-srv>
References: <20180717131837.18411-1-bhe@redhat.com>
 <20180717133109.GI7193@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180717133109.GI7193@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, corbet@lwn.net, linux-doc@vger.kernel.org

Hi Michal,

On 07/17/18 at 03:31pm, Michal Hocko wrote:
> On Tue 17-07-18 21:18:37, Baoquan He wrote:
> > We can still use 'kernelcore=mirror' or 'movable_node' for the usage
> > of hotplug and movable zone. If somebody shows up with a valid usecase
> > we can reconsider.
> 
> Well this doesn't really explain why to deprecate this functionality.
> It is a rather ugly hack that has been originally introduced for large
> order allocations. But we do have compaction these days. Even though the
> compaction cannot solve all the fragmentation issues the zone movable is
> not a great answer as it introduces other issues (basically highmem kind
> of issues we used to have on 32b systems).
> The current code doesn't work with KASLR and the code is too subtle to
> work properly in other cases as well. E.g. movablecore range might cover
> already used memory (e.g. bootmem allocations) and therefore it doesn't
> comply with the basic assumption that the memory is movable and that
> confuses memory hotplug (e.g. 15c30bc09085 ("mm, memory_hotplug: make
> has_unmovable_pages more robust").
> 
> There are probably other issues I am not aware of but primarily the code
> adds a maintenance burden which would be better to get rid of.
> 
> I would also go further and remove all the code the feature is using at
> one go. If somebody really needs this functionality we would need to
> revert the whole thing anyway.

Thanks for these details. I can arrange your above saying and rewrite
patch log. Are you suggesting removing the code "kernelcore=nn" and
"movablecore=" are using? If yes, I can repost with these changes.

Just saw some deprecated codes are still there for future cleaning up.
So posted this v1 patch.

Thanks
Baoquan

> > ---
> >  Documentation/admin-guide/kernel-parameters.txt | 2 ++
> >  mm/page_alloc.c                                 | 3 +++
> >  2 files changed, 5 insertions(+)
> > 
> > diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
> > index efc7aa7a0670..1e22c49866a2 100644
> > --- a/Documentation/admin-guide/kernel-parameters.txt
> > +++ b/Documentation/admin-guide/kernel-parameters.txt
> > @@ -1855,6 +1855,7 @@
> >  	keepinitrd	[HW,ARM]
> >  
> >  	kernelcore=	[KNL,X86,IA-64,PPC]
> > +			[Usage of kernelcore=nn[KMGTPE] | nn% is deprecated]
> >  			Format: nn[KMGTPE] | nn% | "mirror"
> >  			This parameter specifies the amount of memory usable by
> >  			the kernel for non-movable allocations.  The requested
> > @@ -2395,6 +2396,7 @@
> >  			reporting absolute coordinates, such as tablets
> >  
> >  	movablecore=	[KNL,X86,IA-64,PPC]
> > +			[Deprecated]
> >  			Format: nn[KMGTPE] | nn%
> >  			This parameter is the complement to kernelcore=, it
> >  			specifies the amount of memory used for migratable
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 1521100f1e63..86cf05f48b5f 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -6899,6 +6899,8 @@ static int __init cmdline_parse_kernelcore(char *p)
> >  		return 0;
> >  	}
> >  
> > +	pr_warn("Only kernelcore=mirror supported, "
> > +		"usage of kernelcore=nn[KMGTPE]|nn%% is deprecated.\n");
> >  	return cmdline_parse_core(p, &required_kernelcore,
> >  				  &required_kernelcore_percent);
> >  }
> > @@ -6909,6 +6911,7 @@ static int __init cmdline_parse_kernelcore(char *p)
> >   */
> >  static int __init cmdline_parse_movablecore(char *p)
> >  {
> > +	pr_warn("Option movablecore= is deprecated.\n");
> >  	return cmdline_parse_core(p, &required_movablecore,
> >  				  &required_movablecore_percent);
> >  }
> > -- 
> > 2.13.6
> 
> -- 
> Michal Hocko
> SUSE Labs
