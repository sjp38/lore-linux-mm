Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id CC1926B0005
	for <linux-mm@kvack.org>; Thu,  7 Feb 2013 03:41:22 -0500 (EST)
Message-ID: <51136851.1030702@cn.fujitsu.com>
Date: Thu, 07 Feb 2013 16:39:45 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] net: fix functions and variables related to netns_ipvs->sysctl_sync_qlen_max
References: <51131B88.6040809@cn.fujitsu.com> <51132A56.60906@cn.fujitsu.com> <alpine.LFD.2.00.1302070944480.1810@ja.ssi.bg>
In-Reply-To: <alpine.LFD.2.00.1302070944480.1810@ja.ssi.bg>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Julian Anastasov <ja@ssi.bg>
Cc: Andrew Morton <akpm@linux-foundation.org>, davem@davemloft.net, Simon Horman <horms@verge.net.au>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

=E4=BA=8E 2013=E5=B9=B402=E6=9C=8807=E6=97=A5 16:40, Julian Anastasov =E5=
=86=99=E9=81=93:
>=20
> 	Hello,
>=20
> On Thu, 7 Feb 2013, Zhang Yanfei wrote:
>=20
>> Since the type of netns=5Fipvs->sysctl=5Fsync=5Fqlen=5Fmax has been chan=
ged to
>> unsigned long, type of its related proc var sync=5Fqlen=5Fmax should be =
changed
>> to unsigned long, too. Also the return type of function sysctl=5Fsync=5F=
qlen=5Fmax().
>>
>> Besides, the type of ipvs=5Fmaster=5Fsync=5Fstate->sync=5Fqueue=5Flen sh=
ould also be
>> changed to unsigned long.
>=20
> 	v2 looks fine. Thanks! Regarding your question
> see below...
>=20
>> Changelog from V1:
>> - change type of ipvs=5Fmaster=5Fsync=5Fstate->sync=5Fqueue=5Flen to uns=
igned long
>>   as Simon addressed.
>>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: David Miller <davem@davemloft.net>
>> Cc: Julian Anastasov <ja@ssi.bg>
>> Cc: Simon Horman <horms@verge.net.au>
>> Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
>> ---
>>  include/net/ip=5Fvs.h            |    6 +++---
>>  net/netfilter/ipvs/ip=5Fvs=5Fctl.c |    4 ++--
>>  2 files changed, 5 insertions(+), 5 deletions(-)
>>
>> diff --git a/include/net/ip=5Fvs.h b/include/net/ip=5Fvs.h
>> index 68c69d5..1d56f92 100644
>> --- a/include/net/ip=5Fvs.h
>> +++ b/include/net/ip=5Fvs.h
>> @@ -874,7 +874,7 @@ struct ip=5Fvs=5Fapp {
>>  struct ipvs=5Fmaster=5Fsync=5Fstate {
>>  	struct list=5Fhead	sync=5Fqueue;
>>  	struct ip=5Fvs=5Fsync=5Fbuff	*sync=5Fbuff;
>> -	int			sync=5Fqueue=5Flen;
>> +	unsigned long		sync=5Fqueue=5Flen;
>>  	unsigned int		sync=5Fqueue=5Fdelay;
>>  	struct task=5Fstruct	*master=5Fthread;
>>  	struct delayed=5Fwork	master=5Fwakeup=5Fwork;
>> @@ -1052,7 +1052,7 @@ static inline int sysctl=5Fsync=5Fports(struct net=
ns=5Fipvs *ipvs)
>>  	return ACCESS=5FONCE(ipvs->sysctl=5Fsync=5Fports);
>>  }
>> =20
>> -static inline int sysctl=5Fsync=5Fqlen=5Fmax(struct netns=5Fipvs *ipvs)
>> +static inline unsigned long sysctl=5Fsync=5Fqlen=5Fmax(struct netns=5Fi=
pvs *ipvs)
>>  {
>>  	return ipvs->sysctl=5Fsync=5Fqlen=5Fmax;
>>  }
>> @@ -1099,7 +1099,7 @@ static inline int sysctl=5Fsync=5Fports(struct net=
ns=5Fipvs *ipvs)
>>  	return 1;
>>  }
>> =20
>> -static inline int sysctl=5Fsync=5Fqlen=5Fmax(struct netns=5Fipvs *ipvs)
>> +static inline unsigned long sysctl=5Fsync=5Fqlen=5Fmax(struct netns=5Fi=
pvs *ipvs)
>>  {
>>  	return IPVS=5FSYNC=5FQLEN=5FMAX;
>>  }
>> diff --git a/net/netfilter/ipvs/ip=5Fvs=5Fctl.c b/net/netfilter/ipvs/ip=
=5Fvs=5Fctl.c
>> index ec664cb..d79a530 100644
>> --- a/net/netfilter/ipvs/ip=5Fvs=5Fctl.c
>> +++ b/net/netfilter/ipvs/ip=5Fvs=5Fctl.c
>> @@ -1747,9 +1747,9 @@ static struct ctl=5Ftable vs=5Fvars[] =3D {
>>  	},
>>  	{
>>  		.procname	=3D "sync=5Fqlen=5Fmax",
>> -		.maxlen		=3D sizeof(int),
>> +		.maxlen		=3D sizeof(unsigned long),
>>  		.mode		=3D 0644,
>> -		.proc=5Fhandler	=3D proc=5Fdointvec,
>> +		.proc=5Fhandler	=3D proc=5Fdoulongvec=5Fminmax,
>>  	},
>>  	{
>>  		.procname	=3D "sync=5Fsock=5Fsize",
>> --=20
>> 1.7.1
>=20
>=20
>> Another question about the sysctl=5Fsync=5Fqlen=5Fmax:
>> This variable is assigned as:
>>
>> ipvs->sysctl=5Fsync=5Fqlen=5Fmax =3D nr=5Ffree=5Fbuffer=5Fpages() / 32;
>>
>> The function nr=5Ffree=5Fbuffer=5Fpages actually means: counts of pages
>> which are beyond high watermark within ZONE=5FDMA and ZONE=5FNORMAL.
>>
>> is it ok to be called here? Some people misused this function because
>> the function name was misleading them. I am sorry I am totally not
>> familiar with the ipvs code, so I am just asking you about
>> this.
>=20
> 	Using nr=5Ffree=5Fbuffer=5Fpages should be fine here.
> We are using it as rough estimation for the number of sync
> buffers we can use in NORMAL zones. We are using dev->mtu
> for such buffers, so it can take a PAGE=5FSIZE for a buffer.
> We are not interested in HIGHMEM size. high watermarks
> should have negliable effect. I'm even not sure whether
> we need to clamp it for systems with TBs of memory.
>=20

I see. Thanks for your review and your explanation!

Zhang
=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
