Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 08C1D6B0027
	for <linux-mm@kvack.org>; Fri, 22 Mar 2013 10:50:11 -0400 (EDT)
Message-ID: <514C6FF3.9040806@sr71.net>
Date: Fri, 22 Mar 2013 07:51:31 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCHv2, RFC 08/30] thp, mm: rewrite add_to_page_cache_locked()
 to support huge pages
References: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com> <1363283435-7666-9-git-send-email-kirill.shutemov@linux.intel.com> <514B3F24.3070006@sr71.net> <20130322103438.46C5FE0085@blue.fi.intel.com>
In-Reply-To: <20130322103438.46C5FE0085@blue.fi.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 03/22/2013 03:34 AM, Kirill A. Shutemov wrote:
> Dave Hansen wrote:
>> On 03/14/2013 10:50 AM, Kirill A. Shutemov wrote:
>>> +			error = radix_tree_insert(&mapping->page_tree,
>>> +					offset + i, page + i);
>>> +			if (error) {
>>> +				page_cache_release(page + i);
>>> +				break;
>>> +			}
>>>  		}
>>
>> Throughout all this new code, I'd really challenge you to try as much as
>> possible to minimize the code stuck under "if (PageTransHuge(page))".
> 
> I put thp-related code under the 'if' intentionally to be able to optimize
> it out if !CONFIG_TRANSPARENT_HUGEPAGE. The config option is disabled by
> default.

You've gotta give the compiler some credit! :)  In this function's case,
the compiler should be able to realize that nr=1 is constant if
!TRANSPARENT_HUGEPAGE.  It'll realize that all your for loops are:

	for (i = 0; i < 1; i++) {

and will end up generating _very_ similar code to what you get with the
explicit #ifdefs.  You already _have_ #ifdefs, but they're just up in
the headers around PageTransHuge()'s definition.

The advantages for you are *huge* since it means that folks will have a
harder time inadvertently breaking your CONFIG_TRANSPARENT_HUGEPAGE code.

>> Does the cgroup code know how to handle these large pages internally
>> somehow?  It looks like the charge/uncharge is only being done for the
>> head page.
> 
> It can. We only need to remove PageCompound() check there. Patch is in
> git.

OK, cool.  This _might_ deserve a comment or something here.  Again, it
looks asymmetric and fishy to someone just reading the code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
