Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7D0AE6B0005
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 23:26:29 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id q2so2181087pgf.22
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 20:26:29 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id w66sor1934369pfj.12.2018.01.30.20.26.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Jan 2018 20:26:28 -0800 (PST)
Date: Tue, 30 Jan 2018 20:26:19 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [RFC] mm/migrate: Consolidate page allocation helper functions
In-Reply-To: <53cf5454-405b-a812-1389-af4fd7527122@linux.vnet.ibm.com>
Message-ID: <alpine.LSU.2.11.1801302000200.8014@eggly.anvils>
References: <20180130050642.19834-1-khandual@linux.vnet.ibm.com> <20180130143635.GF21609@dhcp22.suse.cz> <53cf5454-405b-a812-1389-af4fd7527122@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org

On Wed, 31 Jan 2018, Anshuman Khandual wrote:
> On 01/30/2018 08:06 PM, Michal Hocko wrote:
> > On Tue 30-01-18 10:36:42, Anshuman Khandual wrote:
> >> Allocation helper functions for migrate_pages() remmain scattered with
> >> similar names making them really confusing. Rename these functions based
> >> on the context for the migration and move them all into common migration
> >> header. Functionality remains unchanged.

I agree that their names could be made less confusing (though didn't
succeed very well when I tried); and maybe a couple of them are general
enough to be used from more than one callsite, and could well live in
mm/migrate.c.

But moving all of page migration's (currently static) new_page allocator
functions away from the code that relies on their special characteristics
(probably relayed to them through a private argument), and into a single
header file, just seems perverse to me.  And likely to be a nuisance when
adding more in future: private structures having to be made public just
to make them visible in that shared header file.

Would it make sense to keep the various functions that may be called by
rmap_walk() together in one rmap_walk.h?  The different filesystems'
writepage methods together in one writepage.h?  I don't think so.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
