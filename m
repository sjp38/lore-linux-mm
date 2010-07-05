Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 82E246B01AC
	for <linux-mm@kvack.org>; Mon,  5 Jul 2010 08:50:56 -0400 (EDT)
Received: by qwk4 with SMTP id 4so2160518qwk.14
        for <linux-mm@kvack.org>; Mon, 05 Jul 2010 05:50:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100704101640.GA1634@cmpxchg.org>
References: <1278235353-9638-1-git-send-email-lliubbo@gmail.com>
	<20100704101640.GA1634@cmpxchg.org>
Date: Mon, 5 Jul 2010 20:50:54 +0800
Message-ID: <AANLkTilqVwfYZ1pYcSnCXGnQqQqVvcPi34QVWCJ7AciF@mail.gmail.com>
Subject: Re: [PATCH] slob:Use _safe funtion to iterate partially free list.
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, mpm@selenic.com
List-ID: <linux-mm.kvack.org>

On Sun, Jul 4, 2010 at 6:16 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> On Sun, Jul 04, 2010 at 05:22:33PM +0800, Bob Liu wrote:
>> Since a list entry may be removed, so use list_for_each_entry_safe
>> instead of list_for_each_entry.
>>
>> Signed-off-by: Bob Liu <lliubbo@gmail.com>
>> ---
>> =C2=A0mm/slob.c | =C2=A0 =C2=A04 ++--
>> =C2=A01 files changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/slob.c b/mm/slob.c
>> index 3f19a34..e2af18b 100644
>> --- a/mm/slob.c
>> +++ b/mm/slob.c
>> @@ -320,7 +320,7 @@ static void *slob_page_alloc(struct slob_page *sp, s=
ize_t size, int align)
>> =C2=A0 */
>> =C2=A0static void *slob_alloc(size_t size, gfp_t gfp, int align, int nod=
e)
>> =C2=A0{
>> - =C2=A0 =C2=A0 struct slob_page *sp;
>> + =C2=A0 =C2=A0 struct slob_page *sp, *tmp;
>> =C2=A0 =C2=A0 =C2=A0 struct list_head *prev;
>> =C2=A0 =C2=A0 =C2=A0 struct list_head *slob_list;
>> =C2=A0 =C2=A0 =C2=A0 slob_t *b =3D NULL;
>> @@ -335,7 +335,7 @@ static void *slob_alloc(size_t size, gfp_t gfp, int =
align, int node)
>>
>> =C2=A0 =C2=A0 =C2=A0 spin_lock_irqsave(&slob_lock, flags);
>> =C2=A0 =C2=A0 =C2=A0 /* Iterate through each partially free page, try to=
 find room */
>> - =C2=A0 =C2=A0 list_for_each_entry(sp, slob_list, list) {
>> + =C2=A0 =C2=A0 list_for_each_entry_safe(sp, tmp, slob_list, list) {
>> =C2=A0#ifdef CONFIG_NUMA
>
> sp's list head is only modified if an allocation was successful, but
> then the iteration stops as well. =C2=A0So I see no reason for your patch=
.
> Did I overlook something?
>

Sorry, I am wrong. Please ignore this patch.
Thanks for your comment.

But It seems that the slob_list maybe have some member's next pointer NULL.
Because I triggered a NULL pointer access error.

And after I changed spin_lock_irqsave(&slob_lock, flags) before set slob_li=
st.
This bug seems disappeared.

I will resend a patch, Please review.
Thanks!

--=20
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
