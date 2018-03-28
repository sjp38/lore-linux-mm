Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id C54FD6B0026
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 17:21:32 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id c16so2035480pgv.8
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 14:21:32 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 1-v6sor1258535pln.97.2018.03.28.14.21.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 28 Mar 2018 14:21:31 -0700 (PDT)
Date: Wed, 28 Mar 2018 14:21:29 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v9 09/24] mm: protect mremap() against SPF hanlder
In-Reply-To: <1fe7529a-947c-fdb2-12d2-b38bdd41bb04@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.20.1803281419460.167685@chino.kir.corp.google.com>
References: <1520963994-28477-1-git-send-email-ldufour@linux.vnet.ibm.com> <1520963994-28477-10-git-send-email-ldufour@linux.vnet.ibm.com> <alpine.DEB.2.20.1803271500540.43106@chino.kir.corp.google.com>
 <1fe7529a-947c-fdb2-12d2-b38bdd41bb04@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On Wed, 28 Mar 2018, Laurent Dufour wrote:

> >> @@ -326,7 +336,10 @@ static unsigned long move_vma(struct vm_area_struct *vma,
> >>  		mremap_userfaultfd_prep(new_vma, uf);
> >>  		arch_remap(mm, old_addr, old_addr + old_len,
> >>  			   new_addr, new_addr + new_len);
> >> +		if (vma != new_vma)
> >> +			vm_raw_write_end(vma);
> >>  	}
> >> +	vm_raw_write_end(new_vma);
> > 
> > Just do
> > 
> > vm_raw_write_end(vma);
> > vm_raw_write_end(new_vma);
> > 
> > here.
> 
> Are you sure ? we can have vma = new_vma done if (unlikely(err))
> 

Sorry, what I meant was do

if (vma != new_vma)
	vm_raw_write_end(vma);
vm_raw_write_end(new_vma);

after the conditional.  Having the locking unnecessarily embedded in the 
conditional has been an issue in the past with other areas of core code, 
unless you have a strong reason for it.
