Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 05D896B0071
	for <linux-mm@kvack.org>; Thu, 27 Feb 2014 17:08:15 -0500 (EST)
Received: by mail-pd0-f177.google.com with SMTP id g10so2965484pdj.8
        for <linux-mm@kvack.org>; Thu, 27 Feb 2014 14:08:15 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id q5si6008871pbh.74.2014.02.27.14.08.14
        for <linux-mm@kvack.org>;
        Thu, 27 Feb 2014 14:08:15 -0800 (PST)
Date: Thu, 27 Feb 2014 14:08:13 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCHv3 1/2] mm: introduce vm_ops->map_pages()
Message-Id: <20140227140813.988b225351b91937f840404b@linux-foundation.org>
In-Reply-To: <530FB55F.2070106@linux.intel.com>
References: <1393530827-25450-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1393530827-25450-2-git-send-email-kirill.shutemov@linux.intel.com>
	<530FB55F.2070106@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Chinner <david@fromorbit.com>, Ning Qu <quning@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, 27 Feb 2014 13:59:59 -0800 Dave Hansen <dave.hansen@linux.intel.com> wrote:

> On 02/27/2014 11:53 AM, Kirill A. Shutemov wrote:
> > +#define FAULT_AROUND_ORDER 4
> > +#define FAULT_AROUND_PAGES (1UL << FAULT_AROUND_ORDER)
> > +#define FAULT_AROUND_MASK ~((1UL << (PAGE_SHIFT + FAULT_AROUND_ORDER)) - 1)
> 
> Looking at the performance data made me think of this: do we really want
> this to be static?  It seems like the kind of thing that will cause a
> regression _somewhere_.

Yes, allowing people to tweak it at runtime would improve testability a
lot.

I don't think we want to let yet another tunable out into the wild
unless we really need to - perhaps a not-for-mainline add-on patch, or
something in debugfs so we have the option of taking it away later.

> Also, the folks with larger base bage sizes probably don't want a
> FAULT_AROUND_ORDER=4.  That's 1MB of fault-around for ppc64, for example.

Yup, we don't want the same app to trigger dramatically different
kernel behaviour when it is moved from x86 to ppc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
