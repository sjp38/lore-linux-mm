Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1AC7B6B02B4
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 07:27:56 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 128so5688233pgd.10
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 04:27:56 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id y2si2215621pgr.397.2017.08.29.04.27.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Aug 2017 04:27:55 -0700 (PDT)
Date: Tue, 29 Aug 2017 13:27:31 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2 14/20] mm: Provide speculative fault infrastructure
Message-ID: <20170829112731.vhgwrzwwlimdbjcn@hirez.programming.kicks-ass.net>
References: <1503007519-26777-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1503007519-26777-15-git-send-email-ldufour@linux.vnet.ibm.com>
 <20170827001823.n5wgkfq36z6snvf2@node.shutemov.name>
 <20170828093727.5wldedputadanssh@hirez.programming.kicks-ass.net>
 <1503954877.4850.19.camel@kernel.crashing.org>
 <20170829083352.qrsxvk3lkiydi3o2@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170829083352.qrsxvk3lkiydi3o2@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Laurent Dufour <ldufour@linux.vnet.ibm.com>, paulmck@linux.vnet.ibm.com, akpm@linux-foundation.org, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On Tue, Aug 29, 2017 at 10:33:52AM +0200, Peter Zijlstra wrote:
> On Tue, Aug 29, 2017 at 07:14:37AM +1000, Benjamin Herrenschmidt wrote:
> > We'd have to audit archs closely. Things like the page walk cache
> > flushing on power etc...
> 
> If you point me where to look, I'll have a poke around. I'm not
> quite sure what you mean with pagewalk cache flushing. Your hash thing
> flushes everything inside the PTL IIRC and the radix code appears fairly
> 'normal'.

mpe helped me out and explained that is the PWC hint to TBLIE.

So, you set need_flush_all when you unhook pud/pmd/pte which you then
use to set PWC. So free_pgtables() will do the PWC when it unhooks
higher level pages.

But you're right that there's some issues, free_pgtables() itself
doesn't seem to use mm->page_table_lock,pmd->lock _AT_ALL_ to unhook the
pages.

If it were to do that, things should work fine since those locks would
then serialize against the speculative faults, we would never install a
page if the VMA would be under tear-down and it would thus not be
visible to your caches either.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
