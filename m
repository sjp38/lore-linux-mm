Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id E54306B0008
	for <linux-mm@kvack.org>; Tue,  2 Oct 2018 12:04:53 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id m45-v6so1311268edc.2
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 09:04:53 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a29-v6si4113843edd.340.2018.10.02.09.04.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Oct 2018 09:04:52 -0700 (PDT)
Date: Tue, 2 Oct 2018 18:04:46 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] migration/mm: Add WARN_ON to try_offline_node
Message-ID: <20181002160446.GA18290@dhcp22.suse.cz>
References: <20181001185616.11427.35521.stgit@ltcalpine2-lp9.aus.stglabs.ibm.com>
 <20181001202724.GL18290@dhcp22.suse.cz>
 <bdbca329-7d35-0535-1737-94a06a19ae28@linux.vnet.ibm.com>
 <df95f828-1963-d8b9-ab58-6d29d2d152d2@linux.vnet.ibm.com>
 <20181002145922.GZ18290@dhcp22.suse.cz>
 <d338b385-626b-0e79-9944-708178fe245d@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d338b385-626b-0e79-9944-708178fe245d@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Bringmann <mwb@linux.vnet.ibm.com>
Cc: Tyrel Datwyler <tyreld@linux.vnet.ibm.com>, Thomas Falcon <tlfalcon@linux.vnet.ibm.com>, Kees Cook <keescook@chromium.org>, Mathieu Malaterre <malat@debian.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Nicholas Piggin <npiggin@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Juliet Kim <minkim@us.ibm.com>, Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, linuxppc-dev@lists.ozlabs.org, Dan Williams <dan.j.williams@intel.com>, Oscar Salvador <osalvador@suse.de>

On Tue 02-10-18 10:14:49, Michael Bringmann wrote:
> On 10/02/2018 09:59 AM, Michal Hocko wrote:
> > On Tue 02-10-18 09:51:40, Michael Bringmann wrote:
> > [...]
> >> When the device-tree affinity attributes have changed for memory,
> >> the 'nid' affinity calculated points to a different node for the
> >> memory block than the one used to install it, previously on the
> >> source system.  The newly calculated 'nid' affinity may not yet
> >> be initialized on the target system.  The current memory tracking
> >> mechanisms do not record the node to which a memory block was
> >> associated when it was added.  Nathan is looking at adding this
> >> feature to the new implementation of LMBs, but it is not there
> >> yet, and won't be present in earlier kernels without backporting a
> >> significant number of changes.
> > 
> > Then the patch you have proposed here just papers over a real issue, no?
> > IIUC then you simply do not remove the memory if you lose the race.
> 
> The problem occurs when removing memory after an affinity change
> references a node that was previously unreferenced.  Other code
> in 'kernel/mm/memory_hotplug.c' deals with initializing an empty
> node when adding memory to a system.  The 'removing memory' case is
> specific to systems that perform LPM and allow device-tree changes.
> The powerpc kernel does not have the option of accepting some PRRN
> requests and accepting others.  It must perform them all.

I am sorry, but you are still too cryptic for me. Either there is a
correctness issue and the the patch doesn't really fix anything or the
final race doesn't make any difference and then the ppc code should be
explicit about that. Checking the node inside the hotplug core code just
looks as a wrong layer to mitigate an arch specific problem. I am not
saying the patch is a no-go but if anything we want a big fat comment
explaining how this is possible because right now it just points to an
incorrect API usage.

That being said, this sounds pretty much ppc specific problem and I
would _prefer_ it to be handled there (along with a big fat comment of
course).
-- 
Michal Hocko
SUSE Labs
