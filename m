Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6861B6B0253
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 13:34:51 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id d28so5381330pfe.2
        for <linux-mm@kvack.org>; Wed, 11 Oct 2017 10:34:51 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id l197si10521165pga.371.2017.10.11.10.34.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Oct 2017 10:34:49 -0700 (PDT)
Subject: Re: [PATCH 0/7 v1] Speed up page cache truncation
References: <20171010151937.26984-1-jack@suse.cz>
 <878tgisyo6.fsf@linux.intel.com> <20171011080658.GK3667@quack2.suse.cz>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <e596a6d7-4858-8fe6-c315-8a285748a31a@intel.com>
Date: Wed, 11 Oct 2017 10:34:47 -0700
MIME-Version: 1.0
In-Reply-To: <20171011080658.GK3667@quack2.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>, Andi Kleen <ak@linux.intel.com>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-fsdevel@vger.kernel.org

On 10/11/2017 01:06 AM, Jan Kara wrote:
>>> when rebasing our enterprise distro to a newer kernel (from 4.4 to 4.12) we
>>> have noticed a regression in bonnie++ benchmark when deleting files.
>>> Eventually we have tracked this down to a fact that page cache truncation got
>>> slower by about 10%. There were both gains and losses in the above interval of
>>> kernels but we have been able to identify that commit 83929372f629 "filemap:
>>> prepare find and delete operations for huge pages" caused about 10% regression
>>> on its own.
>> It's odd that just checking if some pages are huge should be that
>> expensive, but ok ..
> Yeah, I was surprised as well but profiles were pretty clear on this - part
> of the slowdown was caused by loads of page->_compound_head (PageTail()
> and page_compound() use that) which we previously didn't have to load at
> all, part was in hpage_nr_pages() function and its use.

Well, page->_compound_head is part of the same cacheline as the rest of
the page, and the page is surely getting touched during truncation at
_some_ point.  The hpage_nr_pages() might cause the cacheline to get
loaded earlier than before, but I can't imagine that it's that expensive.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
