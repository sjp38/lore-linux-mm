Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 195646B0027
	for <linux-mm@kvack.org>; Fri, 22 Mar 2013 10:43:37 -0400 (EDT)
Message-ID: <514C6E68.4050203@sr71.net>
Date: Fri, 22 Mar 2013 07:44:56 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCHv2, RFC 07/30] thp, mm: introduce mapping_can_have_hugepages()
 predicate
References: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com> <1363283435-7666-8-git-send-email-kirill.shutemov@linux.intel.com> <514B336C.6070404@sr71.net> <20130322101211.34A5EE0085@blue.fi.intel.com>
In-Reply-To: <20130322101211.34A5EE0085@blue.fi.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 03/22/2013 03:12 AM, Kirill A. Shutemov wrote:
> Dave Hansen wrote:
>> On 03/14/2013 10:50 AM, Kirill A. Shutemov wrote:
>>> +static inline bool mapping_can_have_hugepages(struct address_space *m)
>>> +{
>>> +	if (IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE)) {
>>> +		gfp_t gfp_mask = mapping_gfp_mask(m);
>>> +		return !!(gfp_mask & __GFP_COMP);
>>> +	}
>>> +
>>> +	return false;
>>> +}
>>
>> I did a quick search in all your patches and don't see __GFP_COMP
>> getting _set_ anywhere.  Am I missing something?
> 
> __GFP_COMP is part of GFP_TRANSHUGE. We set it for ramfs in patch 20/30.

That's a bit non-obvious.  For a casual observer, it _seems_ like you
should just be setting and checking GFP_TRANSHUGE directly.  It looks
like you were having some problems with __GFP_MOVABLE and masked it out
of GFP_TRANSHUGE and that has cascaded over to _this_ check.

I _think_ the right thing to do is add a comment up there in
mapping_can_have_hugepages() that does (GFP_TRANSHUGE & ~__GFP_MOVABLE),
and adds a TODO in the code and patch comments to clean it up once
ramfs_get_inode() gets fixed up too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
