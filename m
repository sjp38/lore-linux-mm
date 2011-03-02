Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id D57DC8D0039
	for <linux-mm@kvack.org>; Tue,  1 Mar 2011 21:46:44 -0500 (EST)
Message-ID: <4D6DAF86.2000407@cn.fujitsu.com>
Date: Wed, 02 Mar 2011 10:46:30 +0800
From: Lai Jiangshan <laijs@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4 V2] net,rcu: don't assume the size of struct rcu_head
References: <4D6CA860.3020409@cn.fujitsu.com>	 <20110301.001638.104075130.davem@davemloft.net>	 <4D6CB414.8050107@cn.fujitsu.com> <1298971213.3284.4.camel@edumazet-laptop>
In-Reply-To: <1298971213.3284.4.camel@edumazet-laptop>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: David Miller <davem@davemloft.net>, mingo@elte.hu, paulmck@linux.vnet.ibm.com, cl@linux-foundation.org, penberg@kernel.org, mpm@selenic.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org

On 03/01/2011 05:20 PM, Eric Dumazet wrote:
> Le mardi 01 mars 2011 =C3=A0 16:53 +0800, Lai Jiangshan a =C3=A9crit :
>> On 03/01/2011 04:16 PM, David Miller wrote:
>>> From: Lai Jiangshan <laijs@cn.fujitsu.com>
>>> Date: Tue, 01 Mar 2011 16:03:44 +0800
>>>
>>>>
>>>> struct dst=5Fentry assumes the size of struct rcu=5Fhead as 2 * sizeof=
(long)
>>>> and manually adds pads for aligning for "=5F=5Frefcnt".
>>>>
>>>> When the size of struct rcu=5Fhead is changed, these manual padding
>>>> is wrong. Use =5F=5Fattribute=5F=5F((aligned (64))) instead.
>>>>
>>>> Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
>>>
>>> We don't want to use the align if it's going to waste lots of space.
>>>
>>> Instead we want to rearrange the structure so that the alignment comes
>>> more cheaply.
>>
>> Subject: [PATCH 4/4 V2] net,rcu: don't assume the size of struct rcu=5Fh=
ead
>>
>> struct dst=5Fentry assumes the size of struct rcu=5Fhead as 2 * sizeof(l=
ong)
>> and manually adds pads for aligning for "=5F=5Frefcnt".
>>
>> When the size of struct rcu=5Fhead is changed, these manual padding
>> are hardly suit for the changes. So we rearrange the structure,
>> and move the seldom access rcu=5Fhead to the end of the structure.
>>
>> Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
>> ---
>>
>> diff --git a/include/net/dst.h b/include/net/dst.h
>> index 93b0310..d8c5296 100644
>> --- a/include/net/dst.h
>> +++ b/include/net/dst.h
>> @@ -37,7 +37,6 @@
>>  struct sk=5Fbuff;
>> =20
>>  struct dst=5Fentry {
>> -	struct rcu=5Fhead		rcu=5Fhead;
>>  	struct dst=5Fentry	*child;
>>  	struct net=5Fdevice       *dev;
>>  	short			error;
>> @@ -78,6 +77,13 @@ struct dst=5Fentry {
>>  	=5F=5Fu32			=5F=5Fpad2;
>>  #endif
>> =20
>> +	unsigned long		lastuse;
>> +	union {
>> +		struct dst=5Fentry	*next;
>> +		struct rtable =5F=5Frcu	*rt=5Fnext;
>> +		struct rt6=5Finfo		*rt6=5Fnext;
>> +		struct dn=5Froute =5F=5Frcu	*dn=5Fnext;
>> +	};
>> =20
>>  	/*
>>  	 * Align =5F=5Frefcnt to a 64 bytes alignment
>> @@ -92,13 +98,7 @@ struct dst=5Fentry {
>>  	 */
>>  	atomic=5Ft		=5F=5Frefcnt;	/* client references	*/
>>  	int			=5F=5Fuse;
>> -	unsigned long		lastuse;
>> -	union {
>> -		struct dst=5Fentry	*next;
>> -		struct rtable =5F=5Frcu	*rt=5Fnext;
>> -		struct rt6=5Finfo		*rt6=5Fnext;
>> -		struct dn=5Froute =5F=5Frcu	*dn=5Fnext;
>> -	};
>> +	struct rcu=5Fhead		rcu=5Fhead;
>>  };
>> =20
>>  #ifdef =5F=5FKERNEL=5F=5F
>=20
> Nope...
>=20
> "lastuse" and "next" must be in this place, or this introduce false
> sharing we wanted to avoid in the past.
>=20
> I suggest you leave this code as is, we will address the problem when
> rcu=5Fhead changes (assuming we can test a CONFIG=5FRCU=5FHEAD=5FDEBUG or
> something)
>=20
> First part of "struct dst=5Fentry" is mostly read, while part beginning
> after refcnt is often written.
>=20

Is it the cause of false sharing? I thought that all are rare write(except =
=5F=5Frefcnt)
since it is protected by RCU.

Do you allow me just move the seldom access rcu=5Fhead to the end of the st=
ructure
and add pads before =5F=5Frefcnt? I guess it increases about 3% the size of=
 dst=5Fentry.

I accept that I leave this code as is, when I change rcu=5Fhead I will noti=
fy you.

Thanks,
Lai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
