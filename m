Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l2KNOvh2028082
	for <linux-mm@kvack.org>; Tue, 20 Mar 2007 19:24:57 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l2KNOvqu052556
	for <linux-mm@kvack.org>; Tue, 20 Mar 2007 17:24:57 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l2KNOu3r004470
	for <linux-mm@kvack.org>; Tue, 20 Mar 2007 17:24:57 -0600
Subject: Re: [PATCH 1/7] Introduce the pagetable_operations and associated
	helper macros.
From: Dave Hansen <hansendc@us.ibm.com>
In-Reply-To: <20070319200513.17168.52238.stgit@localhost.localdomain>
References: <20070319200502.17168.17175.stgit@localhost.localdomain>
	 <20070319200513.17168.52238.stgit@localhost.localdomain>
Content-Type: text/plain
Date: Tue, 20 Mar 2007 16:24:41 -0700
Message-Id: <1174433081.26166.168.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Arjan van de Ven <arjan@infradead.org>, William Lee Irwin III <wli@holomorphy.com>, Christoph Hellwig <hch@infradead.org>, Ken Chen <kenchen@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 2007-03-19 at 13:05 -0700, Adam Litke wrote:
> 
> +#define has_pt_op(vma, op) \
> +       ((vma)->pagetable_ops && (vma)->pagetable_ops->op)
> +#define pt_op(vma, call) \
> +       ((vma)->pagetable_ops->call) 

Can you get rid of these macros?  I think they make it a wee bit harder
to read.  My brain doesn't properly parse the foo(arg)(bar) syntax.  

+       if (has_pt_op(vma, copy_vma))
+               return pt_op(vma, copy_vma)(dst_mm, src_mm, vma);

+       if (vma->pagetable_ops && vma->pagetable_ops->copy_vma)
+               return vma->pagetable_ops->copy_vma(dst_mm, src_mm, vma);

I guess it does lead to some longish lines.  Does it start looking
really nasty?

If you're going to have them, it might just be best to put a single
unlikely() around the macro definitions themselves to keep anybody from
having to open-code it for any of the users.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
