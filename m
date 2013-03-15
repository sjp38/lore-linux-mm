Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 3FE2D6B0037
	for <linux-mm@kvack.org>; Fri, 15 Mar 2013 09:25:21 -0400 (EDT)
Received: by mail-oa0-f48.google.com with SMTP id j1so3361600oag.35
        for <linux-mm@kvack.org>; Fri, 15 Mar 2013 06:25:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130315132333.B8205E0085@blue.fi.intel.com>
References: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1363283435-7666-9-git-send-email-kirill.shutemov@linux.intel.com>
	<CAJd=RBAH1+YaDvL9=ayx2j6b4jx0CzBZGrAL9LVwPMx4Y=s3Rg@mail.gmail.com>
	<20130315132333.B8205E0085@blue.fi.intel.com>
Date: Fri, 15 Mar 2013 21:25:20 +0800
Message-ID: <CAJd=RBAh7-qBYhCxtj56V5sez1HSek9TNVeu9V=+mW0qNpxEWA@mail.gmail.com>
Subject: Re: [PATCHv2, RFC 08/30] thp, mm: rewrite add_to_page_cache_locked()
 to support huge pages
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Mar 15, 2013 at 9:23 PM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> Hillf Danton wrote:
>> On Fri, Mar 15, 2013 at 1:50 AM, Kirill A. Shutemov
>> <kirill.shutemov@linux.intel.com> wrote:
>> > +       page_cache_get(page);
>> > +       spin_lock_irq(&mapping->tree_lock);
>> > +       page->mapping = mapping;
>> > +       page->index = offset;
>> > +       error = radix_tree_insert(&mapping->page_tree, offset, page);
>> > +       if (unlikely(error))
>> > +               goto err;
>> > +       if (PageTransHuge(page)) {
>> > +               int i;
>> > +               for (i = 1; i < HPAGE_CACHE_NR; i++) {
>>                       struct page *tail = page + i; to easy reader
>>
>> > +                       page_cache_get(page + i);
>> s/page_cache_get/get_page_foll/ ?
>
> Why?
>
see follow_trans_huge_pmd() please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
