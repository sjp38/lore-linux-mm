Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 75FAC6B0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2013 11:12:12 -0500 (EST)
Received: by mail-ie0-f180.google.com with SMTP id bn7so8528169ieb.25
        for <linux-mm@kvack.org>; Tue, 19 Feb 2013 08:12:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20130131144026.bd735c07.akpm@linux-foundation.org>
References: <20130118155724.GA8507@otc-wbsnb-06>
	<20130131144026.bd735c07.akpm@linux-foundation.org>
Date: Wed, 20 Feb 2013 00:12:11 +0800
Message-ID: <CANN689Gvf9SeF9PG+8f_eBBM4vZLyroRr2nhjTcqiHuja-WUSQ@mail.gmail.com>
Subject: Re: PAGE_CACHE_SIZE vs. PAGE_SIZE
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Nick Piggin <npiggin@kernel.dk>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <ak@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>

On Fri, Feb 1, 2013 at 6:40 AM, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Fri, 18 Jan 2013 17:57:25 +0200
> "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
>
>> Hi,
>>
>> PAGE_CACHE_* macros were introduced long time ago in hope to implement
>> page cache with larger chunks than one page in future.
>>
>> In fact it was never done.
>>
>> Some code paths assume PAGE_CACHE_SIZE <= PAGE_SIZE. E.g. we use
>> zero_user_segments() to clear stale parts of page on cache filling, but
>> the function is implemented only for individual small page.
>>
>> It's unlikely that global switch to PAGE_CACHE_SIZE > PAGE_SIZE will never
>> happen since it will affect to much code at once.
>>
>> I think support of larger chunks in page cache can be in implemented in
>> some form of THP with per-fs enabling.
>>
>> Is it time to get rid of PAGE_CACHE_* macros?
>> I can prepare patchset if it's okay.
>
> The distinct PAGE_CACHE_SIZE has never been used for anything, but I do
> kinda like it for documentary reasons: PAGE_SIZE is a raw, low-level
> thing and PAGE_CACHE_SIZE is the specialized
> we're-doing-pagecache-stuff thing.
>
> But I'm sure I could get used to not having it ;)

Personally I always find such distinctions without a difference - like
page_cache_release vs put_page - rather confusing, especially when
working near the fs/mm boundary (for example in and under
handle_pte_fault())

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
