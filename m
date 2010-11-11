Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 8D50F6B0088
	for <linux-mm@kvack.org>; Wed, 10 Nov 2010 22:08:43 -0500 (EST)
Received: by qyk1 with SMTP id 1so794923qyk.14
        for <linux-mm@kvack.org>; Wed, 10 Nov 2010 19:08:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101110190228.e21fdf36.akpm@linux-foundation.org>
References: <1289444754-29469-1-git-send-email-lliubbo@gmail.com>
	<20101110190228.e21fdf36.akpm@linux-foundation.org>
Date: Thu, 11 Nov 2010 11:08:41 +0800
Message-ID: <AANLkTimFK=ypcPD0v_D442inemu-aE-Q529La1-VE8pu@mail.gmail.com>
Subject: Re: [PATCH v2] fix __set_page_dirty_no_writeback() return value
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: fengguang.wu@intel.com, linux-mm@kvack.org, kenchen@google.com
List-ID: <linux-mm.kvack.org>

On Thu, Nov 11, 2010 at 11:02 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Thu, 11 Nov 2010 11:05:54 +0800 Bob Liu <lliubbo@gmail.com> wrote:
>
>> __set_page_dirty_no_writeback() should return true if it actually transi=
tioned
>> the page from a clean to dirty state although it seems nobody used its r=
eturn
>> value now.
>>
>> Change from v1:
>> =C2=A0 =C2=A0 =C2=A0 * preserving cacheline optimisation as Andrew point=
ed out
>>
>> Signed-off-by: Bob Liu <lliubbo@gmail.com>
>> ---
>> =C2=A0mm/page-writeback.c | =C2=A0 =C2=A04 +++-
>> =C2=A01 files changed, 3 insertions(+), 1 deletions(-)
>>
>> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
>> index bf85062..ac7018a 100644
>> --- a/mm/page-writeback.c
>> +++ b/mm/page-writeback.c
>> @@ -1157,8 +1157,10 @@ EXPORT_SYMBOL(write_one_page);
>> =C2=A0 */
>> =C2=A0int __set_page_dirty_no_writeback(struct page *page)
>> =C2=A0{
>> - =C2=A0 =C2=A0 if (!PageDirty(page))
>> + =C2=A0 =C2=A0 if (!PageDirty(page)) {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 SetPageDirty(page);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 1;
>> + =C2=A0 =C2=A0 }
>> =C2=A0 =C2=A0 =C2=A0 return 0;
>> =C2=A0}
>
> But that has a race. =C2=A0If someone else sets PG_Dirty between the test
> and the set, this function will incorrectly return 1.
>
> Which is why it should use test_and_set if we're going to do this.
>

Oh, Sorry for that.
I will make a new patch soon.

--=20
Thanks,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
