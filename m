Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id DE54A6B0006
	for <linux-mm@kvack.org>; Mon,  1 Oct 2018 16:27:28 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id b13-v6so59033edb.1
        for <linux-mm@kvack.org>; Mon, 01 Oct 2018 13:27:28 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v18-v6si1603032ejx.73.2018.10.01.13.27.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Oct 2018 13:27:27 -0700 (PDT)
Date: Mon, 1 Oct 2018 22:27:24 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] migration/mm: Add WARN_ON to try_offline_node
Message-ID: <20181001202724.GL18290@dhcp22.suse.cz>
References: <20181001185616.11427.35521.stgit@ltcalpine2-lp9.aus.stglabs.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181001185616.11427.35521.stgit@ltcalpine2-lp9.aus.stglabs.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Bringmann <mwb@linux.vnet.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Ellerman <mpe@ellerman.id.au>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Nicholas Piggin <npiggin@gmail.com>, Kees Cook <keescook@chromium.org>, Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com>, Russell Currey <ruscur@russell.cc>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Christophe Leroy <christophe.leroy@c-s.fr>, Andrew Morton <akpm@linux-foundation.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Dan Williams <dan.j.williams@intel.com>, Oscar Salvador <osalvador@suse.de>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Mathieu Malaterre <malat@debian.org>, Juliet Kim <minkim@us.ibm.com>, Tyrel Datwyler <tyreld@linux.vnet.ibm.com>, Thomas Falcon <tlfalcon@linux.vnet.ibm.com>

On Mon 01-10-18 13:56:25, Michael Bringmann wrote:
> In some LPAR migration scenarios, device-tree modifications are
> made to the affinity of the memory in the system.  For instance,
> it may occur that memory is installed to nodes 0,3 on a source
> system, and to nodes 0,2 on a target system.  Node 2 may not
> have been initialized/allocated on the target system.
> 
> After migration, if a RTAS PRRN memory remove is made to a
> memory block that was in node 3 on the source system, then
> try_offline_node tries to remove it from node 2 on the target.
> The NODE_DATA(2) block would not be initialized on the target,
> and there is no validation check in the current code to prevent
> the use of a NULL pointer.

I am not familiar with ppc and the above doesn't really help me
much. Sorry about that. But from the above it is not clear to me whether
it is the caller which does something unexpected or the hotplug code
being not robust enough. From your changelog I would suggest the later
but why don't we see the same problem for other archs? Is this a problem
of unrolling a partial failure?

dlpar_remove_lmb does the following

	nid = memory_add_physaddr_to_nid(lmb->base_addr);

	remove_memory(nid, lmb->base_addr, block_sz);

	/* Update memory regions for memory remove */
	memblock_remove(lmb->base_addr, block_sz);

	dlpar_remove_device_tree_lmb(lmb);

Is the whole operation correct when remove_memory simply backs off
silently. Why don't we have to care about memblock resp
dlpar_remove_device_tree_lmb parts? In other words how come the physical
memory range is valid while the node association is not?
-- 
Michal Hocko
SUSE Labs
