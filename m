Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f197.google.com (mail-lb0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6645F6B025F
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 12:28:06 -0400 (EDT)
Received: by mail-lb0-f197.google.com with SMTP id c1so2046378lbw.0
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 09:28:06 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id x9si10256618wmg.67.2016.06.17.09.28.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jun 2016 09:28:05 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id 187so926657wmz.1
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 09:28:04 -0700 (PDT)
Date: Fri, 17 Jun 2016 18:28:03 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/3] mm: Don't blindly assign fallback_migrate_page()
Message-ID: <20160617162803.GK21670@dhcp22.suse.cz>
References: <1466112375-1717-1-git-send-email-richard@nod.at>
 <1466112375-1717-2-git-send-email-richard@nod.at>
 <20160616161121.35ee5183b9ef9f7b7dcbc815@linux-foundation.org>
 <5763A9B2.8060303@nod.at>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5763A9B2.8060303@nod.at>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Weinberger <richard@nod.at>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-mtd@lists.infradead.org, hannes@cmpxchg.org, mgorman@techsingularity.net, n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, hughd@google.com, vbabka@suse.cz, adrian.hunter@intel.com, dedekind1@gmail.com, hch@infradead.org, linux-fsdevel@vger.kernel.org, boris.brezillon@free-electrons.com, maxime.ripard@free-electrons.com, david@sigma-star.at, david@fromorbit.com, alex@nextthing.co, sasha.levin@oracle.com, iamjoonsoo.kim@lge.com, rvaswani@codeaurora.org, tony.luck@intel.com, shailendra.capricorn@gmail.com

On Fri 17-06-16 09:41:38, Richard Weinberger wrote:
> Andrew,
> 
> Am 17.06.2016 um 01:11 schrieb Andrew Morton:
> > On Thu, 16 Jun 2016 23:26:13 +0200 Richard Weinberger <richard@nod.at> wrote:
> > 
> >> While block oriented filesystems use buffer_migrate_page()
> >> as page migration function other filesystems which don't
> >> implement ->migratepage() will automatically get fallback_migrate_page()
> >> assigned. fallback_migrate_page() is not as generic as is should
> >> be. Page migration is filesystem specific and a one-fits-all function
> >> is hard to achieve. UBIFS leaned this lection the hard way.
> >> It uses various page flags and fallback_migrate_page() does not
> >> handle these flags as UBIFS expected.
> >>
> >> To make sure that no further filesystem will get confused by
> >> fallback_migrate_page() disable the automatic assignment and
> >> allow filesystems to use this function explicitly if it is
> >> really suitable.
> > 
> > hm, is there really much point in doing this?  I assume it doesn't
> > actually affect any current filesystems?
> 
> Well, we simply don't know which filesystems are affected by similar issues.

But doesn't this disable the page migration and so potentially reduce
the compaction success rate for the large pile of filesystems? Without
any hint about that?

$ git grep "\.migratepage[[:space:]]*=" -- fs | wc -l
16
out of
$ git grep "struct address_space_operations[[:space:]]*[a-zA-Z0-9_]*[[:space:]]*=" -- fs | wc -l
87

That just seems to be too conservative for something that even not might
be a problem, especially when considering the fallback migration code is
there for many years with only UBIFS seeing a problem.

Wouldn't it be safer to contact FS developers who might have have
similar issue and work with them to use a proper migration code?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
