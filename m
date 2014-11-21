Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id ECC136B0070
	for <linux-mm@kvack.org>; Fri, 21 Nov 2014 04:35:11 -0500 (EST)
Received: by mail-wi0-f180.google.com with SMTP id n3so8123514wiv.13
        for <linux-mm@kvack.org>; Fri, 21 Nov 2014 01:35:10 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dj6si7670576wjc.151.2014.11.21.01.35.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 21 Nov 2014 01:35:09 -0800 (PST)
Date: Fri, 21 Nov 2014 09:35:06 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 02/10] mm: Add p[te|md] protnone helpers for use by NUMA
 balancing
Message-ID: <20141121093506.GV2725@suse.de>
References: <1416478790-27522-1-git-send-email-mgorman@suse.de>
 <1416478790-27522-3-git-send-email-mgorman@suse.de>
 <CA+55aFwV80r66w4RmtY-MAUGkwmfBJe+C5KFD3ZnNgYb_KbBpQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CA+55aFwV80r66w4RmtY-MAUGkwmfBJe+C5KFD3ZnNgYb_KbBpQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LinuxPPC-dev <linuxppc-dev@lists.ozlabs.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, Dave Jones <davej@redhat.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@redhat.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Sasha Levin <sasha.levin@oracle.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>

On Thu, Nov 20, 2014 at 11:54:06AM -0800, Linus Torvalds wrote:
> On Thu, Nov 20, 2014 at 2:19 AM, Mel Gorman <mgorman@suse.de> wrote:
> > This is a preparatory patch that introduces protnone helpers for automatic
> > NUMA balancing.
> 
> Oh, I hadn't noticed that you had renamed these things. It was
> probably already true in your V1 version.
> 
> I do *not* think that "pte_protnone_numa()" makes sense as a name. It
> only confuses people to think that there is still/again something
> NUMA-special about the PTE. The whole point of the protnone changes
> was to make it really very very clear that from a hardware standpoint,
> this is *exactly* about protnone, and nothing else.
> 
> The fact that we then use protnone PTE's for numa faults is a VM
> internal issue, it should *not* show up in the architecture page table
> helpers.
> 
> I'm not NAK'ing this name, but I really think it's a very important
> part of the whole patch series - to stop the stupid confusion about
> NUMA entries. As far as the page tables are concerned, this has
> absolutely _zero_ to do with NUMA.
> 
> We made that mistake once. We're fixing it. Let the naming *show* that
> it's fixed, and this is "pte_protnone()".
> 
> The places that use this for NUMA handling might have a comment or
> something. But they'll be in the VM where this matters, not in the
> architecture page table description files. The comment would be
> something like "if the vma is accessible, but the PTE is marked
> protnone, this is a autonuma entry".
> 

I feared that people would eventually make the mistake of thinking that
pte_protnone() would return true for PROT_NONE VMAs that do *not* have
the page table bit set. I'll use the old name as you suggest and expand
the comment. It'll be in v3.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
