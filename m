Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id DE3546B0092
	for <linux-mm@kvack.org>; Mon, 20 Dec 2010 18:38:25 -0500 (EST)
Received: by iwn40 with SMTP id 40so3770310iwn.14
        for <linux-mm@kvack.org>; Mon, 20 Dec 2010 15:38:24 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LNX.2.00.1012202302460.23785@swampdragon.chaosbits.net>
References: <alpine.LNX.2.00.1012192305260.6486@swampdragon.chaosbits.net>
	<AANLkTikNx5SG9Z=tUu6tyFRqnR2sLe5NxAjLCJr1UKmq@mail.gmail.com>
	<alpine.LNX.2.00.1012202302460.23785@swampdragon.chaosbits.net>
Date: Tue, 21 Dec 2010 08:38:23 +0900
Message-ID: <AANLkTikmKB+4vP-dox+T0QzF-yTz7LQrTURYMcqHShsa@mail.gmail.com>
Subject: Re: [updated PATCH] Close mem leak in error path in mm/hugetlb.c::nr_hugepages_store_common()
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Jesper Juhl <jj@chaosbits.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Dec 21, 2010 at 7:05 AM, Jesper Juhl <jj@chaosbits.net> wrote:
> On Mon, 20 Dec 2010, Minchan Kim wrote:
>
>> On Mon, Dec 20, 2010 at 7:10 AM, Jesper Juhl <jj@chaosbits.net> wrote:
>> > Hi,
>> >
>> > The NODEMASK_ALLOC macro dynamically allocates memory for its second
>> > argument ('nodes_allowed' in this context).
>> > In nr_hugepages_store_common() we may abort early if strict_strtoul()
>> > fails, but in that case we do not free the memory already allocated to
>> > 'nodes_allowed', causing a memory leak.
>> > This patch closes the leak by freeing the memory in the error path.
>> >
>> >
>> > Signed-off-by: Jesper Juhl <jj@chaosbits.net>
>> > ---
>> > =A0hugetlb.c | =A0 =A04 +++-
>> > =A01 file changed, 3 insertions(+), 1 deletion(-)
>> >
>> > =A0compile tested only
>> >
>> > diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>> > index 8585524..9fdcc35 100644
>> > --- a/mm/hugetlb.c
>> > +++ b/mm/hugetlb.c
>> > @@ -1439,8 +1439,10 @@ static ssize_t nr_hugepages_store_common(bool o=
bey_mempolicy,
>> > =A0 =A0 =A0 =A0NODEMASK_ALLOC(nodemask_t, nodes_allowed, GFP_KERNEL | =
__GFP_NORETRY);
>> >
>> > =A0 =A0 =A0 =A0err =3D strict_strtoul(buf, 10, &count);
>> > - =A0 =A0 =A0 if (err)
>> > + =A0 =A0 =A0 if (err) {
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(nodes_allowed);
>>
>> Nice catch. But use NODEMASK_FREE. It might be not kmalloced object.
>>
> Right. I just checked the macro and it used kmalloc(), so I just wrote
> kfree. But you are right, NODEMASK_FREE is the right thing to use here.
> Updated patch below.
>
>
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

Could you resend the completed patch to save Andrew trouble?


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
