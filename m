Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 316226B0087
	for <linux-mm@kvack.org>; Mon, 25 Jan 2010 20:01:12 -0500 (EST)
Received: by pwj10 with SMTP id 10so3300939pwj.6
        for <linux-mm@kvack.org>; Mon, 25 Jan 2010 17:01:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20100125115814.156d401d.akpm@linux-foundation.org>
References: <979dd0561001202107v4ddc1eb7xa59a7c16c452f7a2@mail.gmail.com>
	 <20100125133308.GA26799@desktop>
	 <20100125115814.156d401d.akpm@linux-foundation.org>
Date: Tue, 26 Jan 2010 09:01:10 +0800
Message-ID: <979dd0561001251701y76f35b8as545c390135b34da2@mail.gmail.com>
Subject: Re: [PATCH] Flush dcache before writing into page to avoid alias
From: anfei zhou <anfei.zhou@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux@arm.linux.org.uk, Jamie Lokier <jamie@shareable.org>, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 26, 2010 at 3:58 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Mon, 25 Jan 2010 21:33:08 +0800 anfei <anfei.zhou@gmail.com> wrote:
>
>> Hi Andrew,
>>
>> On Thu, Jan 21, 2010 at 01:07:57PM +0800, anfei zhou wrote:
>> > The cache alias problem will happen if the changes of user shared mapp=
ing
>> > is not flushed before copying, then user and kernel mapping may be map=
ped
>> > into two different cache line, it is impossible to guarantee the coher=
ence
>> > after iov_iter_copy_from_user_atomic. =A0So the right steps should be:
>> > =A0 =A0 flush_dcache_page(page);
>> > =A0 =A0 kmap_atomic(page);
>> > =A0 =A0 write to page;
>> > =A0 =A0 kunmap_atomic(page);
>> > =A0 =A0 flush_dcache_page(page);
>> > More precisely, we might create two new APIs flush_dcache_user_page an=
d
>> > flush_dcache_kern_page to replace the two flush_dcache_page accordingl=
y.
>> >
>> > Here is a snippet tested on omap2430 with VIPT cache, and I think it i=
s
>> > not ARM-specific:
>> > =A0 =A0 int val =3D 0x11111111;
>> > =A0 =A0 fd =3D open("abc", O_RDWR);
>> > =A0 =A0 addr =3D mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_SHARED, fd=
, 0);
>> > =A0 =A0 *(addr+0) =3D 0x44444444;
>> > =A0 =A0 tmp =3D *(addr+0);
>> > =A0 =A0 *(addr+1) =3D 0x77777777;
>> > =A0 =A0 write(fd, &val, sizeof(int));
>> > =A0 =A0 close(fd);
>> > The results are not always 0x11111111 0x77777777 at the beginning as e=
xpected.
>> >
>> Is this a real bug or not necessary to support?
>
> Bug. =A0If variable `addr' has type int* then the contents of that file
> should be 0x11111111 0x77777777. =A0You didn't tell us what the contents
> were in the incorrect case, but I guess it doesn't matter.
>
Sorry, I didn't give the details, here is the old thread with more details:
  http://linux.derkeiler.com/Mailing-Lists/Kernel/2010-01/msg07124.html

Regards,
Anfei.
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
