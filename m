Date: Wed, 7 May 2008 16:39:39 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 08 of 11] anon-vma-rwsem
In-Reply-To: <alpine.LFD.1.10.0805071610490.3024@woody.linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0805071637360.14337@schroedinger.engr.sgi.com>
References: <6b384bb988786aa78ef0.1210170958@duo.random>
 <alpine.LFD.1.10.0805071349200.3024@woody.linux-foundation.org>
 <20080507212650.GA8276@duo.random> <alpine.LFD.1.10.0805071429170.3024@woody.linux-foundation.org>
 <20080507222205.GC8276@duo.random> <20080507153103.237ea5b6.akpm@linux-foundation.org>
 <20080507224406.GI8276@duo.random> <20080507155914.d7790069.akpm@linux-foundation.org>
 <alpine.LFD.1.10.0805071610490.3024@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <andrea@qumranet.com>, steiner@sgi.com, holt@sgi.com, npiggin@suse.de, a.p.zijlstra@chello.nl, kvm-devel@lists.sourceforge.net, kanojsarcar@yahoo.com, rdreier@cisco.com, swise@opengridcomputing.com, linux-kernel@vger.kernel.org, avi@qumranet.com, linux-mm@kvack.org, general@lists.openfabrics.org, hugh@veritas.com, rusty@rustcorp.com.au, aliguori@us.ibm.com, chrisw@redhat.com, marcelo@kvack.org, dada1@cosmosbay.com, paulmck@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Wed, 7 May 2008, Linus Torvalds wrote:

> The code that can take many locks, will have to get the global lock *and* 
> order the types, but that's still trivial. It's something like
> 
> 	spin_lock(&global_lock);
> 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
> 		if (vma->anon_vma)
> 			spin_lock(&vma->anon_vma->lock);
> 	}
> 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
> 		if (!vma->anon_vma && vma->vm_file && vma->vm_file->f_mapping)
> 			spin_lock(&vma->vm_file->f_mapping->i_mmap_lock);
> 	}
> 	spin_unlock(&global_lock);

Multiple vmas may share the same mapping or refer to the same anonymous 
vma. The above code will deadlock since we may take some locks multiple 
times.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
