Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 6CF806B006A
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 21:39:15 -0500 (EST)
Received: by pzk35 with SMTP id 35so4550099pzk.22
        for <linux-mm@kvack.org>; Wed, 20 Jan 2010 18:39:13 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20100121094733.3778.A69D9226@jp.fujitsu.com>
References: <20100120174630.4071.A69D9226@jp.fujitsu.com>
	 <20100120095242.GA5672@desktop>
	 <20100121094733.3778.A69D9226@jp.fujitsu.com>
Date: Thu, 21 Jan 2010 10:39:13 +0800
Message-ID: <979dd0561001201839h323efec5y8a57af0117f77593@mail.gmail.com>
Subject: Re: cache alias in mmap + write
From: anfei zhou <anfei.zhou@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux@arm.linux.org.uk, jamie@shareable.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 21, 2010 at 9:10 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> On Wed, Jan 20, 2010 at 06:10:11PM +0900, KOSAKI Motohiro wrote:
>> > Hello,
>> >
>> > > diff --git a/mm/filemap.c b/mm/filemap.c
>> > > index 96ac6b0..07056fb 100644
>> > > --- a/mm/filemap.c
>> > > +++ b/mm/filemap.c
>> > > @@ -2196,6 +2196,9 @@ again:
>> > > =A0 =A0 =A0 =A0 =A0 if (unlikely(status))
>> > > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> > >
>> > > + =A0 =A0 =A0 =A0 if (mapping_writably_mapped(mapping))
>> > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 flush_dcache_page(page);
>> > > +
>> > > =A0 =A0 =A0 =A0 =A0 pagefault_disable();
>> > > =A0 =A0 =A0 =A0 =A0 copied =3D iov_iter_copy_from_user_atomic(page, =
i, offset, bytes);
>> > > =A0 =A0 =A0 =A0 =A0 pagefault_enable();
>> >
>> > I'm not sure ARM cache coherency model. but I guess correct patch is h=
ere.
>> >
>> > + =A0 =A0 =A0 =A0 =A0 if (mapping_writably_mapped(mapping))
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 flush_dcache_page(page);
>> > +
>> > =A0 =A0 =A0 =A0 =A0 =A0 pagefault_disable();
>> > =A0 =A0 =A0 =A0 =A0 =A0 copied =3D iov_iter_copy_from_user_atomic(page=
, i, offset, bytes);
>> > =A0 =A0 =A0 =A0 =A0 =A0 pagefault_enable();
>> > - =A0 =A0 =A0 =A0 =A0 flush_dcache_page(page);
>> >
>> > Why do we need to call flush_dcache_page() twice?
>> >
>> The latter flush_dcache_page is used to flush the kernel changes
>> (iov_iter_copy_from_user_atomic), which makes the userspace to see the
>> write, =A0and the one I added is used to flush the userspace changes.
>> And I think it's better to split this function into two:
>> =A0 =A0 =A0 flush_dcache_user_page(page);
>> =A0 =A0 =A0 kmap_atomic(page);
>> =A0 =A0 =A0 write to =A0page;
>> =A0 =A0 =A0 kunmap_atomic(page);
>> =A0 =A0 =A0 flush_dcache_kern_page(page);
>> But currently there is no such API.
>
> Why can't we create new api? this your pseudo code looks very fine to me.
>
Thanks for your suggestion, I will try to add the new APIs.  But
firstly, as Jamie
pointed out, can we confirm is this a real bug? Or it depends on the arch.

>
> note: if you don't like to create new api. I can agree your current patch=
.
> but I have three requests.
> =A01. Move flush_dcache_page() into iov_iter_copy_from_user_atomic().
> =A0 =A0Your above explanation indicate it is real intention. plus, change
> =A0 =A0iov_iter_copy_from_user_atomic() fixes fuse too.

OK.

> =A02. Add some commnet. almost developer only have x86 machine. so, arm
> =A0 =A0specific trick need additional explicit explanation. otherwise any=
body
> =A0 =A0might break this code in the future.
> =A03. Resend the patch. original mail isn't good patch format. please con=
sider
> =A0 =A0to reduce akpm suffer.
>
OK.

Thanks,
Anfei.
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
