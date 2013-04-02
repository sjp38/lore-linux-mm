Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id DBCA96B0002
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 10:44:57 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <514C6E68.4050203@sr71.net>
References: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1363283435-7666-8-git-send-email-kirill.shutemov@linux.intel.com>
 <514B336C.6070404@sr71.net>
 <20130322101211.34A5EE0085@blue.fi.intel.com>
 <514C6E68.4050203@sr71.net>
Subject: Re: [PATCHv2, RFC 07/30] thp, mm: introduce
 mapping_can_have_hugepages() predicate
Content-Transfer-Encoding: 7bit
Message-Id: <20130402144648.47240E0085@blue.fi.intel.com>
Date: Tue,  2 Apr 2013 17:46:48 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Dave Hansen wrote:
> On 03/22/2013 03:12 AM, Kirill A. Shutemov wrote:
> > Dave Hansen wrote:
> >> On 03/14/2013 10:50 AM, Kirill A. Shutemov wrote:
> >>> +static inline bool mapping_can_have_hugepages(struct address_space *m)
> >>> +{
> >>> +	if (IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE)) {
> >>> +		gfp_t gfp_mask = mapping_gfp_mask(m);
> >>> +		return !!(gfp_mask & __GFP_COMP);
> >>> +	}
> >>> +
> >>> +	return false;
> >>> +}
> >>
> >> I did a quick search in all your patches and don't see __GFP_COMP
> >> getting _set_ anywhere.  Am I missing something?
> > 
> > __GFP_COMP is part of GFP_TRANSHUGE. We set it for ramfs in patch 20/30.
> 
> That's a bit non-obvious.  For a casual observer, it _seems_ like you
> should just be setting and checking GFP_TRANSHUGE directly.  It looks
> like you were having some problems with __GFP_MOVABLE and masked it out
> of GFP_TRANSHUGE and that has cascaded over to _this_ check.

Checking GFP_TRANSHUGE directly is not right way. File systems can clear
GFP bits or set additional for its own reason. We should not limit file
systems here.

So the only way robust way is to check __GFP_COMP. I'll add comment.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
