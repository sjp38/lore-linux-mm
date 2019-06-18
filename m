Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 93A39C31E5B
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 20:59:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 560B920873
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 20:59:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="dRPi+E6V"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 560B920873
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DFF0B6B0005; Tue, 18 Jun 2019 16:59:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DD6468E0002; Tue, 18 Jun 2019 16:59:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CC5658E0001; Tue, 18 Jun 2019 16:59:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 966276B0005
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 16:59:23 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id b24so8471228plz.20
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 13:59:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=cpaWp8i1mrnSD2hd7fCuJtJFVJXs8j4rKfn1nE3Cl+I=;
        b=C9hXAmZ1cKWzZQlj3LKFi5dm8JCvQGwDlbVCxbc4q/HlIw+LRkZ08SUztbTE0coWYD
         7jjz8cfh98cnxHfXMN124B1lrzQETpzj6BIgAkYe14ElttmfS0fgXYub2mcbSsA8TKdr
         XwEFMpOPzihKE2qx3fOVMgHhOZWY73xjKxz8rjyKl4xHT6Ixzvh3G9/GGpQbEO4IfSxq
         OhiAptNlC3bJ+bAze0DfaezJ0KyXacDT6qZseonP118jf3/CN91Xi8k2ilN13qmEWrFo
         SzvdXtaaPL/g2joc/yfctlP86cJ8xQBNsRJ/hOsKcyI0a/3JGXtpBYS8LXtbMhklrZpa
         aZpg==
X-Gm-Message-State: APjAAAXCeEx/kB9ybtSgypu7Gvl9Py+qfsI7Bz/AvslMcC2BiLPJkGul
	slnJt4cBq0OopNeu5KXSqoBGC/2KFsDmnWEJ7+DFbnbNnwGl6h8MdYNx63KMLnutHU9QzCwm5A8
	jQkkJeWvfyklbWral/Le2KWxNUkG9wHAhdshmNP2Zuxr5fK0+mYzCFEXFS7axULcyew==
X-Received: by 2002:a63:574b:: with SMTP id h11mr4601660pgm.25.1560891563051;
        Tue, 18 Jun 2019 13:59:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwX70VzXMwFGicOFTQyGTZCNwuERbqV6qS5csaX2oGiePGIninNOU5MTqCKc68fX3a9dYZi
X-Received: by 2002:a63:574b:: with SMTP id h11mr4601608pgm.25.1560891562326;
        Tue, 18 Jun 2019 13:59:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560891562; cv=none;
        d=google.com; s=arc-20160816;
        b=YnVncfF8MdEAjUHRiM9czpsely86w0tiIg9GPLAkiMXVg00sVFG+/pYpJs2+w/32Bm
         jCJ7JTrLO9P8RdYIhNKSfRyjzVFuxs58hR5/RqNOOCGewnNwM1IjSSTA2Q1xaNfqUy8T
         prfIDBAlsqy0toFXsBri+9W3KU+0ckpzIBdZrkr/AmZFDJw/9EzsI0kuetQoVOEH7bPM
         gUhi4KzXdTMLoZaOgFEXx2JwnzWAreVQHOj8UE1M/qRgz5a/NC9iFbcZh4MF4E1OKZno
         uS+/tx6AOCumw02Tg2jIbBWKy+w4mm8Bv3RvEOUenbqX/AUj8UoCIGZMc4iKCUqiJ4HE
         jNpQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=cpaWp8i1mrnSD2hd7fCuJtJFVJXs8j4rKfn1nE3Cl+I=;
        b=ccT4oVHxEg3G/xlfoFe+KkfGKNCMMH/jA2oJSztre1nhSPRneKuQIkFKQtIqPH/FBQ
         vcOSpFy/XRLIkR2VZqjEQVIJj++QWIYCj02R+FmvEQeuq/B4JAg89HmwG7q+ZeXD8eB+
         vvpTTQSILoyx9qkZpssFYIEKMWNNK+YfVqXk09HSMoub7ePV3tmChkzculyFHSjdBwln
         A/UhSMoJoqsG9K02qGz32/BnR4OpK31py8x69BarKN0yDAG6Qsn33oYiuXrF2whpLiW7
         xujsh4S1MyiAdP9gVEJn+pIBo7iodYLvRlJOuAwmGYFsL9+sIFNC9ljIpSHk2fyxWhn4
         ippA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=dRPi+E6V;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id f1si1137900pgi.432.2019.06.18.13.59.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 13:59:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=dRPi+E6V;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 57C2C20863;
	Tue, 18 Jun 2019 20:59:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1560891562;
	bh=OKekjAHMHDSKBX7i8AEyG++qk2Jq9H3Y71jv2y4IdLU=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=dRPi+E6V6BOa4jcRdwiJTpkttXzbzF7JzL+etbTckkndfBqAq8OEfjCMcljvaUl5A
	 Y0dguz5W/QAQY/rZu34ZBxhJDhgFbNBRj3YPGSV5CsXkQLhMnGgPxgOMaInyd2e2yY
	 /VadGoXzYEJuUjtFcTrb9+vrKqIoxTcf+93+SKaU=
