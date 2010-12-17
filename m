Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id C01326B009B
	for <linux-mm@kvack.org>; Thu, 16 Dec 2010 20:40:53 -0500 (EST)
Received: by iwn40 with SMTP id 40so210999iwn.14
        for <linux-mm@kvack.org>; Thu, 16 Dec 2010 17:40:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1012161708260.3351@tigran.mtv.corp.google.com>
References: <E1PStc6-0006Cd-0Z@pomaz-ex.szeredi.hu>
	<AANLkTikXQmsgZ8Ea-GoQ4k2St6yCJj8Z3XthuBQ9u+EV@mail.gmail.com>
	<E1PTCV4-0007sR-SO@pomaz-ex.szeredi.hu>
	<20101216220457.GA3450@barrios-desktop>
	<alpine.LSU.2.00.1012161708260.3351@tigran.mtv.corp.google.com>
Date: Fri, 17 Dec 2010 10:40:51 +0900
Message-ID: <AANLkTinhkZKWkthN1R39+6nDbN0xZq-g7jP5-LVLxZ3E@mail.gmail.com>
Subject: Re: [PATCH] mm: add replace_page_cache_page() function
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: Miklos Szeredi <miklos@szeredi.hu>, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi Hugh,

On Fri, Dec 17, 2010 at 10:21 AM, Hugh Dickins <hughd@google.com> wrote:
> On Fri, 17 Dec 2010, Minchan Kim wrote:
>> On Thu, Dec 16, 2010 at 12:59:58PM +0100, Miklos Szeredi wrote:
>> > On Thu, 16 Dec 2010, Minchan Kim wrote:
>> > >
>> > > Why do you release reference of old?
>> >
>> > That's the page cache reference we release. =A0Just like we acquire th=
e
>> > page cache reference for "new" above.
>>
>> I mean current page cache handling semantic and page reference counting =
semantic
>> is separeated. For example, remove_from_page_cache doesn't drop the refe=
rence of page.
>> That's because we need more works after drop the page from page cache.
>> Look at shmem_writepage, truncate_complete_page.
>
> I disagree with you there: I like the way Miklos made it symmetric,
> I like the way delete_from_swap_cache drops the swap cache reference,
> I dislike the way remove_from_page_cache does not - I did once try to
> change that, but did a bad job, messed up reiserfs or reiser4 I forget
> which, retreated in shame.

I agree symmetric is good. I just said current fact which is that
remove_from_page_cache doesn't release ref.
So I thought we have to match current semantic to protect confusing.
Okay. I will not oppose current semantics.
Instead of it, please add it (ex, caller should hold the page
reference) in function description.

I am happy to hear that you tried it.
Although it is hard, I think it's very valuable thing.
Could you give me hint to googling your effort and why it is failed?

>
> In both the examples you give, shmem_writepage and truncate_complete_page=
,
> the caller has to be holding their own reference, in part because they
> locked the page, and will need to unlock it before releasing their ref.
> I think that would be true of any replace_page_cache_page caller.

Agree.

>
>>
>> You makes the general API and caller might need works before the old pag=
e
>> is free. So how about this?
>>
>> err =3D replace_page_cache_page(oldpage, newpage, GFP_KERNEL);
>> if (err) {
>> =A0 =A0 =A0 =A0 ...
>> }
>>
>> page_cache_release(oldpage); /* drop ref of page cache */
>>
>>
>> >
>> > I suspect it's historic that page_cache_release() doesn't drop the
>> > page cache ref.
>>
>> Sorry I can't understand your words.
>
> Me neither: I believe Miklos meant __remove_from_page_cache() rather
> than page_cache_release() in that instance.

Maybe. :)

Thanks for the comment, Hugh.
>
> Hugh
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
