Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 949616B0038
	for <linux-mm@kvack.org>; Thu,  9 Jul 2015 20:21:44 -0400 (EDT)
Received: by pabvl15 with SMTP id vl15so158245263pab.1
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 17:21:44 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id al7si11542408pad.160.2015.07.09.17.21.42
        for <linux-mm@kvack.org>;
        Thu, 09 Jul 2015 17:21:43 -0700 (PDT)
Message-ID: <559F1014.6070306@lge.com>
Date: Fri, 10 Jul 2015 09:21:40 +0900
From: Gioh Kim <gioh.kim@lge.com>
MIME-Version: 1.0
Subject: Re: [RFCv3 3/5] mm/balloon: apply mobile page migratable into balloon
References: <1436243785-24105-1-git-send-email-gioh.kim@lge.com> <1436243785-24105-4-git-send-email-gioh.kim@lge.com> <20150709105119-mutt-send-email-mst@redhat.com>
In-Reply-To: <20150709105119-mutt-send-email-mst@redhat.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>, koct9i@gmail.com, aquini@redhat.com
Cc: jlayton@poochiereds.net, bfields@fieldses.org, vbabka@suse.cz, iamjoonsoo.kim@lge.com, viro@zeniv.linux.org.uk, minchan@kernel.org, linux-fsdevel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, linux-mm@kvack.org, gunho.lee@lge.com, akpm@linux-foundation.org, Gioh Kim <gurugio@hanmail.net>



>> @@ -124,6 +130,7 @@ static inline void balloon_page_insert(struct balloon_dev_info *balloon,
>>   				       struct page *page)
>>   {
>>   	__SetPageBalloon(page);
>> +	page->mapping = balloon->inode->i_mapping;
>>   	SetPagePrivate(page);
>>   	set_page_private(page, (unsigned long)balloon);
>>   	list_add(&page->lru, &balloon->pages);
>> @@ -140,6 +147,7 @@ static inline void balloon_page_insert(struct balloon_dev_info *balloon,
>>   static inline void balloon_page_delete(struct page *page)
>>   {
>>   	__ClearPageBalloon(page);
>> +	page->mapping = NULL;
>>   	set_page_private(page, 0);
>>   	if (PagePrivate(page)) {
>>   		ClearPagePrivate(page);
>
> Order of cleanup here is not the reverse of the order of initialization.
> Better make it exactly the reverse.
>
>
> Also, I have a question: is it enough to lock the page to make changing
> the mapping safe? Do all users lock the page too?
>
>
>
>

I think balloon developers can answer that precisely.

I've just follow this comment:
http://lxr.free-electrons.com/source/include/linux/balloon_compaction.h#L16

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
