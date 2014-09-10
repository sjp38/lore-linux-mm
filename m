Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 75CF96B0036
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 02:51:47 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id fp1so4992923pdb.0
        for <linux-mm@kvack.org>; Tue, 09 Sep 2014 23:51:47 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id jd10si26257262pbd.168.2014.09.09.23.51.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 09 Sep 2014 23:51:46 -0700 (PDT)
Date: Wed, 10 Sep 2014 09:51:29 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH] mm/sl[aou]b: make kfree() aware of error pointers
Message-ID: <20140910065129.GN6549@mwanda>
References: <alpine.LNX.2.00.1409092319370.5523@pobox.suse.cz>
 <20140909162114.44b3e98cf925f125e84a8a06@linux-foundation.org>
 <113623.1410326115@turing-police.cc.vt.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <113623.1410326115@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Valdis.Kletnieks@vt.edu
Cc: Andrew Morton <akpm@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>

On Wed, Sep 10, 2014 at 01:15:15AM -0400, Valdis.Kletnieks@vt.edu wrote:
> On Tue, 09 Sep 2014 16:21:14 -0700, Andrew Morton said:
> > On Tue, 9 Sep 2014 23:25:28 +0200 (CEST) Jiri Kosina <jkosina@suse.cz> wrote:
> > kfree() is quite a hot path to which this will add overhead.  And we
> > have (as far as we know) no code which will actually use this at
> > present.
> 
> We already do a check for ZERO_SIZE_PTR, and given that dereferencing *that* is
> instant death for the kernel, and we see it very rarely, I'm going to guess
> that IS_ERR(ptr) *has* to be true more often than ZERO_SIZE_PTR, and thus even
> more advantageous to short-circuit.

ZERO_SIZE_PTR is sort of common.

ZERO_SIZE_PTR is an mm abstraction and kfree() and ksize() are basically
the only places where we need to test for it.  Also friends of kfree()
like jbd2_journal_free_transaction().

regards,
dan carpenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
