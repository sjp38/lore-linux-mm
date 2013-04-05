Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id DA25C6B0005
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 02:47:35 -0400 (EDT)
Received: by mail-ob0-f175.google.com with SMTP id va7so3347065obc.20
        for <linux-mm@kvack.org>; Thu, 04 Apr 2013 23:47:34 -0700 (PDT)
Message-ID: <515E737D.8030204@gmail.com>
Date: Fri, 05 Apr 2013 14:47:25 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCHv2, RFC 20/30] ramfs: enable transparent huge page cache
References: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com> <1363283435-7666-21-git-send-email-kirill.shutemov@linux.intel.com> <20130402162813.0B4CBE0085@blue.fi.intel.com> <alpine.LNX.2.00.1304021422460.19363@eggly.anvils> <20130403011104.GF16026@blaptop>
In-Reply-To: <20130403011104.GF16026@blaptop>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Ying Han <yinghan@google.com>, Christoph Lameter <cl@linux.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Hi Minchan,
On 04/03/2013 09:11 AM, Minchan Kim wrote:
> On Tue, Apr 02, 2013 at 03:15:23PM -0700, Hugh Dickins wrote:
>> On Tue, 2 Apr 2013, Kirill A. Shutemov wrote:
>>> Kirill A. Shutemov wrote:
>>>> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
>>>>
>>>> ramfs is the most simple fs from page cache point of view. Let's start
>>>> transparent huge page cache enabling here.
>>>>
>>>> For now we allocate only non-movable huge page. It's not yet clear if
>>>> movable page is safe here and what need to be done to make it safe.
>>>>
>>>> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>>>> ---
>>>>   fs/ramfs/inode.c |    6 +++++-
>>>>   1 file changed, 5 insertions(+), 1 deletion(-)
>>>>
>>>> diff --git a/fs/ramfs/inode.c b/fs/ramfs/inode.c
>>>> index c24f1e1..da30b4f 100644
>>>> --- a/fs/ramfs/inode.c
>>>> +++ b/fs/ramfs/inode.c
>>>> @@ -61,7 +61,11 @@ struct inode *ramfs_get_inode(struct super_block *sb,
>>>>   		inode_init_owner(inode, dir, mode);
>>>>   		inode->i_mapping->a_ops = &ramfs_aops;
>>>>   		inode->i_mapping->backing_dev_info = &ramfs_backing_dev_info;
>>>> -		mapping_set_gfp_mask(inode->i_mapping, GFP_HIGHUSER);
>>>> +		/*
>>>> +		 * TODO: what should be done to make movable safe?
>>>> +		 */
>>>> +		mapping_set_gfp_mask(inode->i_mapping,
>>>> +				GFP_TRANSHUGE & ~__GFP_MOVABLE);
>>> Hugh, I've found old thread with the reason why we have GFP_HIGHUSER here, not
>>> GFP_HIGHUSER_MOVABLE:
>>>
>>> http://lkml.org/lkml/2006/11/27/156
>>>
>>> It seems the origin reason is not longer valid, correct?
>> Incorrect, I believe: so far as I know, the original reason remains
>> valid - though it would only require a couple of good small changes
>> to reverse that - or perhaps you have already made these changes?
>>
>> The original reason is that ramfs pages are not migratable,
>> therefore they should be allocated from an unmovable area.
>>
>> As I understand it (and I would have preferred to run a test to check
>> my understanding before replying, but don't have time for that), ramfs
>> pages cannot be migrated for two reasons, neither of them a good reason.
>>
>> One reason (okay, it wouldn't have been quite this way in 2006) is that
>> ramfs (rightly) calls mapping_set_unevictable(), so its pages will fail
>> the page_evictable() test, so they will be marked PageUnevictable, so
>> __isolate_lru_page() will refuse to isolate them for migration (except
>> for CMA).
> True.
>
>> I am strongly in favour of removing that limitation from
>> __isolate_lru_page() (and the thread you pointed - thank you - shows Mel
>> and Christoph were both in favour too); and note that there is no such
>> restriction in the confusingly similar but different isolate_lru_page().
>>
>> Some people do worry that migrating Mlocked pages would introduce the
>> occasional possibility of a minor fault (with migration_entry_wait())
>> on an Mlocked region which never faulted before.  I tend to dismiss
>> that worry, but maybe I'm wrong to do so: maybe there should be a
>> tunable for realtimey people to set, to prohibit page migration from
>> mlocked areas; but the default should be to allow it.
> I agree.
> Just FYI for mlocked page migration
>
> I tried migratioin of mlocked page and Johannes and Mel had a concern
> about that.
> http://lkml.indiana.edu/hypermail/linux/kernel/1109.0/00175.html
>
> But later, Peter already acked it and I guess by reading the thread that
> Hugh was in favour when page migration was merged first time.
>
> http://marc.info/?l=linux-mm&m=133697873414205&w=2
> http://marc.info/?l=linux-mm&m=133700341823358&w=2
>
> Many people said mlock means memory-resident, NOT pinning so it could
> allow minor fault while Mel still had a concern except CMA.
> http://marc.info/?l=linux-mm&m=133674219714419&w=2

How about add a knob?

>> (Of course, we could separate ramfs's mapping_unevictable case from
>> the Mlocked case; but I'd prefer to continue to treat them the same.)
> Fair enough.
>
>> The other reason it looks as if ramfs pages cannot be migrated, is
>> that it does not set a suitable ->migratepage method, so would be
>> handled by fallback_migrate_page(), whose PageDirty test will end
>> up failing the migration with -EBUSY or -EINVAL - if I read it
>> correctly.
> True.
>
>> Perhaps other such reasons would surface once those are fixed.
>> But until ramfs pages can be migrated, they should not be allocated
>> with __GFP_MOVABLE.  (I've been writing about the migratability of
>> small pages: I expect you have the migratability of THPages in flux.)
> Agreed.
>
>> Hugh
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
