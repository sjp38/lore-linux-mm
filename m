Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f176.google.com (mail-yk0-f176.google.com [209.85.160.176])
	by kanga.kvack.org (Postfix) with ESMTP id 6BE136B0253
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 17:28:45 -0400 (EDT)
Received: by ykdz138 with SMTP id z138so23482169ykd.2
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 14:28:45 -0700 (PDT)
Received: from mail.windriver.com (mail.windriver.com. [147.11.1.11])
        by mx.google.com with ESMTPS id w82si2210920ywb.51.2015.09.22.14.28.44
        for <linux-mm@kvack.org>
        (version=TLSv1.1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 22 Sep 2015 14:28:44 -0700 (PDT)
Date: Tue, 22 Sep 2015 17:28:41 -0400
From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH 01/10] mm: make cleancache.c explicitly non-modular
Message-ID: <20150922212841.GJ24829@windriver.com>
References: <1440454482-12250-1-git-send-email-paul.gortmaker@windriver.com>
 <1440454482-12250-2-git-send-email-paul.gortmaker@windriver.com>
 <F91A372A-4443-41C6-880F-5F6B66990FFA@oracle.com>
 <20150825011040.GA3560@windriver.com>
 <20150922152038.GE4454@l.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150922152038.GE4454@l.oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

[Re: [PATCH 01/10] mm: make cleancache.c explicitly non-modular] On 22/09/2015 (Tue 11:20) Konrad Rzeszutek Wilk wrote:

> On Mon, Aug 24, 2015 at 09:10:40PM -0400, Paul Gortmaker wrote:
> > [Re: [PATCH 01/10] mm: make cleancache.c explicitly non-modular] On 24/08/2015 (Mon 20:10) Konrad Rzeszutek Wilk wrote:
> > 
> > > On August 24, 2015 6:14:33 PM EDT, Paul Gortmaker <paul.gortmaker@windriver.com> wrote:
> > > >The Kconfig currently controlling compilation of this code is:
> > > >
> > > >config CLEANCACHE
> > > >bool "Enable cleancache driver to cache clean pages if tmem is present"
> > > >
> > > >...meaning that it currently is not being built as a module by anyone.
> > > 
> > > Why not make it a tristate?
> > 
> > Simple.  I'm making the code consistent with its current behaviour.
> > I'm not looking to extend functionality in code that I don't know
> > intimately.  I can't do that and do it reliably and guarantee it
> > works as a module when it has never been used as such before.
> > 
> > I've got about 130 of these and counting.  Some of them have been bool
> > since before git history ; before the turn of the century.  If there was
> > demand for them to be tristate, then it would have happened by now.  So
> > clearly there is no point in looking at making _those_ tristate.
> > 
> > I did have one uart driver author indicate that he _meant_ his code to
> > be tristate, and he tested it as such, and asked if I would convert it
> > to tristate on his behalf.  And that was fine and I did exactly that.
> > 
> > But unless there are interested users who want their code tristate and
> > can vouch that their code works OK as such, I can only make the code
> > consistent with the implicit non-modular behaviour that the Kconfig and
> > Makefiles have dictated up to now.  Are there such users for CLEANCACHE?
> 
> Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> 
> Sorry for taking so long. It really cannot be tri-state (I tried
> making it an module) as the cleancache hooks are tied in the mm/filemap.c.

No problem, AFAIK these aren't queued anywhere and after having done a
wider sweep, there are some 300+ of them (that give a net removal of ~5k
lines of dead code) with some in maintainer-less code; so it looks like
I'll inevitably have residuals that I'll have to ask Linus to pull directly.

Anyway, thanks for trying to modularize it. I'll add the reviewed tags
and update the commit log on the other one to add your comment.

Paul.
--

> 
> > 
> > Paul.
> > --
> > 
> > > 
> > > 
> > > >
> > > >Lets remove the couple traces of modularity so that when reading the
> > > >driver there is no doubt it is builtin-only.
> > > >
> > > >Since module_init translates to device_initcall in the non-modular
> > > >case, the init ordering remains unchanged with this commit.
> > > >
> > > >Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> > > >Cc: linux-mm@kvack.org
> > > >Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
> > > >---
> > > > mm/cleancache.c | 4 ++--
> > > > 1 file changed, 2 insertions(+), 2 deletions(-)
> > > >
> > > >diff --git a/mm/cleancache.c b/mm/cleancache.c
> > > >index 8fc50811119b..ee0646d1c2fa 100644
> > > >--- a/mm/cleancache.c
> > > >+++ b/mm/cleancache.c
> > > >@@ -11,7 +11,7 @@
> > > >  * This work is licensed under the terms of the GNU GPL, version 2.
> > > >  */
> > > > 
> > > >-#include <linux/module.h>
> > > >+#include <linux/init.h>
> > > > #include <linux/fs.h>
> > > > #include <linux/exportfs.h>
> > > > #include <linux/mm.h>
> > > >@@ -316,4 +316,4 @@ static int __init init_cleancache(void)
> > > > #endif
> > > > 	return 0;
> > > > }
> > > >-module_init(init_cleancache)
> > > >+device_initcall(init_cleancache)
> > > 
> > > 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
