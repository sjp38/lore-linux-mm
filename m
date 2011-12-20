Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 561426B004D
	for <linux-mm@kvack.org>; Mon, 19 Dec 2011 23:22:49 -0500 (EST)
Received: by vcge1 with SMTP id e1so4773408vcg.14
        for <linux-mm@kvack.org>; Mon, 19 Dec 2011 20:22:48 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4EEE5B08.8010703@gmail.com>
References: <1324209529-15892-1-git-send-email-ozaki.ryota@gmail.com> <4EEE5B08.8010703@gmail.com>
From: Ryota Ozaki <ozaki.ryota@gmail.com>
Date: Tue, 20 Dec 2011 13:22:27 +0900
Message-ID: <CAKrYomjxhXwXdDJUP3ny3oa-wo81LJmsQmG8Emj986BHp+LbNQ@mail.gmail.com>
Subject: Re: [PATCH][RESEND] mm: Fix off-by-one bug in print_nodes_state
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@suse.de>, linux-mm@kvack.org, stable@kernel.org

Hi Kosaki-san,

I'm sorry for my late reply.
2011/12/19 KOSAKI Motohiro <kosaki.motohiro@gmail.com>:
> (12/18/11 6:58 AM), Ryota Ozaki wrote:
>> /sys/devices/system/node/{online,possible} involve a garbage byte
>> because print_nodes_state returns content size + 1. To fix the bug,
>> the patch changes the use of cpuset_sprintf_cpulist to follow the
>> use at other places, which is clearer and safer.
>>
>> This bug was introduced since v2.6.24.
>>
>> Signed-off-by: Ryota Ozaki<ozaki.ryota@gmail.com>
>> ---
>> =A0 drivers/base/node.c | =A0 =A08 +++-----
>> =A0 1 files changed, 3 insertions(+), 5 deletions(-)
>>
>> diff --git a/drivers/base/node.c b/drivers/base/node.c
>> index 5693ece..ef7c1f9 100644
>> --- a/drivers/base/node.c
>> +++ b/drivers/base/node.c
>> @@ -587,11 +587,9 @@ static ssize_t print_nodes_state(enum node_states s=
tate, char *buf)
>> =A0 {
>> =A0 =A0 =A0 int n;
>>
>> - =A0 =A0 n =3D nodelist_scnprintf(buf, PAGE_SIZE, node_states[state]);
>> - =A0 =A0 if (n> =A00&& =A0PAGE_SIZE> =A0n + 1) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 *(buf + n++) =3D '\n';
>> - =A0 =A0 =A0 =A0 =A0 =A0 *(buf + n++) =3D '\0';
>> - =A0 =A0 }
>> + =A0 =A0 n =3D nodelist_scnprintf(buf, PAGE_SIZE-2, node_states[state])=
;
>
> PAGE_SIZE-1. This seems another off by one. buf[n++] =3D '=A5n' mean
> override old trailing '=A50' and buf[n] =3D '=A50' mean to append one byt=
e.
> Then totally, we append one byte.

Thanks for pointing this out, you're right. (nodelist_)scnprintf returns
size-1 at most, thus we need to remain just one byte. I'll fix it in
the next patch.

Actually I bring the code from another and such the flaw can be found in ot=
her
functions. So I'll them as well.

  ozaki-r

>
>> + =A0 =A0 buf[n++] =3D '\n';
>> + =A0 =A0 buf[n] =3D '\0';
>> =A0 =A0 =A0 return n;
>> =A0 }
>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
