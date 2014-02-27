Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f169.google.com (mail-ve0-f169.google.com [209.85.128.169])
	by kanga.kvack.org (Postfix) with ESMTP id 2ADCB6B0071
	for <linux-mm@kvack.org>; Thu, 27 Feb 2014 17:06:30 -0500 (EST)
Received: by mail-ve0-f169.google.com with SMTP id pa12so2932068veb.14
        for <linux-mm@kvack.org>; Thu, 27 Feb 2014 14:06:29 -0800 (PST)
Received: from mail-vc0-x22f.google.com (mail-vc0-x22f.google.com [2607:f8b0:400c:c03::22f])
        by mx.google.com with ESMTPS id wg4si1814695vcb.38.2014.02.27.14.06.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 27 Feb 2014 14:06:29 -0800 (PST)
Received: by mail-vc0-f175.google.com with SMTP id ij19so3190856vcb.34
        for <linux-mm@kvack.org>; Thu, 27 Feb 2014 14:06:29 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <530FB55F.2070106@linux.intel.com>
References: <1393530827-25450-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1393530827-25450-2-git-send-email-kirill.shutemov@linux.intel.com>
	<530FB55F.2070106@linux.intel.com>
Date: Thu, 27 Feb 2014 14:06:29 -0800
Message-ID: <CA+55aFzUYTHXcVnZL0vTGRPh3oQ8qYGO9+Va1Ch3P1yX+9knDg@mail.gmail.com>
Subject: Re: [PATCHv3 1/2] mm: introduce vm_ops->map_pages()
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Chinner <david@fromorbit.com>, Ning Qu <quning@gmail.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Feb 27, 2014 at 1:59 PM, Dave Hansen
<dave.hansen@linux.intel.com> wrote:
>
> Also, the folks with larger base bage sizes probably don't want a
> FAULT_AROUND_ORDER=4.  That's 1MB of fault-around for ppc64, for example.

Actually, I'd expect that they won't mind, because there's no real
extra cost (the costs are indepenent of page size).

For small mappings the mapping size itself will avoid the
fault-around, and for big mappings they'll get the reduced page
faults.

They chose 64kB pages for a reason (although arguably that reason is
"our TLB fills are horrible crap"), they'll be fine with that "let's
try to map a few pages around us".

That said, making it runtime configurable for testing is likely a good
thing anyway, with some hardcoded maximum fault-around size for
sanity.

              Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
