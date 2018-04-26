Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 058236B0005
	for <linux-mm@kvack.org>; Thu, 26 Apr 2018 12:07:32 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id 39so17362273qkx.0
        for <linux-mm@kvack.org>; Thu, 26 Apr 2018 09:07:32 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id y14si4114211qvb.99.2018.04.26.09.07.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Apr 2018 09:07:31 -0700 (PDT)
Date: Thu, 26 Apr 2018 12:07:25 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [dm-devel] [PATCH v5] fault-injection: introduce kvmalloc fallback
 options
In-Reply-To: <20180426184845-mutt-send-email-mst@kernel.org>
Message-ID: <alpine.LRH.2.02.1804261202350.24656@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.DEB.2.21.1804251417470.166306@chino.kir.corp.google.com> <alpine.LRH.2.02.1804251720090.9428@file01.intranet.prod.int.rdu2.redhat.com> <1524694663.4100.21.camel@HansenPartnership.com> <alpine.LRH.2.02.1804251830540.25124@file01.intranet.prod.int.rdu2.redhat.com>
 <20180426125817.GO17484@dhcp22.suse.cz> <alpine.LRH.2.02.1804261006120.32722@file01.intranet.prod.int.rdu2.redhat.com> <1524753932.3226.5.camel@HansenPartnership.com> <alpine.LRH.2.02.1804261100170.12157@file01.intranet.prod.int.rdu2.redhat.com>
 <1524756256.3226.7.camel@HansenPartnership.com> <alpine.LRH.2.02.1804261142480.21152@file01.intranet.prod.int.rdu2.redhat.com> <20180426184845-mutt-send-email-mst@kernel.org>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="185206533-1736142901-1524758846=:24656"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>, Michal Hocko <mhocko@kernel.org>, David Rientjes <rientjes@google.com>, dm-devel@redhat.com, eric.dumazet@gmail.com, netdev@vger.kernel.org, jasowang@redhat.com, Randy Dunlap <rdunlap@infradead.org>, linux-kernel@vger.kernel.org, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, edumazet@google.com, Andrew Morton <akpm@linux-foundation.org>, virtualization@lists.linux-foundation.org, David Miller <davem@davemloft.net>, Vlastimil Babka <vbabka@suse.cz>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--185206533-1736142901-1524758846=:24656
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT



On Thu, 26 Apr 2018, Michael S. Tsirkin wrote:

> On Thu, Apr 26, 2018 at 11:44:21AM -0400, Mikulas Patocka wrote:
> > 
> > 
> > On Thu, 26 Apr 2018, James Bottomley wrote:
> > 
> > > On Thu, 2018-04-26 at 11:05 -0400, Mikulas Patocka wrote:
> > > > 
> > > > On Thu, 26 Apr 2018, James Bottomley wrote:
> > > [...]
> > > > > Perhaps find out beforehand instead of insisting on an approach
> > > > without
> > > > > knowing.  On openSUSE the grub config is built from the files in
> > > > > /etc/grub.d/ so any package can add a kernel option (and various
> > > > > conditions around activating it) simply by adding a new file.
> > > > 
> > > > And then, different versions of the debug kernel will clash when 
> > > > attempting to create the same file.
> > > 
> > > Don't be silly ... there are many ways of coping with that in rpm/dpkg.
> > 
> > I know you can deal with it - but how many lines of code will that 
> > consume? Multiplied by the total number of rpm-based distros.
> > 
> > Mikulas
> 
> I don't think debug kernels should inject faults by default.

But it is not injecting any faults. It is using the fault-injection 
framework because Michal said that it should use it. The original version 
of the patch didn't use the fault-injection framework at all.

The kvmalloc function can take two branches, the kmalloc branch and 
vmalloc branch. The vmalloc branch is taken rarely, so the kernel contains 
bugs regarding this path - and the patch increases the probability that 
the vmalloc patch is taken, to discover the bugs early and make them 
reproducible.

> IIUC debug kernels mainly exist so people who experience e.g. memory
> corruption can try and debug the failure. In this case, CONFIG_DEBUG_SG
> will *already* catch a failure early. Nothing special needs to be done.

The patch helps people debug such memory coprruptions (such as using DMA 
API on the result of kvmalloc).

> There is a much smaller class of people like QA who go actively looking
> for trouble. That's the kind of thing fault injection is good for, and
> IMO you do not want your QA team to test a separate kernel - otherwise
> you are never quite sure whatever was tested will work in the field.
> So a config option won't help them either.
> 
> How do you make sure QA tests a specific corner case? Add it to
> the test plan :)
> 
> I don't speak for Red Hat, etc.
> 
> -- 
> MST

Mikulas
--185206533-1736142901-1524758846=:24656--
