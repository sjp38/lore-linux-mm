Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 57C356B01EE
	for <linux-mm@kvack.org>; Thu,  1 Apr 2010 09:42:48 -0400 (EDT)
Received: by pvg2 with SMTP id 2so373106pvg.14
        for <linux-mm@kvack.org>; Thu, 01 Apr 2010 06:42:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100401103210.12C0.A69D9226@jp.fujitsu.com>
References: <2f11576a1003310717y1fe1aa66p8f92135d5eec29e6@mail.gmail.com>
	 <w2gcf18f8341003311830pb0d697efi721641050c88a254@mail.gmail.com>
	 <20100401103210.12C0.A69D9226@jp.fujitsu.com>
Date: Thu, 1 Apr 2010 21:42:46 +0800
Message-ID: <o2wcf18f8341004010642m2f25ec2fg9f1275a659ed7a10@mail.gmail.com>
Subject: Re: [PATCH] __isolate_lru_page: skip unneeded mode check
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 1, 2010 at 9:39 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> >> @@ -862,15 +862,10 @@ int __isolate_lru_page(struct page *page, int m=
ode,
>> >> int file)
>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!PageLRU(page))
>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return ret;
>> >>
>> >> - =C2=A0 =C2=A0 =C2=A0 /*
>> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0* When checking the active state, we nee=
d to be sure we are
>> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0* dealing with comparible boolean values=
. =C2=A0Take the logical not
>> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0* of each.
>> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>> >> - =C2=A0 =C2=A0 =C2=A0 if (mode !=3D ISOLATE_BOTH && (!PageActive(pag=
e) !=3D !mode))
>> >> + =C2=A0 =C2=A0 =C2=A0 if (mode !=3D ISOLATE_BOTH && (PageActive(page=
) !=3D mode))
>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return ret;
>> >
>> > no. please read the comment.
>> >
>>
>> Hm,. I have read it, but still miss it :-).
>> PageActive(page) will return an int 0 or 1, mode is also int 0 or 1(
>> already !=3D ISOLATE_BOTH).
>> There are comparible and why must to be sure to boolean values?
>
> hm, ok. you are right.
> please resend this part as individual patch.
>

I have resent this part :-).

>
>> >> - =C2=A0 =C2=A0 =C2=A0 if (mode !=3D ISOLATE_BOTH && page_is_file_cac=
he(page) !=3D file)
>> >> + =C2=A0 =C2=A0 =C2=A0 if (page_is_file_cache(page) !=3D file)
>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return ret;
>> >
>> > no. please consider lumpy reclaim.
>>
>> During lumpy reclaim mode is ISOLATE_BOTH, that case we don't check
>> page_is_file_cache() ? =C2=A0Would you please explain it a little more ,=
i
>> am still unclear about it.
>> Thanks a lot.
>
> ISOLATE_BOTH is for to help allocate high order memory. then,
> it ignore both PageActive() and page_is_file_cache(). otherwise,
> we fail to allocate high order memory.
>

I got it, thanks.
And I have resent a patch collected ISOLATE_BOTH check.

--=20
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
