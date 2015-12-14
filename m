Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f173.google.com (mail-io0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id 523406B0038
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 12:54:50 -0500 (EST)
Received: by iofo67 with SMTP id o67so51988883iof.3
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 09:54:50 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m81si3444779iom.134.2015.12.14.09.54.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Dec 2015 09:54:49 -0800 (PST)
Date: Mon, 14 Dec 2015 18:55:09 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [RFC] mm: change find_vma() function
Message-ID: <20151214175509.GA25681@redhat.com>
References: <1450090945-4020-1-git-send-email-yalin.wang2010@gmail.com> <20151214121107.GB4201@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151214121107.GB4201@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: yalin wang <yalin.wang2010@gmail.com>, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, gang.chen.5i5j@gmail.com, mhocko@suse.com, kwapulinski.piotr@gmail.com, aarcange@redhat.com, dcashman@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 12/14, Kirill A. Shutemov wrote:
>
> On Mon, Dec 14, 2015 at 07:02:25PM +0800, yalin wang wrote:
> > change find_vma() to break ealier when found the adderss
> > is not in any vma, don't need loop to search all vma.
> >
> > Signed-off-by: yalin wang <yalin.wang2010@gmail.com>
> > ---
> >  mm/mmap.c | 3 +++
> >  1 file changed, 3 insertions(+)
> >
> > diff --git a/mm/mmap.c b/mm/mmap.c
> > index b513f20..8294c9b 100644
> > --- a/mm/mmap.c
> > +++ b/mm/mmap.c
> > @@ -2064,6 +2064,9 @@ struct vm_area_struct *find_vma(struct mm_struct *mm, unsigned long addr)
> >  			vma = tmp;
> >  			if (tmp->vm_start <= addr)
> >  				break;
> > +			if (!tmp->vm_prev || tmp->vm_prev->vm_end <= addr)
> > +				break;
> > +
>
> This 'break' would return 'tmp' as found vma.

But this would be right?

Not that I think this optimization makes sense, I simply do not know,
but to me this change looks technically correct at first glance...

But the changelog is wrong or I missed something. This change can stop
the main loop earlier; if "tmp" is the first vma, or if the previous one
is below the address. Or perhaps I just misread that "not in any vma"
note in the changelog.

No?

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
