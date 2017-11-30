Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 65C706B0038
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 03:23:19 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id h18so4452627pfi.2
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 00:23:19 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o4si2634035pgf.8.2017.11.30.00.23.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 30 Nov 2017 00:23:18 -0800 (PST)
Date: Thu, 30 Nov 2017 09:23:14 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mmap.2: document new MAP_FIXED_SAFE flag
Message-ID: <20171130082314.6b4cubakdhwtis7y@dhcp22.suse.cz>
References: <20171129144219.22867-1-mhocko@kernel.org>
 <20171129144524.23518-1-mhocko@kernel.org>
 <593899ff-08ad-6c3f-d69d-346f6bc5d1f6@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <593899ff-08ad-6c3f-d69d-346f6bc5d1f6@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Khalid Aziz <khalid.aziz@oracle.com>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org, Florian Weimer <fweimer@redhat.com>

On Wed 29-11-17 19:16:39, John Hubbard wrote:
[...]
> Hi Michal,
> 
> I've taken the liberty of mostly rewriting this part, in order to more closely 
> match the existing paragraphs; to fix minor typos; and to attempt to slightly
> clarify the paragraph.
> 
> +.BR MAP_FIXED_SAFE " (since Linux 4.16)"
> +Similar to MAP_FIXED with respect to the
> +.I
> +addr
> +enforcement, but different in that MAP_FIXED_SAFE never clobbers a pre-existing
> +mapped range. If the requested range would collide with an existing
> +mapping, then this call fails with
> +.B EEXIST.
> +This flag can therefore be used as a way to atomically (with respect to other
> +threads) attempt to map an address range: one thread will succeed; all others
> +will report failure. Please note that older kernels which do not recognize this
> +flag will typically (upon detecting a collision with a pre-existing mapping)
> +fall back a "non-MAP_FIXED" type of behavior: they will return an address that
> +is different than the requested one. Therefore, backward-compatible software
> +should check the returned address against the requested address.
> +.TP

I have taken yours. Thanks a lot!

> (I'm ignoring the naming, because there is another thread about that,
> so please just the above as "MAP_FIXED_whatever-is-chosen".)
> 
> > @@ -449,6 +461,12 @@ is not a valid file descriptor (and
> >  .B MAP_ANONYMOUS
> >  was not set).
> >  .TP
> > +.B EEXIST
> > +range covered by
> > +.IR addr , 
> 
> nit: trailing space on the above line.

fixed

> > +.IR length
> > +is clashing with an existing mapping.
> > +.TP
> >  .B EINVAL
> >  We don't like
> >  .IR addr ,
> > 
> 
> One other thing: reading through mmap.2, I now want to add this as well:
> 
> diff --git a/man2/mmap.2 b/man2/mmap.2
> index 622a7000d..780cad6d9 100644
> --- a/man2/mmap.2
> +++ b/man2/mmap.2
> @@ -222,20 +222,25 @@ part of the existing mapping(s) will be discarded.
>  If the specified address cannot be used,
>  .BR mmap ()
>  will fail.
> -Because requiring a fixed address for a mapping is less portable,
> -the use of this option is discouraged.
> +Software that aspires to be as portable as possible should use this option with
> +care, keeping in mind that different kernels and C libraries may set up quite
> +different mapping ranges.
> 
> 
> ...because that advice is just wrong (it presumes that "less portable" ==
> "must be discouraged").
> 
> Should I send out a separate patch for that, or is it better to glom it together 
> with this one?

yes please
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
