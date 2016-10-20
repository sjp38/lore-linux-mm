Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id A076A6B025E
	for <linux-mm@kvack.org>; Thu, 20 Oct 2016 19:10:40 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id f129so137441273itc.7
        for <linux-mm@kvack.org>; Thu, 20 Oct 2016 16:10:40 -0700 (PDT)
Received: from mail-it0-x242.google.com (mail-it0-x242.google.com. [2607:f8b0:4001:c0b::242])
        by mx.google.com with ESMTPS id a7si1522391ioe.155.2016.10.20.16.10.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Oct 2016 16:10:40 -0700 (PDT)
Received: by mail-it0-x242.google.com with SMTP id k64so8496367itb.0
        for <linux-mm@kvack.org>; Thu, 20 Oct 2016 16:10:40 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Subject: Re: [RFC] scripts: Include postprocessing script for memory allocation tracing
From: Janani Ravichandran <janani.rvchndrn@gmail.com>
In-Reply-To: <20161018131343.GJ12092@dhcp22.suse.cz>
Date: Thu, 20 Oct 2016 18:10:37 -0500
Content-Transfer-Encoding: quoted-printable
Message-Id: <4F0F918D-B98A-48EC-82ED-EE7D32F222EA@gmail.com>
References: <20160912121635.GL14524@dhcp22.suse.cz> <0ACE5927-A6E5-4B49-891D-F990527A9F50@gmail.com> <20160919094224.GH10785@dhcp22.suse.cz> <BFAF8DCA-F4A6-41C6-9AA0-C694D33035A3@gmail.com> <20160923080709.GB4478@dhcp22.suse.cz> <E8FAA4EF-DAA1-4E18-B48F-6677E6AFE76E@gmail.com> <2D27EF16-B63B-4516-A156-5E2FB675A1BB@gmail.com> <20161016073340.GA15839@dhcp22.suse.cz> <CANnt6X=RpSnuxGXZfF6Qa5mJpzC8gL3wkKJi3tQMZJBZJVWF3w@mail.gmail.com> <A6E7231A-54FF-4D5C-90F5-0A8C4126CFEA@gmail.com> <20161018131343.GJ12092@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Janani Ravichandran <janani.rvchndrn@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal,

> On Oct 18, 2016, at 8:13 AM, Michal Hocko <mhocko@kernel.org> wrote:
>=20
>>=20
>=20
> yes, function_graph tracer will give you _some_ information but it =
will
> not have the context you are looking for, right? See the following
> example
>=20
> ------------------------------------------
> 0) x-www-b-22756  =3D>  x-termi-4083=20
> ------------------------------------------
>=20
> 0)               |  __alloc_pages_nodemask() {
> 0)               |  /* mm_page_alloc: page=3Dffffea000411b380 =
pfn=3D1066702 order=3D0 migratetype=3D0 gfp_flags=3DGFP_KERNEL */
> 0)   3.328 us    |  }
> 3)               |  __alloc_pages_nodemask() {
> 3)               |  /* mm_page_alloc: page=3Dffffea0008f1f6c0 =
pfn=3D2344923 order=3D0 migratetype=3D0 gfp_flags=3DGFP_KERNEL */
> 3)   1.011 us    |  }
> 0)               |  __alloc_pages_nodemask() {
> 0)               |  /* mm_page_alloc: page=3Dffffea000411b380 =
pfn=3D1066702 order=3D0 migratetype=3D0 gfp_flags=3DGFP_KERNEL */
> 0)   0.587 us    |  }
> 3)               |  __alloc_pages_nodemask() {
> 3)               |  /* mm_page_alloc: page=3Dffffea0008f1f6c0 =
pfn=3D2344923 order=3D0 migratetype=3D0 gfp_flags=3DGFP_KERNEL */
> 3)   1.125 us    |  }
>=20
> How do I know which process has performed those allocations? I know =
that
> CPU0 should be running x-termi-4083 but what is running on other CPUs?
>=20
> Let me explain my usecase I am very interested in. Say I that a =
usespace
> application is not performing well. I would like to see some =
statistics
> about memory allocations performed for that app - are there few =
outliers
> or the allocation stalls increase gradually? Where do we spend time =
during
> that allocation? Reclaim LRU pages? Compaction or the slab shrinkers?
>=20
> To answer those questions I need to track particular events =
(alocation,
> reclaim, compaction) to the process and know how long each step
> took. Maybe we can reconstruct something from the above output but it =
is
> a major PITA.  If we either hard start/stop pairs for each step (which
> we already do have for reclaim, compaction AFAIR) then this is an easy
> scripting. Another option would be to have only a single tracepoint =
for
> each step with a timing information.
>=20
> See my point?

Yes, if we want to know what processes are running on what CPUs,
echo funcgraph-proc > trace_options in the tracing directory should give =
us
what we want.

The bash script which is part of this patch does this kind of setup for =
you.
As a result, the output you get is something like what you see here:

=
https://github.com/Jananiravichandran/Analyzing-tracepoints/blob/master/no=
_tp_no_threshold.txt

Does this answer your question? Let me know if otherwise.

Janani.

> --=20
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
