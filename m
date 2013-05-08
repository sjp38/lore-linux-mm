Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id C7CAB6B00B2
	for <linux-mm@kvack.org>; Wed,  8 May 2013 10:33:08 -0400 (EDT)
Received: by mail-qa0-f44.google.com with SMTP id o13so2796735qaj.17
        for <linux-mm@kvack.org>; Wed, 08 May 2013 07:33:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAHGf_=rFd7xktoom2kg_1QgoCrqsVwdo2gzVR6UDzvm53ngjgw@mail.gmail.com>
References: <1367967522-3934-1-git-send-email-j.glisse@gmail.com>
	<CAHGf_=ofADKRCgDN5Tanx4PyvoJFF9r=cHYMd+VRc=N3=4FGuA@mail.gmail.com>
	<CAH3drwbt_YX-jWrwsp0X2CH3t9ms65fX40cvumr4FyRhKBcbyw@mail.gmail.com>
	<CAHGf_=rFd7xktoom2kg_1QgoCrqsVwdo2gzVR6UDzvm53ngjgw@mail.gmail.com>
Date: Wed, 8 May 2013 10:33:07 -0400
Message-ID: <CAH3drwZym3+o2cUhB37Zi6ALj65Z7j+N1w9WA-t1+0xi7XjWaw@mail.gmail.com>
Subject: Re: [PATCH] mm: honor FOLL_GET flag in follow_hugetlb_page v2
From: Jerome Glisse <j.glisse@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Jerome Glisse <jglisse@redhat.com>

On Tue, May 7, 2013 at 10:41 PM, KOSAKI Motohiro
<kosaki.motohiro@gmail.com> wrote:
> On Tue, May 7, 2013 at 8:51 PM, Jerome Glisse <j.glisse@gmail.com> wrote:
>> On Tue, May 7, 2013 at 8:47 PM, KOSAKI Motohiro
>> <kosaki.motohiro@gmail.com> wrote:
>>> On Tue, May 7, 2013 at 6:58 PM,  <j.glisse@gmail.com> wrote:
>>>> From: Jerome Glisse <jglisse@redhat.com>
>>>>
>>>> Do not increase page count if FOLL_GET is not set. None of the
>>>> current user can trigger the issue because none of the current
>>>> user call __get_user_pages with both the pages array ptr non
>>>> NULL and the FOLL_GET flags non set in other word all caller
>>>> of __get_user_pages that don't set the FOLL_GET flags also call
>>>> with pages == NULL.
>>>
>>> Because, __get_user_pages() doesn't allow pages==NULL and FOLL_GET is on.
>>
>> Yes but this allow pages != NULL and FOLL_GET not set and as i said
>> there is no such user of that yet and this is exactly what i was
>> trying to use.
>
> Why? The following bug_on inhibit both case.

Yes i get lost on the double negation, but still my patch is correct
and i am not using gup but follow_hugetlb_page directly and i run into
the issue. My patch does not change the behavior for current user,
just fix assumption new user might have when not setting the FOLL_GET
flags.

>>>     VM_BUG_ON(!!pages != !!(gup_flags & FOLL_GET));

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
