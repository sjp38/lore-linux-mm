Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id AB78F6B13FA
	for <linux-mm@kvack.org>; Tue,  7 Feb 2012 20:41:56 -0500 (EST)
Received: by bkty12 with SMTP id y12so49519bkt.14
        for <linux-mm@kvack.org>; Tue, 07 Feb 2012 17:41:55 -0800 (PST)
Message-ID: <4F31D2E0.5020704@openvz.org>
Date: Wed, 08 Feb 2012 05:41:52 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH BUGFIX] mm: fix find_get_page() for shmem exceptional
 entries
References: <20120207103121.28345.28611.stgit@zurg> <4F31003E.2090901@openvz.org> <alpine.LSU.2.00.1202071011450.1849@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1202071011450.1849@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hugh Dickins wrote:
> On Tue, 7 Feb 2012, Konstantin Khlebnikov wrote:
>
>> Bug was added in commit v3.0-7291-g8079b1c (mm: clarify the radix_tree
>> exceptional cases)
>> So, v3.1 and v3.2 affected.
>>
>> Konstantin Khlebnikov wrote:
>>> It should return NULL, otherwise the caller will be very surprised.
>>>
>>> Signed-off-by: Konstantin Khlebnikov<khlebnikov@openvz.org>
>
> Thanks for worrying about it, but Nak to this patch.
>
> If you have found somewhere that is surprised by an exceptional entry
> instead of a page, then indeed we shall need to fix that: I'm not
> aware of any.

Oh, this is very dangerous semantics, especially for function called "find-get-page"
which sometimes returns not-getted not-a-page =)

>
> There are several places that are prepared for the possibility:
> find_lock_page() (and your patch would be breaking shmem.c's use of
> find_lock_page()), mincore_page(), memcontrol.c's mc_handle_file_pte().
>
> Of the remaining calls to find_get_page(), my understanding is that
> either they are filesystems operating upon their own pagecache, or
> they involve using ->readpage() - that's one of the two reasons why
> I gave shmem its own ->splice_read() and removed its ->readpage()
> before switching over to use the exceptional entries.
>
> Hugh
>
>>> ---
>>>    mm/filemap.c |    1 +
>>>    1 files changed, 1 insertions(+), 0 deletions(-)
>>>
>>> diff --git a/mm/filemap.c b/mm/filemap.c
>>> index 518223b..ca98cb5 100644
>>> --- a/mm/filemap.c
>>> +++ b/mm/filemap.c
>>> @@ -693,6 +693,7 @@ repeat:
>>>    			 * here as an exceptional entry: so return it without
>>>    			 * attempting to raise page count.
>>>    			 */
>>> +			page = NULL;
>>>    			goto out;
>>>    		}
>>>    		if (!page_cache_get_speculative(page))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
