From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: Re: Fixup the page of buddy_higher address's calculation
Date: Thu, 23 Aug 2012 20:30:34 +0800
Message-ID: <35355.0796317451$1345725083@news.gmane.org>
References: <CAFNq8R7ibTNeRP_Wftwyr7mK6Du4TVysQysgL_RYj+CGf9N2qg@mail.gmail.com>
 <20120823095022.GB10685@dhcp22.suse.cz>
 <CAFNq8R5pY0yPp-LQYNywpMhVtXgqPSy3RYqHVTVpPXs52kOmJw@mail.gmail.com>
Reply-To: Gavin Shan <shangw@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1T4WZC-0000Rt-Ae
	for glkm-linux-mm-2@m.gmane.org; Thu, 23 Aug 2012 14:31:18 +0200
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 981AD6B0044
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 08:31:14 -0400 (EDT)
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Thu, 23 Aug 2012 06:31:13 -0600
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 785A21FF003B
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 06:31:07 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7NCUjgV044412
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 06:31:01 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7NCUj9K002561
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 06:30:45 -0600
Content-Disposition: inline
In-Reply-To: <CAFNq8R5pY0yPp-LQYNywpMhVtXgqPSy3RYqHVTVpPXs52kOmJw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Haifeng <omycle@gmail.com>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <jweiner@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Aug 23, 2012 at 06:21:06PM +0800, Li Haifeng wrote:
>I am sorry for my mistake.
>
>higher_buddy is corresponding with buddy_index, and higher page is
>corresponding with combined_idx. That is right.
>
>But, How we get the page address from index offset? The key answer is
>what is the base value.
>So calculating the address based page should be (page + (buddy_idx - pag=
e_idx)).
>
>Maybe, a diagram is easier to understand.
>
> |-------------------------|-------------|
>page               combined   buddy
>
>buddy's page address=3D page=E2=80=98s page address + (buddy - page)*siz=
eof(struct page)
>
>Clear?
>

It sounds reasonable.

>2012/8/23 Michal Hocko <mhocko@suse.cz>:
>> On Thu 23-08-12 16:40:13, Li Haifeng wrote:
>>> From d7cd78f9d71a5c9ddeed02724558096f0bb4508a Mon Sep 17 00:00:00 200=
1
>>> From: Haifeng Li <omycle@gmail.com>
>>> Date: Thu, 23 Aug 2012 16:27:19 +0800
>>> Subject: [PATCH] Fixup the page of buddy_higher address's calculation
>>
>> Some general questions:
>> Any word about the change? Is it really that obvious? Why do you think=
 the
>> current state is incorrect? How did you find out?
>>
>> And more specific below:
>>
>>> Signed-off-by: Haifeng Li <omycle@gmail.com>
>>> ---
>>>  mm/page_alloc.c |    2 +-
>>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>>
>>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>>> index ddbc17d..5588f68 100644
>>> --- a/mm/page_alloc.c
>>> +++ b/mm/page_alloc.c
>>> @@ -579,7 +579,7 @@ static inline void __free_one_page(struct page *p=
age,
>>>                 combined_idx =3D buddy_idx & page_idx;
>>>                 higher_page =3D page + (combined_idx - page_idx);
>>>                 buddy_idx =3D __find_buddy_index(combined_idx, order =
+ 1);
>>> -               higher_buddy =3D page + (buddy_idx - combined_idx);
>>> +               higher_buddy =3D page + (buddy_idx - page_idx);

Haifeng, Not sure it would be better? At least, the expression
would be more explicitly meaningful than yours.

		    higher_buddy =3D higher_page + (buddy_idx - combined_idx);

Thanks,
Gavin

>>
>> We are finding buddy index for combined_idx so why should we use
>> page_idx here?
>>
>>>                 if (page_is_buddy(higher_page, higher_buddy, order + =
1)) {
>>>                         list_add_tail(&page->lru,
>>>                                 &zone->free_area[order].free_list[mig=
ratetype]);
>>> --
>>> 1.7.5.4
>>
>> --
>> Michal Hocko
>> SUSE Labs
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
