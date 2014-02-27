Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f180.google.com (mail-ve0-f180.google.com [209.85.128.180])
	by kanga.kvack.org (Postfix) with ESMTP id 0722F6B0031
	for <linux-mm@kvack.org>; Thu, 27 Feb 2014 16:28:23 -0500 (EST)
Received: by mail-ve0-f180.google.com with SMTP id jz11so4387585veb.39
        for <linux-mm@kvack.org>; Thu, 27 Feb 2014 13:28:23 -0800 (PST)
Received: from mail-ve0-x232.google.com (mail-ve0-x232.google.com [2607:f8b0:400c:c01::232])
        by mx.google.com with ESMTPS id cx4si1689389vcb.5.2014.02.27.13.28.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 27 Feb 2014 13:28:23 -0800 (PST)
Received: by mail-ve0-f178.google.com with SMTP id jy13so4542663veb.9
        for <linux-mm@kvack.org>; Thu, 27 Feb 2014 13:28:23 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1393530827-25450-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1393530827-25450-1-git-send-email-kirill.shutemov@linux.intel.com>
Date: Thu, 27 Feb 2014 13:28:22 -0800
Message-ID: <CA+55aFwOe_m3cfQDGxmcBavhyQTqQQNGvACR4YPLaazM_0oyUw@mail.gmail.com>
Subject: Re: [PATCHv3 0/2] mm: map few pages around fault address if they are
 in page cache
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Chinner <david@fromorbit.com>, Ning Qu <quning@gmail.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Feb 27, 2014 at 11:53 AM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> Here's new version of faultaround patchset. It took a while to tune it and
> collect performance data.

Andrew, mind taking this into -mm with my acks? It's based on top of
Kirill's cleanup patches that I think are also in your tree.

Kirill - no complaints from me. I do have two minor issues that you
might satisfy, but I think the patch is fine as-is.

The issues/questions are:

 (a) could you test this on a couple of different architectures? Even
if you just have access to intel machines, testing it across a couple
of generations of microarchitectures would be good. The reason I say
that is that from my profiles, it *looks* like the page fault costs
are relatively higher on Ivybridge/Haswell than on some earlier
uarchs.

   Now, I may well be wrong about the uarch issue, and maybe I just
didn't notice it as much before. I've stared at a lot of profiles over
the years, though, and the page fault cost seems to stand out much
more than it used to. And don't get me wrong - it might not be because
Ivy/Haswell is any worse, it might just be that exception performance
hasn't improved together with some other improvements.

 (b) I suspect we should try to strongly discourage filesystems from
actually using map_pages unless they use the standard
filemap_map_pages function as-is. Even with the fairly clean
interface, and forcing people to use "do_set_pte()", I think the docs
might want to try to more explicitly discourage people from using this
to do their own hacks..

Hmm? Either way, even without those questions answered, I'm happy with
how your patches look.

                    Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
