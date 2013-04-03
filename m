Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id A20776B0036
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 09:53:47 -0400 (EDT)
Date: Wed, 3 Apr 2013 13:53:45 +0000
From: Christoph Lameter <cl@linux.com>
Subject: RE: [PATCHv2, RFC 20/30] ramfs: enable transparent huge page cache
In-Reply-To: <alpine.LNX.2.00.1304021422460.19363@eggly.anvils>
Message-ID: <0000013dd02cbd43-c64cd198-7c04-4dfa-acdc-e725c776fed7-000000@email.amazonses.com>
References: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com> <1363283435-7666-21-git-send-email-kirill.shutemov@linux.intel.com> <20130402162813.0B4CBE0085@blue.fi.intel.com> <alpine.LNX.2.00.1304021422460.19363@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Ying Han <yinghan@google.com>, Minchan Kim <minchan@kernel.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, 2 Apr 2013, Hugh Dickins wrote:

> I am strongly in favour of removing that limitation from
> __isolate_lru_page() (and the thread you pointed - thank you - shows Mel
> and Christoph were both in favour too); and note that there is no such
> restriction in the confusingly similar but different isolate_lru_page().

Well the naming could be cleaned up. The fundamental issue with migrating
pages is that all references have to be tracked and updates in a way that
no references can be followed to invalid or stale page contents. If ramfs
does not maintain separate pointers but only relies on pointers already
handled by the migration logic then migration is fine.

> Some people do worry that migrating Mlocked pages would introduce the
> occasional possibility of a minor fault (with migration_entry_wait())
> on an Mlocked region which never faulted before.  I tend to dismiss
> that worry, but maybe I'm wrong to do so: maybe there should be a
> tunable for realtimey people to set, to prohibit page migration from
> mlocked areas; but the default should be to allow it.

Could we have a different way of marking pages "pinned"? This is useful
for various subsystems (like RDMA and various graphics drivers etc) which
need to ensure that virtual address to physical address mappings stay the
same for a prolonged period of time. I think this use case is becoming
more frequent given that offload techniques have to be used these days to
overcome the limits on processor performance.

> The other reason it looks as if ramfs pages cannot be migrated, is
> that it does not set a suitable ->migratepage method, so would be
> handled by fallback_migrate_page(), whose PageDirty test will end
> up failing the migration with -EBUSY or -EINVAL - if I read it
> correctly.

These could be handled the same way that anonymous pages are handled.

> But until ramfs pages can be migrated, they should not be allocated
> with __GFP_MOVABLE.  (I've been writing about the migratability of
> small pages: I expect you have the migratability of THPages in flux.)

I agree.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
