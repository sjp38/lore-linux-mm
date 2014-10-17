Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f182.google.com (mail-lb0-f182.google.com [209.85.217.182])
	by kanga.kvack.org (Postfix) with ESMTP id D8EC06B0073
	for <linux-mm@kvack.org>; Fri, 17 Oct 2014 11:52:22 -0400 (EDT)
Received: by mail-lb0-f182.google.com with SMTP id z11so912220lbi.27
        for <linux-mm@kvack.org>; Fri, 17 Oct 2014 08:52:22 -0700 (PDT)
Received: from mail.efficios.com (mail.efficios.com. [78.47.125.74])
        by mx.google.com with ESMTP id lj3si2608566lab.112.2014.10.17.08.52.20
        for <linux-mm@kvack.org>;
        Fri, 17 Oct 2014 08:52:21 -0700 (PDT)
Date: Fri, 17 Oct 2014 15:52:14 +0000 (UTC)
From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Message-ID: <616734389.10923.1413561134767.JavaMail.zimbra@efficios.com>
In-Reply-To: <20141016223331.GA11169@wil.cx>
References: <1411677218-29146-1-git-send-email-matthew.r.wilcox@intel.com> <1411677218-29146-8-git-send-email-matthew.r.wilcox@intel.com> <20141016095027.GE19075@thinkos.etherlink> <20141016195112.GE11522@wil.cx> <20141016223331.GA11169@wil.cx>
Subject: Re: [PATCH v11 07/21] dax,ext2: Replace XIP read and write with DAX
 I/O
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

----- Original Message -----
> From: "Matthew Wilcox" <willy@linux.intel.com>
> To: "Mathieu Desnoyers" <mathieu.desnoyers@efficios.com>
> Cc: "Matthew Wilcox" <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
> linux-kernel@vger.kernel.org
> Sent: Friday, October 17, 2014 12:33:31 AM
> Subject: Re: [PATCH v11 07/21] dax,ext2: Replace XIP read and write with DAX I/O
> 
> On Thu, Oct 16, 2014 at 03:51:12PM -0400, Matthew Wilcox wrote:
> > On Thu, Oct 16, 2014 at 11:50:27AM +0200, Mathieu Desnoyers wrote:
> > > > +			if (rw == WRITE) {
> > > > +				if (!buffer_mapped(bh)) {
> > > > +					retval = -EIO;
> > > > +					/* FIXME: fall back to buffered I/O */
> > > 
> > > Fallback on buffered I/O would void guarantee about having data stored
> > > into persistent memory after write returns. Not sure we actually want
> > > that.
> > 
> > Yeah, I think that comment is just stale.  I can't see a way in which
> > buffered I/O would succeed after DAX I/O falis.
> 
> On further consideration, I think the whole thing is just foolish.
> I don't see how get_block(create == 1) can return success *and* a buffer
> that is !mapped.

Perhaps a safe approach could be to put a BUG_ON() to check this assumption ?

Thanks,

Mathieu

> 
> So I did this nice simplification:
> 
> -                       if (rw == WRITE) {
> -                               if (!buffer_mapped(bh)) {
> -                                       retval = -EIO;
> -                                       /* FIXME: fall back to buffered I/O
> */
> -                                       break;
> -                               }
> -                               hole = false;
> -                       } else {
> -                               hole = !buffer_written(bh);
> -                       }
> +                       hole = (rw != WRITE) && !buffer_written(bh);
> 
> (compile-tested only; I'm going to run all the changes through xfstests
> next week when I'm back home before sending out a v12).
> 



-- 
Mathieu Desnoyers
EfficiOS Inc.
http://www.efficios.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
