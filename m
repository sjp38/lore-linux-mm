Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 789C26B0009
	for <linux-mm@kvack.org>; Wed, 10 Feb 2016 06:23:00 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id p63so21932877wmp.1
        for <linux-mm@kvack.org>; Wed, 10 Feb 2016 03:23:00 -0800 (PST)
Received: from mail-wm0-x22d.google.com (mail-wm0-x22d.google.com. [2a00:1450:400c:c09::22d])
        by mx.google.com with ESMTPS id yn6si3999411wjc.37.2016.02.10.03.22.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Feb 2016 03:22:59 -0800 (PST)
Received: by mail-wm0-x22d.google.com with SMTP id p63so21932304wmp.1
        for <linux-mm@kvack.org>; Wed, 10 Feb 2016 03:22:59 -0800 (PST)
Date: Wed, 10 Feb 2016 13:22:57 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] thp, vmstats: count deferred split events
Message-ID: <20160210112256.GA26440@node.shutemov.name>
References: <1455009302-57702-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20160209132012.db18cdd7203b1d8b29483657@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160209132012.db18cdd7203b1d8b29483657@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org

On Tue, Feb 09, 2016 at 01:20:12PM -0800, Andrew Morton wrote:
> On Tue,  9 Feb 2016 12:15:02 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> 
> > Counts how many times we put a THP in split queue. Currently, it happens
> > on partial unmap of a THP.
> 
> Why do we need this?

Rapidly growing value can indicate that an application behaves
unfriendly wrt THP: often fault in huge page and then unmap part of it.
This leads to unnecessary memory fragmentation and the application may
require tuning.

Before refcouting rework thp_split_page would indicate the same. Not so much
now as we don't split huge pages that often.
 
The event also can help with debugging kernel [mis-]behaviour.

> > --- a/mm/vmstat.c
> > +++ b/mm/vmstat.c
> > @@ -847,6 +847,7 @@ const char * const vmstat_text[] = {
> >  	"thp_collapse_alloc_failed",
> >  	"thp_split_page",
> >  	"thp_split_page_failed",
> > +	"thp_deferred_split_page",
> >  	"thp_split_pmd",
> >  	"thp_zero_page_alloc",
> >  	"thp_zero_page_alloc_failed",
> 
> Documentation/vm/transhuge.txt, please. 

Updated patch is below.

> While you're in there please > check that we haven't missed anything else.

The rest of the documents is up-to-date.
