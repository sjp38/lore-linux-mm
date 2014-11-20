Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f171.google.com (mail-qc0-f171.google.com [209.85.216.171])
	by kanga.kvack.org (Postfix) with ESMTP id 9515C6B0069
	for <linux-mm@kvack.org>; Thu, 20 Nov 2014 14:54:08 -0500 (EST)
Received: by mail-qc0-f171.google.com with SMTP id r5so2668027qcx.2
        for <linux-mm@kvack.org>; Thu, 20 Nov 2014 11:54:08 -0800 (PST)
Received: from mail-qa0-x232.google.com (mail-qa0-x232.google.com. [2607:f8b0:400d:c00::232])
        by mx.google.com with ESMTPS id h4si3713514qai.124.2014.11.20.11.54.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 20 Nov 2014 11:54:07 -0800 (PST)
Received: by mail-qa0-f50.google.com with SMTP id w8so2483912qac.9
        for <linux-mm@kvack.org>; Thu, 20 Nov 2014 11:54:07 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1416478790-27522-3-git-send-email-mgorman@suse.de>
References: <1416478790-27522-1-git-send-email-mgorman@suse.de>
	<1416478790-27522-3-git-send-email-mgorman@suse.de>
Date: Thu, 20 Nov 2014 11:54:06 -0800
Message-ID: <CA+55aFwV80r66w4RmtY-MAUGkwmfBJe+C5KFD3ZnNgYb_KbBpQ@mail.gmail.com>
Subject: Re: [PATCH 02/10] mm: Add p[te|md] protnone helpers for use by NUMA balancing
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LinuxPPC-dev <linuxppc-dev@lists.ozlabs.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, Dave Jones <davej@redhat.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@redhat.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Sasha Levin <sasha.levin@oracle.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>

On Thu, Nov 20, 2014 at 2:19 AM, Mel Gorman <mgorman@suse.de> wrote:
> This is a preparatory patch that introduces protnone helpers for automatic
> NUMA balancing.

Oh, I hadn't noticed that you had renamed these things. It was
probably already true in your V1 version.

I do *not* think that "pte_protnone_numa()" makes sense as a name. It
only confuses people to think that there is still/again something
NUMA-special about the PTE. The whole point of the protnone changes
was to make it really very very clear that from a hardware standpoint,
this is *exactly* about protnone, and nothing else.

The fact that we then use protnone PTE's for numa faults is a VM
internal issue, it should *not* show up in the architecture page table
helpers.

I'm not NAK'ing this name, but I really think it's a very important
part of the whole patch series - to stop the stupid confusion about
NUMA entries. As far as the page tables are concerned, this has
absolutely _zero_ to do with NUMA.

We made that mistake once. We're fixing it. Let the naming *show* that
it's fixed, and this is "pte_protnone()".

The places that use this for NUMA handling might have a comment or
something. But they'll be in the VM where this matters, not in the
architecture page table description files. The comment would be
something like "if the vma is accessible, but the PTE is marked
protnone, this is a autonuma entry".

                    Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
