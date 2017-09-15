Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 538736B0038
	for <linux-mm@kvack.org>; Fri, 15 Sep 2017 12:38:25 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id t184so3940361qke.0
        for <linux-mm@kvack.org>; Fri, 15 Sep 2017 09:38:25 -0700 (PDT)
Received: from alln-iport-4.cisco.com (alln-iport-4.cisco.com. [173.37.142.91])
        by mx.google.com with ESMTPS id z47si1342916qta.96.2017.09.15.09.38.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Sep 2017 09:38:24 -0700 (PDT)
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
From: Taras Kondratiuk <takondra@cisco.com>
In-Reply-To: <a5232e66-e05a-e89c-a7ba-2d3572b609d9@cisco.com>
References: <150543458765.3781.10192373650821598320@takondra-t460s>
 <a5232e66-e05a-e89c-a7ba-2d3572b609d9@cisco.com>
Message-ID: <150549350270.4512.4357187826510021894@takondra-t460s>
Subject: Re: Detecting page cache trashing state
Date: Fri, 15 Sep 2017 09:38:22 -0700
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Walker <danielwa@cisco.com>, linux-mm@kvack.org
Cc: xe-linux-external@cisco.com, Ruslan Ruslichenko <rruslich@cisco.com>, linux-kernel@vger.kernel.org

Quoting Daniel Walker (2017-09-15 07:22:27)
> On 09/14/2017 05:16 PM, Taras Kondratiuk wrote:
> > Hi
> >
> > In our devices under low memory conditions we often get into a trashing
> > state when system spends most of the time re-reading pages of .text
> > sections from a file system (squashfs in our case). Working set doesn't
> > fit into available page cache, so it is expected. The issue is that
> > OOM killer doesn't get triggered because there is still memory for
> > reclaiming. System may stuck in this state for a quite some time and
> > usually dies because of watchdogs.
> >
> > We are trying to detect such trashing state early to take some
> > preventive actions. It should be a pretty common issue, but for now we
> > haven't find any existing VM/IO statistics that can reliably detect such
> > state.
> >
> > Most of metrics provide absolute values: number/rate of page faults,
> > rate of IO operations, number of stolen pages, etc. For a specific
> > device configuration we can determine threshold values for those
> > parameters that will detect trashing state, but it is not feasible for
> > hundreds of device configurations.
> >
> > We are looking for some relative metric like "percent of CPU time spent
> > handling major page faults". With such relative metric we could use a
> > common threshold across all devices. For now we have added such metric
> > to /proc/stat in our kernel, but we would like to find some mechanism
> > available in upstream kernel.
> >
> > Has somebody faced similar issue? How are you solving it?
> =

> =

> Did you make any attempt to tune swappiness ?
> =

> Documentation/sysctl/vm.txt
> =

> swappiness
> =

> This control is used to define how aggressive the kernel will swap
> memory pages.  Higher values will increase agressiveness, lower values
> decrease the amount of swap.
> =

> The default value is 60.
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D
> =

> Since your using squashfs I would guess that's going to act like swap. =

> The default tune of 60 is most likely for x86 servers which may not be a =

> good value for some other device.

Swap is disabled in our systems, so anonymous pages can't be evicted.
As per my understanding swappiness tune is irrelevant.

Even with enabled swap swappiness tune can't help much in this case. If
working set doesn't fit into available page cache we will hit the same
trashing state.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
