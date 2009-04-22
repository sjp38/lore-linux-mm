Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id C0C656B00A7
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 05:46:10 -0400 (EDT)
Received: by rv-out-0708.google.com with SMTP id f25so2144668rvb.26
        for <linux-mm@kvack.org>; Wed, 22 Apr 2009 02:46:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <49EEB46D.90802@gmail.com>
References: <49E8292D.7050904@gmail.com>
	 <20090420084533.7f701e16.minchan.kim@barrios-desktop>
	 <49EBDADB.4040307@gmail.com>
	 <20090420114236.dda3de34.minchan.kim@barrios-desktop>
	 <49EEB46D.90802@gmail.com>
Date: Wed, 22 Apr 2009 18:46:52 +0900
Message-ID: <28c262360904220246q6be8167fxd44fa21936070e4b@mail.gmail.com>
Subject: Re: Does get_user_pages_fast lock the user pages in memory in my
	case?
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Huang Shijie <shijie8@gmail.com>
Cc: linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 22, 2009 at 3:08 PM, Huang Shijie <shijie8@gmail.com> wrote:
>
>>> I read the kernel code again. In my case ,the kernel will pin the pages
>>> in memory.
>>> I missed function is_page_cache_freeable() in the pageout().
>>>
>>> In my case, is_page_cache_freeable()will return false ,for
>>> page_count(page) is 3 now:
>>> <1> one is from alloc_page_* in page fault.
>>> <2> one is from get_usr_pages()
>>> <3> one is from add_to_swap() in shrink_page_list()
>>>
>>
>> One more, try_to_unmap will call page_cache_release. So, count is 2.
>>
>
> I found I missed something.When code reachs is_page_cache_freeable().
> page_count(page) is 3:
>
> <1> alloc_page_* in page fault . [page count is 1]
> <2> get_usr_pages(). =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 [page coun=
t is 2]
> <3> isolate_pages_global() =C2=A0 =C2=A0 =C2=A0 [page count is 3]
> <4> add_to_swap() =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
[page count is 4]
> <5> try_to_unmap() =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 [page=
 count is 3]
>
Yes. It seems you're right.
I missed isolate. ;-;
Thanks for fixing me.

> so it not a bug, just a vicious circle.
>
> Do i miss something?
>
>
>



--=20
Kinds regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
