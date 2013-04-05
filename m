From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCHv2, RFC 20/30] ramfs: enable transparent huge page cache
Date: Fri, 5 Apr 2013 16:35:49 +0800
Message-ID: <11346.7749128633$1365150998@news.gmane.org>
References: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1363283435-7666-21-git-send-email-kirill.shutemov@linux.intel.com>
 <20130402162813.0B4CBE0085@blue.fi.intel.com>
 <alpine.LNX.2.00.1304021422460.19363@eggly.anvils>
 <20130403011104.GF16026@blaptop>
 <515E737D.8030204@gmail.com>
 <20130405080106.GB32126@blaptop>
 <515e89d2.e725320a.3a74.7fe7SMTPIN_ADDED_BROKEN@mx.google.com>
 <20130405083112.GD32126@blaptop>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1UO28M-00042Q-O5
	for glkm-linux-mm-2@m.gmane.org; Fri, 05 Apr 2013 10:36:31 +0200
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id E8D316B0027
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 04:36:01 -0400 (EDT)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Fri, 5 Apr 2013 14:02:53 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 0C8471258023
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 14:07:14 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r358ZkuZ5767488
	for <linux-mm@kvack.org>; Fri, 5 Apr 2013 14:05:47 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r358Zp3P008621
	for <linux-mm@kvack.org>; Fri, 5 Apr 2013 19:35:52 +1100
Content-Disposition: inline
In-Reply-To: <20130405083112.GD32126@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Simon Jeons <simon.jeons@gmail.com>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Ying Han <yinghan@google.com>, Christoph Lameter <cl@linux.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Apr 05, 2013 at 05:31:12PM +0900, Minchan Kim wrote:
>Hi Wanpeng,
>
>On Fri, Apr 05, 2013 at 04:22:17PM +0800, Wanpeng Li wrote:
>> On Fri, Apr 05, 2013 at 05:01:06PM +0900, Minchan Kim wrote:
>> >On Fri, Apr 05, 2013 at 02:47:25PM +0800, Simon Jeons wrote:
>> >> Hi Minchan,
>> >> On 04/03/2013 09:11 AM, Minchan Kim wrote:
>> >> >On Tue, Apr 02, 2013 at 03:15:23PM -0700, Hugh Dickins wrote:
>> >> >>On Tue, 2 Apr 2013, Kirill A. Shutemov wrote:
>> >> >>>Kirill A. Shutemov wrote:
>> >> >>>>From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
>> >> >>>>
>> >> >>>>ramfs is the most simple fs from page cache point of view. Let's start
>> >> >>>>transparent huge page cache enabling here.
>> >> >>>>
>> >> >>>>For now we allocate only non-movable huge page. It's not yet clear if
>> >> >>>>movable page is safe here and what need to be done to make it safe.
>> >> >>>>
>> >> >>>>Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>> >> >>>>---
>> >> >>>>  fs/ramfs/inode.c |    6 +++++-
>> >> >>>>  1 file changed, 5 insertions(+), 1 deletion(-)
>> >> >>>>
>> >> >>>>diff --git a/fs/ramfs/inode.c b/fs/ramfs/inode.c
>> >> >>>>index c24f1e1..da30b4f 100644
>> >> >>>>--- a/fs/ramfs/inode.c
>> >> >>>>+++ b/fs/ramfs/inode.c
>> >> >>>>@@ -61,7 +61,11 @@ struct inode *ramfs_get_inode(struct super_block *sb,
>> >> >>>>  		inode_init_owner(inode, dir, mode);
>> >> >>>>  		inode->i_mapping->a_ops = &ramfs_aops;
>> >> >>>>  		inode->i_mapping->backing_dev_info = &ramfs_backing_dev_info;
>> >> >>>>-		mapping_set_gfp_mask(inode->i_mapping, GFP_HIGHUSER);
>> >> >>>>+		/*
>> >> >>>>+		 * TODO: what should be done to make movable safe?
>> >> >>>>+		 */
>> >> >>>>+		mapping_set_gfp_mask(inode->i_mapping,
>> >> >>>>+				GFP_TRANSHUGE & ~__GFP_MOVABLE);
>> >> >>>Hugh, I've found old thread with the reason why we have GFP_HIGHUSER here, not
>> >> >>>GFP_HIGHUSER_MOVABLE:
>> >> >>>
>> >> >>>http://lkml.org/lkml/2006/11/27/156
>> >> >>>
>> >> >>>It seems the origin reason is not longer valid, correct?
>> >> >>Incorrect, I believe: so far as I know, the original reason remains
>> >> >>valid - though it would only require a couple of good small changes
>> >> >>to reverse that - or perhaps you have already made these changes?
>> >> >>
>> >> >>The original reason is that ramfs pages are not migratable,
>> >> >>therefore they should be allocated from an unmovable area.
>> >> >>
>> >> >>As I understand it (and I would have preferred to run a test to check
>> >> >>my understanding before replying, but don't have time for that), ramfs
>> >> >>pages cannot be migrated for two reasons, neither of them a good reason.
>> >> >>
>> >> >>One reason (okay, it wouldn't have been quite this way in 2006) is that
>> >> >>ramfs (rightly) calls mapping_set_unevictable(), so its pages will fail
>> >> >>the page_evictable() test, so they will be marked PageUnevictable, so
>> >> >>__isolate_lru_page() will refuse to isolate them for migration (except
>> >> >>for CMA).
>> >> >True.
>> >> >
>> >> >>I am strongly in favour of removing that limitation from
>> >> >>__isolate_lru_page() (and the thread you pointed - thank you - shows Mel
>> >> >>and Christoph were both in favour too); and note that there is no such
>> >> >>restriction in the confusingly similar but different isolate_lru_page().
>> >> >>
>> >> >>Some people do worry that migrating Mlocked pages would introduce the
>> >> >>occasional possibility of a minor fault (with migration_entry_wait())
>> >> >>on an Mlocked region which never faulted before.  I tend to dismiss
>> >> >>that worry, but maybe I'm wrong to do so: maybe there should be a
>> >> >>tunable for realtimey people to set, to prohibit page migration from
>> >> >>mlocked areas; but the default should be to allow it.
>> >> >I agree.
>> >> >Just FYI for mlocked page migration
>> >> >
>> >> >I tried migratioin of mlocked page and Johannes and Mel had a concern
>> >> >about that.
>> >> >http://lkml.indiana.edu/hypermail/linux/kernel/1109.0/00175.html
>> >> >
>> >> >But later, Peter already acked it and I guess by reading the thread that
>> >> >Hugh was in favour when page migration was merged first time.
>> >> >
>> >> >http://marc.info/?l=linux-mm&m=133697873414205&w=2
>> >> >http://marc.info/?l=linux-mm&m=133700341823358&w=2
>> >> >
>> >> >Many people said mlock means memory-resident, NOT pinning so it could
>> >> >allow minor fault while Mel still had a concern except CMA.
>> >> >http://marc.info/?l=linux-mm&m=133674219714419&w=2
>> >> 
>> >> How about add a knob?
>> >
>> >Maybe, volunteering?
>> 
>> Hi Minchan,
>> 
>> I can be the volunteer, what I care is if add a knob make sense?
>
>Frankly sepaking, I'd like to avoid new knob but there might be
>some workloads suffered from mlocked page migration so we coudn't
>dismiss it. In such case, introducing the knob would be a solution
>with default enabling. If we don't have any report for a long time,
>we can remove the knob someday, IMHO.

Ok, I will start coding next week. ;-)

Regards,
Wanpeng Li 

>
>Thanks.
>
>-- 
>Kind regards,
>Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
