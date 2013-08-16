Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 0E6406B0032
	for <linux-mm@kvack.org>; Fri, 16 Aug 2013 10:14:53 -0400 (EDT)
Message-ID: <520E33D1.4040005@oracle.com>
Date: Fri, 16 Aug 2013 08:14:41 -0600
From: Khalid Aziz <khalid.aziz@oracle.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH] Fix aio performance regression for database caused
 by THP
References: <1376590389.24607.33.camel@concerto> <20130816090425.GA2162@shutemov.name>
In-Reply-To: <20130816090425.GA2162@shutemov.name>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, akpm@linux-foundation.org
Cc: aarcange@redhat.com, hannes@cmpxchg.org, mgorman@suse.de, riel@redhat.com, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 08/16/2013 03:04 AM, Kirill A. Shutemov wrote:
> On Thu, Aug 15, 2013 at 12:13:09PM -0600, Khalid Aziz wrote:
>>
>> -	if (likely(page != page_head && get_page_unless_zero(page_head))) {
>> +	/*
>> +	 * If this is a hugetlbfs page, it can not be split under
>> +	 * us. Simply increment refcount for head page
>> +	 */
>> +	if (PageHuge(page)) {
>> +		page_head = compound_head(page);
>> +		atomic_inc(&page_head->_count);
>> +		got = true;
>
> Why not just return here and don't increase indentantion level for rest of
> the function?
>

Good point.

Andrew, I can rework the patch if you would like.

Thanks,
Khalid

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
