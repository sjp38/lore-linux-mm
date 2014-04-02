Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id 636A06B00A2
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 07:46:02 -0400 (EDT)
Received: by mail-qg0-f46.google.com with SMTP id 63so56120qgz.33
        for <linux-mm@kvack.org>; Wed, 02 Apr 2014 04:46:02 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id e30si679102qge.36.2014.04.02.04.46.01
        for <linux-mm@kvack.org>;
        Wed, 02 Apr 2014 04:46:01 -0700 (PDT)
Message-ID: <1396439119.2726.29.camel@menhir>
Subject: Re: [PATCH] mm: msync: require either MS_ASYNC or MS_SYNC
From: Steven Whitehouse <swhiteho@redhat.com>
Date: Wed, 02 Apr 2014 12:45:19 +0100
In-Reply-To: <20140402111032.GA27551@infradead.org>
References: <533B04A9.6090405@bbn.com>
	 <20140402111032.GA27551@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Richard Hansen <rhansen@bbn.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Greg Troxel <gdt@ir.bbn.com>

Hi,

On Wed, 2014-04-02 at 04:10 -0700, Christoph Hellwig wrote:
> On Tue, Apr 01, 2014 at 02:25:45PM -0400, Richard Hansen wrote:
> > For the flags parameter, POSIX says "Either MS_ASYNC or MS_SYNC shall
> > be specified, but not both." [1]  There was already a test for the
> > "both" condition.  Add a test to ensure that the caller specified one
> > of the flags; fail with EINVAL if neither are specified.
> 
> This breaks various (sloppy) existing userspace for no gain.
> 
> NAK.
> 
Agreed. It might be better to have something like:

if (flags == 0)
	flags = MS_SYNC;

That way applications which don't set the flags (and possibly also don't
check the return value, so will not notice an error return) will get the
sync they desire. Not that either of those things is desirable, but at
least we can make the best of the situation. Probably better to be slow
than to potentially lose someone's data in this case,

Steve.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
