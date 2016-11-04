Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1596C28026C
	for <linux-mm@kvack.org>; Fri,  4 Nov 2016 00:32:20 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id y16so8548046wmd.6
        for <linux-mm@kvack.org>; Thu, 03 Nov 2016 21:32:20 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cj2si12949474wjc.184.2016.11.03.21.32.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 03 Nov 2016 21:32:18 -0700 (PDT)
Date: Fri, 4 Nov 2016 05:32:14 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 01/21] mm: Join struct fault_env and vm_fault
Message-ID: <20161104043214.GA3569@quack2.suse.cz>
References: <1478039794-20253-1-git-send-email-jack@suse.cz>
 <1478039794-20253-3-git-send-email-jack@suse.cz>
 <20161102095848.GB20724@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161102095848.GB20724@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Wed 02-11-16 12:58:48, Kirill A. Shutemov wrote:
> On Tue, Nov 01, 2016 at 11:36:08PM +0100, Jan Kara wrote:
> > Currently we have two different structures for passing fault information
> > around - struct vm_fault and struct fault_env. DAX will need more
> > information in struct vm_fault to handle its faults so the content of
> > that structure would become event closer to fault_env. Furthermore it
> > would need to generate struct fault_env to be able to call some of the
> > generic functions. So at this point I don't think there's much use in
> > keeping these two structures separate. Just embed into struct vm_fault
> > all that is needed to use it for both purposes.
> 
> What about just reference fault_env from vm_fault? We don't always need
> vm_fault where we nee fault_env. It may save space on stack for some
> codepaths.

I was considering that as well but there is some duplication between those
two which I'd prefer to avoid and you would need both structures for the
fault handler which you eventually end up calling anyway (and that is very
likely the most stack-demanding path) so maximum stack consumption would
likely be even slightly higher.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
