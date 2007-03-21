Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id l2LEmr8w009109
	for <linux-mm@kvack.org>; Wed, 21 Mar 2007 10:48:53 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l2LEobSQ061808
	for <linux-mm@kvack.org>; Wed, 21 Mar 2007 08:50:37 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l2LEoaKL018098
	for <linux-mm@kvack.org>; Wed, 21 Mar 2007 08:50:37 -0600
Subject: Re: [PATCH 1/7] Introduce the pagetable_operations and associated
	helper macros.
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <1174433081.26166.168.camel@localhost.localdomain>
References: <20070319200502.17168.17175.stgit@localhost.localdomain>
	 <20070319200513.17168.52238.stgit@localhost.localdomain>
	 <1174433081.26166.168.camel@localhost.localdomain>
Content-Type: text/plain
Date: Wed, 21 Mar 2007 09:50:30 -0500
Message-Id: <1174488630.21684.5.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <hansendc@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Arjan van de Ven <arjan@infradead.org>, William Lee Irwin III <wli@holomorphy.com>, Christoph Hellwig <hch@infradead.org>, Ken Chen <kenchen@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 2007-03-20 at 16:24 -0700, Dave Hansen wrote:
> On Mon, 2007-03-19 at 13:05 -0700, Adam Litke wrote:
> > 
> > +#define has_pt_op(vma, op) \
> > +       ((vma)->pagetable_ops && (vma)->pagetable_ops->op)
> > +#define pt_op(vma, call) \
> > +       ((vma)->pagetable_ops->call) 
> 
> Can you get rid of these macros?  I think they make it a wee bit harder
> to read.  My brain doesn't properly parse the foo(arg)(bar) syntax.  
> 
> +       if (has_pt_op(vma, copy_vma))
> +               return pt_op(vma, copy_vma)(dst_mm, src_mm, vma);
> 
> +       if (vma->pagetable_ops && vma->pagetable_ops->copy_vma)
> +               return vma->pagetable_ops->copy_vma(dst_mm, src_mm, vma);
> 
> I guess it does lead to some longish lines.  Does it start looking
> really nasty?

Yeah, it starts to look pretty bad.  Some of these calls are in code
that is already indented several times.

> If you're going to have them, it might just be best to put a single
> unlikely() around the macro definitions themselves to keep anybody from
> having to open-code it for any of the users.  

It should be pretty easy to wrap has_pt_op() with an unlikely().  Good
suggestion.

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
