Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id 15C6A6B0275
	for <linux-mm@kvack.org>; Thu, 27 Oct 2016 11:42:40 -0400 (EDT)
Received: by mail-yb0-f198.google.com with SMTP id g68so53086596ybi.1
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 08:42:40 -0700 (PDT)
Received: from mail-qk0-x243.google.com (mail-qk0-x243.google.com. [2607:f8b0:400d:c09::243])
        by mx.google.com with ESMTPS id x84si2927690ywd.331.2016.10.27.08.42.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Oct 2016 08:42:39 -0700 (PDT)
Received: by mail-qk0-x243.google.com with SMTP id x11so2794401qka.0
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 08:42:39 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Subject: Re: [RFC] scripts: Include postprocessing script for memory allocation tracing
From: Janani Ravichandran <janani.rvchndrn@gmail.com>
In-Reply-To: <20161021070832.GE6045@dhcp22.suse.cz>
Date: Thu, 27 Oct 2016 11:42:35 -0400
Content-Transfer-Encoding: quoted-printable
Message-Id: <49064D60-DE83-4545-960E-5FB5897441C5@gmail.com>
References: <20160919094224.GH10785@dhcp22.suse.cz> <BFAF8DCA-F4A6-41C6-9AA0-C694D33035A3@gmail.com> <20160923080709.GB4478@dhcp22.suse.cz> <E8FAA4EF-DAA1-4E18-B48F-6677E6AFE76E@gmail.com> <2D27EF16-B63B-4516-A156-5E2FB675A1BB@gmail.com> <20161016073340.GA15839@dhcp22.suse.cz> <CANnt6X=RpSnuxGXZfF6Qa5mJpzC8gL3wkKJi3tQMZJBZJVWF3w@mail.gmail.com> <A6E7231A-54FF-4D5C-90F5-0A8C4126CFEA@gmail.com> <20161018131343.GJ12092@dhcp22.suse.cz> <4F0F918D-B98A-48EC-82ED-EE7D32F222EA@gmail.com> <20161021070832.GE6045@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Janani Ravichandran <janani.rvchndrn@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


> On Oct 21, 2016, at 3:08 AM, Michal Hocko <mhocko@kernel.org> wrote:
>=20
> Interesting.
> $ cat /debug/tracing/available_tracers=20
> function_graph preemptirqsoff preemptoff irqsoff function nop
>=20
> Do I have to configure anything specially? And if I do why isn't it =
any
> better to simply add a start tracepoint and make this available also =
to
> older kernels?

Well, you just need to enable the function_graph tracer in the tracing =
directory:
echo function_graph > current_tracer,

set funcgraph-proc in trace_options to get process information:
echo funcgraph-proc > trace_options,

set funcgraph-abstime in trace_options to get timestamp,
echo funcgraph-abstime > trace_options

set all the functions we=E2=80=99d like to observe as filters. For e.g.
echo __alloc_pages_nodemask > set_ftrace_filter

and enable the tracepoints we would like to get information from.

I didn=E2=80=99t add a begin tracepoint for this as Steven Rostedt had =
suggested
using function graph instead of begin/end tracepoints (we already have
a tracepoint in __alloc_pages_nodemask - trace_mm_page_alloc to get=20
some information about the allocation and we can just use function graph=20=

to see how long __alloc_pages_nodemask() takes).

Janani

> --=20
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
