Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 3D99D6B003C
	for <linux-mm@kvack.org>; Tue, 28 May 2013 12:33:40 -0400 (EDT)
Message-ID: <51A4DC5F.7050406@sr71.net>
Date: Tue, 28 May 2013 09:33:35 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCHv4 15/39] thp, mm: trigger bug in replace_page_cache_page()
 on THP
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com> <1368321816-17719-16-git-send-email-kirill.shutemov@linux.intel.com> <519BD65C.1050709@sr71.net> <20130528125328.5385CE0090@blue.fi.intel.com>
In-Reply-To: <20130528125328.5385CE0090@blue.fi.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 05/28/2013 05:53 AM, Kirill A. Shutemov wrote:
> Dave Hansen wrote:
>> On 05/11/2013 06:23 PM, Kirill A. Shutemov wrote:
>>> +	VM_BUG_ON(PageTransHuge(old));
>>> +	VM_BUG_ON(PageTransHuge(new));
>>>  	VM_BUG_ON(!PageLocked(old));
>>>  	VM_BUG_ON(!PageLocked(new));
>>>  	VM_BUG_ON(new->mapping);
>>
>> The code calling replace_page_cache_page() has a bunch of fallback and
>> error returning code.  It seems a little bit silly to bring the whole
>> machine down when you could just WARN_ONCE() and return an error code
>> like fuse already does:
> 
> What about:
> 
> 	if (WARN_ONCE(PageTransHuge(old) || PageTransHuge(new),
> 		     "%s: unexpected huge page\n", __func__))
> 		return -EINVAL;

That looks sane to me.  But, please do make sure to differentiate in the
error message between thp and hugetlbfs (if you have the room).

BTW, I'm also not sure you need to print the function name.  The
WARN_ON() register dump usually has the function name.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
