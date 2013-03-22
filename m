Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id A3CD36B0027
	for <linux-mm@kvack.org>; Fri, 22 Mar 2013 10:37:09 -0400 (EDT)
Message-ID: <514C6CE3.5080201@sr71.net>
Date: Fri, 22 Mar 2013 07:38:27 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCHv2, RFC 04/30] radix-tree: implement preload for multiple
 contiguous elements
References: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com> <1363283435-7666-5-git-send-email-kirill.shutemov@linux.intel.com> <514B2D94.8040206@sr71.net> <20130322094745.E20D9E0085@blue.fi.intel.com>
In-Reply-To: <20130322094745.E20D9E0085@blue.fi.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 03/22/2013 02:47 AM, Kirill A. Shutemov wrote:
> Dave Hansen wrote:
>> On 03/14/2013 10:50 AM, Kirill A. Shutemov wrote:
>>> +#define RADIX_TREE_PRELOAD_NR		512 /* For THP's benefit */
>>
>> This eventually boils down to making the radix_tree_preload array
>> larger.  Do we really want to do this unconditionally if it's only for
>> THP's benefit?
> 
> It will be useful not only for THP. Batching can be useful to solve
> scalability issues.

Still, it seems like something that little machines with no THP support
probably don't want to pay the cost for.  Perhaps you could enable it
for THP||NR_CPUS>$FOO.

>> For those of us too lazy to go compile a kernel and figure this out in
>> practice, how much bigger does this make the nodes[] array?
> 
> We have three possible RADIX_TREE_MAP_SHIFT:
> 
> #ifdef __KERNEL__
> #define RADIX_TREE_MAP_SHIFT	(CONFIG_BASE_SMALL ? 4 : 6)
> #else
> #define RADIX_TREE_MAP_SHIFT	3	/* For more stressful testing */
> #endif
> 
> On 64-bit system:
> For RADIX_TREE_MAP_SHIFT=3, old array size is 43, new is 107.
> For RADIX_TREE_MAP_SHIFT=4, old array size is 31, new is 63.
> For RADIX_TREE_MAP_SHIFT=6, old array size is 21, new is 30.
> 
> On 32-bit system:
> For RADIX_TREE_MAP_SHIFT=3, old array size is 21, new is 84.
> For RADIX_TREE_MAP_SHIFT=4, old array size is 15, new is 46.
> For RADIX_TREE_MAP_SHIFT=6, old array size is 11, new is 19.
> 
> On most machines we will have RADIX_TREE_MAP_SHIFT=6.

Could you stick that in your patch description?  The total cost is
"array size" * sizeof(void*) * NR_CPUS, right?

-- Dave Hansen, Intel OTC Scalability Team

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
