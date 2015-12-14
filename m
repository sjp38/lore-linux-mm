Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id B75BC6B0038
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 16:11:35 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id p66so81871251wmp.1
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 13:11:35 -0800 (PST)
Received: from mail-wm0-x233.google.com (mail-wm0-x233.google.com. [2a00:1450:400c:c09::233])
        by mx.google.com with ESMTPS id p190si27926478wmg.80.2015.12.14.13.11.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Dec 2015 13:11:34 -0800 (PST)
Received: by mail-wm0-x233.google.com with SMTP id p66so81870671wmp.1
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 13:11:34 -0800 (PST)
Date: Mon, 14 Dec 2015 23:11:32 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC] mm: change find_vma() function
Message-ID: <20151214211132.GA7390@node.shutemov.name>
References: <1450090945-4020-1-git-send-email-yalin.wang2010@gmail.com>
 <20151214121107.GB4201@node.shutemov.name>
 <20151214175509.GA25681@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151214175509.GA25681@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: yalin wang <yalin.wang2010@gmail.com>, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, gang.chen.5i5j@gmail.com, mhocko@suse.com, kwapulinski.piotr@gmail.com, aarcange@redhat.com, dcashman@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Dec 14, 2015 at 06:55:09PM +0100, Oleg Nesterov wrote:
> On 12/14, Kirill A. Shutemov wrote:
> >
> > On Mon, Dec 14, 2015 at 07:02:25PM +0800, yalin wang wrote:
> > > change find_vma() to break ealier when found the adderss
> > > is not in any vma, don't need loop to search all vma.
> > >
> > > Signed-off-by: yalin wang <yalin.wang2010@gmail.com>
> > > ---
> > >  mm/mmap.c | 3 +++
> > >  1 file changed, 3 insertions(+)
> > >
> > > diff --git a/mm/mmap.c b/mm/mmap.c
> > > index b513f20..8294c9b 100644
> > > --- a/mm/mmap.c
> > > +++ b/mm/mmap.c
> > > @@ -2064,6 +2064,9 @@ struct vm_area_struct *find_vma(struct mm_struct *mm, unsigned long addr)
> > >  			vma = tmp;
> > >  			if (tmp->vm_start <= addr)
> > >  				break;
> > > +			if (!tmp->vm_prev || tmp->vm_prev->vm_end <= addr)
> > > +				break;
> > > +
> >
> > This 'break' would return 'tmp' as found vma.
> 
> But this would be right?

Hm. Right. Sorry for my tone.

I think the right condition is 'tmp->vm_prev->vm_end < addr', not '<=' as
vm_end is the first byte after the vma. But it's equivalent in practice
here.

Anyway, I don't think it's possible to gain anything measurable from this
optimization.

> 
> Not that I think this optimization makes sense, I simply do not know,
> but to me this change looks technically correct at first glance...
> 
> But the changelog is wrong or I missed something. This change can stop
> the main loop earlier; if "tmp" is the first vma,

For the first vma, we don't get anything comparing to what we have now:
check for !rb_node on the next iteration would have the same trade off and
effect as the proposed check.

> or if the previous one is below the address.

Yes, but would it compensate additional check on each 'tmp->vm_end > addr'
iteration to the point? That's not obvious.

> Or perhaps I just misread that "not in any vma" note in the changelog.
> 
> No?
> 
> Oleg.
> 

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
