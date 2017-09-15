Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B905A6B0038
	for <linux-mm@kvack.org>; Fri, 15 Sep 2017 13:28:35 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id y77so5173888pfd.2
        for <linux-mm@kvack.org>; Fri, 15 Sep 2017 10:28:35 -0700 (PDT)
Received: from rcdn-iport-1.cisco.com (rcdn-iport-1.cisco.com. [173.37.86.72])
        by mx.google.com with ESMTPS id r83si896910pfr.566.2017.09.15.10.28.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Sep 2017 10:28:34 -0700 (PDT)
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
From: Taras Kondratiuk <takondra@cisco.com>
In-Reply-To: <20170915143619.2ifgex2jxck2xt5u@dhcp22.suse.cz>
References: <150543458765.3781.10192373650821598320@takondra-t460s>
 <20170915143619.2ifgex2jxck2xt5u@dhcp22.suse.cz>
Message-ID: <150549651001.4512.15084374619358055097@takondra-t460s>
Subject: Re: Detecting page cache trashing state
Date: Fri, 15 Sep 2017 10:28:30 -0700
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, xe-linux-external@cisco.com, Ruslan Ruslichenko <rruslich@cisco.com>, linux-kernel@vger.kernel.org

Quoting Michal Hocko (2017-09-15 07:36:19)
> On Thu 14-09-17 17:16:27, Taras Kondratiuk wrote:
> > Hi
> > =

> > In our devices under low memory conditions we often get into a trashing
> > state when system spends most of the time re-reading pages of .text
> > sections from a file system (squashfs in our case). Working set doesn't
> > fit into available page cache, so it is expected. The issue is that
> > OOM killer doesn't get triggered because there is still memory for
> > reclaiming. System may stuck in this state for a quite some time and
> > usually dies because of watchdogs.
> > =

> > We are trying to detect such trashing state early to take some
> > preventive actions. It should be a pretty common issue, but for now we
> > haven't find any existing VM/IO statistics that can reliably detect such
> > state.
> > =

> > Most of metrics provide absolute values: number/rate of page faults,
> > rate of IO operations, number of stolen pages, etc. For a specific
> > device configuration we can determine threshold values for those
> > parameters that will detect trashing state, but it is not feasible for
> > hundreds of device configurations.
> > =

> > We are looking for some relative metric like "percent of CPU time spent
> > handling major page faults". With such relative metric we could use a
> > common threshold across all devices. For now we have added such metric
> > to /proc/stat in our kernel, but we would like to find some mechanism
> > available in upstream kernel.
> > =

> > Has somebody faced similar issue? How are you solving it?
> =

> Yes this is a pain point for a _long_ time. And we still do not have a
> good answer upstream. Johannes has been playing in this area [1].
> The main problem is that our OOM detection logic is based on the ability
> to reclaim memory to allocate new memory. And that is pretty much true
> for the pagecache when you are trashing. So we do not know that
> basically whole time is spent refaulting the memory back and forth.
> We do have some refault stats for the page cache but that is not
> integrated to the oom detection logic because this is really a
> non-trivial problem to solve without triggering early oom killer
> invocations.
> =

> [1] http://lkml.kernel.org/r/20170727153010.23347-1-hannes@cmpxchg.org

Thanks Michal. memdelay looks promising. We will check it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
