Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id D783C6B025F
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 14:15:00 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id b136so111511580ioe.9
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 11:15:00 -0700 (PDT)
Received: from resqmta-ch2-05v.sys.comcast.net (resqmta-ch2-05v.sys.comcast.net. [2001:558:fe21:29:69:252:207:37])
        by mx.google.com with ESMTPS id c93si7885370ioj.279.2017.08.14.11.14.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Aug 2017 11:14:59 -0700 (PDT)
Date: Mon, 14 Aug 2017 13:14:57 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: How can we share page cache pages for reflinked files?
In-Reply-To: <20170814064838.GB21024@dastard>
Message-ID: <alpine.DEB.2.20.1708141307380.32429@nuc-kabylake>
References: <20170810042849.GK21024@dastard> <20170810161159.GI31390@bombadil.infradead.org> <20170811042519.GS21024@dastard> <20170811170847.GK31390@bombadil.infradead.org> <20170814064838.GB21024@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Matthew Wilcox <willy@infradead.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Mon, 14 Aug 2017, Dave Chinner wrote:

> > Use XFS+reflink+DAX on top of this loop device.  Now there's only one
> > copy of each page in RAM.
>
> Yes, I can see how that could work. Crazy, out of the box, abuses
> DAX for non-DAX purposes and uses stuff we haven't enabled yet
> because nobody has done the work to validate it. Full points for
> creativity! :)

Another not so crazy solution is to break the 1-1 relation between page
structs and pages. We already have issues with huge pages where one struct
page may represent 2m of memmory using 512 or so page struct.

Therer are also constantly attempts to expand struct page.

So how about an m->n relationship? Any page (may it be 4k, 2m or 1G) has
one page struct for each mapping that it is a member of?

Maybe a the page state could consist of a base struct that describes
the page state and then 1..n  pieces of mapping information? In the future
other state info could be added to the end if we allow dynamic sizing of
page structs.

This would also allow the inevitable creeping page struct bloat to get
completely out of control.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