Date: Tue, 18 Jun 2019 13:59:20 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Uladzislau Rezki <urezki@gmail.com>
Cc: Joel Fernandes <joelaf@google.com>, Arnd Bergmann <arnd@arndb.de>, Roman
 Penyaev <rpenyaev@suse.de>, "open list:MEMORY MANAGEMENT"
 <linux-mm@kvack.org>, Roman Gushchin <guro@fb.com>, Michal Hocko
 <mhocko@suse.com>, Matthew Wilcox <willy@infradead.org>, Thomas Garnier
 <thgarnie@google.com>, Oleksiy Avramchenko
 <oleksiy.avramchenko@sonymobile.com>, Steven Rostedt <rostedt@goodmis.org>,
 Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Tejun
 Heo <tj@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Rick
 Edgecombe <rick.p.edgecombe@intel.com>, Andrey Ryabinin
 <aryabinin@virtuozzo.com>, Mike Rapoport <rppt@linux.ibm.com>, LKML
 <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] mm/vmalloc: avoid bogus -Wmaybe-uninitialized warning
Message-Id: <20190618135920.9dd7bdc78fc0ce33ee65d99c@linux-foundation.org>
In-Reply-To: <20190618140622.bbak3is7yv32hfjn@pc636>
References: <20190618092650.2943749-1-arnd@arndb.de>
	<CAJWu+oqzd8MJqusRV0LAK=Xnm7VSRSu3QbNZ-j5h9_MbzcFhhg@mail.gmail.com>
	<20190618140622.bbak3is7yv32hfjn@pc636>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 18 Jun 2019 16:06:22 +0200 Uladzislau Rezki <urezki@gmail.com> wrote:

> On Tue, Jun 18, 2019 at 09:40:28AM -0400, Joel Fernandes wrote:
> > On Tue, Jun 18, 2019 at 5:27 AM Arnd Bergmann <arnd@arndb.de> wrote:
> > >
> > > gcc gets confused in pcpu_get_vm_areas() because there are too many
> > > branches that affect whether 'lva' was initialized before it gets
> > > used:
> > >
> > > mm/vmalloc.c: In function 'pcpu_get_vm_areas':
> > > mm/vmalloc.c:991:4: error: 'lva' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> > >     insert_vmap_area_augment(lva, &va->rb_node,
> > >     ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> > >      &free_vmap_area_root, &free_vmap_area_list);
> > >      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> > > mm/vmalloc.c:916:20: note: 'lva' was declared here
> > >   struct vmap_area *lva;
> > >                     ^~~
> > >
> > > Add an intialization to NULL, and check whether this has changed
> > > before the first use.
> > >
> > > Fixes: 68ad4a330433 ("mm/vmalloc.c: keep track of free blocks for vmap allocation")
> > > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> > > ---
> > >  mm/vmalloc.c | 9 +++++++--
> > >  1 file changed, 7 insertions(+), 2 deletions(-)
> > >
> > > diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> > > index a9213fc3802d..42a6f795c3ee 100644
> > > --- a/mm/vmalloc.c
> > > +++ b/mm/vmalloc.c
> > > @@ -913,7 +913,12 @@ adjust_va_to_fit_type(struct vmap_area *va,
> > >         unsigned long nva_start_addr, unsigned long size,
> > >         enum fit_type type)
> > >  {
> > > -       struct vmap_area *lva;
> > > +       /*
> > > +        * GCC cannot always keep track of whether this variable
> > > +        * was initialized across many branches, therefore set
> > > +        * it NULL here to avoid a warning.
> > > +        */
> > > +       struct vmap_area *lva = NULL;
> > 
> > Fair enough, but is this 5-line comment really needed here?
> > 
> How it is rewritten now, probably not. I would just set it NULL and
> leave the comment, but that is IMHO. Anyway
> 

I agree - given that the patch does this:

@@ -972,7 +977,7 @@ adjust_va_to_fit_type(struct vmap_area *
 	if (type != FL_FIT_TYPE) {
 		augment_tree_propagate_from(va);
 
-		if (type == NE_FIT_TYPE)
+		if (lva)
 			insert_vmap_area_augment(lva, &va->rb_node,
 				&free_vmap_area_root, &free_vmap_area_list);
 	}

the comment simply isn't relevant any more.  Although I guess this
might be a bit helpful:

@@ -977,7 +972,7 @@ adjust_va_to_fit_type(struct vmap_area *
 	if (type != FL_FIT_TYPE) {
 		augment_tree_propagate_from(va);
 
-		if (lva)
+		if (lva)	/* type == NE_FIT_TYPE */
 			insert_vmap_area_augment(lva, &va->rb_node,
 				&free_vmap_area_root, &free_vmap_area_list);
 	}

